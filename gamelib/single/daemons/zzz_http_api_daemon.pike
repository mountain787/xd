/**
 * ========================================================================
 * HTTP API Daemon - Vue UI Backend (Adapted for xiand)
 * ========================================================================
 *
 * 提供Vue前端与MUD游戏服务器之间的HTTP API接口
 *
 * 架构：
 *   Vue Browser → HTTP API (8888) → Virtual Connection → MUD Game (5555)
 *
 * 模块化设计：
 *   - config.pike: 配置常量
 *   - utils.pike: 工具函数
 *   - virtual_conn.pike: 虚拟连接池
 *   - auth.pike: 认证功能
 *   - command_queue.pike: 异步请求队列
 *   - html_renderer.pike: HTML渲染
 *   - rate_limit.pike: 速率限制
 *
 * ========================================================================
 * @author  Claude Code
 * @version 3.0.0 (Modular Refactor - xiand)
 * @since   2024
 * ========================================================================
 */

#include <globals.h>
#include <lowlib.h>
#include <gamelib/include/gamelib.h>

inherit LOW_DAEMON;

// ========================================================================
// HTTP API 日志函数 (必须在 include 之前定义)
// ========================================================================

/** HTTP API 调试开关：1=启用日志(werror输出), 0=关闭日志 */
constant HTTP_API_DEBUG = 1;

/**
 * HTTP API 专用日志函数 - 根据调试开关输出
 * @param fmt 格式化字符串
 * @param args ... 参数
 */
void http_werror(string fmt, mixed ... args)
{
    if(HTTP_API_DEBUG) {
        werror("[HTTP_API]" + sprintf(fmt, @args));
    }
}

// ========================================================================
// 导入模块
// ========================================================================

#include "_http_api_mod/config.pike"
#include "_http_api_mod/utils.pike"
#include "_http_api_mod/virtual_conn.pike"
#include "_http_api_mod/auth.pike"
#include "_http_api_mod/command_queue.pike"
#include "_http_api_mod/thread_manager.pike"
#include "_http_api_mod/html_renderer.pike"
#include "_http_api_mod/rate_limit.pike"

// ========================================================================
// 全局变量
// ========================================================================

/** HTTP服务器端口对象 */
Protocols.HTTP.Server.Port http_port;

/** API只读模式 */
int api_only_mode = 1;

// ========================================================================
// 初始化
// ========================================================================

protected void create()
{
    werror("========================================\n");
    werror("[HTTP_API] Daemon Loading...\n");
    werror("[HTTP_API] HTTP_PORT = %d\n", HTTP_PORT);
    werror("[HTTP_API] HTTP_API_DEBUG = %d\n", HTTP_API_DEBUG);
    werror("[HTTP_API] ROOT = %s\n", ROOT);
    werror("[HTTP_API] SROOT = %s\n", SROOT);
    werror("========================================\n");

    call_out(start_server, 5);
    // 定期清理
    call_out(cleanup_rate_limits, 60);
    call_out(cleanup_idle_connections, 60);
    // 启动队列处理
    call_out(start_worker_thread, 10);
    call_out(process_user_queues, QUEUE_CHECK_INTERVAL / 1000);
}

void start_server()
{
    werror("[HTTP_API] start_server() called, http_port=%O\n", http_port);
    if(http_port) {
        werror("[HTTP_API] Server already running!\n");
        return;
    }

    werror("[HTTP_API] Creating HTTP.Server.Port on 0.0.0.0:%d\n", HTTP_PORT);
    mixed err = catch {
        http_port = Protocols.HTTP.Server.Port(handle_request, HTTP_PORT, "0.0.0.0");
    };

    if(err) {
        werror("[HTTP_API] ERROR starting server: %O\n", err);
    } else {
        werror("[HTTP_API] Successfully started on port %d\n", HTTP_PORT);
        werror("[HTTP_API] Listening on http://0.0.0.0:%d\n", HTTP_PORT);
        werror("[HTTP_API] API Endpoints available:\n");
        werror("[HTTP_API]   - GET  /health\n");
        werror("[HTTP_API]   - GET  /api/partitions\n");
        werror("[HTTP_API]   - GET  /api/challenge\n");
        werror("[HTTP_API]   - POST /api/login\n");
        werror("[HTTP_API]   - GET  /api (execute command)\n");
        werror("========================================\n");
    }
}

void set_api_only_mode(int mode)
{
    api_only_mode = mode;
}

// ========================================================================
// 命令执行系统
// ========================================================================

/**
 * 执行系统级命令
 */
string execute_system_command(string cmd)
{
    http_werror(" execute_system: %s\n", cmd);

    string output = "";
    array args = cmd / " ";
    string cmd_name = args[0];

    string cmd_file = ROOT + "/gamelib/cmds/" + cmd_name + ".pike";
    object cmd_obj = load_object(cmd_file);

    if(cmd_obj) {
        mixed err = catch {
            mixed result = cmd_obj->main(cmd[sizeof(cmd_name)..]);
            if(stringp(result)) {
                output += result;
            }
        };
        if(err) {
            http_werror(" System command error: %s\n", describe_error(err));
            output += "命令执行错误\n";
        }
    } else {
        output += "未知系统命令: " + cmd_name + "\n";
    }

    return output;
}

/**
 * 执行内部命令 (通过玩家的command方法)
 */
string execute_internal_command(object player, string cmd)
{
    // http_werror(" execute_internal: %s\n", cmd);

    // 解析命令
    string first_word = cmd;
    string target_arg = "";
    int space_pos = search(cmd, " ");
    if(space_pos > 0) {
        first_word = cmd[0..space_pos-1];
        target_arg = cmd[space_pos+1..];
    }

    // 保存原始this_player
    object original_this_player = this_player();
    set_this_player(player);

    // 创建虚拟连接对象来捕获输出
    object buffer_conn = BufferConnection();

    // xiand: 使用绝对路径加载 CONND
    object connd = find_object(SROOT + "/connd.pike");
    if(!connd) {
        connd = load_object(SROOT + "/connd.pike");
    }

    // 保存原始连接并设置虚拟连接
    object original_conn = connd->query_conn(player);
    connd->set_conn(player, buffer_conn);

    // 直接调用command()
    mixed err = catch {
        player->command(cmd);
        // http_werror(" command() executed\n");
    };

    // 获取命令输出
    string output_buffer = buffer_conn->get_output();

    // 恢复原始连接
    connd->set_conn(player, original_conn);
    set_this_player(original_this_player);

    if(err) {
        http_werror(" Command error: %s\n", describe_error(err));
        output_buffer += "命令执行错误\n";
    }

    // http_werror(" Captured output: %d bytes\n", sizeof(output_buffer));

    // 如果没有捕获到输出，生成默认输出
    if(sizeof(output_buffer) == 0) {
        if((first_word == "look" || first_word == "l") && sizeof(target_arg) > 0) {
            output_buffer = get_target_info(player, target_arg);
        } else {
            output_buffer = get_room_info(player);
        }
        // http_werror(" Generated output: %d bytes\n", sizeof(output_buffer));
    }

    return output_buffer;
}

/**
 * 获取目标对象信息
 */
string get_target_info(object player, string target_name)
{
    string output = "";
    object room = environment(player);
    mixed target;

    if(!room) {
        return "你处于虚空中。\n[返回:look]";
    }

    array inv = all_inventory(room);
    foreach(inv, object ob) {
        if(ob == player) continue;
        string ob_name = functionp(ob->query_name) ? ob->query_name() : "";
        if(ob_name == target_name) {
            target = ob;
            break;
        }
        if(functionp(ob->query_name_cn) && ob->query_name_cn() == target_name) {
            target = ob;
            break;
        }
        if(functionp(ob->query_short)) {
            string short_name = ob->query_short();
            if(search(short_name, target_name) >= 0) {
                target = ob;
                break;
            }
        }
    }

    if(!target) {
        return sprintf("这里没有 %s。\n[返回:look]", target_name);
    }

    string name = "";
    if(functionp(target->query_short)) {
        name = target->query_short();
    } else if(functionp(target->query_name_cn)) {
        name = target->query_name_cn();
    } else {
        name = target_name;
    }
    output += name + "\n";

    if(functionp(target->query_long)) {
        string long_desc = target->query_long();
        if(long_desc && sizeof(long_desc) > 0) {
            output += long_desc + "\n";
        }
    }
    if(functionp(target->query_desc)) {
        string desc = target->query_desc();
        if(desc && sizeof(desc) > 0) {
            output += desc + "\n";
        }
    }

    int is_npc = 0;
    if(functionp(target->attack) || functionp(target->kill) ||
       (target->query_hp && functionp(target->query_hp))) {
        is_npc = 1;
    }

    output += "\n";
    if(is_npc) {
        output += "[切磋:" + target_name + "]\n";
        output += "[杀戮:" + target_name + "]\n";
    }
    output += "[返回:look]";

    return output;
}

