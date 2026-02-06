#include <command.h>
#include <gamelib/include/gamelib.h>
/*
浼氬憳鏈嶅姟棣栭〉
auther: evan
2008.07.16
*/
int main(string arg)
{
	object me = this_player();
	string s = "***浼氬憳鏈嶅姟***\n\n";
	s +="[浼氬憳浼樻儬鏀跨瓥:vip_service_show]\n\n";
	s += VIPD->get_vip_state_des(me);
	s += "\n[杩斿洖:yushi_myzone.pike]\n";
	s += "[杩斿洖娓告垙:look]\n";
	write(s);
	return 1;
}
