#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string|zero arg)
{
	string s,group;
	s=arg;
	string t = "";
	sscanf(arg,"%s %s",s,group);
	if(group==0){
		t="组名涓嶈兘涓虹┖锛岃返回閲嶆柊閫夋嫨銆俓n";
	}
	else{
		t = this_player()->qqlist_group_insert(s,group)+"\n";
	}
	t+="[返回:my_qqlist]\n";
	t+="[返回游戏:look]\n";
	write(t);
	return 1;
}
