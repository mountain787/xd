#include <globals.h>
inherit LOW_FILTER;

protected private string headerU=
"<wml> <head> <meta forua=\"true\" http-equiv=\"Cache-Control\" content=\"max-age=0\"/> </head>";
//static private string headerG="ContentType=text/vnd.wap.wml; charset=gb2312\nCharset=gb2312\n\n"
//"<?xml version=\"1.0\" encoding=\"gb2312\"?> <!DOCTYPE wml PUBLIC \"-//WAPFORUM//DTD WML 1.1//EN\" \"http://www.wapforum.org/DTD/wml_1.1.xml\"> <wml> <head> <meta forua=\"true\" http-equiv=\"Cache-Control\" content=\"max-age=0\"/> </head>";
protected private string headerG="ContentType=text/vnd.wap.wml; charset=utf-8\nCharset=utf-8\n\n"
"<?xml version=\"1.0\" encoding=\"utf-8\"?> <!DOCTYPE wml PUBLIC \"-//WAPFORUM//DTD WML 1.1//EN\" \"http://www.wapforum.org/DTD/wml_1.1.xml\"> <wml> <head> <meta forua=\"true\" http-equiv=\"Cache-Control\" content=\"max-age=0\"/> </head>";
protected private string footer=
"</wml>";

array(string) input;
string out;
protected void create()
{
	::create();
	input=({});
	out="";
}
string setup(string __url)
{
	url=__url; //url=/xiand/main.jsp
	return "";
}
string string_to_wap(string s)
{
	string out="";
	for(int i=0;i<sizeof(s);i++){
		if(s[i]>0&&s[i]<=127){
			out+=s[i..i];
		}
		else{
			out+=string_to_utf8(s[i..i]);
		}
	}
	return out;
}
string net_dead()
{
	//werror("\n555555555555555555555 wml.pike net_dead call 555555555555555555555555555555\n");
	string stimer="<card title=\""+decode(title)+"\">";
	/*
	if(this_player()->wml_timer_interval&&(this_player()->wml_timer_cmd||this_player()->wml_timer_url)){
		if(this_player()->wml_timer_cmd){
			if(this_player()["hide"])
				stimer="<card  title=\""+decode(title)+"\" ontimer=\""+url+"?_cmd="+replace(this_player()->hide(this_player()->wml_timer_cmd),([" ":"+","&":"&amp;"]))+"\"> <timer value=\""+this_player()->wml_timer_interval+"\"/>";
			else
				stimer="<card  title=\""+decode(title)+"\" ontimer=\""+url+"?_cmd="+this_player()->wml_timer_cmd+"\"> <timer value=\""+this_player()->wml_timer_interval+"\"/>";
		}
		else{
			stimer="<card  title=\""+decode(title)+"\" ontimer=\""+replace(this_player()->wml_timer_url,([" ":"+","&":"&amp;"]))+"\"> <timer value=\""+this_player()->wml_timer_interval+"\"/>";
		}
	}
	*/
	string s;
	s=string_to_wap(headerU+stimer+"<p>"+out+"</p></card>"+footer);
	input=({});
	out="";
	//werror("\n555555555555555555555 wml.pike net_dead end 555555555555555555555555555555\n");
	return s;
}
string process_input(string s)
{
	mixed err;
	err=catch{
		//s=utf8_to_string(s);//Locale.Charset.encoder("euc_cn")->feed(s)->drain();
		//s=Locale.Charset.encoder("euc_cn")->feed(s)->drain();
		s = decode(s);
	};
	if(err){
		s="charerror "+s;
	}
	if(sizeof(s)&&s[0]>='0'&&s[0]<='9'){
		int n;
		string tail="";
		sscanf(s,"%d %s",n,tail);
		if(this_player()["hidden"]){
			if(n<sizeof(this_player()->hidden))
				s=this_player()->hidden[n]+tail;
			else 
				s="look";
		}
	}
	return s;
}
private string decode(string s,void|int skip_filter)
{
	string out="";
	int last_char;
	for(int i=0;i<sizeof(s);i++){
		if(!skip_filter&&s[i]=='%'){
			if(i<sizeof(s)-1){
				if(s[i+1]=='%'){
					out+='%';
					i++;
				}
				else if(s[i+1]>='0'&&s[i+1]<='9'||s[i+1]>='a'&&s[i+1]<='f'||s[i+1]>='A'&&s[i+1]<='F')
				{
					int n;
					sscanf(s[i+1..i+2],"%x",n);
					out+=sprintf("%c",n);
					i+=2;
				}
				else{
					out+="%";
				}
			}
		}
		else if(s[i]>=0&&s[i]<128){
			if(last_char=='\n'&&s[i]=='\n'){
			}
			else{
				if(skip_filter){
					out+=s[i..i];
				}
				else{
					out+=replace(s[i..i],(["&":"&amp;","<":"&lt;",">":"&gt;","\n":"<br/>"]));
				}
			}
		}
		else{
			out+=Locale.Charset.decoder("euc_cn")->feed(s[i..i+1])->drain();
			i++;
		}
		last_char=s[i];
	}
	return out;
}
string filter(string s)
{
	string txd = "";
	string userid = this_player()->name;
	string passwd = this_player()->password;
	txd = userid+"~"+passwd;
	txd = decode(txd);
	/////////////////////
	string usid = "";
	usid = this_player()->query_userip();
	if(usid)
		usid = decode(usid);
	else
		usid = "xxxxyyyy";
	///////////////20060309 by qianglee
	if(url==0){
		out+=s;
		return "";
	}
	string d;
	while(s&&sizeof(s)){
		//werror("string s = %s\n",s);
		if(sscanf(s,"%s[",d)){
			out+=decode(d);
			s=s[sizeof(d)..];
		}
		else{
			out+=decode(s);
			s=0;
			break;
		}
		string type,name,cmd,acmd,href,ahref;
		string data;
		string buf;
		string fvalue;
		if(sscanf(s,"[%s]",buf)){
			if(upper_case(buf)=="OL"){
				out+="<ol>";
			}
			else if(upper_case(buf)=="/OL"){
				out+="</ol>";
			}
			if(sizeof(buf)&&buf[0]=='<'){
				out+=decode(buf,1);
			}
			if(sscanf(buf,"wml %s",data)){
				out+=decode(buf,1);
			}
			else if(sscanf(buf,"prev %s:%s",name,cmd)){
				if(cmd&&cmd!=""){
					if(this_player()["hide"])
						cmd=this_player()->hide(cmd);
