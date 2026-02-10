/* wiz_cd.pike
 * 鏀瑰彉褰撳墠璺緞
 */
#include <command.h>
#include <wapmud2/include/wapmud2.h>
int main(string|zero arg)
{
	//if( this_player()->query_name()!="zhubin"||this_player()->query_name()!="wangyan" )
	//	return 1;
	if(!arg)
		arg="..";
	cd(arg);
	write("褰撳墠璺緞涓猴細 %s \n",getcwd());
	return 1;
}
