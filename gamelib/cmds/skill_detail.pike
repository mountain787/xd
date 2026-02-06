#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	string s = "";
	if(arg)
		s += this_player()->view_performs(arg);
	else
		s += "浣犺鏌ョ湅鐨勬妧鑳戒笉瀛樺湪銆俓n";
	this_player()->write_view(WAP_VIEWD["/emote"],0,0,s);
	return 1;
}