/**
 * 获取房间信息
 */
string get_room_info(object player)
{
    string output = "";
    object room = environment(player);

    if(!room) {
        return "你处于虚空中...\n";
    }

    if(functionp(room->query_short)) {
        output += room->query_short() + "\n";
    }

    if(functionp(room->query_desc)) {
        string desc = room->query_desc();
        if(desc && sizeof(desc) > 0) {
            output += desc + "\n";
        }
    }
    else if(functionp(room->query_long)) {
        output += room->query_long() + "\n";
    }

    if(functionp(room->query_exits)) {
        mapping exits = room->query_exits();
        if(exits && sizeof(exits) > 0) {
            output += "\n";
            foreach(indices(exits), string dir) {
                output += sprintf("[%s:go %s]", dir, dir);
            }
        }
    }

    array inv = all_inventory(room);
    if(sizeof(inv) > 1) {
        output += "\n\n";
        foreach(inv, object ob) {
            if(ob != player && functionp(ob->query_short)) {
                string name = ob->query_short();
                if(name) {
                    string cmd_name = name;
                    if(functionp(ob->query_name)) {
                        string ob_name = ob->query_name();
                        if(ob_name && sizeof(ob_name) > 0) {
                            cmd_name = ob_name;
                        }
                    }
                    output += sprintf("[%s:look %s]", name, cmd_name);
                }
            }
        }
    }

    return output;
}

/**
 * 登录并执行命令 (主入口函数)
 *
 * 线程路由策略:
 * - 因果类命令: 主线程单队列执行 (战斗、交易等)
 * - 非因果命令: 用户独立线程执行 (look、score等，并行不互斥)
 */
string execute_command(string userid, string password, string cmd)
{
    // 使用线程管理器路由执行
    return route_and_execute(userid, password, cmd);
}

// ========================================================================
// 同步版本的命令执行函数 (供线程管理器调用)
// ========================================================================

/**
 * 同步执行命令 (用于核心命令主线程执行)
 */
string execute_command_sync(string userid, string password, string cmd)
{
    // http_werror(" execute_command_sync: %s for %s\n", cmd, userid);

    mixed err = catch {
        // 检查是否已有虚拟连接
        object player = get_player_from_connection(userid);
        if(player) {
            return execute_internal_command(player, cmd);
        }

        // 重要：在创建新玩家之前，先检查是否已有同名玩家
        object existing_player = find_player(userid);
        if(existing_player) {
            // 通知旧连接被踢掉
            catch {
                existing_player->tell_object("\n你的账号在别处登录，你被踢下线了。\n");
            };

            // 踢掉旧连接
            object connd = find_object(SROOT + "/connd.pike");
            if(!connd) connd = load_object(SROOT + "/connd.pike");
            object existing_conn = connd->query_conn(existing_player);
            if(existing_conn && existing_conn != UNDEFINED) {
                catch {
                    existing_conn->close();
                };
            }
            remove_virtual_connection(userid);
            // 直接使用已存在的玩家 - 不需要再 setup!
            player = existing_player;
        } else {
            // 没有找到已存在的玩家，直接创建（不使用 login.pike，因为 exec() 无效）
            // 密码已经在 TXD Token 解码中验证过了（或者由前端负责）
            string user_prog_file = ROOT + "/gamelib/clone/user.pike";
            program user_prog = compile_file(user_prog_file);
            player = user_prog(user_prog_file);

            if(player) {
                player->set_name(userid);
                player->set_project("gamelib");
                player->setup(password);
            }
        }

        if(!player) {
            return "{\"error\":\"登录失败\"}";
        }

        // 再次检查（防止创建过程中又有新连接）
        object check_player = find_player(userid);
        if(check_player && check_player != player) {
            // Detected duplicate player during setup, cleaning up
            // 保持当前的 player，销毁旧的
            // 通知旧连接被踢掉
            catch {
                check_player->tell_object("\n你的账号在别处登录，你被踢下线了。\n");
            };

            object connd = find_object(SROOT + "/connd.pike");
            if(!connd) connd = load_object(SROOT + "/connd.pike");
            object check_conn = connd->query_conn(check_player);
            if(check_conn && check_conn != UNDEFINED) {
                catch {
                    check_conn->close();
                };
            }
            remove_virtual_connection(userid);
        }

        // 保存到连接池
        set_virtual_connection(userid, ({0, time(), player}));

        return execute_internal_command(player, cmd);
    };

    if(err) {
        http_werror(" execute_command_sync error: %s\n", describe_error(err));
        return "{\"error\":\"命令执行失败: " + replace(describe_error(err), "\n", " ") + "\"}";
    }
}

/**
 * 同步执行内部命令 (供用户线程调用)
 * 支持创建玩家对象（如果不存在）
 */
string execute_internal_command_sync(string userid, string password, string cmd)
{
    // http_werror(" execute_internal_command_sync: %s for %s\n", cmd, userid);

    object player = get_player_from_connection(userid);
    if(!player && password && password != "") {
        // 玩家不存在，尝试直接创建玩家对象（xiand没有login.pike）
        string user_file = ROOT + "/gamelib/clone/user.pike";
        program user_prog = compile_file(user_file);
        player = user_prog(user_file);
        if(player) {
            player->set_name(userid);
            player->set_project("gamelib");
            player->setup(userid);

            object init_room = load_object(ROOT + "/gamelib/d/init");
            if(init_room) {
                player->move(init_room);
            }

            // 踢掉同名的 socket 连接（如果有）
            object existing_player = find_player(userid);
            if(existing_player && existing_player != player) {
                object connd = find_object(SROOT + "/connd.pike");
                if(!connd) connd = load_object(SROOT + "/connd.pike");
                object existing_conn = connd->query_conn(existing_player);
                if(existing_conn && existing_conn != UNDEFINED) {
                    catch {
                        existing_conn->close();
                    };
                    http_werror("[HTTP_API] Kicked socket connection for user: %s (internal_sync)\n", userid);
                }
            }

            // 保存到连接池
            set_virtual_connection(userid, ({0, time(), player}));
        }
    }

    if(!player) {
        return "{\"error\":\"未登录\"}";
    }

    return execute_internal_command(player, cmd);
}

// ========================================================================
// HTTP路由
// ========================================================================

