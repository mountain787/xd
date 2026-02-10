#include <command.h>
#include <gamelib/include/gamelib.h>

//鐐瑰嚮搴楅摵鎺ㄨ崘閾炬帴璋冪敤鐨勬寚浠わ紝璇ユ寚浠や富瑕佸疄鐜板垪鍑哄凡缁忔帹鑽愪笖娌¤繃鏈熺殑搴楅摵

int main(string|zero arg)
{
	string s = "";
	object me = this_player();
	s += "搴楅摵鎺ㄨ崘锛歕n\n";
	s += HOMED->query_shopRcm_list();
	s += "\n\n";
	s += "[鎺ㄨ崘鎴戠殑搴楅摵:home_shop_recommend_confirm]\n";
	me->write_view(WAP_VIEWD["/emote"],0,0,s);
	return 1;
}
