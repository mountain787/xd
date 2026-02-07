#include <command.h>
#include <wapmud2/include/wapmud2.h>
int main(string arg)
{
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== init.pike main() called: arg="+arg+"\n");
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== init.pike: this_player="+sprintf("%O", this_player())+"\n");
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== init.pike: in_combat="+sprintf("%O", this_player()->in_combat)+"\n");
	if(this_player()->in_combat){
		this_player()->reset_view(WAP_VIEWD["/fight"]);
		Stdio.append_file("/tmp/xiand_debug_flow.log", "=== init.pike: calling write_view for combat\n");
		this_player()->write_view();
	}
	else{
		this_player()->reset_view(WAP_VIEWD["/look"]);
		Stdio.append_file("/tmp/xiand_debug_flow.log", "=== init.pike: calling write_view for normal\n");
		this_player()->write_view();
	}
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== init.pike: write_view returned\n");
	return 1;
}
