#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	object me = this_player();
	string s = "";
	if(!arg){
		s += "[娣诲姞鎴块棿:home_functionroom_buy_list home_base]\n";
		s += "[鍙樺崠鎴块棿:home_functionroom_remind home_base]\n";
	}
	/*
	if(HOMED->if_can_buy_functionroom(me->query_name())){
		s += "鎮ㄦ墍鎷ユ湁鐨勫姛鑳芥埧闂存暟閲忓凡杈惧埌涓婇檺锛屼笉鑳藉啀娣诲姞鍒殑鍔熻兘鎴块棿\n";
		s += "\n[杩斿洖:popview]\n";
		write(s);
		return 1;
	}
	*/
	else{
		s += HOMED->query_function_room_for_sale(arg);
	}
	s += "\n[杩斿洖:popview]\n";
	write(s);
	return 1;
}
