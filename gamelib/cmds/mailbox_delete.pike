#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	string s = "";
	int n;
	sscanf(arg,"%d",n);
	this_player()->delete_mail(n);
	s+="鎴愬姛鍒犻櫎璇ラ偖浠讹紝璇疯繑鍥烇紒\n";
	s+="[返回:mailbox]\n";
	write(s);
	//this_player()->write_view(WAP_VIEWD["/mailbox_delete"]);
	return 1;
}