void handle_request(Protocols.HTTP.Server.Request req)
{
    string path = req->not_query;
    string method = req->request_type;

    // http_werror(" %s %s from %s\n", method, path, req->remote_addr || "unknown");

    mixed err = catch {
        // CORS预检
        if(method == "OPTIONS") {
            send_cors(req);
            return;
        }

        // API路由分发
        switch(path) {
            case "/api":
                handle_api(req);
                break;
            case "/api/partitions":
                handle_api_partitions(req);
                break;
            case "/api/challenge":
                handle_api_challenge(req);
                break;
            case "/api/status":
                handle_api_status(req);
                break;
            case "/api/autofight":
                handle_api_autofight(req);
                break;
            case "/api/async":
                handle_api_async(req);
                break;
            case "/api/result":
                handle_api_result(req);
                break;
            case "/api/chat/messages":
                handle_api_chat_messages(req);
                break;
            case "/api/chat/send":
                handle_api_chat_send(req);
                break;
            case "/exits":
                handle_exits(req);
                break;
            case "/room":
                handle_room(req);
                break;
            case "/health":
                mapping m = ([ "status": "ok", "time": time(), "port": HTTP_PORT ]);
                send_json(req, m);
                break;
            case "/":
                if(api_only_mode) {
                    mapping info = ([ "message": "HTTP API Server", "api": "/api", "health": "/health" ]);
                    send_json(req, info);
                } else {
                    serve_file(req, "web/web_vue/index.html", "text/html");
                }
                break;
            default:
                // 处理 /api/html?xxx 格式
                if(has_prefix(path, "/api/html")) {
                    handle_api_html(req);
                }
                // 处理 /api/json?xxx 格式 - 返回JSON供Vue前端解析
                else if(has_prefix(path, "/api/json")) {
                    handle_api_json(req);
                }
                // 处理 /api/battle_status?xxx 格式 - 获取战斗状态（敌我双方）
                else if(has_prefix(path, "/api/battle_status")) {
                    handle_api_battle_status(req);
                }
                // 处理 /api/performs?xxx 格式 - 获取可用招式列表
                else if(has_prefix(path, "/api/performs")) {
                    handle_api_performs(req);
                }
                // translate.js 从 http_api 目录提供（始终允许，不受api_only_mode限制）
                else if(path == "/includes/translate.js") {
                    serve_file(req, "gamelib/single/d/http_api/translate.js", "application/javascript");
                }
                // 静态资源
                else if(has_prefix(path, "/css/") || has_prefix(path, "/js/")) {
                    if(!api_only_mode) {
                        serve_file(req, "web/web_vue" + path, guess_type(path));
                    } else {
                        send_json(req, ([ "error": "API only mode" ]), 404);
                    }
                }
                // images 目录在 web/ 下
                else if(has_prefix(path, "/images/")) {
                    if(!api_only_mode) {
                        serve_file(req, "web" + path, guess_type(path));
                    } else {
                        send_json(req, ([ "error": "API only mode" ]), 404);
                    }
                }
                else {
                    send_json(req, ([ "error": "Not found" ]), 404);
                }
                break;
        }
    };

    if(err) {
        http_werror(" Request error: %s\n", describe_error(err));
        // 检查对象是否已被析构，避免再次调用函数导致错误
        if(objectp(req)) {
            mixed send_err = catch {
                send_json(req, ([ "error": "Internal error" ]), 500);
            };
            if(send_err) {
                http_werror(" Failed to send error response: %s\n", describe_error(send_err));
            }
        }
    }
}

// ========================================================================
// API处理函数
// ========================================================================

void handle_api(Protocols.HTTP.Server.Request req)
{
    mapping params = get_params(req);
    string txd = url_decode(params["txd"]);
    string userid = params["userid"];
    string password = params["password"];
    string cmd = params["cmd"];
    if(!cmd || cmd == "") cmd = "look";

    string auth_userid, auth_password;

    if(txd && txd != "" && txd != " ") {
        mapping auth = decode_txd(txd);
        if(!auth) {
            send_json(req, ([ "error": "TXD认证信息无效" ]), 401);
            return;
        }
        auth_userid = auth["userid"];
        auth_password = auth["password"];
    }
    else if(userid && password && userid != "" && password != "") {
        auth_userid = userid;
        auth_password = password;
    }
    else {
        send_json(req, ([ "error": "缺少认证信息" ]), 400);
        return;
    }

    string response = execute_command(auth_userid, auth_password, cmd);

    if(!response) {
        send_json(req, ([ "error": "命令执行失败" ]), 500);
        return;
    }

    if(search(response, "登录错误") != -1 || search(response, "用户名不存在") != -1) {
        send_json(req, ([ "error": "用户名或密码错误" ]), 401);
        return;
    }

    mapping result = parse_response_to_json(response, auth_userid);
    send_json(req, result);
}

void handle_api_html(Protocols.HTTP.Server.Request req)
{
    mapping params = get_params(req);
    string txd = url_decode(params["txd"]);
    string userid = params["userid"];
    string password = params["password"];
    string cmd = params["cmd"];
    if(!cmd || cmd == "") cmd = "look";

    string client_ip = req->remote_addr || "unknown";

    // 注册命令处理 - 直接实现注册逻辑（xiand没有login_regnew命令）
    if(has_prefix(cmd, "login_regnew ")) {
        if(check_register_rate_limit(client_ip)) {
            send_html_error(req, "注册尝试过于频繁，请稍后再试");
            return;
        }

        // 解析Vue发送的参数
        string path, user_name, password_hash, session_id, challenge;
        if(sscanf(cmd, "login_regnew %s %s %s %s %s", path, user_name, password_hash, session_id, challenge) == 5) {
            http_werror(" Registration params: path=%s, user=%s, ip=%s\n", path, user_name, client_ip);

            // HTTP API 模式下直接实现注册逻辑
            string result;
            if(sizeof(user_name) < 2 || sizeof(password_hash) < 2) {
                result = "error2";
            } else {
                // 检查用户名只包含字母数字
                int valid_name = 1;
                for(int i = 0; i < sizeof(user_name); i++) {
                    int c = user_name[i];
                    if(!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9'))) {
                        valid_name = 0;
                        break;
                    }
                }
                if(!valid_name) {
                    result = "error2";
                } else {
                    // 检查用户是否已存在
                    string user_file_path = ROOT + "/" + path + "/u/" + user_name[sizeof(user_name)-2..] + "/" + user_name + ".o";
                    string existing_user = Stdio.read_file(user_file_path);

                    if(existing_user) {
                        // 用户已存在
                        result = "error1";
                    } else {
                        // 检查内存中是否有在线用户
                        object user_in_memory = find_player(user_name);
                        if(user_in_memory) {
                            result = "error1";
                        } else {
                            // 创建新用户 - 直接创建用户文件
                            program u;
                            mixed err = catch {
                                object m = (object)(ROOT + "/" + path + "/master.pike");
                                if(m) u = m->connect();
                                if(!u) u = (program)(ROOT + "/" + path + "/clone/user.pike");

                                object me = u();
                                me->set_name(user_name);
                                me->set_name_newbei("test");
                                me->set_password(password_hash);
                                me->set_project(path);
                                me->set_userip(client_ip);

                                if(me->setup(user_name)) {
                                    // 注册成功
                                    if(environment(me) == 0)
                                        me->move(LOW_VOID_OB);

                                    // xiand does not have promotion/referral system
                                    // This section removed

                                    result = user_name + "," + password_hash;
                                } else {
                                    result = "error2";
                                }
                            };
                            if(err) {
                                http_werror(" Registration error: %s\n", describe_error(err));
                                result = "error2";
                            }
                        }
                    }
                }
            }

            http_werror(" Registration result: %s\n", result);

            // 返回注册结果
            string html = "<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><title>注册</title></head><body><div>" + result + "</div></body></html>";
            mapping resp = ([ ]);
            resp["type"] = "text/html; charset=UTF-8";
            resp["data"] = html;
            resp["error"] = 200;
            resp["extra_heads"] = (["cache-control": "no-cache", "Access-Control-Allow-Origin": "*"]);
            req->response_and_finish(resp);
            return;
        }

        // 参数格式错误或加载失败
        http_werror(" Registration failed: invalid parameters or command not loaded\n");
        send_html_error(req, "error2");
        return;
    }

    // 认证
    string auth_userid, auth_password;
    string challenge = params["challenge"];

    if(txd && txd != "" && txd != " ") {
        mapping auth = decode_txd(txd);
        if(!auth) {
            send_html_error(req, "TXD认证信息无效");
            return;
        }
        auth_userid = auth["userid"];
        auth_password = auth["password"];
    }
    else if(userid && password && userid != "" && password != "") {
        auth_userid = userid;
        auth_password = password;

        if(challenge && sizeof(challenge) > 0) {
            string stored_password = get_user_password(auth_userid);
            if(stored_password && !verify_password_hash(challenge, password, stored_password)) {
                send_html_error(req, "用户名或密码错误");
                return;
            }
        }
    }
    else {
        send_html_error(req, "缺少认证信息");
        return;
    }

    // 登录速率限制
    int is_login_attempt = (!txd || txd == "" || txd == " ");
    if(is_login_attempt) {
        if(check_login_rate_limit(client_ip)) {
            send_html_error(req, "登录尝试过于频繁，请稍后再试");
            return;
        }
    }

    // 解码命令
    int hidden_index;
    string input;
    if(sscanf(cmd, "%d %s", hidden_index, input) == 2) {
        string base_cmd = unhide_command(auth_userid, (string)hidden_index);
        cmd = base_cmd + " " + input;
    } else {
        cmd = unhide_command(auth_userid, cmd);
    }

    string response = execute_command(auth_userid, auth_password, cmd);

    if(!response) {
        if(is_login_attempt) record_login_failure(client_ip);
        send_html_error(req, "命令执行失败");
        return;
    }

    int login_success = 0, login_failed = 0;
    if(is_login_attempt) {
        if(search(response, "登录错误") != -1 || search(response, "用户名不存在") != -1) {
            login_failed = 1;
        } else if(search(response, "error") == -1 && sizeof(response) > 10) {
            login_success = 1;
        }
    }

    if(login_failed) {
        record_login_failure(client_ip);
    } else if(login_success) {
        reset_login_failures(client_ip);
    }

    string html = response_to_html(response, auth_userid, cmd);

    mapping resp = ([ ]);
    resp["type"] = "text/html; charset=UTF-8";
    resp["data"] = html;
    resp["error"] = 200;
    resp["extra_heads"] = (["cache-control": "no-cache", "Access-Control-Allow-Origin": "*"]);
    req->response_and_finish(resp);
}

