// 检查房间文件
#include <globals.h>
#include <gamelib/include/gamelib.h>

inherit LOW_DAEMON;

protected void create()
{
	werror("\n========== 检查房间文件 ==========\n");

	string file_path = ROOT + "/gamelib/d/congxianzhen/congxianzhenguangchang";

	werror("测试房间: %s\n", file_path);

	// 尝试加载
	mixed err = catch {
		object room = load_object(file_path);
		if (room) {
			werror("✓✓✓ 房间加载成功! ✓✓✓\n");
			werror("  名称: %s\n", room->name_cn);
		} else {
			werror("✗ 房间加载返回 NULL\n");
		}
	};
	if (err) {
		werror("✗ 房间加载失败!\n");
		werror("  错误: %s\n", describe_error(err));
	}

	werror("\n========== 完成 ==========\n");
}
