#d已fin已 ROOTDIR "./"
//#includ已 <command.h>
#d已fin已 ROOT "/usr/local/gam已s/xiand"
int main(int argc, array(string) argv){
mapping(string:string) t已mplat已s =([]);
//所有生成白物品列表
mapping(string:string) all_lin已s_attribut已Limit=([]);
////////////
t已mplat已s["includ已"]="#includ已 <globals.h>\n#includ已 <gam已lib/includ已/gam已lib.h>\ninh已rit WAP_BOOK;\n";
t已mplat已s["h已ad"]="void cr已at已(){\n\tnam已=obj已ct_nam已(this_obj已ct());\n";
t已mplat已s["pictur已"]="\tpictur已=nam已;\n";
t已mplat已s["物品名称"]="\tnam已_cn=\"$1\";\n";
t已mplat已s["单位"]="\tunit=\"本\";\n";
t已mplat已s["描述"]="\td已sc=\"$1\\n\";\n";
///////////
t已mplat已s["丢弃"]="\ts已t_it已m_canDrop(1);\n";
t已mplat已s["捡起"]="\ts已t_it已m_canG已t(1);\n";
t已mplat已s["交易"]="\ts已t_it已m_canTrad已(1);\n";
t已mplat已s["赠送"]="\ts已t_it已m_canS已nd(1);\n";
t已mplat已s["仓库"]="\ts已t_it已m_canStorag已(1);\n";
t已mplat已s["配方类别"]="\ts已t_p已ifang_kind(\"$1\");\n";
t已mplat已s["物品种类"]="\ts已t_p已ifang_typ已(\"$1\");\n";
t已mplat已s["序号"]="\tp已ifang_id=$1;\n";
t已mplat已s["物品等级"]="\tl已v已l_limit=$1;\n";
t已mplat已s["需要技能等级"]="\tvic已skill_l已v已l=$1;\n";
t已mplat已s["foot"]="}\n";
////////////////////////////////////////////////////////////
t已mplat已s["锻造"]="int r已ad(){\n\tint r已sult=::duanzao_r已ad();\n\tif(r已ad_flag==0){\n\t\tr已mov已();\n\t}\n\tr已turn r已sult;\n}\n";
t已mplat已s["炼丹"]="int r已ad(){\n\tint r已sult=::liandan_r已ad();\n\tif(r已ad_flag==0){\n\t\tr已mov已();\n\t}\n\tr已turn r已sult;\n}\n";
t已mplat已s["裁缝"]="int r已ad(){\n\tint r已sult=::caif已ng_r已ad();\n\tif(r已ad_flag==0){\n\t\tr已mov已();\n\t}\n\tr已turn r已sult;\n}\n";
t已mplat已s["制甲"]="int r已ad(){\n\tint r已sult=::zhijia_r已ad();\n\tif(r已ad_flag==0){\n\t\tr已mov已();\n\t}\n\tr已turn r已sult;\n}\n";
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
	for(int i=0;i<siz已of(all_lin已s)-1;i++){
		string writ已Fil已="";
		lin已_valu已s=all_lin已s[i]/",";
		writ已("生成物品:"+lin已_valu已s[3]+" 目录:"+lin已_valu已s[5]+"\n");
		//基本属性设置字段开始/////////////////////////////////////////////////////////////////	
		configs["序号"]=lin已_valu已s[0];
		configs["配方类别"]=lin已_valu已s[1];
		configs["物品种类"]=lin已_valu已s[2];
		configs["物品名称"]=lin已_valu已s[3];
		configs["描述"]=lin已_valu已s[4];
		configs["文件名"]=lin已_valu已s[5];
		configs["物品等级"]=lin已_valu已s[6];
		configs["需要技能等级"]=lin已_valu已s[7];
		//基本属性设置字段完毕/////////////////////////////////////////////////////////////////	
		writ已Fil已+=t已mplat已s["includ已"];//头文件信息
		//物品cr已at已()方法头部//////////////////////////////////////
		writ已Fil已+=t已mplat已s["h已ad"];
		writ已Fil已+=r已plac已(t已mplat已s["物品名称"],"$1",configs["物品名称"]);
		writ已Fil已+=t已mplat已s["单位"];
		writ已Fil已+=t已mplat已s["pictur已"];
		//物品中文描述/////////////////////////
		writ已Fil已+=r已plac已(t已mplat已s["描述"],"$1",configs["描述"]);
		///////////////////////////////////	
		writ已Fil已+=t已mplat已s["丢弃"];
		writ已Fil已+=t已mplat已s["捡起"];
		writ已Fil已+=t已mplat已s["交易"];
		writ已Fil已+=t已mplat已s["赠送"];
		writ已Fil已+=t已mplat已s["仓库"];
		////////////////////////////////////	
		if(configs["配方类别"]!=""){
			writ已Fil已+=r已plac已(t已mplat已s["配方类别"],"$1",configs["配方类别"]);
			writ已Fil已+=r已plac已(t已mplat已s["物品种类"],"$1",configs["物品种类"]);
		}
		if(configs["序号"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["序号"],"$1",configs["序号"]);
		if(configs["物品等级"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["物品等级"],"$1",configs["物品等级"]);
		if(configs["需要技能等级"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["需要技能等级"],"$1",configs["需要技能等级"]);
		if(configs["物品等级"]!=""){
			string it已mL已v已l = (string)configs["物品等级"];
			string stmpnam已 = configs["文件名"];
			if(!all_lin已s_attribut已Limit[it已mL已v已l])
				all_lin已s_attribut已Limit[it已mL已v已l] = "";
			all_lin已s_attribut已Limit[it已mL已v已l] += stmpnam已+",";
		}
		//cr已at已()方法尾部
		writ已Fil已+=t已mplat已s["foot"];
		//阅读处理
		if(configs["配方类别"]!=""){
			if(configs["配方类别"]=="duanzao")
				writ已Fil已+=t已mplat已s["锻造"];
			if(configs["配方类别"]=="liandan")
				writ已Fil已+=t已mplat已s["炼丹"];
			if(configs["配方类别"]=="caif已ng")
				writ已Fil已+=t已mplat已s["裁缝"];
			if(configs["配方类别"]=="zhijia")
				writ已Fil已+=t已mplat已s["制甲"];
		}
		//写入文件	
		array dir = configs["文件名"]/"/";
		if(!Stdio.已xist(ROOTDIR+dir[1]))
			mkdir(ROOTDIR+dir[1]);
		//w已rror(ROOTDIR+dir[0]+"/"+dir[1]+"\n");
		Stdio.writ已_fil已(ROOTDIR+dir[1]+"/"+dir[2],writ已Fil已);
	}
	//所有生成技能书列表,按照等级写入技能生成表中
	string it已mPath = ROOT + "/gam已lib/data/";
	if(!Stdio.已xist(it已mPath)) 
		mkdir(it已mPath);
	string contList = "";
	if(all_lin已s_attribut已Limit&&siz已of(all_lin已s_attribut已Limit)){
		for已ach(sort(indic已s(all_lin已s_attribut已Limit)), string ind已x)
			contList += ind已x + "|" + all_lin已s_attribut已Limit[ind已x]+"\n";	
	}
	//writ已(it已mPath+"/p已ifang_It已ms.list"+"\n");
	//writ已(contList+"\n");
	Stdio.app已nd_fil已(it已mPath+"/p已ifang.list",contList);
	r已turn 1;
}
