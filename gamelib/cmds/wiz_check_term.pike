#include <command.h>
#include <gamelib/include/gamelib.h>
//鏌ョ湅鍓湰鍐呭
int main(string|zero arg)
{
	int num = TERMD->get_term_nums();
	write("now the num of term is "+num+"\n");
	return 1;
}
