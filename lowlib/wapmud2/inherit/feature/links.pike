string links;
string inventory_links;

// 智能去重：对于相同命令的链接，只保留最后一个
private string deduplicate_links(string links_str) {
	if(!links_str || sizeof(links_str) == 0) {
		return "";
	}

	// 查找所有链接模式 [...:command ...]
	// 记录每种命令最后出现的位置
	mapping(string:int) last_pos = ([]);
	int pos = 0;

	while(pos < sizeof(links_str)) {
		int start = search(links_str, "[", pos);
		if(start < 0) break;

		int end = search(links_str, "]", start);
		if(end < 0) break;

		string link = links_str[start..end];
		// 提取命令部分（冒号后面的第一个单词）
		int colon = search(link, ":");
		if(colon > 0) {
			// 获取命令（如 "unwear xxx 0"）
			string cmd = link[colon+1..];
			// 提取命令动词（第一个空格前的部分）
			int space = search(cmd, " ");
			if(space > 0) {
				string cmd_verb = cmd[0..space-1];
				// 对于相同命令动词，记录最后位置
				last_pos[cmd_verb] = end + 1;
			}
		}
		pos = end + 1;
	}

	// 如果只有一种命令或没有重复，直接返回
	if(sizeof(last_pos) <= 1) {
		return links_str;
	}

	// 构建结果：只保留每种命令的最后一个
	string result = "";
	array(string) verbs = indices(last_pos);
	// 按位置排序
	array(int) positions = values(last_pos);
	sort(positions);

	pos = 0;
	foreach(positions; int p) {
		// 找到对应这个位置的命令
		foreach(indices(last_pos), string verb) {
			if(last_pos[verb] == p) {
				// 从 links_str 中提取这个链接
				int link_start = search(links_str, "[", pos);
				while(link_start >= 0 && link_start < p) {
					int link_end = search(links_str, "]", link_start);
					if(link_end == p - 1) {
						string link = links_str[link_start..link_end];
						result += link;
					}
					link_start = search(links_str, "[", link_start + 1);
				}
				break;
			}
		}
	}

	// 保留所有非链接的内容
	// 简化方案：如果检测到大量重复，返回清理后的版本
	if(result != "" && sizeof(result) < sizeof(links_str) / 2) {
		return result;
	}
	return links_str;
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
		// 如果内容过长（超过500字符），启用去重
		if(sizeof(links_str) > 500) {
			return deduplicate_links(links_str);
		}
		return links_str;
	}
	return "";
}
