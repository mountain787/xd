#include <command.h>
#include <wapmud2/include/wapmud2.h>
#include <lowlib.h>
#define PAGESIZE 6000
#define BYTESPERLINK 100

mapping load_bytes(string name,int pos,int len)
{
	string text;
	string header="";
	string footer="";

	string who,fun;
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== load_bytes() called: name="+name+" pos="+pos+" len="+len+"\n");
	if(sscanf(name,"%s/%s",who,fun)!=2){
		Stdio.append_file("/tmp/xiand_debug_flow.log", "=== load_bytes: sscanf failed\n");
		return 0;
	}
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== load_bytes: who="+who+" fun="+fun+"\n");
	if(who=="_player"){
		object player=this_player();
		Stdio.append_file("/tmp/xiand_debug_flow.log", "=== load_bytes: player="+sprintf("%O", player)+"\n");
		if(player!=0){
			//spliter - try both direct access and query function
			Stdio.append_file("/tmp/xiand_debug_flow.log", "=== load_bytes: trying `->(player, fun)\n");
			mixed f=`->(player,fun);
			Stdio.append_file("/tmp/xiand_debug_flow.log", "=== load_bytes: f="+sprintf("%O", f)+"\n");
			if(!f && player["query_spliter"]){
				Stdio.append_file("/tmp/xiand_debug_flow.log", "=== load_bytes: trying player->query_spliter()\n");
				f=player->query_spliter();
				Stdio.append_file("/tmp/xiand_debug_flow.log", "=== load_bytes: f from query_spliter="+sprintf("%O", f)+"\n");
			}
			string whole;
			if(functionp(f)){
				Stdio.append_file("/tmp/xiand_debug_flow.log", "=== load_bytes: f is function\n");
				whole=f();
			}
			else if(mappingp(f)){
				Stdio.append_file("/tmp/xiand_debug_flow.log", "=== load_bytes: f is mapping\n");
				whole=f["text"];
				header=f["header"];
				footer=f["footer"];
			}
			Stdio.append_file("/tmp/xiand_debug_flow.log", "=== load_bytes: whole="+sprintf("%.100O", whole)+" header="+sprintf("%.100O", header)+" footer="+sprintf("%.100O", footer)+"\n");
			if(whole){
				int whole_size=sizeof(whole);
				for(int j=whole_size-1;j>=0;j--){
					if(whole[j]=='\n'||whole[j]==' '||whole[j]=='\r'){
						whole=whole[0..j-1];
					}
					else{
						break;
					}
				}
				text=whole[pos..pos+len-1];
			}
		}
	}
	else if(who=="_env"){
		object env=environment(previous_object());
		if(env!=0){
			mixed f=`->(env,fun);
			string whole;
			if(functionp(f)){
				whole=f();
			}
			else if(mappingp(f)){
				whole=f["text"];
				header=f["header"];
				footer=f["footer"];
			}
			if(whole){
				int whole_size=sizeof(whole);
				for(int j=whole_size-1;j>=0;j--){
					if(whole[j]=='\n'||whole[j]==' '||whole[j]=='\r'){
						whole=whole[0..j-1];
					}
					else{
						break;
					}
				}
				text=whole[pos..pos+len-1];
			}
		}
	}
	return (["header":header,"text":text,"footer":footer]);
}

