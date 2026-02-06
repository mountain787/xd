#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
    this_player()->write_view(WAP_VIEWD["/qqlist_admin_new"],0,0,arg);      
    return 1;
	/*
	object me = this_player();
	string desc="";
	if(!arg||arg==""||sizeof(arg)==0){
		desc += "鎮ㄨ緭鍏ョ殑缁勫悕涓嶆纭紝璇烽噸鏂拌緭鍏ワ細\n";	
		desc+="缁勫悕[string zm:...]\n";
		desc+="[submit 鎻愪氦:qqlist_admin ...]\n";
		desc+="[杩斿洖:qqlist_admin_groups]\n";
		write(desc);
		return 1;
	}
	else{
	
	}
	desc+="[杩斿洖:qqlist_admin_groups]\n";
	write(desc);
	return 1;
	*/
}
