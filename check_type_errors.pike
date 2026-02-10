#!/usr/bin/env pike
// 检查所有 Pike 文件的类型错误
// 使用 Pike 9 的严格模式编译检查

constant ROOT = "/usr/local/games/xiand";

int errors = 0;
int checked = 0;

void check_file(string path)
{
	checked++;
	mixed err = catch {
		program p = (program)path;
	};
	if (err) {
		errors++;
		werror("✗ %s\n", path);
		// 获取错误描述和回溯
		string desc = describe_error(err);
		array bt = err[0]; // backtrace
		if (arrayp(bt) && sizeof(bt) > 0) {
			werror("  错误: %s\n", desc);
			// 尝试提取文件和行号
			for (int i = 0; i < sizeof(bt); i++) {
				if (arrayp(bt[i]) && sizeof(bt[i]) >= 3) {
					string file = bt[i][0];
					int line = bt[i][1];
					if (file && search(file, ".pike") != -1) {
						werror("  位置: %s:%d\n", file, line);
					}
				}
			}
		}
	}
}

void main(int argc, array(string) argv)
{
	werror("========== 检查 Pike 文件类型错误 ==========\n");

	// 获取所有 .pike 文件
	array(string) files = get_dir(ROOT + "/gamelib/**/*.pike");
	if (!files) files = ({});

	// 手动搜索一些关键目录
	array(string) dirs = ({
		ROOT + "/gamelib/cmds",
		ROOT + "/gamelib/d",
		ROOT + "/gamelib/clone",
		ROOT + "/gamelib/single/daemons",
	});

	foreach (dirs, string dir) {
		array(string) dir_files = get_dir(dir + "/*.pike");
		if (dir_files) {
			foreach (dir_files, string f) {
				files += ({ dir + "/" + f });
			}
		}

		// 递归子目录
		array(string) subdirs = get_dir(dir + "/*");
		if (subdirs) {
			foreach (subdirs, string sd) {
				string subpath = dir + "/" + sd;
				if (Stdio.is_dir(subpath)) {
					array(string) subfiles = get_dir(subpath + "/*.pike");
					if (subfiles) {
						foreach (subfiles, string sf) {
							files += ({ subpath + "/" + sf });
						}
					}
				}
			}
		}
	}

	werror("找到 %d 个 .pike 文件\n", sizeof(files));

	// 检查每个文件
	foreach (files, string f) {
		check_file(f);
	}

	werror("\n========== 检查完成 ==========\n");
	werror("检查文件: %d\n", checked);
	werror("错误文件: %d\n", errors);

	exit(errors > 0 ? 1 : 0);
}
