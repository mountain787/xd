/* wiz_qge74hye
 * @author hps
 * 鍙互鐬棿绉诲姩
 * 鎸囦护鏍煎紡 wiz_qge74hye [鐜╁|鍦板浘鏂囦欢璺緞鍚峾NPC鏂囦欢璺緞鍚峕
 */
#include <command.h>
#include <gamelib/include/gamelib.h>
#define HOME "~/gamelib/d/congxianzhen/congxianzhenguangchang"

int main(string arg)
{
	object me=this_player();
	//if( this_player()->query_name()!="zhubin"||this_player()->query_name()!="wangyan" )	
	//	return 1;
	if(!arg)
		arg = HOME;
	object ob=find_player(arg);
	if(!ob) {
		if(arg&&sizeof(arg)>1&&arg[0]=='~'&&arg[1]=='/')
			arg=ROOT+arg[1..];
			ob=find_object(arg);
	}
	if(!ob) ob=find_object(arg);
	if(!ob) ob=load_object(arg);
	if(!ob){
		write("涓嶅瓨鍦ㄦ寚瀹氱殑鐗╀欢.\n");
		return 1;
	}
	if(ob->is_room){
		me->move(ob);
		write("%O \n",ob);
	}
	else
		if(environment(ob)){
			me->move(environment(ob));
			write("%O \n",environment(ob));
		}
	return 1;
}
