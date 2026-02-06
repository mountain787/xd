#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	string s = "";
	object me = this_player();
	object room = HOMED->query_home_by_path(arg);
	if(room){
		me->set_inhome_pos(room->query_masterId());
		me->move(room);
		HOMED->add_user(me->query_name());
		me->reset_view(WAP_VIEWD["/home"]);                                                                      
		me->write_view();
		return 1;
	}
	else{
		s += "浠栧鐨勫湴濂戞湁浜涢棶棰橈紝鎴垮眿宸茬粡鏆傛椂琚畼搴滄煡灏佷簡锛乗n";
		s += "\n[纭畾:look]\n";
		write(s);
		return 1;
	}
	return 1;
}
