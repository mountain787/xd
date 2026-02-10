#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string|zero arg)
{
	object me = this_player();
	string s = "";
	if(!arg){
		s += "你想解散哪个团战？\n";
		s += "[返回游戏:look]\n";
		write(s);
		return 1;
	}
	int rs = TERMD->destory_term(arg, me->query_name());
	switch(rs){
		case 0:
			s += "解散失败，没有该团战\n";
		break;
		case 1:
			s += "成功解散团战。\n";
            //刷新团战
            TERMD->flush_term(me->query_term());
		break;
		case 2:
			s += "解散失败,未找到该团战。\n";
		break;
		case 3:
			s += "解散失败,未找到该团战。\n";
		break;
		case 4:
			s += "非团长权限，不能解散团战\n";
		break;
	}
	s += "[返回游戏:look]\n";
	write(s);
	return 1;
}
