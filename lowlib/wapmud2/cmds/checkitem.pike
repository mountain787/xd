#include <command.h>
#include <wapmud2/include/wapmud2.h>
int main(string arg)
{
	string name=arg;
	int count;
	sscanf(arg,"%s %d",name,count);
	object ob=present(name,environment(this_player()),count);
	if(ob){
		string s=ob->query_name_cn()+"\n";
		s+=ob->query_picture_url()+"\n";
		if(ob->query_item_type()=="weapon"||ob->query_item_type()=="single_weapon"||ob->query_item_type()=="double_weapon"||ob->query_item_type()=="armor"||ob->query_item_type()=="decorate"||ob->query_item_type()=="jewelry")
			s+=ob->query_content();
		s+=ob->query_desc();
		if(ob->query_item_type()=="source")
			s+=ob->query_inventory_links(count)+"\n";
		else
			s+="[鎹¤捣:get "+ob->query_name()+" "+count+"]\n";
		s+="[杩斿洖:items]\n";
		s+="[杩斿洖娓告垙:look]\n";
		write(s);
	}
	else{
		string s = "";
		s+= "娌℃湁杩欎釜鐗╁搧\n";
		s+="[杩斿洖:items]\n";
		s+="[杩斿洖娓告垙:look]\n";
		write(s);
	}
	return 1;
}
