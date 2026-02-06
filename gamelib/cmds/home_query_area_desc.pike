#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	object me = this_player();
	string s = "";
	s += HOMED->query_area_desc(arg) + "\n";
	s += "[杩斿洖:home_purchase_slot_list " +arg+ "]\n";
	write(s);
	return 1;
}
