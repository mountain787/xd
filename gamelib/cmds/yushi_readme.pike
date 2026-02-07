#include <command.h>
#include <gamelib/include/gamelib.h>
#define YUSHI_PATH ROOT "/gamelib/clone/item/yushi/"
//鐜夌煶玩家鎿嶄綔鎺ュ彛
int main(string arg)
{
	object me = this_player();
	string s = "";
	s += "挑战获取灵玉说明：
";
	s += "用户挑战50元，即可获得5艘天灵玉\n";
	s += "鎹愯禒鑱旂粶qq:1811117272\n";
	//s += "[神州行卡挑战获取灵玉说明:szx_readme]\n";
	//s += me->query_mini_picture_url("decorate11")+"[鐭俊鎹愯禒鑾峰彇浠欑帀璇存槑:yushi_msg_readme]\n";
	//s += me->query_mini_picture_url("decorate11")+"[閾惰鎹愯禒鑾峰彇浠欑帀璇存槑:add_big_fee_des]\n";
	s += "[返回:yushi_myzone]\n";
	s += "[返回游戏:look]\n";
	write(s);
	return 1;
}
