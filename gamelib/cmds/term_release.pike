#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	object me = this_player();
	string s = "";
	if(!arg){
		s += "浣犳兂瑙ｆ暎鍝釜闃熶紞锛焅n";
		s += "[返回游戏:look]\n";
		write(s);
		return 1;
	}
	int rs = TERMD->destory_term(arg, me->query_name());
	switch(rs){
		case 0:
			s += "瑙ｆ暎澶辫触锛屾病鏈夎闃熶紞\n";
		break;
		case 1:
			s += "鎴愬姛瑙ｆ暎闃熶紞銆俓n";
            //鍒锋柊闃熶紞
            TERMD->flush_term(me->query_term());  
		break;
		case 2:
			s += "瑙ｆ暎澶辫触,鏈壘鍒拌闃熶紞銆俓n";
		break;
		case 3:
			s += "瑙ｆ暎澶辫触,鏈壘鍒拌闃熶紞銆俓n";
		break;
		case 4:
			s += "闈為槦闀挎潈闄愶紝涓嶈兘瑙ｆ暎闃熶紞\n";
		break;
	}
	s += "[返回游戏:look]\n";
	write(s);
	return 1;
}
