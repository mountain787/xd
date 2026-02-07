#include <globals.h>
int main(string arg)
{
	Stdio.append_file("/tmp/xiand_conn_debug.log", "========flush_filter.pike main called==========\n");
	flush_filter();
	Stdio.append_file("/tmp/xiand_conn_debug.log", "========flush_filter.pike main end==========\n");
	return 1;
}
