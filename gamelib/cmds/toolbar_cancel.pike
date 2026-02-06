#include <command.h>
#include <gamelib/include/gamelib.h>
//arg = num
int main(string arg)
{
	int num=(int)arg;
	string s = "";
	if(this_player()->clean_toolbar(num)){
		s = "浣犲凡鍙栨秷浜嗗揩鎹烽敭"+(num+1)+"鐨勮缃甛n";
	}
	else 
		s += "鍙栨秷璁剧疆澶辫触\n";
	s += "[杩斿洖:my_toolbar]\n";
	s += "[杩斿洖娓告垙:look]\n";
	write(s);
	return 1;
}