// ========================================================================
// JSON API - 返回解析后的结构化数据供Vue前端渲染
// ========================================================================

void handle_api_json(Protocols.HTTP.Server.Request req)
{
    mapping params = get_params(req);
    string txd = url_decode(params["txd"]);
    string userid = params["userid"];
    string password = params["password"];
    string cmd = params["cmd"];
    if(!cmd || cmd == "") cmd = "look";

    string client_ip = req->remote_addr || "unknown";

    // 认证
    string auth_userid, auth_password;

    if(txd && txd != "" && txd != " ") {
        mapping auth = decode_txd(txd);
        if(!auth) {
            send_json(req, ([ "error": "TXD认证信息无效" ]), 401);
            return;
        }
        auth_userid = auth["userid"];
        auth_password = auth["password"];
    }
    else if(userid && password && userid != "" && password != "") {
        auth_userid = userid;
        auth_password = password;
    }
    else {
        send_json(req, ([ "error": "缺少认证信息" ]), 400);
        return;
    }

    // 解码隐藏命令（cmd可能是数字索引）
    string actual_cmd = unhide_command(auth_userid, cmd);

    // 执行命令
    string response = execute_command(auth_userid, auth_password, actual_cmd);
    string new_txd = generate_txd(auth_userid);

    // 解析MUD输出为结构化数据
    array(mapping) lines = parse_mud_to_json(response, new_txd, auth_userid);

    // 检测复制命令
    string copy_data;
    string copy_type;
    if(search(response, "COPY_CODE:") != -1) {
        // 提取复制数据 - 只提取到行尾或UI按钮前
        sscanf(response, "%*sCOPY_CODE:%[^[ \n\r]", copy_data);
        copy_type = "code";
        // 从lines中移除这一行
        lines = filter(lines, lambda(mapping m) {
            string text = get_line_text(m);
            return search(text, "COPY_CODE:") == -1;
        });
    } else if(search(response, "COPY_LINK:") != -1) {
        // 提取复制数据 - 只提取到行尾或UI按钮前
        sscanf(response, "%*sCOPY_LINK:%[^[ \n\r]", copy_data);
        copy_type = "link";
        lines = filter(lines, lambda(mapping m) {
            string text = get_line_text(m);
            return search(text, "COPY_LINK:") == -1;
        });
    }

    // 构建响应
    mapping json_result = ([
        "lines": lines,
        "userid": auth_userid,
        "cmd": cmd,
        "txd": new_txd,
        "timestamp": time()
    ]);

    // 如果有复制数据，添加到响应中
    if(copy_data && sizeof(copy_data) > 0 && copy_type) {
        json_result->copy = (["type":copy_type, "data":copy_data]);
    }

    // 返回JSON格式
    send_json(req, json_result);
}

/**
 * 获取行的完整文本内容
 */
string get_line_text(mapping m)
{
    if(!m["segments"]) return "";

    string text = "";
    array segments = m["segments"];
    foreach(segments, mixed seg) {
        if(seg["type"] == "text") {
            if(seg["parts"]) {
                foreach(seg["parts"], mixed p) {
                    if(p["content"]) text += p["content"];
                }
            }
        } else if(seg["type"] == "button") {
            text += seg["label"] || "";
        }
    }
    return text;
}

/**
 * 解析MUD输出为结构化JSON数组
 * 每行是一个对象，包含type和content
 */
array(mapping) parse_mud_to_json(string response, string txd, string userid)
{
    array(mapping) result = ({});

    if(!response) return result;

    array raw_lines = response / "\n";

    foreach(raw_lines, string line) {
        string original_line = line;
        line = String.trim_all_whites(line);

        // 去掉行尾的{数字}标记
        while(1) {
            int start = search(line, "{");
            if(start == -1) break;
            int end = search(line, "}", start);
            if(end == -1) break;
            string between = line[start+1..end-1];
            int is_all_digits = 1;
            for(int i = 0; i < sizeof(between); i++) {
                if(between[i] < '0' || between[i] > '9') {
                    is_all_digits = 0;
                    break;
                }
            }
            if(is_all_digits) {
                line = line[0..start-1] + line[end+1..];
            } else {
                break;
            }
        }

        if(!sizeof(line)) {
            result += ({(["type": "empty"])});
            continue;
        }

        // 解析一行中的多个元素（文本、按钮、输入框）
        array(mapping) segments = parse_line_segments(line, txd, userid);
        result += ({(["type": "line", "segments": segments])});
    }

    return result;
}

/**
 * 解析一行中的多个段落
 */
array(mapping) parse_line_segments(string line, string txd, string userid)
{
    array(mapping) segments = ({});
    int current = 0;

    while(current < sizeof(line)) {
        int start = search(line, "[", current);
        if(start == -1) {
            if(current < sizeof(line)) {
                string text = line[current..];
                segments += ({parse_text_segment(text)});
            }
            break;
        }
        if(start > current) {
            string text = line[current..start-1];
            segments += ({parse_text_segment(text)});
        }
        int end = search(line, "]", start);
        if(end == -1) {
            segments += ({parse_text_segment(line[start..])});
            break;
        }

        string bracket_content = line[start+1..end-1];
        mapping parsed = parse_bracket_content(bracket_content, txd, userid);
        if(parsed) {
            segments += ({parsed});
        } else {
            segments += ({parse_text_segment(line[start..end])});
        }
        current = end + 1;
    }

    return segments;
}

/**
 * 解析文本段落（处理颜色代码）
 */
mapping parse_text_segment(string text)
{
    if(!sizeof(text)) return 0;

    array(mapping) parts = ({});
    int i = 0;

    while(i < sizeof(text)) {
        // 检查颜色代码 § (0xc2 0xa7 in UTF-8)
        if(i < sizeof(text) - 2 && (text[i] & 0xff) == 0xc2 && (text[i+1] & 0xff) == 0xa7) {
            int color_code = text[i+2] & 0xff;
            string color_class = "";

            switch(color_code) {
                case 0x30: color_class = "color-black"; break;
                case 0x31: color_class = "color-red-bold"; break;
                case 0x32: color_class = "color-green-bold"; break;
                case 0x33: color_class = "color-blue-bold"; break;
                case 0x34: color_class = "color-cyan-bold"; break;
                case 0x35: color_class = "color-purple-bold"; break;
                case 0x36: color_class = "color-orange-bold"; break;
                case 0x37: color_class = "color-gray"; break;
                case 0x38: color_class = "color-dark-gray"; break;
                case 0x39: color_class = "color-light-gray"; break;
                // 小写字母颜色码 (WAPMUD扩展)
                case 0x61: color_class = "color-red"; break;      // a
                case 0x62: color_class = "color-green"; break;     // b
                case 0x63: color_class = "color-cyan"; break;      // c
                case 0x64: color_class = "color-purple"; break;    // d
                case 0x65: color_class = "color-yellow"; break;    // e
                case 0x66: color_class = "color-white"; break;     // f
                case 0x67: color_class = "color-gold"; break;      // g
                case 0x72: parts += ({(["type": "color-end"])}); i += 3; continue;  // r = reset
                case 0x78: color_class = "color-bold"; break;     // x
                default: i += 2; continue;
            }

            parts += ({(["type": "color-start", "class": color_class])});
            i += 3;
        }
        else if((text[i] & 0xff) >= 0 && (text[i] & 0xff) < 128) {
            int c = text[i];
            if(c == '&') {
                parts += ({(["type": "text", "content": "&amp;"])});
            } else {
                parts += ({(["type": "text", "content": sprintf("%c", c)])});
            }
            i++;
        }
        else {
            // UTF-8多字节字符
            int byte_count = 2;
            int first_byte = text[i] & 0xff;
            if((first_byte & 0xE0) == 0xC0) byte_count = 2;
            else if((first_byte & 0xF0) == 0xE0) byte_count = 3;
            else if((first_byte & 0xF8) == 0xF0) byte_count = 4;

            if(i + byte_count - 1 < sizeof(text)) {
                parts += ({(["type": "text", "content": text[i..i+byte_count-1]])});
                i += byte_count;
            } else {
                parts += ({(["type": "text", "content": text[i..]])});
                i = sizeof(text);
            }
        }
    }

    return (["type": "text", "parts": parts]);
}

