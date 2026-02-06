#include <command.h>
#include <wapmud2/include/wapmud2.h>
#include <gamelib/include/gamelib.h>

//鏈嶅姟涓績
int main(string arg)
{
	object me = this_player();
	string s = "";
	string masterId = me->query_name();
	object env = environment(me);
	int ind = (int)arg;
	//鍙湁鎴块棿鐨勪富浜烘墠鑳借繘鏈嶅姟涓績棰嗗彇鐗╁搧
	if(HOMED->is_master(env->homeId)){
	int result = HOMED->get_pass_time_ob(me,ind);
	if(result){
		s += "棰嗗彇鎴愬姛\n";
		HOMED->save_shopItem(masterId,"",ind);
	}
	else 
		s += "棰嗗彇澶辫触锛岃涓庡鏈嶈仈绯籠n";
	}
	s += "[杩斿洖娓告垙:look]\n";
	write(s);
	return 1;
}