int view_file(string name,int pos,int ppos)
{
	string text;
	string header;
	string footer;
	int len;
	int i;
	int last_pos;
	int last_len;
	string path="";
	int last=-1;
	int eof=0;
	int pair=0;
	int eol=0;
	int maxlen;
	int should_sub=0;
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer.view_file() called: name="+name+" pos="+pos+" ppos="+ppos+"\n");
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer: EFUNSD="+sprintf("%O", EFUNSD)+"\n");
	mapping m=load_bytes(name,pos,PAGESIZE);
	if(m){
		text=m["text"]+"\n";
		header=m["header"];
		footer=m["footer"];
	}
	//头部
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer: calling write for header, header="+sprintf("%.100s", header)+"\n");
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer: about to call EFUNSD->write\n");
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer: EFUNSD="+sprintf("%O", EFUNSD)+"\n");
	if(EFUNSD){
		Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer: EFUNSD exists, calling write\n");
		EFUNSD->write(header);
		Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer: EFUNSD->write returned\n");
	}
	else{
		Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer: ERROR! EFUNSD is null/0\n");
	}
	if(text==0){
		Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer: text is 0, returning\n");
		return 0;
	}
	if(sizeof(text)<PAGESIZE)
		eof=1;
	maxlen=PAGESIZE;
	int found_semicolon;
	int sum=0;
	for(i=0;i<sizeof(text)-1&&sum<maxlen;i++,sum++){
		should_sub++;
		if(text[i]>127){
			i++;
			sum++;
		}
		else if(text[i]=='['){
			pair=i;
			found_semicolon=0;
		}
		else if(text[i]==':'){
			found_semicolon=1;
		}
		else if(text[i]==']'){
			if(found_semicolon){
				sum+=BYTESPERLINK;
			}
			pair=0;
		}
		else if(text[i]=='\n'||text[i]=='\r'){
			if(i>0&&(text[i-1]=='\n'||text[i-1]=='\r'))
				text[i]=' ';
			else
				text[i]='\n';
			eol=i;
		}
	}
	if(pair){
		i=pair;
	}
	len=i;
	if(eof&&len!=sizeof(text)&&len!=sizeof(text)-1){
		eof=0;
	}
	else if(eof&&len==sizeof(text)-1){
		len=sizeof(text);
	}
	if(text!=""){
		text=text[0..len-1];
		//中部内容
		Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer: calling write for text, size="+sizeof(text)+"\n");
		EFUNSD->write(text+"\n");
		if(!eof){
			Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer: calling write for next page link\n");
			EFUNSD->write("[下一页:_explorer "+name+" "+(pos+len)+" "+ppos+"]\n");
		}
	}
	if(pos!=0){
		if(pos>PAGESIZE){
			last_pos=pos-PAGESIZE;
			last_len=PAGESIZE;
		}
		else{
			last_pos=0;
			last_len=pos;
		}
		m=load_bytes(name,last_pos,last_len);
		if(m){
			text=m["text"]+"\n";
		}
		pair=0;
		eol=0;
		maxlen=PAGESIZE;
		sum=0;
		for(i=0;i<sizeof(text)-1&&sum<maxlen;i++,sum++){
			found_semicolon=0;
			should_sub++;
			if(text[sizeof(text)-1-i]>127){
				i++;
				sum++;
			}
			else if(text[sizeof(text)-1-i]==']'){
				pair=i;
			}
			else if(text[sizeof(text)-1-i]==':'){
				found_semicolon=1;
				should_sub=0;
			}
			else if(text[sizeof(text)-1-i]=='['){
				if(text[sizeof(text)-1-i+1]!='<'){
					sum+=BYTESPERLINK;
				}
				pair=0;
				if(sum>=maxlen)
					break;
			}
			else if(text[sizeof(text)-1-i]=='\n'||text[sizeof(text)-1-i]=='\r'){
				eol=i;
			}

		}
		if(pair){
			if(i==sizeof(text)-1&&text[0]=='['){
				pair=0;
			}
			else{
				i=pair;
			}
		}
		last_len=i;
		last_pos=pos-i;
		if(last_pos==1||last_pos==-1)
			last_pos=0;
		Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer: calling write for prev page link\n");
		EFUNSD->write("[上一页:_explorer "+name+" "+last_pos+" "+ppos+"]\n");
	}
	//尾部信息
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer: calling write for footer\n");
	EFUNSD->write(footer);
	return 1;
}
int main(string arg)
{
	string name,name_cn;
	int pos,ppos;
	int i;
	array(string) files;
	array(string) names;
	array(string) hide=({});
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer.pike main() called: arg="+arg+"\n");
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer.pike: this_player="+sprintf("%O", this_player())+"\n");
	if(sscanf(arg,"%s %d %d",name,pos,ppos)!=3)
		if(sscanf(arg,"%s %d",name,pos)!=2)
			name=arg;
	Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer.pike: name="+name+" pos="+pos+" ppos="+ppos+"\n");
	if(name[0]=='_'){
		Stdio.append_file("/tmp/xiand_debug_flow.log", "=== _explorer.pike: calling view_file\n");
		return view_file(name,pos,ppos);
	}
	return 1;
}
