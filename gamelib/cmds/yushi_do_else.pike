#include <command.h>
#include <gamelib/include/gamelib.h>

int main(string arg)
{
	object me = this_player();
	string s = "鐜夌煶鐩稿叧鎿嶄綔\n";
	s += "\n";
	s += "[鍏朵粬鏂瑰紡璐拱:add_else_fee]\n";
	s += "[鐜夌煶璇存槑:yushi_explain]\n";
	s += "[鎹愯禒鑾峰彇鐜夌煶璇存槑:yushi_readme]\n";
	s += "[鐐煎寲瑁呭璇存槑:convert_readme]\n";
	me->write_view(WAP_VIEWD["/emote"],0,0,s);
	return 1;
}
