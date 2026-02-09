# HTTP API login.pike exec() Issue Fix

## 问题描述

当 HTTP API 调用 `login.pike->main()` 时，出现以下错误：
- API 请求卡死，无响应
- 错误信息：`Cannot call functions in destructed objects`
- 错误位置：`gamenv/single/daemons/http_api.pike` 中的 `execute_command_sync` 或 `execute_internal_command_sync`

## 根本原因

`login.pike->main()` 内部调用了 `exec()` 函数，用于替换玩家对象的程序。在 socket 连接模式下这没问题，但在 HTTP API 模式下会导致：

```
socket 模式：
login.pike->main() → exec() → 玩家对象替换 → socket连接继续存在 ✓

HTTP API 模式：
login.pike->main() → exec() → HTTP Request 对象被析构 → 无法返回响应 ✗
```

## 检测方法

搜索以下代码模式：
```pike
object login_cmd = load_object(ROOT + "/pikenv/system/cmds/login.pike");
if(login_cmd) {
    login_cmd->main(login_arg);  // ❌ 这会导致问题
}
```

## 修复方案

**绕过 `login.pike->main()`，直接创建玩家对象：**

```pike
// ❌ 修复前（有问题）
string login_arg = sprintf("gamenv %s %s %s", userid, password, session);
object login_cmd = load_object(ROOT + "/pikenv/system/cmds/login.pike");
login_cmd->main(login_arg);  // exec() 会析构 HTTP Request
player = get_player_from_connection(userid);

// ✅ 修复后（正确）
// HTTP API 模式：直接创建玩家对象，不通过 login.pike
// 因为 login.pike 内部调用 exec() 会析构 HTTP Request 对象
player = create_http_api_player(userid, password);
// 或者手动创建：
string user_file = ROOT + "/gamenv/clone/user.pike";
program user_prog = compile_file(user_file);
player = user_prog(user_file);
player->set_name(userid);
player->set_project("gamenv");
player->setup(password);
```

## 涉及文件

- `gamenv/single/daemons/http_api.pike` - 主要修复位置
  - `execute_command_sync()` 函数
  - `execute_internal_command_sync()` 函数
- `gamenv/single/daemons/http_api/thread_manager.pike` - 日志追踪

## 验证方法

1. 前端使用 TXD 发送请求
2. 后端不应调用 `login_cmd->main()`
3. 日志中应看到 `Creating player directly (HTTP API mode)...`
4. API 正常返回 JSON 响应

## 项目状态

| 项目 | 状态 | 说明 |
|------|------|------|
| oldtx/tx | ✅ 已修复 | commit `b0aee2feb` |
| txpike9 | ✅ 已修复 | commit `22ca21497f` |
| xiand | ✅ 无需修复 | 从一开始就使用直接创建方式 |

## 关键注释

在代码中添加说明注释：
```pike
// HTTP API 模式：不调用 login.pike->main()，因为它内部调用 exec() 会析构 HTTP Request 对象
// 直接创建玩家对象（与 execute_command_sync 保持一致）
```

## 相关问题

- 断线重连时，虚拟连接池被清空，需要重新创建玩家
- TXD 密码解码需要正确处理 URL 编码
- 前端需要添加超时机制防止无限等待
