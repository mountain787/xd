string links;
string inventory_links;

// 自动去重：对于相同命令的链接，只保留最后一个
// 使用 catch 确保任何错误都不会影响原有功能
private string safe_deduplicate(string links_str) {
	if(!links_str || sizeof(links_str) == 0) {
		return links_str;
	}

	mixed err = catch {
		// 检测是否有重复链接
		mapping(string:int) link_counts = ([]);
		mapping(string:string) last_link = ([]);
		int pos = 0;

		while(pos < sizeof(links_str)) {
			int start = search(links_str, "[", pos);
			if(start < 0) break;

			int end = search(links_str, "]", start);
			if(end < 0) break;

			string link_full = links_str[start..end];
			int colon = search(link_full, ":");
			if(colon > 0 && colon < sizeof(link_full) - 1) {
				// 提取命令部分（冒号后的第一个词）
				string cmd_part = link_full[colon+1..];
				int space = search(cmd_part, " ");
				if(space > 0) {
					string cmd_key = cmd_part[0..space-1];
					link_counts[cmd_key]++;
					last_link[cmd_key] = link_full;
				}
			}
			pos = end + 1;
		}

		// 检查是否有重复
		int has_dup = 0;
		foreach(values(link_counts), int c) {
			if(c > 1) { has_dup = 1; break; }
		}

		// 没有重复，直接返回
		if(!has_dup) {
			return links_str;
		}

		// 有重复，构建去重结果
		string result = "";
		foreach(values(last_link), string l) {
			result += l;
		}
		return result;
	};

	if(err) {
		// 出错时返回原字符串
		return links_str;
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
		return safe_deduplicate(links_str);
	}
	return "";
}
