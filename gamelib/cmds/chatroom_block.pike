#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string|zero arg)
{
	object me = this_player();
	string s = "";
	if(!arg)
		s+="浣犺灞忚斀鍝釜玩家锛焅n";
	else{
		if(me["/plus/chatblock"]&&sizeof(me["/plus/chatblock"])){
			int belocked = 0;
			foreach(me["/plus/chatblock"],string uid){
				if(uid&&uid==arg){
					belocked  = 1;
					break;
				}
			}
			if(belocked)
				s += "浣犲凡缁忓睆钄借繃浜嗚玩家锛屼笉鐢ㄩ噸澶嶅睆钄借返回銆俓n";	
			else{
				me["/plus/chatblock"]+=({arg});
				s += "浣犲凡缁忚繃婊ゆ帀浜嗚玩家鍦ㄨ亰澶╅閬撶殑鍙戣█鍐呭锛岃返回銆俓n";	
			}
		}
		else{
			me["/plus/chatblock"]=({arg});
			s += "浣犲凡缁忚繃婊ゆ帀浜嗚玩家鍦ㄨ亰澶╅閬撶殑鍙戣█鍐呭锛岃返回銆俓n";	
		}
	}
	s+="[返回:chatroom_entry "+me->query_chatid()+"]\n";
	s+="[返回游戏:look]\n";
	write(s);
	return 1;
}
