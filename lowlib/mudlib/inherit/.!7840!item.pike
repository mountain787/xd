#include <globals.h>
#include <mudlib/include/mudlib.h>
inherit LOW_BASE;
inherit LOW_F_DBASE;
inherit MUD_F_HEARTBEAT;
protected mapping(int:string) m_rareLevel = ([
	0:"",
