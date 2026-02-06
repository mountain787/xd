#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	object me = this_player();
	string s = "";
	if(!arg)
		s+="浣犺灞忚斀鍝釜鐜╁锛焅n";
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
				s += "浣犲凡缁忓睆钄借繃浜嗚鐜╁锛屼笉鐢ㄩ噸澶嶅睆钄借杩斿洖銆俓n";	
			else{
				me["/plus/chatblock"]+=({arg});
				s += "浣犲凡缁忚繃婊ゆ帀浜嗚鐜╁鍦ㄨ亰澶╅閬撶殑鍙戣█鍐呭锛岃杩斿洖銆俓n";	
			}
		}
		else{
			me["/plus/chatblock"]=({arg});
			s += "浣犲凡缁忚繃婊ゆ帀浜嗚鐜╁鍦ㄨ亰澶╅閬撶殑鍙戣█鍐呭锛岃杩斿洖銆俓n";	
		}
	}
	s+="[杩斿洖:chatroom_entry "+me->query_chatid()+"]\n";
	s+="[杩斿洖娓告垙:look]\n";
	write(s);
	return 1;
}
