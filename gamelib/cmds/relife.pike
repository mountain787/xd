#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	object player=this_player();
	string s = "浣犲凡缁忔垚鍔熷皢璇ユ埧闂磋缃垚涓哄娲荤偣锛岃杩斿洖銆俓n";
	if(arg)
		player->relife=arg;
	s += "[杩斿洖娓告垙:look]\n";
	write(s);
	return 1;
}
