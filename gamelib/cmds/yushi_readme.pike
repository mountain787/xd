#include <command.h>
#include <gamelib/include/gamelib.h>
#define YUSHI_PATH ROOT "/gamelib/clone/item/yushi/"
//钻灵玩家操作接口
int main(string|zero arg)
{
	object me = this_player();
	string s = "";
	s += "挑战获取灵玉说明：\n";
	s += "用户挑战50元，即可获得5艘天灵玉\n";
	s += "挑战联络qq:1811117272\n";
	//s += "[神州行卡挑战获取灵玉说明:szx_readme]\n";
	//s += me->query_mini_picture_url("decorate11")+"[短信挑战获取灵玉说明:yushi_msg_readme]\n";
	//s += me->query_mini_picture_url("decorate11")+"[银行卡挑战获取灵玉说明:add_big_fee_des]\n";
	s += "[返回:yushi_myzone]\n";
	s += "[返回游戏:look]\n";
	write(s);
	return 1;
}
