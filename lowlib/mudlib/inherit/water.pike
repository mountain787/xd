#include <globals.h>
#include <mudlib/include/mudlib.h>
//鐗╁搧涓殑楗枡
inherit MUD_COMBINE_ITEM;
//inherit MUD_ITEM;
//鍏锋湁楗枡鐨勫睘鎬ф柟娉曞拰缁ф壙鍏崇郴
inherit MUD_F_DRINKED;
private string initer=((set_item_type("water")),"");
