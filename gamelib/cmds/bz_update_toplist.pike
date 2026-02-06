#include <command.h>
#include <gamelib/include/gamelib.h>  
//姝ゆ寚浠ゅ埛鏂板府娲剧殑鎺掕
int main(string arg)
{
	string s = "";
	object me=this_player();
	BANGZHAND->update_bang_toplist(1);
	me->command("bz_top_list");
	//s += "\n[杩斿洖娓告垙:look]\n";
	//write(s);
	return 1;
}
