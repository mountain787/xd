#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	object me = this_player();
	string s = "";
	if(!HOMED->if_have_home(me->query_name()))
	{
		s += "浣犺繕娌℃湁鍦颁骇锛岀┖鎵嬪鐧界嫾鍦ㄨ繖閲屽彲琛屼笉閫歕n";
	}
	else
	{
		s += HOMED->get_sell_functionroom_list(arg);
	}
	s += "\n[杩斿洖娓告垙:look]\n"; 
	write(s);
	return 1;
}
