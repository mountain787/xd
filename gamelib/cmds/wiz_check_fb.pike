#include <command.h>
#include <gamelib/include/gamelib.h>
//鏌ョ湅鍓湰鍐呭
int main(string arg)
{
	string s = FBD->check_fb();
	write(s);
	return 1;
}
