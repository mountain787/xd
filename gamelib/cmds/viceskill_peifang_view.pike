#include <command.h>
#include <gamelib/include/gamelib.h>
//arg = "duanzao" or "lianjin"
int main(string arg)
{
	string s = "浣犲彧鏈夊浼氫簡鐩稿叧鐨勬妧鑳斤紝鎵嶈兘璇绘噦杩欎簺鍗疯酱涓婄殑涓滆タ\n";
	object me=this_player();
	if(arg == "duanzao")
		s += PEIFANGD->query_duanzao_peifang_list(1,20);
	if(arg == "liandan")
		s += PEIFANGD->query_liandan_peifang_list(1,20);
	if(arg == "caifeng")
		s += PEIFANGD->query_caifeng_peifang_list(1,20);
	if(arg == "zhijia")
		s += PEIFANGD->query_zhijia_peifang_list(1,20);
	me->write_view(WAP_VIEWD["/emote"],0,0,s);
	//s += "\n[杩斿洖娓告垙:look]\n";
	//write(s);
	return 1;
}
