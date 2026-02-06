#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	object me = this_player();
	string s = "";
	s += "锛婚槦浼嶇姸鎬侊冀\n";
	s += TERMD->query_termStatus(me->query_term(),me->query_name());
	s += "[杩斿洖娓告垙:look]\n";
	write(s);
	return 1;
}
