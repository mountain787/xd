#!/usr/bin/env pike
// 测试房间编译

constant ROOT = "/usr/local/games/xiand";

void main()
{
	werror("\n========== 测试房间编译 ==========\n");
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
			return;
		}
	};
	if (err) {
		werror("  ✗ 编译失败!\n");
		werror("  错误: %s\n", describe_error(err));
		return;
	}

	// 尝试创建对象
	werror("\n步骤2: 创建对象...\n");
	err = catch {
		program p = (program)room_path;
		object room = p();
		if (room) {
			werror("  ✓✓✓ 对象创建成功! ✓✓✓\n");
			werror("  name_cn: %s\n", room->name_cn);
		} else {
			werror("  ✗ 对象创建返回 NULL\n");
		}
	};
	if (err) {
		werror("  ✗ 创建失败!\n");
		werror("  错误: %s\n", describe_error(err));
	}

	werror("\n========== 完成 ==========\n");
}
