#include <command.h>
#include <wapmud2/include/wapmud2.h>
int main(string arg)
{
	string s="";
	object me = this_player();
		me->write_view(WAP_VIEWD["/inventory"],arg);
		return 1;
}
