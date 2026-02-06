#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	object me = this_player();
	string s = "";
	object ob = find_player(arg);
	if(ob){
		s += ob->query_name_cn()+"锛歕n";
		s += ob->view_equip();
	}
	else
		s += "浣犺瑙傚療鐨勫璞″苟涓嶅瓨鍦╘n";
	//s += "[杩斿洖:char "+arg+"]\n";
	//s += "[杩斿洖娓告垙:look]\n";
	//write(s);
	me->write_view(WAP_VIEWD["/emote"],0,0,s);
	return 1;
}
