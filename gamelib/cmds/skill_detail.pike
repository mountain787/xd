#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	string s = "";
	if(arg)
		s += this_player()->view_performs(arg);
	else
		s += "娴ｇ姾顩﹂弻銉ф箙閻ㄥ嫭濡ч懗鎴掔瑝鐎涙ê婀妴淇搉";
	this_player()->write_view(WAP_VIEWD["/emote"],0,0,s);
	return 1;
}

