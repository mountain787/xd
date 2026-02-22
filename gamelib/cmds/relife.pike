#include <command.h>
#include <gamelib/include/gamelib.h>
//arg = "duanzao" or "lianjin"
int main(string|zero arg)
{
	string s = "你只有学会了相关的技能，才能细数那些钻卡上的东西\n";
	object me=this_player();

	// DEBUG LOG
	werror("========== [RELIFE] START ==========\n");
	werror("[RELIFE] arg=%O, type=%t\n", arg, arg);
	werror("[RELIFE] player=%s\n", me ? me->query_name() : "null");
	werror("[RELIFE] vice_skills=%O\n", me ? me->vice_skills : "null");

	if(arg == "duanzao"){
		werror("[RELIFE] Calling query_duanzao_peifang_list(1,20)\n");
		s += PEIFANGD->query_duanzao_peifang_list(1,20);
		werror("[RELIFE] query_duanzao_peifang_list returned, s length=%d\n", sizeof(s));
	}
	if(arg == "liandan"){
		werror("[RELIFE] Calling query_liandan_peifang_list(1,20)\n");
		s += PEIFANGD->query_liandan_peifang_list(1,20);
		werror("[RELIFE] query_liandan_peifang_list returned, s length=%d\n", sizeof(s));
	}
	if(arg == "caifeng"){
		werror("[RELIFE] Calling query_caifeng_peifang_list(1,20)\n");
		s += PEIFANGD->query_caifeng_peifang_list(1,20);
		werror("[RELIFE] query_caifeng_peifang_list returned, s length=%d\n", sizeof(s));
	}
	if(arg == "zhijia"){
		werror("[RELIFE] Calling query_zhijia_peifang_list(1,20)\n");
		s += PEIFANGD->query_zhijia_peifang_list(1,20);
		werror("[RELIFE] query_zhijia_peifang_list returned, s length=%d\n", sizeof(s));
	}

	werror("[RELIFE] Final s length=%d\n", sizeof(s));
	werror("========== [RELIFE] END ==========\n");

	me->write_view(WAP_VIEWD["/emote"],0,0,s);
	//s += "\n[返回游戏:look]\n";
	//write(s);
	return 1;
}