/**
 * 解析方括号内容 [label:command] 等
 */
mapping parse_bracket_content(string content, string txd, string userid)
{
    string var_name, default_val, width, type, label, action_cmd;

    // 输入框 [类型 变量名:...] 或 [变量名:默认值...宽度]
    if(sscanf(content, "%s %s:..*%s...*%s", type, var_name, default_val, width) == 4 ||
       sscanf(content, "%s:..*%s...*%s", var_name, default_val, width) == 3) {
        return ([
            "type": "input",
            "name": var_name,
            "default": default_val,
            "width": width,
            "isPassword": (type == "passwd"),
            "txd": txd
        ]);
    }
    else if(sscanf(content, "%s %s:...", type, var_name) == 2) {
        return ([
            "type": "input",
            "name": var_name,
            "default": "",
            "width": "",
            "isPassword": (type == "passwd" || type == "password"),
            "txd": txd
        ]);
    }
    else if(search(content, ":") > 0 && has_suffix(content, ":...")) {
        int colon_pos = search(content, ":");
        string cmd_name = content[0..colon_pos-1];
        return ([
            "type": "cmd-input",
            "cmd": cmd_name,
            "txd": txd
        ]);
    }
    // 处理 [类型:变量名: ...] 格式（如 [string:manage_userMain ...]）
    else if(has_suffix(content, " ...]")) {
        // 去掉开头的 [ 和结尾的: ...]
        string inner = content[1..sizeof(content)-6];  // 去掉 [ 和 : ...]
        // 查找第一个 : 分隔类型和变量名
        int colon_pos = search(inner, ":");
        if(colon_pos > 0) {
            type = inner[0..colon_pos-1];
            var_name = inner[colon_pos+1..];
            // 检查类型是否是已知的输入类型
            if(type == "string" || type == "passwd" || type == "password" ||
               type == "int" || type == "number" || type == "float") {
                return ([
                    "type": "input",
                    "name": var_name,
                    "default": "",
                    "width": "",
                    "isPassword": (type == "passwd" || type == "password"),
                    "txd": txd
                ]);
            }
        }
        // 如果不是 [类型:变量名: ...] 格式，回退到原来的 cmd-input 处理
        string cmd_name = content[0..sizeof(content)-5];
        return ([
            "type": "cmd-input",
            "cmd": cmd_name,
            "txd": txd
        ]);
    }
    // 处理 类型:变量名 ... 格式（如 string:manage_userMain ...）
    // 注意：这里content没有方括号，已经被strip掉了
    else if(has_suffix(content, " ...")) {
        // 去掉结尾的 " ..."
        string prefix = content[0..sizeof(content)-4];
        // 检查是否是 类型:变量名 格式
        int colon_pos = search(prefix, ":");
        if(colon_pos > 0) {
            type = String.trim_all_whites(prefix[0..colon_pos-1]);
            var_name = String.trim_all_whites(prefix[colon_pos+1..]);
            // 检查类型是否是已知的输入类型
            if(type == "string" || type == "passwd" || type == "password" ||
               type == "int" || type == "number" || type == "float") {
                return (([
                    "type": "input",
                    "name": var_name,
                    "default": "",
                    "width": "",
                    "isPassword": (type == "passwd" || type == "password"),
                    "txd": txd
                ]));
            }
        }
        // 不是已知类型，回退到 cmd-input
        string cmd_name = String.trim_all_whites(prefix);
        return (([
            "type": "cmd-input",
            "cmd": cmd_name,
            "txd": txd
        ]));
    }
    else {
        int pos = search(content, ":");
        if(pos > 0) {
            label = content[0..pos-1];
            action_cmd = content[pos+1..];

            // 图片链接 [imgurl picture:/images/...]
            if(label == "imgurl picture" || has_prefix(label, "imgurl picture ")) {
                // 提取图片路径
                string image_path = action_cmd;
                // 如果 label 包含额外信息（如 "imgurl picture:头像"），路径从 action_cmd 获取
                if(has_prefix(action_cmd, "picture:")) {
                    image_path = action_cmd[8..]; // 跳过 "picture:"
                }
                return ([
                    "type": "image",
                    "src": image_path,
                    "alt": "图片"
                ]);
            }
            // URL链接 [url 显示文本:https://...]
            else if(search(label, "url ") == 0 &&
               (search(action_cmd, "http://") == 0 || search(action_cmd, "https://") == 0)) {
                return ([
                    "type": "url-link",
                    "text": label[4..],
                    "url": action_cmd
                ]);
            } else {
                // 普通按钮 - 处理标签中的颜色代码
                string hidden_cmd = hide_command(userid, action_cmd);
                string css_class = get_button_css_class(label);
                string processed_label = process_color_codes(label);
                return ([
                    "type": "button",
                    "label": processed_label,
                    "cmd": hidden_cmd,
                    "class": css_class
                ]);
            }
        }
    }

    return 0;
}

/**
 * 处理字符串中的颜色代码，返回HTML
 * 将 §X...§r 转换为 <span class="color-...">...</span>
 */
string process_color_codes(string text)
{
    if(!text || sizeof(text) == 0) return text;

    string result = "";
    int i = 0;
    string current_class = "";

    while(i < sizeof(text)) {
        // 检查颜色代码 § (0xc2 0xa7 in UTF-8)
        if(i < sizeof(text) - 2 && (text[i] & 0xff) == 0xc2 && (text[i+1] & 0xff) == 0xa7) {
            int color_code = text[i+2] & 0xff;

            // 先关闭之前的span
            if(sizeof(current_class) > 0) {
                result += "</span>";
                current_class = "";
            }

            string color_class = "";
            int is_reset = 0;

            switch(color_code) {
                case 0x30: color_class = "color-black"; break;
                case 0x31: color_class = "color-red-bold"; break;
                case 0x32: color_class = "color-green-bold"; break;
                case 0x33: color_class = "color-blue-bold"; break;
                case 0x34: color_class = "color-cyan-bold"; break;
                case 0x35: color_class = "color-purple-bold"; break;
                case 0x36: color_class = "color-orange-bold"; break;
                case 0x37: color_class = "color-gray"; break;
                case 0x38: color_class = "color-dark-gray"; break;
                case 0x39: color_class = "color-light-gray"; break;
                // 小写字母颜色码
                case 0x61: color_class = "color-red"; break;      // a
                case 0x62: color_class = "color-green"; break;     // b
                case 0x63: color_class = "color-cyan"; break;      // c
                case 0x64: color_class = "color-purple"; break;    // d
                case 0x65: color_class = "color-yellow"; break;    // e
                case 0x66: color_class = "color-white"; break;     // f
                case 0x67: color_class = "color-gold"; break;      // g
                case 0x72: is_reset = 1; break;                   // r = reset
                case 0x78: color_class = "color-bold"; break;     // x
                default: break;
            }

            if(is_reset) {
                // 重置颜色，不开启新span
            } else if(sizeof(color_class) > 0) {
                result += "<span class='" + color_class + "'>";
                current_class = color_class;
            }

            i += 3;
        }
        else {
            // 普通字符，需要转义HTML特殊字符
            int c = text[i] & 0xff;
            if(c == '&') {
                result += "&amp;";
                i++;
            } else if(c == '<') {
                result += "&lt;";
                i++;
            } else if(c == '>') {
                result += "&gt;";
                i++;
            } else if(c == '"') {
                result += "&quot;";
                i++;
            } else if(c == '\'') {
                result += "&#039;";
                i++;
            } else if((text[i] & 0xff) >= 0 && (text[i] & 0xff) < 128) {
                result += sprintf("%c", c);
                i++;
            } else {
                // UTF-8多字节字符
                int byte_count = 2;
                int first_byte = text[i] & 0xff;
                if((first_byte & 0xE0) == 0xC0) byte_count = 2;
                else if((first_byte & 0xF0) == 0xE0) byte_count = 3;
                else if((first_byte & 0xF8) == 0xF0) byte_count = 4;
                else if((first_byte & 0xC0) == 0x80) byte_count = 1;
                else byte_count = 2;

                if(i + byte_count <= sizeof(text)) {
                    result += text[i..i+byte_count-1];
                } else {
                    result += text[i..];
                }
                i += byte_count;
            }
        }
    }

    // 关闭未关闭的span
    if(sizeof(current_class) > 0) {
        result += "</span>";
    }

    return result;
}

