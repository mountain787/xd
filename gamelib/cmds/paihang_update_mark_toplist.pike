#include <command.h>
#include <gamelib/include/gamelib.h>  
//姝ゆ寚浠ゆ洿鏂扮患鍚堝疄鍔涚殑鎺掕锛屾祴璇曠敤
int main(string arg)
{
	string s = "";
	object me=this_player();
	PAIHANGD->update_mark_toplist(1);
	me->command("paihang_mark_toplist");
	//s += "\n[杩斿洖娓告垙:look]\n";
	//write(s);
	return 1;
}
