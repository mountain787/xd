#include <command.h>
#include <gamelib/include/gamelib.h>

int main(string arg)
{
	object me = this_player();
	string s = "钻灵关操作\n";
	s += "\n";
	s += "[其他方式购买:add_else_fee]\n";
	s += "[钻灵说明:yushi_explain]\n";
	s += "[挑战获取钻灵说明:yushi_readme]\n";
	s += "[点化装备说明:convert_readme]\n";
	me->write_view(WAP_VIEWD["/emote"],0,0,s);
	return 1;
}
