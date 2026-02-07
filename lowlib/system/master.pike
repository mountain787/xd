#include <globals.h>
program connect()
{
	Stdio.append_file("/tmp/xiand_conn_debug.log", "connect() called\n");
	Stdio.append_file("/tmp/xiand_conn_debug.log", "connect: LOW_LOGIN_OB="+LOW_LOGIN_OB+"\n");
	Stdio.append_file("/tmp/xiand_conn_debug.log", "connect: ROOT="+ROOT+"\n");
	Stdio.append_file("/tmp/xiand_conn_debug.log", "connect: SROOT="+SROOT+"\n");
	//werror("--------- system/master.pike is begin called ------------\n");
	program login_ob;
	mixed err;
	err = catch{
		Stdio.append_file("/tmp/xiand_conn_debug.log", "connect: trying to compile...\n");
		login_ob = (program)(LOW_LOGIN_OB);
		Stdio.append_file("/tmp/xiand_conn_debug.log", "connect: compiled successfully\n");
	};
	Stdio.append_file("/tmp/xiand_conn_debug.log", "connect: login_ob="+sprintf("%O", login_ob)+"\n");
	if (err) {
		Stdio.append_file("/tmp/xiand_conn_debug.log", "connect: ERROR="+sprintf("%O", err)+"\n");
		werror("It looks like someone is working on the player object.\n");
		master()->handle_error(err);
		destruct(this_object());
	}
	//werror("--------- system/master.pike is end called ------------\n");
	return login_ob;
}
array hosts_list;
void create(){
	hosts_list=filter(Stdio.read_file(SROOT+"/etc/hosts_list")/"\n",`!=,"");
}
string ip;
int port;
