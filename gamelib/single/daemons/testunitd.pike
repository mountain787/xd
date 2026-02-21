#!/usr/bin/env pike
/**
 * 单元测试守护进程
 */

#include <globals.h>
#include <gamelib/include/gamelib.h>

inherit LOW_DAEMON;

// 运行测试
void run_tests()
{
	werror("\n========== 运行测试 ==========\n");

	// 测试房间编译 - congxianzhenguangchang
	werror("\n[测试] 编译房间 congxianzhenguangchang\n");
	string room_path = ROOT + "/gamelib/d/congxianzhen/congxianzhenguangchang";
	mixed err = catch {
		program p = (program)room_path;
		if (p) {
			werror("  ✓ 编译成功!\n");
			// 尝试创建对象
			object room = p();
			if (room) {
				werror("  ✓ 对象创建成功! name_cn=%s\n", room->name_cn);
			} else {
				werror("  ✗ 对象创建返回 NULL\n");
			}
		} else {
			werror("  ✗ 编译返回 NULL\n");
		}
	};
	if (err) {
		werror("  ✗ 错误: %s\n", describe_error(err));
	}

	// 测试房间编译 - yuhuacunguangchang
	werror("\n[测试] 编译房间 yuhuacunguangchang\n");
	room_path = ROOT + "/gamelib/d/jinaodao/yuhuacunguangchang";
	err = catch {
		program p = (program)room_path;
		if (p) {
			werror("  ✓ 编译成功!\n");
			// 尝试创建对象
			object room = p();
			if (room) {
				werror("  ✓ 对象创建成功! name_cn=%s\n", room->name_cn);
			} else {
				werror("  ✗ 对象创建返回 NULL\n");
			}
		} else {
			werror("  ✗ 编译返回 NULL\n");
		}
	};
	if (err) {
		werror("  ✗ 错误: %s\n", describe_error(err));
		werror("  ✗ 回溯:\n%s\n", describe_backtrace(err));
	}

	werror("\n========== 测试完成 ==========\n");
}

protected void create()
{
	werror("[TESTUNITD] 单元测试守护进程启动\n");
	call_out(run_tests, 3);
}
