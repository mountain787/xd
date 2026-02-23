#include <globals.h>
#include <wapmud2/include/wapmud2.h>
inherit MUD_WEAPON;
inherit WAP_F_VIEW_PICTURE;
inherit WAP_F_VIEW_LINKS;
inherit WAP_F_VIEW_VALUE;
//特殊任务物品可以重载此方法，变为不可装备状态
string query_inventory_links(void|int count)
{
	string base_links = ::query_inventory_links(count);
	string target_link;
	string other_link;

	if(!equiped){
		target_link = "[装配:wield "+name+" "+count+"]";
		other_link = "[放下:unwield "+name+" "+count+"]";
	}
	else{
		target_link = "[放下:unwield "+name+" "+count+"]";
		other_link = "[装配:wield "+name+" "+count+"]";
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
string query_extra_links(void|int count)
{
	return "";
}
