#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== look.pike main() called: arg="+arg+"\n");
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== look.pike: this_player="+sprintf("%O", this_player())+"\n");
	if(this_player()->sid=="5dwap"){
		int tmp = time() - (int)this_player()["/push/push_time"];
		if(tmp>=300){
			//tell_object(this_player(),"欢迎尝试仙道，您现在是游客身份，你的档案将不会被保存，欢迎点击注册一个正式帐号来体验仙道的乐趣。\n[免费注册:reg_account]\n");
			//return 1;
		}
	}
	if(this_player()->in_combat){
		Stdio.append_file("/tmp/xiand_debug_flow.log", "=== look.pike: in combat, reset_view to fight\n");
		this_player()->reset_view(WAP_VIEWD["/fight"]);
		this_player()->write_view();
	}
	else{
		Stdio.append_file("/tmp/xiand_debug_flow.log", "=== look.pike: normal, reset_view to look\n");
			this_player()->reset_view(WAP_VIEWD["/look"]);
		this_player()->write_view();
	}
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== look.pike: write_view returned\n");
	return 1;
}
