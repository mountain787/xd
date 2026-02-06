#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	object me = this_player();
	object room = HOMED->query_room_by_masterId(arg,"main");
	string s = "";
	if(room){
		me->move(room);
		me->reset_view(WAP_VIEWD["/home"]);                                                                      
		me->write_view();
		return 1;
	}
	else{
		s += "浠栧濂藉儚杩樺湪瑁呬慨锛岀◢鍚庡啀鏉ュ惂\n";
		s += "\n[纭畾:look]\n";
		write(s);
		return 1;
	}
	return 1;
}
