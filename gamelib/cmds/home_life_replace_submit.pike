#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string arg)
{
	string lifeType = "";
	int ind = 0;
	sscanf(arg,"%s %d",lifeType,ind);
	string re = "";
	re += "浣犵‘璁よ鏇挎崲鍚楋紵\n";
	re += "[纭:home_life_add "+ lifeType +" "+ ind +"]\n";
	re += "[杩斿洖:home_life_detail "+ lifeType +" " +ind +"]";
	write(re);
	return 1;
}
