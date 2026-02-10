// 简单编译测试
#include <globals.h>
#include <gamelib/include/gamelib.h>

inherit LOW_DAEMON;

void create()
{
	werror("\n========== 编译测试 ==========\n");

	string room_path = ROOT + "/gamelib/d/congxianzhen/congxianzhenguangchang";
	werror("房间: %s\n", room_path);

	// 尝试编译
	werror("\n步骤1: 编译...\n");
	mixed err = catch {
		program p = (program)room_path;
		if (p) {
			werror("  ✓ 编译成功!\n");
		} else {
			werror("  ✗ 编译返回 NULL\n");
		}
	};
	if (err) {
		werror("  ✗ 编译失败!\n");
		werror("  错误: %s\n", describe_error(err));
	}

	werror("\n========== 完成 ==========\n");
}