/**
 * 根据按钮标签获取CSS类名
 */
string get_button_css_class(string label)
{
    if(search(label, "东→") != -1 || search(label, "西←") != -1 ||
       search(label, "南↓") != -1 || search(label, "北↑") != -1) {
        return "btn btn-outline-success btn-sm";
    }
    else if(search(label, "杀戮") != -1 || search(label, "商城") != -1 ||
            search(label, "锻造") != -1) {
        return "btn btn-outline-warning btn-sm";
    }
    else if(search(label, "吃药") != -1) {
        return "btn btn-outline-purple btn-sm";
    }
    return "btn btn-outline-info btn-sm";
}

void handle_api_partitions(Protocols.HTTP.Server.Request req)
{
    string area = getenv("GAME_AREA");
    if(!area || area == "") area = "01";
    if(has_prefix(area, "xd")) area = area[2..];

    int start_area, end_area;
    if(search(area, "-") > 0) {
        array(string) parts = area / "-";
        start_area = (int)parts[0];
        end_area = (int)parts[1];
    } else {
        start_area = (int)area;
        end_area = start_area;
    }

    array(mapping) partitions = ({});
    for(int i = start_area; i <= end_area; i++) {
        string zone_num = sprintf("%02d", i);
        partitions += ({([
            "value": "xd" + zone_num,
            "label": "原" + i + "区"
        ])});
    }

    send_json(req, ([
        "partitions": partitions,
        "game_area": getenv("GAME_AREA") || "01"
    ]));
}

void handle_api_challenge(Protocols.HTTP.Server.Request req)
{
    string salt = "";
    for(int i = 0; i < 32; i++) {
        int r = random(62);
        if(r < 26) salt += sprintf("%c", 'a' + r);
        else if(r < 52) salt += sprintf("%c", 'A' + r - 26);
        else salt += sprintf("%c", '0' + r - 52);
    }

    string timestamp = sprintf("%d", time());
    send_json(req, ([
        "challenge": salt + ":" + timestamp,
        "timestamp": (int)timestamp
    ]));
}

void handle_api_status(Protocols.HTTP.Server.Request req)
{
    mapping params = get_params(req);
    string txd = url_decode(params["txd"]);

    if(!txd || txd == "" || txd == " ") {
        send_json(req, ([ "error": "需要认证信息：txd" ]), 400);
        return;
    }

    mapping auth = decode_txd(txd);
    if(!auth) {
        send_json(req, ([ "error": "TXD认证信息无效" ]), 401);
        return;
    }

    string userid = auth["userid"];
    object player = get_player_from_connection(userid);

    // 如果虚拟连接池中没有，尝试从 find_player 获取
    if(!player) {
        player = find_player(userid);
    }

    if(!player) {
        send_json(req, ([ "error": "玩家未登录" ]), 401);
        return;
    }

    mapping result = query_player_state(player);
    send_json(req, result);
}

/**
 * 获取战斗状态 API
 * 返回玩家和敌人的状态信息
 */
void handle_api_battle_status(Protocols.HTTP.Server.Request req)
{
    mapping params = get_params(req);
    string txd = url_decode(params["txd"]);

    if(!txd || txd == "" || txd == " ") {
        send_json(req, ([ "error": "需要认证信息：txd" ]), 400);
        return;
    }

    mapping auth = decode_txd(txd);
    if(!auth) {
        send_json(req, ([ "error": "TXD认证信息无效" ]), 401);
        return;
    }

    string userid = auth["userid"];
    object player = get_player_from_connection(userid);

    if(!player) {
        send_json(req, ([ "error": "玩家未登录" ]), 401);
        return;
    }

    // 获取玩家状态
    mapping player_state = query_player_state(player);
    player_state["userid"] = userid;

    // 查找敌人
    mapping enemy_state = ([]);

    // 方法1: 检查玩家是否在战斗中
    int in_combat = 0;
    if(functionp(player->query_in_combat)) {
        in_combat = player->query_in_combat();
    }

    if(!in_combat) {
        // 不在战斗中
        send_json(req, ([
            "in_battle": false,
            "player": player_state
        ]));
        return;
    }

    // 方法2: 获取房间中的所有对象，找到敌人的敌人
    object room = environment(player);
    if(!room) {
        send_json(req, ([
            "in_battle": true,
            "player": player_state,
            "enemy": 0
        ]));
        return;
    }

    // 获取房间中的所有生物
    array inv = all_inventory(room);
    object|zero enemy_obj = UNDEFINED;

    foreach(inv, object ob) {
        if(ob == player) continue;  // 跳过自己

        // 检查是否是生物
        if(functionp(ob->query_living) && ob->query_living()) {
            // 检查该对象是否在战斗中，且敌人是玩家
            if(functionp(ob->query_in_combat) && ob->query_in_combat()) {
                // 检查该对象的敌人是否是玩家
                // 通过检查该对象是否正在攻击玩家
                if(functionp(ob->query_attack_target)) {
                    if(ob->query_attack_target() == player) {
                        enemy_obj = ob;
                        break;
                    }
                }
            }
        }
    }

    // 如果没找到，尝试通过环境中的其他方式判断
    if(!enemy_obj) {
        // 检查房间中是否有其他玩家/NPC在战斗
        foreach(inv, object ob) {
            if(ob == player) continue;
            if(functionp(ob->is_npc) || functionp(ob->query_player)) {
                // 这是一个潜在敌人
                if(functionp(ob->query_in_combat) && ob->query_in_combat()) {
                    enemy_obj = ob;
                    break;
                }
            }
        }
    }

    if(enemy_obj) {
        // 获取敌人状态
        string e_name = "未知";
        if(functionp(enemy_obj->query_name)) {
            e_name = enemy_obj->query_name();
        }
        enemy_state["name"] = e_name;

        string e_name_cn = e_name;
        if(functionp(enemy_obj->query_name_cn)) {
            e_name_cn = enemy_obj->query_name_cn();
        }
        enemy_state["name_cn"] = e_name_cn;

        int e_is_npc = 1;
        if(functionp(enemy_obj->is_npc)) {
            e_is_npc = enemy_obj->is_npc();
        }
        enemy_state["is_npc"] = e_is_npc;

        // 仿照玩家血量获取方式：直接访问变量
        // 参考 html_renderer.pike: int jing = player->jing;
        int e_jing = enemy_obj->jing;
        int e_jing_max = enemy_obj->jing_max;

        // -1 表示死亡，转为 0
        if(e_jing < 0) {
            e_jing = 0;
        }

        // 直接显示真实值
        enemy_state["hp"] = e_jing;
        enemy_state["hp_max"] = e_jing_max;
        enemy_state["is_dead"] = (e_jing <= 0);

        http_werror(" Enemy %s HP: %d/%d (jing=%d, jing_max=%d)\n",
                   e_name, e_jing, e_jing_max, e_jing, e_jing_max);

        // 如果敌人是玩家，尝试获取userid
        if(!e_is_npc && functionp(enemy_obj->query_userid)) {
            enemy_state["userid"] = enemy_obj->query_userid();
        }
    }

    // http_werror(" battle_status response: in_battle=%d, enemy=%O\n", 1, enemy_obj ? enemy_state : 0);
    send_json(req, ([
        "in_battle": true,
        "player": player_state,
        "enemy": enemy_obj ? enemy_state : 0
    ]));
}

