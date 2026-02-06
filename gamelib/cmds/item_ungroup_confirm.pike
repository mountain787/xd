#include <command.h>
#include <gamelib/include/gamelib.h>
//澶嶆暟鐗╁搧鍒嗙粍
int main(string arg)
{
	object me = this_player();
	string s = "";
	string num_s = "";
	string name = "";
	int count = 0;
	int num = 0;
	//[item_ungroup_confirm linglongyu 0  no=1]
	sscanf(arg,"%s %d %s",name,count,num_s);
	werror("----num_s=["+num_s+"]\n");
	sscanf(num_s,"no=%d",num);
	werror("----num=["+num+"]\n");
	object ob = present(name,me,count);
	if(ob){
		if(num>=1 && num<ob->amount){
			me->remove_combine_item(ob->query_name(),num);
			string file_path = file_name(ob);
			object ob_new = clone((file_path/"#")[0]);
			ob_new->amount = num;
			ob_new->move(me);
			s += "鎮ㄥ凡缁忔垚鍔熷皢璇ョ墿鍝佸垎缁刓n";
		}
		else{
			s += "杈撳叆鐨勬暟瀛椾笉姝ｇ‘\n";
		}
	}
	else{
		s += "浣犲寘閲屾病鏈夎繖鏍风殑鐗╁搧\n";
	}
	s += "[杩斿洖娓告垙:look]\n";
	write(s);
	return 1;
}
