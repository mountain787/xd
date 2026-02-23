string links;
string inventory_links;

// 智能去重：对于相同命令的链接，只保留最后一个
private string deduplicate_links(string links_str) {
	if(!links_str || sizeof(links_str) == 0) {
		return "";
	}

	// 检测是否有重复：统计每个命令动词出现的次数
	mapping(string:int) cmd_count = ([]);
	mapping(string:string) last_links = ([]);
	int pos = 0;

	while(pos < sizeof(links_str)) {
		int start = search(links_str, "[", pos);
		if(start < 0) break;

		int end = search(links_str, "]", start);
		if(end < 0) break;

		string link = links_str[start..end];
		int colon = search(link, ":");
		if(colon > 0) {
			string cmd = link[colon+1..];
			int space = search(cmd, " ");
			if(space > 0) {
				string cmd_verb = cmd[0..space-1];
				cmd_count[cmd_verb]++;
				last_links[cmd_verb] = link;  // 保存最后一个链接
			}
		}
		pos = end + 1;
	}

	// 如果没有重复，直接返回原字符串
	int has_duplicate = 0;
	foreach(cmd_count[string cmd]; int count) {
		if(count > 1) {
			has_duplicate = 1;
			break;
		}
	}
	if(!has_duplicate) {
		return links_str;
	}

	// 有重复，构建去重后的结果：每个命令只保留最后一个
	string result = "";
	foreach(indices(last_links), string cmd) {
		result += last_links[cmd];
	}
	return result;
}

string query_links(void|int count){
	if(links){
		return replace(links,"%d",""+count);
	}
	return "";
}

string query_inventory_links(void|int count){
	if(inventory_links){
		string links_str = replace(inventory_links,"%d",""+count);
		// 自动检测并去重
		return deduplicate_links(links_str);
	}
	return "";
}
