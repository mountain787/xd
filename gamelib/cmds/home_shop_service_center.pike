#include <command.h>
#include <gamelib/include/gamelib.h>

//鏈嶅姟涓績
int main(string arg)
{
	object me = this_player();
	string s = "";
	string masterId = me->query_name();
	s += HOMED->get_past_time_items(masterId);
	s += "[杩斿洖娓告垙:look]\n";
	write(s);
	return 1;
}