void handle_api_autofight(Protocols.HTTP.Server.Request req)
{
    if(req->request_type != "POST") {
        send_json(req, ([ "error": "只支持 POST 请求" ]), 405);
        return;
    }

    mapping params = get_params(req);
    string txd = url_decode(params["txd"]);
    string action = url_decode(params["action"] || "toggle");

    if(!txd || txd == "" || txd == " ") {
        send_json(req, ([ "error": "需要认证信息：txd" ]), 400);
        return;
    }

    mapping auth = decode_txd(txd);
    if(!auth) {
        send_json(req, ([ "error": "TXD认证信息无效" ]), 401);
        return;
    }

    string userid = auth["userid"];
    object player = get_player_from_connection(userid);

    if(!player) {
        send_json(req, ([ "error": "玩家未登录" ]), 401);
        return;
    }

    int new_state = 0;
    string current = player->query_autofight();

    if(action == "on" || (action == "toggle" && current != "enable")) {
        player->set_autofight("enable");
        new_state = 1;
    } else {
        player->set_autofight("disable");
        new_state = 0;
    }

    send_json(req, ([
        "autofight": new_state,
        "message": new_state ? "自动战斗已开启" : "自动战斗已关闭"
    ]));
}

/**
 * 获取可用招式列表 API
 * 直接从玩家对象读取招式数据
 */
void handle_api_performs(Protocols.HTTP.Server.Request req)
{
    mixed err = catch {
        mapping params = get_params(req);
        string txd = url_decode(params["txd"]);

        // werror("[API] /api/performs START\n");

        if(!txd || txd == "" || txd == " ") {
            // werror("[API] /api/performs ERROR: missing txd\n");
            send_json(req, ([ "error": "需要认证信息：txd" ]), 400);
            return;
        }

        mapping auth = decode_txd(txd);
        if(!auth) {
            // werror("[API] /api/performs ERROR: decode_txd failed\n");
            send_json(req, ([ "error": "TXD认证信息无效" ]), 401);
            return;
        }

        string userid = auth["userid"];
        // werror("[API] /api/performs userid=%s\n", userid);

        object player = get_player_from_connection(userid);
        if(!player) {
            // werror("[API] /api/performs ERROR: player not found for userid=%s\n", userid);
            send_json(req, ([ "error": "玩家未登录" ]), 401);
            return;
        }

        // werror("[API] /api/performs player found\n");

        // 获取当前装备的武功
        object|zero attack_skill;
        if(functionp(player->query_attack_skill)) {
            attack_skill = player->query_attack_skill();
        }
        // werror("[API] /api/performs attack_skill=%O\n", attack_skill);

        array performs_list = ({});
        string skill_name = "unknown";
        string skill_name_cn = "未装配武功";
        int skill_level = 0;
        int player_neili = 0;

        if(attack_skill) {
            // 获取武功名称
            if(functionp(attack_skill->query_name)) {
                skill_name = attack_skill->query_name() || "unknown";
            }
            if(functionp(attack_skill->query_name_cn)) {
                skill_name_cn = attack_skill->query_name_cn() || "未知武功";
            }
            // werror("[API] /api/performs skill_name=%s skill_name_cn=%s\n", skill_name, skill_name_cn);

            // 获取武功等级 (skills 是映射属性，直接访问)
            mapping skills = player->skills;
            // werror("[API] /api/performs skills=%O\n", skills);
            if(skills && skills[skill_name]) {
                skill_level = skills[skill_name][0];
            }
            // werror("[API] /api/performs skill_level=%d\n", skill_level);

            // 获取内力
            if(functionp(player->query_neili)) {
                player_neili = player->query_neili();
            }

            // 获取所有可用招式
            array(object) performs = ({});
            if(functionp(attack_skill->all_performs)) {
                performs = attack_skill->all_performs(player);
            }
            // werror("[API] /api/performs performs=%O count=%d\n", performs, sizeof(performs));

            if(performs && sizeof(performs) > 0) {
                foreach(performs, object perform_obj) {
                    // werror("[API] /api/performs process perform_obj=%O\n", perform_obj);
                    if(!perform_obj) {
                        // werror("[API] /api/performs skipping null perform_obj\n");
                        continue;
                    }

                    // 获取招式ID - 使用 object_name 获取对象名称
                    string perform_id = object_name(perform_obj);

                    // 获取招式中文名 - name_cn 是直接变量
                    string perform_name_cn = perform_obj->name_cn || "";

                    // werror("[API] /api/performs perform: id=%s name_cn=%s\n", perform_id, perform_name_cn);

                    // 获取所需内力 - 如果没有neili_cost属性，默认为0
                    int neili_cost = 0;
                    if(intp(perform_obj->neili_cost)) {
                        neili_cost = perform_obj->neili_cost;
                    } else if(intp(perform_obj->qi_damage)) {
                        neili_cost = perform_obj->qi_damage;
                    }

                    // 获取所需等级 - 如果没有level_req属性，默认为0
                    int level_req = 0;
                    if(intp(perform_obj->level_req)) {
                        level_req = perform_obj->level_req;
                    }

                    // 检查是否可用（等级足够）
                    int available = 1;
                    if(level_req > 0 && skill_level < level_req) {
                        available = 0;
                    }

                    // 检查内力是否足够
                    int enough_neili = player_neili >= neili_cost;

                    if(sizeof(perform_name_cn) > 0) {
                        performs_list += ({
                            ([
                                "id": perform_id,
                                "name_cn": perform_name_cn,
                                "neili_cost": neili_cost,
                                "level_req": level_req,
                                "skill_level": skill_level,
                                "available": available,
                                "enough_neili": enough_neili
                            ])
                        });
                    }
                }
            }
        }

        // werror("[API] /api/performs SUCCESS: total_performs=%d\n", sizeof(performs_list));

        // 生成新的 txd
        string new_txd = generate_txd(userid);

        send_json(req, ([
            "performs": performs_list,
            "skill_name": skill_name,
            "skill_name_cn": skill_name_cn,
            "skill_level": skill_level,
            "player_neili": player_neili,
            "in_combat": 0,
            "txd": new_txd
        ]));

        // werror("[API] /api/performs END\n");
    };

    if(err) {
        werror("[API] /api/performs EXCEPTION: %s\n", describe_error(err));
        werror("[API] /api/performs BACKTRACE: %s\n", sprintf("%O", err));
        send_json(req, ([ "error": "服务器错误" ]), 500);
    }
}

void handle_api_async(Protocols.HTTP.Server.Request req)
{
    mapping params = get_params(req);
    string txd = url_decode(params["txd"]);
    string cmd = params["cmd"];
    if(!cmd || cmd == "") cmd = "look";

    if(!txd || txd == "" || txd == " ") {
        send_json(req, ([ "error": "需要认证信息：txd" ]), 400);
        return;
    }

    mapping auth = decode_txd(txd);
    if(!auth) {
        send_json(req, ([ "error": "TXD认证信息无效" ]), 401);
        return;
    }

    string userid = auth["userid"];
    cmd = unhide_command(userid, cmd);

    string request_id = userid + "_" + sprintf("%d", time() * 1000 + random(999));
    int enqueued = enqueue_user_request(userid, cmd, request_id);

    if(enqueued) {
        send_json(req, ([
            "request_id": request_id,
            "status": "queued",
            "message": "命令已加入队列"
        ]));
    } else {
        send_json(req, ([ "error": "队列已满，请稍后重试" ]), 503);
    }
}

