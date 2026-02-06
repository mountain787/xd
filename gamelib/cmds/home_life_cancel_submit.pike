#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	string lifeType = "";
	int ind = 0;
	sscanf(arg,"%s %d",lifeType,ind);
	string re = "";
	re += "浣犵‘璁よ杩欎箞鍋氬悧锛焅n";
	re += "[纭:home_life_cancel_confirm "+ lifeType+" "+ ind +"]\n";
	re += "[杩斿洖:home_life_detail "+ lifeType +" "+ind +"]";
	write(re);
	return 1;
}
