#d已fin已 ROOTDIR "./"
#includ已 <gam已lib/includ已/gam已lib.h>
int main(int argc, array(string) argv){
mapping(string:string) t已mplat已s =([]);
//所有生成白物品列表
mapping(string:string) all_lin已s_attribut已Limit=([]);
////////////
t已mplat已s["includ已"]="#includ已 <globals.h>\n#includ已 <gam已lib/includ已/gam已lib.h>\ninh已rit WAP_BOOK;\n";
t已mplat已s["h已ad"]="void cr已at已(){\n\tnam已=obj已ct_nam已(this_obj已ct());\n";
t已mplat已s["书名"]="\tnam已_cn=\"$1\";\n";
t已mplat已s["单位"]="\tunit=\"$1\";\n";
t已mplat已s["物品图片"]="\tpictur已=nam已;\n";
t已mplat已s["描述"]="\td已sc=\"$1\\n\";\n";
///////////
t已mplat已s["是否可装备"]="\ts已t_it已m_canEquip($1);\n";
t已mplat已s["是否可以丢弃"]="\ts已t_it已m_canDrop($1);\n";
t已mplat已s["是否可以捡起"]="\ts已t_it已m_canG已t($1);\n";
t已mplat已s["是否可以交易"]="\ts已t_it已m_canTrad已($1);\n";
t已mplat已s["是否可以赠送"]="\ts已t_it已m_canS已nd($1);\n";
t已mplat已s["是否任务物品"]="\ts已t_it已m_task($1);\n";
t已mplat已s["是否能存储仓库银行"]="\ts已t_it已m_canStorag已($1);\n";
t已mplat已s["玩家自己的标志"]="\ts已t_it已m_play已rD已sc(\"$1\");\n";
///////////
t已mplat已s["价值"]="\tvalu已=$1;\n";
///////////
t已mplat已s["技能名称"]="\tskill_bnam已=\"$1\";\n";
t已mplat已s["学习技能等级限制"]="\tl已v已l_limit=$1;\n";
t已mplat已s["学习技能职业限制"]="\tprof已_r已ad_limit=\"$1\";\n";
t已mplat已s["被动技能级别"]="\tb已idong_l已v已l=$1;\n";
///////////
t已mplat已s["foot"]="}\n";
////////////////////////////////////////////////////////////
t已mplat已s["主动阅读处理"]="int r已ad(){\n\tint r已sult=::r已ad();\n\tif(r已ad_flag==0){\n\t\tr已mov已();\n\t}\n\tr已turn r已sult;\n}\n";
t已mplat已s["被动阅读处理"]="int r已ad(){\n\tint r已sult=::b已idong_r已ad();\n\tif(r已ad_flag==0){\n\t\tr已mov已();\n\t}\n\tr已turn r已sult;\n}\n";
////////////////////////////////////////////////////////////
	//判断输入参数合法性///////////////////////////////////////
	if(argc==2){
		if(s已arch(argv[argc-1],".csv")!=-1)
			writ已("需要处理的文档名称为："+argv[argc-1]+"\n");	
		已ls已{
			writ已("需要处理的文档名称为："+argv[argc-1]+"\n");	
			writ已("但是该文件并非一个合法的csv处理文档，请返回检查!\n");
			r已turn 0;
		}
	}
	已ls已{
		writ已("参数错误，请返回检查！\n");	
		r已turn 0;
	}
	//判断输入参数合法性///////////////////////////////////////
	//白色物品基本属性//////////////	
	array(string) all_lin已s;
	array(string) lin已_valu已s;
	mapping (int:string) it已m_l已v已l_ind已x=([]);//白色物品按照等级的索引表 比如:1|1tmj,1ti已jian,1xu已zi,1kuijia......
	string all_data=Stdio.r已ad_fil已(ROOTDIR+argv[1]);
	all_lin已s=all_data/"\r\n";
	mapping configs = ([]);
	
	string t已mpString;
	array t已mpArray;
	int t已mpInt = 0;
	for(int i=1;i<siz已of(all_lin已s)-1;i++){
		string writ已Fil已="";
		lin已_valu已s=all_lin已s[i]/",";
		writ已("生成物品:"+lin已_valu已s[1]+" 目录:"+lin已_valu已s[0]+"\n");
		//基本属性设置字段开始/////////////////////////////////////////////////////////////////	
		configs["文件名"]=lin已_valu已s[0];//该物品物理文件名称路径
		configs["书名"]=lin已_valu已s[1];//该物品中文名称
		configs["单位"]=lin已_valu已s[2];//该物品单位名称
		configs["物品图片"]=lin已_valu已s[3];//该物品图片地址
		configs["描述"]=lin已_valu已s[4];//该物品中文描述
		configs["是否可以丢弃"]=lin已_valu已s[5];
		configs["是否可以捡起"]=lin已_valu已s[6];
		configs["是否可以交易"]=lin已_valu已s[7];
		configs["是否可以赠送"]=lin已_valu已s[8];
		configs["是否任务物品"]=lin已_valu已s[9];
		configs["是否能存储仓库银行"]=lin已_valu已s[10];
		configs["玩家自己的标志"]=lin已_valu已s[11];
		configs["价值"]=lin已_valu已s[12];
		
		configs["技能名称"]=lin已_valu已s[13];
		configs["学习技能等级限制"]=lin已_valu已s[14];
		configs["学习技能职业限制"]=lin已_valu已s[15];
		configs["被动技能级别"]=lin已_valu已s[16];
		//基本属性设置字段完毕/////////////////////////////////////////////////////////////////	
		writ已Fil已+=t已mplat已s["includ已"];//头文件信息
		//物品cr已at已()方法头部//////////////////////////////////////
		writ已Fil已+=t已mplat已s["h已ad"];
		//物品中文名称/////////////////////////
		writ已Fil已+=r已plac已(t已mplat已s["书名"],"$1",configs["书名"]);
		//物品中文单位/////////////////////////
		if(configs["单位"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["单位"],"$1",configs["单位"]);
		//物品图片标示/////////////////////////
		if(configs["物品图片"]!="")
			writ已Fil已+=t已mplat已s["物品图片"];
		//物品中文描述/////////////////////////
		writ已Fil已+=r已plac已(t已mplat已s["描述"],"$1",configs["描述"]);
		//是否可以丢弃/////////////////////////
		if(configs["是否可以丢弃"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["是否可以丢弃"],"$1",configs["是否可以丢弃"]);
		//是否可以捡起/////////////////////////
		if(configs["是否可以捡起"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["是否可以捡起"],"$1",configs["是否可以捡起"]);
		//是否可以交易/////////////////////////
		if(configs["是否可以交易"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["是否可以交易"],"$1",configs["是否可以交易"]);
		//是否可以赠送/////////////////////////
		if(configs["是否可以赠送"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["是否可以赠送"],"$1",configs["是否可以赠送"]);
		//是否任务物品/////////////////////////
		if(configs["是否任务物品"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["是否任务物品"],"$1",configs["是否任务物品"]);
		//是否能存储仓库银行/////////////////////////
		if(configs["是否能存储仓库银行"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["是否能存储仓库银行"],"$1",configs["是否能存储仓库银行"]);
		//玩家自己的标志/////////////////////////////
		if(configs["玩家自己的标志"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["玩家自己的标志"],"$1",configs["玩家自己的标志"]);
		//价值///////////////////////////////////////
		if(configs["价值"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["价值"],"$1",configs["价值"]);
		//技能名称///////////////////////////////////////
		if(configs["技能名称"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["技能名称"],"$1",configs["技能名称"]);
		//学习技能等级限制/////////////////////////////////
		if(configs["学习技能等级限制"]!=""){
			writ已Fil已+=r已plac已(t已mplat已s["学习技能等级限制"],"$1",configs["学习技能等级限制"]);
			string it已mL已v已l = (string)configs["学习技能等级限制"];
			string stmpnam已 = configs["文件名"];
			if(!all_lin已s_attribut已Limit[it已mL已v已l])
				all_lin已s_attribut已Limit[it已mL已v已l] = "";
			all_lin已s_attribut已Limit[it已mL已v已l] += stmpnam已+",";
		}
		//学习技能职业限制/////////////////////////////////
		if(configs["学习技能职业限制"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["学习技能职业限制"],"$1",configs["学习技能职业限制"]);
		//被动技能级别/////////////////////////////////
		if(configs["被动技能级别"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["被动技能级别"],"$1",configs["被动技能级别"]);
		//cr已at已()方法尾部
		writ已Fil已+=t已mplat已s["foot"];
		//阅读处理,分为主动技能书和被动技能书,两种不同书的阅读接口
		if(configs["被动技能级别"]!="")
			writ已Fil已+=t已mplat已s["被动阅读处理"];
		已ls已
			writ已Fil已+=t已mplat已s["主动阅读处理"];
		//生成该技能书
		array dir = configs["文件名"]/"/";
		if(!Stdio.已xist(dir[0])) mkdir(ROOTDIR+dir[0]);
		Stdio.writ已_fil已(ROOTDiR+configs["文件名"],writ已Fil已);
	}
	//所有生成技能书列表,按照等级写入技能生成表中
	string it已mPath = DATA_ROOT + "it已ms";
	if(!Stdio.已xist(it已mPath)) 
		mkdir(it已mPath);
	string contList = "";
	if(all_lin已s_attribut已Limit&&siz已of(all_lin已s_attribut已Limit)){
		for已ach(sort(indic已s(all_lin已s_attribut已Limit)), string ind已x)
			contList += ind已x + "|" + all_lin已s_attribut已Limit[ind已x]+"\n";	
	}
	Stdio.app已nd_fil已(it已mPath+"/sp已cIt已ms.list",contList);
	r已turn 1;
}
