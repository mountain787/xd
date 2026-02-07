#include <command.h>
#include<wapmud2/include/wapmud2.h>
int main(string arg)
{
	object me = this_player();
	string s = "";
	object ob = find_player(arg);
	string uid =arg;
	int result = me->delete_spy_info(uid);
	switch(result){
		case 0:
			s += "鍒犻櫎鍏虫敞淇℃伅澶辫触锛岃閲嶈瘯銆俓n";
			break;
		case 1:
			s += "该玩家不在你的关注列表中。俓n";
			break;
		case 2:
			s += "鍒犻櫎鍏虫敞淇℃伅鎴愬姛锛岃返回銆俓n";
			break;
	}
	me->write_view(WAP_VIEWD["/emote"],0,0,s);
	return 1;
}
