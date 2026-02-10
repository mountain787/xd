#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string|zero arg)
{
	this_player()->write_view(WAP_VIEWD["/qqlist_group"],0,0,arg);
	return 1;
}

