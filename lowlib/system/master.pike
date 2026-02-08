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
	// Load hosts list
	hosts_list=filter(Stdio.read_file(SROOT+"/etc/hosts_list")/"\n",`!=,"");

	// Load daemons from gamelib/single/daemons/
	werror("========================================\n");
	werror("[MASTER] Loading daemons from: "+ROOT+"/gamelib/single/daemons/\n");
	call_out(load_daemons, 2);
}

void load_daemons()
{
	array files = get_dir(ROOT+"/gamelib/single/daemons");
	werror("[MASTER] get_dir() returned %d files\n", sizeof(files));
	foreach(files,string s){
		mixed err = catch{
			werror("[MASTER] Loading daemon: %s\n", s);
			object ob=(object)(ROOT+"/gamelib/single/daemons/"+s);
			werror("[MASTER]   Loaded: %s -> %O\n", s, ob);
		};
		if(err) {
			werror("[MASTER] ERROR loading %s: %O\n", s, err);
		}
	}
	werror("[MASTER] All daemons loaded\n");
	werror("========================================\n");
}
string ip;
int port;
