#include <globals.h>
#include <wapmud2/include/wapmud2.h>
inherit MUD_ARMOR;
inherit WAP_F_VIEW_LINKS;
inherit WAP_F_VIEW_VALUE;
inherit WAP_F_VIEW_PICTURE;
//特殊任务物品可以重载此方法，变为不可装备状态
string query_inventory_links(void|int count)
{
	string base_links = ::query_inventory_links(count);
	string new_link;
	string old_link;

	if(!equiped){
		new_link = "[穿戴:wear "+name+" "+count+"]";
		old_link = "[脱下:unwear "+name+" "+count+"]";
	}
	else{
		new_link = "[脱下:unwear "+name+" "+count+"]";
		old_link = "[穿戴:wear "+name+" "+count+"]";
	}

	// 调试日志
	werror("[DEBUG] query_inventory_links: name=%s equiped=%d base_links_len=%d\n",
		name, equiped, sizeof(base_links));
	if(sizeof(base_links) > 200) {
		werror("[DEBUG] base_links (first 200): %s\n", base_links[0..199]);
	}

	// 移除旧的状态链接（避免穿戴/脱下按钮同时存在）
	if(search(base_links, old_link) >= 0){
		werror("[DEBUG] Removing old_link: %s\n", old_link);
		base_links = replace(base_links, old_link, "");
	}

	// 检查新链接是否已存在，避免重复
	if(search(base_links, new_link) < 0){
		werror("[DEBUG] Adding new_link: %s\n", new_link);
		base_links += new_link;
	} else {
		werror("[DEBUG] Link already exists: %s\n", new_link);
	}

	return base_links;
}
