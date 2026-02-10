#include <command.h>
#include <gamelib/include/gamelib.h>
//鍒楀嚭鐢ㄧ帀鐭冲厬鎹㈢殑鐗╁搧鍒楄〃
int main(string|zero arg)
{
	object me = this_player();
	string s = "浣犲笇鏈涙崲鐐逛粈涔堬細\n";
	me->write_view(WAP_VIEWD["/emote"],0,0,s);
	return 1;
}
