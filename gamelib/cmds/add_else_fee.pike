#include <command.h>
#include <gamelib/include/gamelib.h>

//其他方式挑战获取灵玉
int main(string arg)
{
	object me = this_player();
	string s = "";
	s += "其他方式挑战获取灵玉\n";
	//s += "[短信挑战获取灵玉:add_sms_fee]\n";
	//s += "[银行卡划账挑战获取钻灵:add_big_fee]\n";
	s += "\n";
	s += "[返回灵玉乐园:yushi_myzone]\n";
	s += "[返回游戏:look]\n";
	write(s);
	return 1;
}
