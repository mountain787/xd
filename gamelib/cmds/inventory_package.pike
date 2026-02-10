#include <command.h>
#include <gamelib/include/gamelib.h>

int main(string|zero arg)
{
	if(!arg)
	{
		this_player()->write_view(WAP_VIEWD["/inventory_package"]);
		return 1;
	}
	return 1;
}
