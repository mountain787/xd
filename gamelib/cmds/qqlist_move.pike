#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	string s,group;
	s=arg;
	string t = "";
	sscanf(arg,"%s %s",s,group);
	if(group==0){
		t="缁勫悕涓嶈兘涓虹┖锛岃杩斿洖閲嶆柊閫夋嫨銆俓n";
	}
	else{
		t = this_player()->qqlist_group_insert(s,group)+"\n";
	}
	t+="[杩斿洖:my_qqlist]\n";
	t+="[杩斿洖娓告垙:look]\n";
	write(t);
	return 1;
}
