#include <command.h>
#include <gamelib/include/gamelib.h>

int main(string|zero arg)
{
	object me = this_player();
	string s = "";
	string current_name = me->query_name_cn(1); // 获取真实名字，不含VIP后缀

	// 检查是否是无名开头的名字 (search返回0表示找到匹配)
	if(search(current_name, "无名") != 0) {
		s = "你的名字是【" + current_name + "】，不能修改。\n";
		s += "只有名字以\"无名\"开头的玩家才能修改名字。\n";
		s += "[返回游戏:look]\n";
		write(s);
		return 1;
	}

	// 没有参数，显示提示
	if(!arg || arg=="") {
		s = "======== 修改名字 ========\n";
		s += "你当前的名字是：【" + current_name + "】\n";
		s += "\n";
		s += "请输入你的新名字（2-6个中文字符，或2-12个英文字母/数字）：\n";
		s += "[set_name ...]\n";
		s += "\n";
		s += "注意：名字一旦选定无法更改，请仔细选取！\n";
		s += "[返回游戏:look]\n";
		write(s);
		return 1;
	}

	// 去除空格和%20
	if(search(arg, " ")!=-1) {
		array(string) t=arg/" ";
		if(sizeof(t)==2&&t[0]==t[1]) {
			arg=t[0];
		}
	}
	arg=replace(arg, (["%20":""]));

	// 检查名字长度
	if(sizeof(arg) < 2 || sizeof(arg) > 12) {
		s = "名字长度必须在2-12个字符之间。\n";
		s += "[set_name ...]\n";
		s += "[返回游戏:look]\n";
		write(s);
		return 1;
	}

	// 验证名字内容
	int has_chinese = 0;
	int has_ascii = 0;

	for(int i=0;i<sizeof(arg);i++) {
		if(arg[i]>=0&&arg[i]<=127) {
			// ASCII字符
			if(arg[i]>='a'&&arg[i]<='z'||arg[i]>='A'&&arg[i]<='Z'||arg[i]>='0'&&arg[i]<='9') {
				has_ascii = 1;
			} else {
				s = "名字只能包含中文、英文字母或数字。\n";
				s += "[set_name ...]\n";
				s += "[返回游戏:look]\n";
				write(s);
				return 1;
			}
		} else {
			// 中文字符（UTF-8多字节）
			has_chinese = 1;
		}
	}

	// 如果混合中文和ASCII，检查是否合理
	if(has_chinese && has_ascii) {
		if(sizeof(arg) > 18) {
			s = "名字过长，请缩短一些。\n";
			s += "[set_name ...]\n";
			s += "[返回游戏:look]\n";
			write(s);
			return 1;
		}
	}

	// 纯中文名字检查（2-6个汉字）
	if(has_chinese && !has_ascii) {
		// UTF-8中每个汉字占3个字节
		int char_count = sizeof(arg) / 3;
		if(char_count < 2 || char_count > 6) {
			s = "中文名字必须是2-6个汉字。\n";
			s += "[set_name ...]\n";
			s += "[返回游戏:look]\n";
			write(s);
			return 1;
		}
	}

	// 检查是否包含敏感词
	array(string) forbidden_words = ({
		"管理员", "客服", "系统", "GM", "gm",
		"官方", "管理", "ROOT", "root",
		"ADMIN", "admin", "游戏", "运营"
	});

	for(int i=0;i<sizeof(forbidden_words);i++) {
		string word = forbidden_words[i];
		if(search(arg, word) != -1) {
			s = "名字包含不允许的词语，请重新选择。\n";
			s += "[set_name ...]\n";
			s += "[返回游戏:look]\n";
			write(s);
			return 1;
		}
	}

	// 设置新名字
	me->name_cn = arg;
	me->set_original_name_cn(arg); // 保存为原始名称，防止VIP后缀累积

	s = "======== 恭喜！ ========\n";
	s += "你的名字已修改成功！\n";
	s += "新名字：【" + arg + "】\n";
	s += "\n";
	s += "祝你游戏愉快！\n";
	s += "[返回游戏:look]\n";
	write(s);

	return 1;
}
