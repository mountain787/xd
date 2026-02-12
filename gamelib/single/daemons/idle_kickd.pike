// 空闲踢人守护进程 - 处理原生 socket 连接
// 定期检查所有在线用户的空闲时间，超过阈值则自动踢下线
/*
【功能说明】
  每隔一定时间检查原生 socket 连接用户的空闲时间
  (HTTP API 虚拟连接用户由 http_api_daemon 处理)
  如果用户空闲时间超过设定阈值，则自动踢下线

【配置参数】
  CHECK_INTERVAL: 检查间隔时间（秒），默认60秒
  IDLE_TIMEOUT: 空闲超时时间（秒），默认3600秒（60分钟）
  IDLE_TIMEOUT_VIP: VIP用户空闲超时时间（秒），默认7200秒（120分钟）

【日志】
  踢人日志记录到 ROOT+"/log/idle_kick.log.YYYY-MM-DD"
*/
#include <globals.h>
#include <gamelib/include/gamelib.h>

#define CHECK_INTERVAL 60        // 每分钟检查一次
#define IDLE_TIMEOUT 3600        // 普通用户60分钟踢人
#define IDLE_TIMEOUT_VIP 7200    // VIP用户120分钟踢人

// HTTP API daemon 对象引用
object http_api_daemon;

protected void create()
{
	// 延迟获取 HTTP API daemon，确保它已加载
	call_out(start_idle_check, 10);
}

void start_idle_check()
{
	http_api_daemon = find_object(ROOT + "/gamelib/single/daemons/http_api_daemon.pike");
	call_out(check_idle_users, CHECK_INTERVAL);
}

// 检查所有在线用户的空闲时间
void check_idle_users()
{
	array list = users(1);
	int kicked_count = 0;

	foreach(list, object user) {
		if(!user) continue;

		catch {
			// 跳过 HTTP API 虚拟连接用户（由 http_api_daemon 处理）
			if(http_api_daemon && functionp(http_api_daemon->has_virtual_connection)) {
				string userid = user->query_name();
				if(http_api_daemon->has_virtual_connection(userid)) {
					continue;  // 跳过虚拟连接用户
				}
			}

			int idle_time = user->query_idle();
			if(idle_time <= 0) continue;

			int vip_flag = user->query_vip_flag();
			int timeout = (vip_flag && vip_flag > 0) ? IDLE_TIMEOUT_VIP : IDLE_TIMEOUT;

			// 空闲时间超过阈值，踢人
			if(idle_time >= timeout) {
				string name = user->query_name();
				string name_cn = user->query_name_cn();
				int level = user->query_level();

				// 记录日志
				log_idle_kick(name, name_cn, level, idle_time, "SOCKET");

				// 踢下线
				user->remove();
				kicked_count++;
			}
		};
	}

	// 继续下一次检查
	call_out(check_idle_users, CHECK_INTERVAL);
}

// 记录踢人日志
void log_idle_kick(string name, string name_cn, int level, int idle_time, string conn_type)
{
	string now = ctime(time());
	string log_time = now[0..sizeof(now)-2];

	mapping now_time = localtime(time());
	int day = now_time["mday"];
	int mon = now_time["mon"]+1;
	int year = now_time["year"]+1900;

	string mon_str = (mon < 10) ? "0"+mon : (string)mon;
	string day_str = (day < 10) ? "0"+day : (string)day;
	string date_str = year+"-"+mon_str+"-"+day_str;

	string vip_str = (conn_type == "SOCKET") ? "" : "VIP用户";
	string idle_min = (string)(idle_time / 60);

	string log_msg = sprintf("[%s] %s(%s) %d级 %s%s [%s] 空闲%s分钟 被踢下线\n",
		log_time, name_cn, name, level, vip_str, (vip_str != "" ? " " : ""), conn_type, idle_min);

	Stdio.append_file(ROOT+"/log/idle_kick.log."+date_str, log_msg);
}

// 查询当前配置信息
string query_status()
{
	string s = "=== Socket 空闲踢人系统状态 ===\n";
	s += "检查间隔: "+(CHECK_INTERVAL/60)+"分钟\n";
	s += "普通用户超时: "+(IDLE_TIMEOUT/60)+"分钟\n";
	s += "VIP用户超时: "+(IDLE_TIMEOUT_VIP/60)+"分钟\n";
	return s;
}
