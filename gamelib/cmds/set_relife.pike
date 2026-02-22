#include <command.h>
#include <gamelib/include/gamelib.h>
//arg = room path, e.g., "/gamelib/d/congxianzhen/congxianzhenguangchang"
//用于设置玩家复活点
int main(string|zero arg)
{
	object me=this_player();

	if(!arg){
		write("请指定房间路径。\n");
		return 1;
	}

	me->relife = arg;
	string s = "你已经成功将该房间设置成为复活点，请返回。\n";
	s += "[返回游戏:look]\n";
	write(s);
	return 1;
}
