#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string|zero arg)
{
    this_player()->write_view(WAP_VIEWD["/qqlist_admin_new"],0,0,arg);      
    return 1;
	/*
	object me = this_player();
	string desc="";
	if(!arg||arg==""||sizeof(arg)==0){
		desc += "鎮ㄨ緭鍏ョ殑组名涓嶆确认紝璇烽噸鏂拌緭鍏ワ細\n";	
		desc+="组名[string zm:...]\n";
		desc+="[submit 提交:qqlist_admin ...]\n";
		desc+="[返回:qqlist_admin_groups]\n";
		write(desc);
		return 1;
	}
	else{
	
	}
	desc+="[返回:qqlist_admin_groups]\n";
	write(desc);
	return 1;
	*/
}