void handle_api_result(Protocols.HTTP.Server.Request req)
{
    mapping params = get_params(req);
    string request_id = params["request_id"];

    if(!request_id || request_id == "") {
        send_json(req, ([ "error": "缺少request_id参数" ]), 400);
        return;
    }

    string|zero result = get_request_result(request_id);

    if(result == 0) {
        send_json(req, ([ "status": "pending", "message": "命令正在执行中" ]));
    } else if(result == UNDEFINED) {
        send_json(req, ([ "error": "请求超时或已过期" ]), 408);
    } else {
        string txd = params["txd"];
        string userid = "";
        if(txd && txd != "") {
            mapping auth = decode_txd(txd);
            if(auth) userid = auth["userid"];
        }

        string html = response_to_html(result, userid, "look");
        mapping resp = ([ ]);
        resp["type"] = "text/html; charset=UTF-8";
        resp["data"] = html;
        resp["error"] = 200;
        resp["extra_heads"] = (["cache-control": "no-cache", "Access-Control-Allow-Origin": "*"]);
        req->response_and_finish(resp);
    }
}

void handle_exits(Protocols.HTTP.Server.Request req)
{
    mapping params = get_params(req);
    string txd = url_decode(params["txd"]);

    if(!txd || txd == "" || txd == " ") {
        send_json(req, ([ "error": "需要认证信息：txd" ]), 400);
        return;
    }

    mapping auth = decode_txd(txd);
    if(!auth) {
        send_json(req, ([ "error": "TXD认证信息无效" ]), 401);
        return;
    }

    string userid = auth["userid"];
    object player = get_player_from_connection(userid);

    if(!player) {
        send_json(req, ([ "error": "玩家未登录" ]), 401);
        return;
    }

    send_json(req, query_room_exits(player));
}

void handle_room(Protocols.HTTP.Server.Request req)
{
    mapping params = get_params(req);
    string txd = url_decode(params["txd"]);

    if(!txd || txd == "" || txd == " ") {
        send_json(req, ([ "error": "需要认证信息：txd" ]), 400);
        return;
    }

    mapping auth = decode_txd(txd);
    if(!auth) {
        send_json(req, ([ "error": "TXD认证信息无效" ]), 401);
        return;
    }

    string userid = auth["userid"];
    object player = get_player_from_connection(userid);

    if(!player) {
        send_json(req, ([ "error": "玩家未登录" ]), 401);
        return;
    }

    send_json(req, query_room_info(player));
}

void handle_api_chat_messages(Protocols.HTTP.Server.Request req)
{
    mapping params = get_params(req);
    string txd = params["txd"];
    string channel = params["channel"] || "pub_channel";

    if(!txd || txd == "") {
        send_json(req, ([ "error": "缺少txd参数" ]), 401);
        return;
    }

    mapping auth = decode_txd(txd);
    if(!auth) {
        send_json(req, ([ "error": "无效的txd" ]), 401);
        return;
    }

    string userid = auth["userid"];

    object chatroomd = find_object(ROOT + "/gamelib/single/daemons/chatroomd");
    if(!chatroomd) {
        chatroomd = load_object(ROOT + "/gamelib/single/daemons/chatroomd");
    }

    if(!chatroomd) {
        send_json(req, ([ "error": "聊天服务不可用" ]), 503);
        return;
    }

    string chat_msg = chatroomd->query_chat_msg(channel, userid);

    array(string) messages = ({});
    if(chat_msg && sizeof(chat_msg)) {
        foreach(chat_msg / "\n", string line) {
            line = String.trim_all_whites(line);
            if(sizeof(line) > 0) {
                string cleaned = clean_chat_message(line);
                if(sizeof(cleaned) > 0) {
                    messages += ({cleaned});
                }
            }
        }
    }

    send_json(req, ([
        "channel": channel,
        "messages": messages,
        "count": sizeof(messages),
        "timestamp": time()
    ]));
}

void handle_api_chat_send(Protocols.HTTP.Server.Request req)
{
    if(req->request_type != "POST") {
        send_json(req, ([ "error": "只支持POST请求" ]), 405);
        return;
    }

    mapping params = get_params(req);
    string txd = params["txd"];
    string channel = params["channel"] || "pub_channel";
    string message = params["message"];

    if(!txd || txd == "") {
        send_json(req, ([ "error": "缺少txd参数" ]), 401);
        return;
    }

    mapping auth = decode_txd(txd);
    if(!auth) {
        send_json(req, ([ "error": "无效的txd" ]), 401);
        return;
    }

    string userid = auth["userid"];
    string password = auth["password"];

    if(!message || message == "") {
        send_json(req, ([ "error": "消息内容不能为空" ]), 400);
        return;
    }

    execute_command(userid, password, "ui_chat " + message);

    send_json(req, ([
        "success": 1,
        "channel": channel,
        "message": message,
        "timestamp": time()
    ]));
}

// ========================================================================
// 辅助查询函数
// ========================================================================

mapping query_room_exits(object player)
{
    mapping result = ([ ]);
    result["timestamp"] = time();
    result["room"] = ([ ]);
    result["exits"] = (["北": 0, "东": 0, "南": 0, "西": 0]);

    object room = environment(player);
    if(!room) {
        result["room"]["name"] = "虚空";
        result["room"]["desc"] = "你处于虚空中...";
        return result;
    }

    if(functionp(room->query_short)) {
        result["room"]["name"] = room->query_short();
    } else if(functionp(room->query_name_cn)) {
        result["room"]["name"] = room->query_name_cn();
    } else {
        result["room"]["name"] = "未知房间";
    }

    if(functionp(room->query_desc)) {
        string desc = room->query_desc();
        if(desc) result["room"]["desc"] = desc;
    }

    if(functionp(room->query_exits)) {
        mapping exits = room->query_exits();
        if(exits && sizeof(exits) > 0) {
            foreach(indices(exits), string dir) {
                string dest_path = exits[dir];
                string dest_name = "";

                if(dest_path && sizeof(dest_path) > 0) {
                    if(!has_prefix(dest_path, ROOT) && !has_prefix(dest_path, "/")) {
                        dest_path = ROOT + "/" + dest_path;
                    } else if(has_prefix(dest_path, "/") && !has_prefix(dest_path, ROOT)) {
                        dest_path = ROOT + dest_path;
                    }

                    object dest_room = load_object(dest_path);
                    if(dest_room) {
                        if(functionp(dest_room->query_short)) {
                            dest_name = dest_room->query_short();
                        } else if(functionp(dest_room->query_name_cn)) {
                            dest_name = dest_room->query_name_cn();
                        }
                    }
                }

                string norm_dir = normalize_direction(dir);
                array valid_dirs = indices(result["exits"]);
                if(search(valid_dirs, norm_dir) >= 0) {
                    result["exits"][norm_dir] = ([
                        "direction": dir,
                        "command": "leave " + dir,
                        "destination": dest_name || ""
                    ]);
                }
            }
        }
    }

    return result;
}

mapping query_room_info(object player)
{
    mapping result = ([ ]);
    result["timestamp"] = time();
    result["room"] = ([ ]);
    result["npcs"] = ({});

    object room = environment(player);
    if(!room) {
        result["room"]["name"] = "虚空";
        result["room"]["desc"] = "你处于虚空中...";
        return result;
    }

    if(functionp(room->query_short)) {
        result["room"]["name"] = room->query_short();
    } else if(functionp(room->query_name_cn)) {
        result["room"]["name"] = room->query_name_cn();
    } else {
        result["room"]["name"] = "未知房间";
    }

    if(functionp(room->query_desc)) {
        string desc = room->query_desc();
        if(desc) result["room"]["desc"] = desc;
    } else if(functionp(room->query_long)) {
        result["room"]["desc"] = room->query_long();
    }

    array inv = all_inventory(room);
    foreach(inv, object ob) {
        if(ob != player && functionp(ob->query_short)) {
            string name = ob->query_short();
            if(name) {
                mapping npc = ([ "name": name ]);
                if(functionp(ob->query_name)) {
                    string ob_name = ob->query_name();
                    if(ob_name && sizeof(ob_name) > 0) {
                        npc["command"] = "look " + ob_name;
                    } else {
                        npc["command"] = "look " + name;
                    }
                } else {
                    npc["command"] = "look " + name;
                }
                result["npcs"] += ({npc});
            }
        }
    }

    return result;
}

// ========================================================================
// 状态查询
// ========================================================================

mapping query_status()
{
    mapping m = ([ ]);
    m["running"] = http_port != 0;
    m["port"] = HTTP_PORT;
    m["api_only"] = api_only_mode;
    m["connections"] = query_connection_status();
    m["queue"] = query_queue_status();
    m["rate_limits"] = query_rate_limit_status();
    return m;
}
