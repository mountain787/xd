// 在游戏环境中测试房间编译 - yuhuacunguangchang
inherit ROOM;

protected void create()
{
	werror("\n========== 测试房间编译 ==========\n");

	string room_path = ROOT + "/gamelib/d/jinaodao/yuhuacunguangchang";

	werror("步骤1: 尝试编译房间程序...\n");
	mixed err = catch {
		program room_prog = (program)room_path;
		if (room_prog) {
			werror("  ✓ 编译成功! program=%O\n", room_prog);
		} else {
			werror("  ✗ 编译返回 NULL\n");
			return;
		}
	};
	if (err) {
		werror("  ✗ 编译失败!\n");
		werror("    错误: %s\n", describe_error(err));
		werror("    回溯:\n%s\n", describe_backtrace(err));
		return;
	}

	werror("\n步骤2: 尝试创建房间对象...\n");
	err = catch {
		object room = room_prog();
		if (room) {
			werror("  ✓ 对象创建成功!\n");
			werror("    name_cn=%s\n", room->name_cn);
		} else {
			werror("  ✗ 对象创建返回 NULL\n");
		}
	};
	if (err) {
		werror("  ✗ 对象创建失败!\n");
		werror("    错误: %s\n", describe_error(err));
		werror("    回溯:\n%s\n", describe_backtrace(err));
	}

	werror("\n========== 测试完成 ==========\n");
}
