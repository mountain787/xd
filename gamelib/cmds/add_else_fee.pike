#include <command.h>
#include <gamelib/include/gamelib.h>

//鍏朵粬鏂瑰紡鎹愯禒鑾峰彇浠欑帀
int main(string arg)
{
	object me = this_player();
	string s = "";
	s += "鍏朵粬鏂瑰紡鎹愯禒鑾峰彇浠欑帀\n";
	//s += "[鐭俊鎹愯禒鑾峰彇浠欑帀:add_sms_fee]\n";
	//s += "[閾惰姹囨鎹愯禒鑾峰彇鐜夌煶:add_big_fee]\n";
	s += "\n";
	s += "[杩斿洖浠欑帀濡欏潑:yushi_myzone]\n";
	s += "[杩斿洖娓告垙:look]\n";
	write(s);
	return 1;
}
