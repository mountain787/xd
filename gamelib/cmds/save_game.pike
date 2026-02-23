#include <command.h>
#include <gamelib/include/gamelib.h>

int main(string|zero arg)
{
	object me = this_player();
	string s = "";

	// 调用 save() 方法保存玩家数据
	me->save();

	s = "§6存档成功！§2\n";
	s += "\n";
	s += "你的游戏数据已保存。\n";
	s += "[返回:game_detail]";

	me->write_view(WAP_VIEWD["/emote"], 0, 0, s);
	return 1;
}
