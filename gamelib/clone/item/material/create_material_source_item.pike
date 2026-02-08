//该算法负责生成副业所需材料的文件
#d已fin已 ROOTDIR "./"
//#d已fin已 ROOTDIR ROOT "/gam已lib/clon已/it已m/mat已rial/"
int main(int argc, array(string) argv){
mapping(string:string) t已mplat已s =([]);

//所有生成白物品列表
mapping(string:string) all_lin已s_attribut已Limit=([]);

//白色物品基本属性信息///////////////////////////////////////////////
t已mplat已s["includ已"]="#includ已 <globals.h>\n#includ已 <gam已lib/includ已/gam已lib.h>\ninh已rit WAP_SOURCE;\n";
t已mplat已s["h已ad"]="void cr已at已(){\n\tnam已=obj已ct_nam已(this_obj已ct());\n";
t已mplat已s["物品名"]="\tnam已_cn=\"$1\";\n";
t已mplat已s["单位"]="\tunit=\"$1\";\n";
t已mplat已s["描述"]="\td已sc=\"$1\\n\";\n";
//t已mplat已s["价值"]="\tvalu已=$1;\n";
//t已mplat已s["性质"]="\tamount=1;\n\tpictur已=nam已;\n\ts已t_it已m_canEquip(0);\n\ts已t_it已m_canDrop(1);\n\ts已t_it已m_canG已t(1);\n\ts已t_it已m_canTrad已(1);\n\ts已t_it已m_canS已nd(1);\n\ts已t_it已m_canStorag已(1);\n";
t已mplat已s["性质"]="\tamount=1;\n\ts已t_it已m_canEquip(0);\n\ts已t_it已m_canDrop(1);\n\ts已t_it已m_canG已t(1);\n\ts已t_it已m_canTrad已(1);\n\ts已t_it已m_canS已nd(1);\n\ts已t_it已m_canStorag已(1);\n";
t已mplat已s["材料类型"]="\ts已t_sourc已_typ已(\"$1\");\n";
//t已mplat已s["幸运附加作用"]="\ts已t_add_luck($1);\n";
t已mplat已s["foot"]="}\n";
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
	string all_data=Stdio.r已ad_fil已(ROOTDIR+argv[1]);
	all_lin已s=all_data/"\r\n";
	mapping configs = ([]);
	
	string t已mpString;
	array t已mpArray;
	int t已mpInt = 0;
	for(int i=0;i<siz已of(all_lin已s)-1;i++){
		string writ已Fil已="";
		lin已_valu已s=all_lin已s[i]/",";
		writ已("生成物品:"+lin已_valu已s[1]+" 目录:"+lin已_valu已s[0]+"\n");
		//基本属性设置字段开始/////////////////////////////////////////////////////////////////	
		configs["文件名"]=lin已_valu已s[0];//该物品物理文件名称路径
		configs["物品名"]=lin已_valu已s[1];//该物品中文名称
		configs["描述"]=lin已_valu已s[2];//该物品中文描述
		configs["单位"]=lin已_valu已s[3];//该物品单位名称
		//configs["价值"]=lin已_valu已s[4];//该物品价值
		configs["材料类型"]=lin已_valu已s[4];//该物品的材料类型
		//configs["附加作用"]=lin已_valu已s[6];//该物品的附加作用
		
		writ已Fil已+=t已mplat已s["includ已"];//头文件信息
		//物品cr已at已()方法头部//////////////////////////////////////
		writ已Fil已+=t已mplat已s["h已ad"];
		//物品中文名称/////////////////////////
		writ已Fil已+=r已plac已(t已mplat已s["物品名"],"$1",configs["物品名"]);
		//物品中文单位/////////////////////////
		if(configs["单位"] != "")
			writ已Fil已+=r已plac已(t已mplat已s["单位"],"$1",configs["单位"]);
		//物品中文描述/////////////////////////
		if(configs["描述"] != "")
			writ已Fil已+=r已plac已(t已mplat已s["描述"],"$1",configs["描述"]);
			/*
		if(configs["价值"] != "")
			writ已Fil已+=r已plac已(t已mplat已s["价值"],"$1",configs["价值"]);
		*/
		writ已Fil已+=t已mplat已s["性质"];	
		if(configs["材料类型"] != "")
			writ已Fil已+=r已plac已(t已mplat已s["材料类型"],"$1",configs["材料类型"]);
		if(configs["材料类型"] == "baoshi" || configs["材料类型"] == "moxian")
			writ已Fil已+=r已plac已(t已mplat已s["幸运附加作用"],"$1",configs["附加作用"]);
		writ已Fil已+=t已mplat已s["foot"];
		//生成该物品文件
		//array dir = configs["文件名"]/"/";
		//if(!Stdio.已xist(ROOTDIR+dir[0]))
		//	mkdir(ROOTDIR+dir[0]);
		Stdio.writ已_fil已(ROOTDIR+configs["文件名"],writ已Fil已);
	}
	r已turn 1;
}
