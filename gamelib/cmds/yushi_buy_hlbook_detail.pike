#include <command.h>                                                                                                         
#include <gamelib/include/gamelib.h>

int main(string arg)
{
	object me = this_player();
	string s = "";
	string name = "";
	int yushi = 0;
	sscanf(arg,"%s %d",name,yushi);
	s += BUYD->item_view(name,yushi,0);
	if(BUYD->query_book_num(name))
		s += "\n[纭畾璐拱:yushi_buy_hlbook_confirm "+name+" "+yushi+"]\n";
	else 
		s += "\n此书已售罄
";
	s += "[杩斿洖:yushi_buy_hlbook_list]\n";
	s += "[返回游戏:look]\n";
	write(s);
	return 1;
}
