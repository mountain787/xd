#include <globals.h>

int main(string arg)
{
	object player =this_player();
	string s="";
	s += "杈撳叆涓枃鍑洪敊锛乗n1.鍙兘鎮ㄨ緭鍏ヤ簡鐗规畩瀛楃銆俓n2.鍙兘鏄墜鏈哄瀷鍙烽棶棰榎n";
	s += "[杩斿洖:look]\n";
	write(s);
	Stdio.append_file(ROOT+"/log/char_error.log",arg+"\n");
	return 1;
}
