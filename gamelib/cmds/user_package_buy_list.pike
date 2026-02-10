#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string|zero arg)
{
	object me = this_player();
	string s="璐拱\n\n";
	if(!arg){
		s += "[璐拱鑳屽寘:user_package_buy_list beibao]\n";
		s += "[璐拱浠撳簱:user_package_buy_list cangku]";
		me->write_view(WAP_VIEWD["/emote"],0,0,s);
		return 1;
	}
	else{
		string type = arg;
		if(type=="cangku"){
			s += "[榛勯噾璐拱:user_package_buy]\n";
		}
		s += BUYD->get_pac_list(type,"user_package_buy_confirm");
	}
	me->write_view(WAP_VIEWD["/emote"],0,0,s);
	return 1;
}
