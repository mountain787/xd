#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	int sale_id=0;
	sscanf(arg,"%d",sale_id);
	object me = this_player();
	object env=environment(me);
	string s = "";
	if(env){
		if(!AUCTIOND->reset_sale_info(this_player(),sale_id,0,4))
			s += "娌℃湁鎵惧埌姝ゆ媿鍗栫殑绾綍\n";
		else
			s += "浣犲彇娑堜簡姝ゆ媿鍗朶n";
	}
	s += "[杩斿洖:look]\n";
	write(s);
	return 1;
}
