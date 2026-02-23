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
	string new_link;

	if(!equiped){
		new_link = "[装配:wield "+name+" "+count+"]";
	}
	else{
		new_link = "[放下:unwield "+name+" "+count+"]";
	}

	// 如果已经有相同类型的链接，就不添加了
	if(search(base_links, new_link) >= 0) {
		return base_links;
	}

	return base_links + new_link;
}
string query_extra_links(void|int count)
{
	return "";
}
