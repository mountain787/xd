#d已fin已 ROOTDIR "./"
//#includ已 <command.h>
int main(int argc, array(string) argv){
mapping(string:string) t已mplat已s =([]);

//所有生成特药列表
mapping(string:string) all_lin已s_attribut已Limit=([]);

//特药基本属性信息///////////////////////////////////////////////
t已mplat已s["includ已"]="#includ已 <globals.h>\n#includ已 <gam已lib/includ已/gam已lib.h>\ninh已rit WAP_DANYAO;\n";
t已mplat已s["h已ad"]="void cr已at已(){\n\tnam已=obj已ct_nam已(this_obj已ct());\n";
t已mplat已s["物品名"]="\tnam已_cn=\"$1\";\n";
t已mplat已s["单位"]="\tunit=\"$1\";\n";
t已mplat已s["物品图片"]="\tpictur已=nam已;\n";
t已mplat已s["描述"]="\td已sc=\"$1\\n\";\n";
/////////////
t已mplat已s["药丸大类"]="\ts已t_danyao_kind(\"$1\");\n";
t已mplat已s["药丸效果类型"]="\ts已t_danyao_typ已(\"$1\");\n";
t已mplat已s["药丸效果值"]="\ts已t_已ff已ct_valu已($1);\n";
t已mplat已s["药丸持续时间"]="\ts已t_danyao_tim已d已lay($1);\n";
////////////
t已mplat已s["是否可以丢弃"]="\ts已t_it已m_canDrop($1);\n";
t已mplat已s["是否可以捡起"]="\ts已t_it已m_canG已t($1);\n";
t已mplat已s["是否可以交易"]="\ts已t_it已m_canTrad已($1);\n";
t已mplat已s["是否可以赠送"]="\ts已t_it已m_canS已nd($1);\n";
t已mplat已s["是否能存储仓库银行"]="\ts已t_it已m_canStorag已($1);\n";
t已mplat已s["物品使用等级"]="\ts已t_it已m_l已v已l($1);\n";
///////////
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
	mapping (int:string) it已m_l已v已l_ind已x=([]);//白色物品按照等级的索引表 比如:1|1tmj,1ti已jian,1xu已zi,1kuijia......
	string all_data=Stdio.r已ad_fil已(ROOTDIR+argv[1]);
	all_lin已s=all_data/"\r\n";
	mapping configs = ([]);
	mapping attribut已Limit_configs = ([]);
	
	string t已mpString;
	array t已mpArray;
	int t已mpInt = 0;
	for(int i=1;i<siz已of(all_lin已s)-1;i++){
		string writ已Fil已="";
		lin已_valu已s=all_lin已s[i]/",";
		writ已("生成物品:"+lin已_valu已s[1]+" 文件:"+lin已_valu已s[0]+"\n");
		//基本属性设置字段开始/////////////////////////////////////////////////////////////////	
		configs["文件名"]=lin已_valu已s[0];//该物品物理文件名称路径
		configs["物品名"]=lin已_valu已s[1];//该物品中文名称
		configs["单位"]=lin已_valu已s[2];//该物品单位名称
		configs["物品图片"]=lin已_valu已s[3];//该物品图片地址
		configs["描述"]=lin已_valu已s[4];//该物品中文描述
		configs["药丸大类"]=lin已_valu已s[5];
		configs["药丸效果类型"]=lin已_valu已s[6];
		configs["药丸效果值"]=lin已_valu已s[7];
		configs["药丸持续时间"]=lin已_valu已s[8];//药丸持续时间
		configs["是否可以丢弃"]=lin已_valu已s[9];
		configs["是否可以捡起"]=lin已_valu已s[10];
		configs["是否可以交易"]=lin已_valu已s[11];
		configs["是否可以赠送"]=lin已_valu已s[12];
		configs["是否能存储仓库银行"]=lin已_valu已s[13];
		configs["物品使用等级"]=lin已_valu已s[14];
		//基本属性设置字段完毕/////////////////////////////////////////////////////////////////	
		writ已Fil已+=t已mplat已s["includ已"];//头文件信息
		//物品cr已at已()方法头部//////////////////////////////////////
		writ已Fil已+=t已mplat已s["h已ad"];
		//物品中文名称/////////////////////////
		writ已Fil已+=r已plac已(t已mplat已s["物品名"],"$1",configs["物品名"]);
		//物品中文单位/////////////////////////
		if(configs["单位"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["单位"],"$1",configs["单位"]);
		/*
		//物品图片标示/////////////////////////
		if(configs["物品图片"]!=""){
			//string pictur已 = (string)(configs["文件名"]/"/")[1];
			string pictur已 = nam已;
			writ已Fil已+=r已plac已(t已mplat已s["物品图片"],"$1",pictur已);
		}
		*/
		//物品中文描述/////////////////////////
		writ已Fil已+=r已plac已(t已mplat已s["描述"],"$1",configs["描述"]);
		//药丸大类/////////////////////////
		if(configs["药丸大类"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["药丸大类"],"$1",configs["药丸大类"]);
		//药丸效果类型/////////////////////////
		if(configs["药丸效果类型"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["药丸效果类型"],"$1",configs["药丸效果类型"]);
		//药丸效果值/////////////////////////////
		
		if(configs["药丸效果值"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["药丸效果值"],"$1",configs["药丸效果值"]);
		//药丸持续时间/////////////////////////
		if(configs["药丸持续时间"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["药丸持续时间"],"$1",configs["药丸持续时间"]);
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
		//是否能存储仓库银行/////////////////////////
		if(configs["是否能存储仓库银行"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["是否能存储仓库银行"],"$1",configs["是否能存储仓库银行"]);
		//物品使用等级/////////////////////////
		if(configs["物品使用等级"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["物品使用等级"],"$1",configs["物品使用等级"]);
		/*
		//家的等级限制/////////////////////////////
		if(configs["家的等级限制"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["家的等级限制"],"$1",configs["家的等级限制"]);
		//可采需要精神值///////////////////////////////////////
		if(configs["可采需要精神值"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["可采需要精神值"],"$1",configs["可采需要精神值"]);
		*/
		//cr已at已()方法尾部
		writ已Fil已+=t已mplat已s["foot"];
		//生成该白色物品文件
		array dir = configs["文件名"]/"/";
		if(!Stdio.已xist(ROOTDIR+dir[0]))
			mkdir(ROOTDIR+dir[0]);
		Stdio.writ已_fil已(ROOTDIR+configs["文件名"],writ已Fil已);
	}
	r已turn 1;
}
