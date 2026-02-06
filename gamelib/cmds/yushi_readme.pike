#include <command.h>
#include <gamelib/include/gamelib.h>
#define YUSHI_PATH ROOT "/gamelib/clone/item/yushi/"
//鐜夌煶鐜╁鎿嶄綔鎺ュ彛
int main(string arg)
{
	object me = this_player();
	string s = "";
	s += "鎹愯禒鑾峰彇浠欑帀璇存槑锛歕n";
	s += "鐢ㄦ埛鎹愯禒50鍏冿紝鍗冲彲鑾峰緱5棰楃幉鐝戠帀\n";
	s += "鎹愯禒鑱旂粶qq:1811117272\n";
	//s += "[绁炲窞琛屽崱鎹愯禒鑾峰彇浠欑帀璇存槑:szx_readme]\n";
	//s += me->query_mini_picture_url("decorate11")+"[鐭俊鎹愯禒鑾峰彇浠欑帀璇存槑:yushi_msg_readme]\n";
	//s += me->query_mini_picture_url("decorate11")+"[閾惰鎹愯禒鑾峰彇浠欑帀璇存槑:add_big_fee_des]\n";
	s += "[杩斿洖:yushi_myzone]\n";
	s += "[杩斿洖娓告垙:look]\n";
	write(s);
	return 1;
}
