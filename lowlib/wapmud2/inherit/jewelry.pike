#include <globals.h>
#include <wapmud2/include/wapmud2.h>
inherit MUD_JEWELRY;
inherit WAP_F_VIEW_LINKS;
inherit WAP_F_VIEW_VALUE;
inherit WAP_F_VIEW_PICTURE;
//特殊任务物品可以重载此方法，变为不可装备状态
string query_inventory_links(void|int count)
{
	string base_links = ::query_inventory_links(count);
	string target_link;
	string other_link;

	if(!equiped){
		target_link = "[戴上:wear "+name+" "+count+"]";
		other_link = "[脱下:unwear "+name+" "+count+"]";
	}
	else{
		target_link = "[脱下:unwear "+name+" "+count+"]";
		other_link = "[戴上:wear "+name+" "+count+"]";
	}

	// 循环清除所有 target_link 和 other_link
	while(search(base_links, target_link) >= 0) {
		base_links = replace(base_links, target_link, "");
	}
	while(search(base_links, other_link) >= 0) {
		base_links = replace(base_links, other_link, "");
	}

	return base_links + target_link;
}
