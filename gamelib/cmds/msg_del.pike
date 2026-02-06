#include <command.h>
#include <gamelib/include/gamelib.h>

//鍒犻櫎鍏憡

int main(string arg)
{
	int id = (int)arg;
	string s = "";
	if(MSGD->msg_del(id)==1){
		s += "鍒犻櫎鎴愬姛锛乗n";
		MSGD->write_file();
	}
	else {
		s += "璇ュ叕鍛婁笉瀛樺湪锛乗n";
	}
	s += "\n";
	s += "[杩斿洖:msg_read admin old]\n";
	s += "[杩斿洖娓告垙:look]\n";
	write(s);
	return 1;
}
