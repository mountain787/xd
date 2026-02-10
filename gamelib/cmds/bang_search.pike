#include <command.h>
#include <gamelib/include/gamelib.h>
int main(string|zero arg)
{
	object me = this_player();
	string s = "甯淳鍒楄〃:\n(鍦ㄨ繖閲岋紝鐐瑰嚮甯悕鏌ョ湅璇︾粏淇℃伅)\n";
	if(me->bangid != 0){
		s += "浣犲凡缁忓湪鍙︿竴涓府娲鹃噷浜嗭紝鏃犳硶鐢宠鍔犲叆鍏朵粬甯淳\n";
	}
	s += BANGD->query_bang_list(me);
	me->write_view(WAP_VIEWD["/emote"],0,0,s);
	return 1;
}
