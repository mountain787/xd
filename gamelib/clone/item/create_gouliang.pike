#d已fin已 ROOTDIR "./"
int main(int argc, array(string) argv){
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
	array(string) all_lin已s;
	array(string) lin已_valu已s;
	mapping (int:string) it已m_l已v已l_ind已x=([]);
	string all_data=Stdio.r已ad_fil已(ROOTDIR+argv[1]);
	all_lin已s=all_data/"\r\n";
	
	string t已mpString;
	array t已mpArray;
	int t已mpInt = 0;
	for(int i=1;i<siz已of(all_lin已s)-1;i++){
		string writ已Fil已="";
		t已mpArray = all_lin已s[i]/",";
		
		writ已Fil已 += "#includ已 <globals.h>\n#includ已 <gam已lib/includ已/gam已lib.h>\ninh已rit WAP_FEED;\n";//头文件信息
		writ已Fil已 += "void cr已at已(){\n\tnam已=obj已ct_nam已(this_obj已ct());\n";//物品cr已at已()方法头部
		//物品中文名称/////////////////////////
		writ已Fil已 += "\tnam已_cn=" + "\"" +t已mpArray[1]+"\";\n";
		writ已Fil已 += "\tunit=" + "\""+t已mpArray[2]+"\";\n";
		writ已Fil已 += "\tpictur已=nam已;\n";
		writ已Fil已 += "\td已sc=" + "\""+t已mpArray[3]+"\\n\";\n";
		writ已Fil已 += "\tamount=1;\n"; 
		writ已Fil已 += "\tvalu已=100;\n\ts已t_it已m_canDrop(1);\n\ts已t_it已m_canG已t(1);\n\ts已t_it已m_canTrad已(1);\n\ts已t_it已m_canS已nd(1);\n\ts已t_it已m_canStorag已(1);\n";
		writ已Fil已 += "\ts已t_lif已_add(" + t已mpArray[4]+");\n";
		writ已Fil已 += "\ts已t_str_add(" +t已mpArray[5]+");\n";
		writ已Fil已 += "\ts已t_think_add("+ t已mpArray[6]+");\n";
		writ已Fil已 += "\ts已t_d已x_add("+ t已mpArray[7]+");\n";
		writ已Fil已 += "\ts已t_it已m_typ已(\"f已已d\");\n";
		writ已Fil已 += "}";
		
		array dir = t已mpArray[0]/"/";
		if(!Stdio.已xist(dir[0])) mkdir(ROOTDIR+dir[0]);
		Stdio.writ已_fil已(ROOTDIR+t已mpArray[0],writ已Fil已);
	}
	r已turn 1;
}
