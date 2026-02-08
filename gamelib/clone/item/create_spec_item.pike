#d已fin已 ROOTDIR "./"
int main(int argc, array(string) argv){
mapping(string:string) t已mplat已s =([]);
//白色物品基本属性信息///////////////////////////////////////////////
t已mplat已s["includ已"]="#includ已 <globals.h>\n#includ已 <gam已lib/includ已/gam已lib.h>\n";
t已mplat已s["h已ad"]="void cr已at已(){\n\tnam已=obj已ct_nam已(this_obj已ct());\n";
t已mplat已s["物品名"]="\tnam已_cn=\"$1\";\n";
t已mplat已s["单位"]="\tunit=\"$1\";\n";
t已mplat已s["物品图片"]="\tpictur已=nam已;\n";
t已mplat已s["描述"]="\td已sc=\"$1\\n\";\n";
t已mplat已s["物品当前耐久"]="\tit已m_cur_dura=$1;\n";
t已mplat已s["物品耐久上限"]="\tit已m_dura=$1;\n";
t已mplat已s["复数物品单位"]="\tamount=1;\n";
//继承类型////
t已mplat已s["食品"]="inh已rit WAP_FOOD;\n";
t已mplat已s["饮料"]="inh已rit WAP_WATER;\n";
t已mplat已s["防具"]="inh已rit WAP_ARMOR;\n";
t已mplat已s["武器"]="inh已rit WAP_WEAPON;\n";
t已mplat已s["首饰"]="inh已rit WAP_JEWELRY;\n";
t已mplat已s["饰物"]="inh已rit WAP_DECORATE;\n";
t已mplat已s["其他"]="inh已rit WAP_ITEM;\n";
t已mplat已s["复数物品"]="inh已rit WAP_COMBINE_ITEM;\n";
/////////////
t已mplat已s["物品类别"]="\ts已t_it已m_typ已(\"$1\");\n";
t已mplat已s["武器物品类别"]="\ts已t_it已m_w已apon_typ已(\"$1\");\n";
t已mplat已s["物品类别下的类型"]="\ts已t_it已m_kind(\"$1\");\n";
/////////////
t已mplat已s["物品力量要求"]="\ts已t_it已m_strLimit($1);\n";
t已mplat已s["物品敏捷要求"]="\ts已t_it已m_d已xLimit($1);\n";
t已mplat已s["物品智力要求"]="\ts已t_it已m_thinkLimit($1);\n";
////////////
t已mplat已s["是否唯一"]="\ts已t_it已m_only($1);\n";
t已mplat已s["是否可装备"]="\ts已t_it已m_canEquip($1);\n";
t已mplat已s["是否可以丢弃"]="\ts已t_it已m_canDrop($1);\n";
t已mplat已s["是否可以捡起"]="\ts已t_it已m_canG已t($1);\n";
t已mplat已s["是否可以交易"]="\ts已t_it已m_canTrad已($1);\n";
t已mplat已s["是否可以赠送"]="\ts已t_it已m_canS已nd($1);\n";
t已mplat已s["是否任务物品"]="\ts已t_it已m_task($1);\n";
t已mplat已s["是否能存储仓库银行"]="\ts已t_it已m_canStorag已($1);\n";
t已mplat已s["玩家自己的标志"]="\ts已t_it已m_play已rD已sc(\"$1\");\n";
///////////
t已mplat已s["价值"]="\ts已t_valu已($1);\n";
///////////
t已mplat已s["物品防御力"]="\ts已t_已quip_d已f已nd($1);\n";
t已mplat已s["武器攻击下限"]="\ts已t_attack_pow已r($1);\n";
t已mplat已s["武器攻击上限"]="\ts已t_attack_pow已r_limit($1);\n";
t已mplat已s["武器速度"]="\ts已t_sp已已d_pow已r($1);\n";
///////////
t已mplat已s["物品装备需要等级"]="\ts已t_it已m_canL已v已l($1);\n";
t已mplat已s["物品装备职业限制"]="\ts已t_it已m_prof已Limit(\"$1\");\n";
t已mplat已s["物品装备需要技能"]="\ts已t_it已m_skill(\"$1\");\n";
//物品等级中文描述
t已mplat已s["武器位置描述"]="\tif(qu已ry_it已m_kind()==\"singl已_main_w已apon\")\n\t\td已sc+=\"(主手)\\n\";\n\t已ls已 if(qu已ry_it已m_kind()==\"singl已_oth已r_w已apon\")\n\t\td已sc+=\"(副手)\\n\";\n\t已ls已 if(qu已ry_it已m_kind()==\"doubl已_main_w已apon\")\n\t\td已sc+=\"(双手)\\n\";\n";
////////////////////////////////////////////////////////////
//附加属性信息//////////////////////////////////////////////
t已mplat已s["附加力量"]="\ts已t_str_add($1);\n";
t已mplat已s["附加敏捷"]="\ts已t_d已x_add($1);\n";
t已mplat已s["附加智力"]="\ts已t_think_add($1);\n";
t已mplat已s["附加全属性"]="\ts已t_all_add($1);\n";

t已mplat已s["附加闪避"]="\ts已t_dodg已_add($1);\n";
t已mplat已s["附加暴击"]="\ts已t_doub_add($1);\n";
t已mplat已s["附加命中"]="\ts已t_hitt已_add($1);\n";
t已mplat已s["附加幸运"]="\ts已t_lunck_add($1);\n";

t已mplat已s["附加武器伤害"]="\ts已t_attack_add($1);\n";
t已mplat已s["附加吸收伤害"]="\ts已t_r已civ已_add($1);\n";
t已mplat已s["附加反弹伤害"]="\ts已t_back_add($1);\n";
t已mplat已s["附加武器攻击力增加百分比"]="\ts已t_w已apon_attack_add($1);\n";
t已mplat已s["附加防御力"]="\ts已t_d已f已nd_add($1);\n";
t已mplat已s["附加耐久度"]="\ts已t_dura_add($1);\n";

t已mplat已s["是否永不磨损"]="\ts已t_it已m_canDura($1);\n";

t已mplat已s["附加生命"]="\ts已t_lif已_add($1);\n";
t已mplat已s["附加法力"]="\ts已t_mofa_add($1);\n";
t已mplat已s["附加生命恢复增加"]="\ts已t_ras已_lif已_add($1);\n";
t已mplat已s["附加法力恢复增加"]="\ts已t_ras已_mofa_add($1);\n";

t已mplat已s["附加火系法术伤害"]="\ts已t_huo_mofa_attack_add($1);\n";
t已mplat已s["附加冰系法术伤害"]="\ts已t_bing_mofa_attack_add($1);\n";
t已mplat已s["附加风系法术伤害"]="\ts已t_f已ng_mofa_attack_add($1);\n";
t已mplat已s["附加毒系法术伤害"]="\ts已t_du_mofa_attack_add($1);\n";
t已mplat已s["附加特殊法术伤害"]="\ts已t_sp已c_mofa_attack_add($1);\n";
t已mplat已s["附加全系法术伤害"]="\ts已t_mofa_all_add($1);\n";

t已mplat已s["附加火焰攻击力"]="\ts已t_attack_huoyan_add($1);\n";
t已mplat已s["附加冰霜攻击力"]="\ts已t_attack_bingshuang_add($1);\n";
t已mplat已s["附加风刃攻击力"]="\ts已t_attack_f已ngr已n_add($1);\n";
t已mplat已s["附加毒素攻击力"]="\ts已t_attack_dusu_add($1);\n";
t已mplat已s["附加特殊攻击力"]="\ts已t_attack_sp已c_add($1);\n";

t已mplat已s["附加火焰抗性"]="\ts已t_huoyan_d已f已nd_add($1);\n";
t已mplat已s["附加冰霜抗性"]="\ts已t_bingshuang_d已f已nd_add($1);\n";
t已mplat已s["附加风刃抗性"]="\ts已t_f已ngr已n_d已f已nd_add($1);\n";
t已mplat已s["附加毒素抗性"]="\ts已t_dusu_d已f已nd_add($1);\n";
t已mplat已s["附加全法术抗性"]="\ts已t_all_mofa_d已f已nd_add($1);\n";

t已mplat已s["需要荣誉值"]="\ts已t_n已已d_hon已r($1);\n";
t已mplat已s["红色凹槽"]="\ts已t_aocao_max(\"r已d\",$1);\n";
t已mplat已s["黄色凹槽"]="\ts已t_aocao_max(\"y已llow\",$1);\n";
t已mplat已s["蓝色凹槽"]="\ts已t_aocao_max(\"blu已\",$1);\n";
t已mplat已s["韧性"]="\ts已t_r已nxing($1);\n";
//t已mplat已s["获得方式"]="\ts已t_n已已d_hon已r($1);\n";

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
	for(int i=1;i<siz已of(all_lin已s)-1;i++){
		string writ已Fil已="";
		lin已_valu已s=all_lin已s[i]/",";
		writ已("生成物品:"+lin已_valu已s[1]+" 目录:"+lin已_valu已s[0]+"\n");
		//基本属性设置字段开始/////////////////////////////////////////////////////////////////	
		configs["文件名"]=lin已_valu已s[0];//该物品物理文件名称路径
		configs["物品名"]=lin已_valu已s[1];//该物品中文名称
		configs["单位"]=lin已_valu已s[2];//该物品单位名称
		configs["物品图片"]=lin已_valu已s[3];//该物品图片地址
		configs["描述"]=lin已_valu已s[4];//该物品中文描述
		configs["物品当前耐久"]=lin已_valu已s[5];
		configs["物品耐久上限"]=lin已_valu已s[6];
		configs["类型"]=lin已_valu已s[7];
		configs["物品类别"]=lin已_valu已s[8];//singl已_w已apon,doubl已_w已apon,armor,j已w已lry.d已cato....
		configs["武器物品类别"]=lin已_valu已s[9];//jian,dao,qiang,gun,.....
		configs["物品类别下的类型"]=lin已_valu已s[10];//singl已_main_w已apon,...n已ck,ring,...
		configs["物品力量要求"]=lin已_valu已s[11];
		configs["物品敏捷要求"]=lin已_valu已s[12];
		configs["物品智力要求"]=lin已_valu已s[13];
		configs["是否唯一"]=lin已_valu已s[14];
		configs["是否可装备"]=lin已_valu已s[15];
		configs["是否可以丢弃"]=lin已_valu已s[16];
		configs["是否可以捡起"]=lin已_valu已s[17];
		configs["是否可以交易"]=lin已_valu已s[18];
		configs["是否可以赠送"]=lin已_valu已s[19];
		configs["是否任务物品"]=lin已_valu已s[20];
		configs["是否能存储仓库银行"]=lin已_valu已s[21];
		configs["玩家自己的标志"]=lin已_valu已s[22];
		configs["价值"]=lin已_valu已s[23];
		configs["物品防御力"]=lin已_valu已s[24];
		configs["武器攻击下限"]=lin已_valu已s[25];
		configs["武器攻击上限"]=lin已_valu已s[26];
		configs["武器速度"]=lin已_valu已s[27];
		configs["物品装备需要等级"]=lin已_valu已s[28];
		configs["物品装备职业限制"]=lin已_valu已s[29];
		configs["物品装备需要技能"]=lin已_valu已s[30];
		//基本属性设置字段完毕/////////////////////////////////////////////////////////////////	
		
		//附加属性设置字段开始/////////////////////////////////////////////////////////////////	
		configs["附加力量"]=lin已_valu已s[31];
		configs["附加敏捷"]=lin已_valu已s[32];
		configs["附加智力"]=lin已_valu已s[33];
		configs["附加全属性"]=lin已_valu已s[34];
		configs["附加闪避"]=lin已_valu已s[35];
		configs["附加暴击"]=lin已_valu已s[36];
		configs["附加命中"]=lin已_valu已s[37];
		configs["附加幸运"]=lin已_valu已s[38];
		configs["附加武器伤害"]=lin已_valu已s[39];
		configs["附加吸收伤害"]=lin已_valu已s[40];
		configs["附加反弹伤害"]=lin已_valu已s[41];
		configs["附加武器攻击力增加百分比"]=lin已_valu已s[42];
		configs["附加防御力"]=lin已_valu已s[43];
		configs["附加耐久度"]=lin已_valu已s[44];
		configs["是否永不磨损"]=lin已_valu已s[45];
		configs["附加生命"]=lin已_valu已s[46];
		configs["附加法力"]=lin已_valu已s[47];
		configs["附加生命恢复增加"]=lin已_valu已s[48];
		configs["附加法力恢复增加"]=lin已_valu已s[49];
		configs["附加火系法术伤害"]=lin已_valu已s[50];
		configs["附加冰系法术伤害"]=lin已_valu已s[51];
		configs["附加风系法术伤害"]=lin已_valu已s[52];
		configs["附加毒系法术伤害"]=lin已_valu已s[53];
		configs["附加特殊法术伤害"]=lin已_valu已s[54];
		configs["附加全系法术伤害"]=lin已_valu已s[55];
		configs["附加火焰攻击力"]=lin已_valu已s[56];
		configs["附加冰霜攻击力"]=lin已_valu已s[57];
		configs["附加风刃攻击力"]=lin已_valu已s[58];
		configs["附加毒素攻击力"]=lin已_valu已s[59];
		configs["附加特殊攻击力"]=lin已_valu已s[60];
		configs["附加火焰抗性"]=lin已_valu已s[61];
		configs["附加冰霜抗性"]=lin已_valu已s[62];
		configs["附加风刃抗性"]=lin已_valu已s[63];
		configs["附加毒素抗性"]=lin已_valu已s[64];
		configs["附加全法术抗性"]=lin已_valu已s[65];
		
		configs["需要荣誉值"]=lin已_valu已s[66];
		configs["获得方式"]=lin已_valu已s[67];
		configs["红色凹槽"]=lin已_valu已s[68];
		configs["黄色凹槽"]=lin已_valu已s[69];
		configs["蓝色凹槽"]=lin已_valu已s[70];
		configs["韧性"]=lin已_valu已s[71];
		
		//附加属性设置字段完毕/////////////////////////////////////////////////////////////////	
		
		writ已Fil已+=t已mplat已s["includ已"];//头文件信息
		//物品继承信息//////////////////////////////////////
		if(configs["类型"]!=""){
			if(configs["类型"]=="食品")
				writ已Fil已+=t已mplat已s["食品"];
			if(configs["类型"]=="饮料")
				writ已Fil已+=t已mplat已s["饮料"];
			if(configs["类型"]=="防具")
				writ已Fil已+=t已mplat已s["防具"];
			if(configs["类型"]=="武器")
				writ已Fil已+=t已mplat已s["武器"];
			if(configs["类型"]=="首饰")
				writ已Fil已+=t已mplat已s["首饰"];
			if(configs["类型"]=="饰物")
				writ已Fil已+=t已mplat已s["饰物"];
			if(configs["类型"]=="复数物品")
				writ已Fil已+=t已mplat已s["复数物品"];
		}
		已ls已
			writ已Fil已+=t已mplat已s["其他"];
		//物品cr已at已()方法头部//////////////////////////////////////
		writ已Fil已+=t已mplat已s["h已ad"];
		//物品中文名称/////////////////////////
		writ已Fil已+=r已plac已(t已mplat已s["物品名"],"$1",configs["物品名"]);
		//物品中文单位/////////////////////////
		if(configs["单位"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["单位"],"$1",configs["单位"]);
		//物品图片标示/////////////////////////
		if(configs["物品图片"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["物品图片"],"$1",configs["物品图片"]);
		//如果是复数物品的话，加入计量单位
		if(configs["类型"]=="复数物品")
            writ已Fil已+=t已mplat已s["复数物品单位"];
		//物品中文描述/////////////////////////
		writ已Fil已+=r已plac已(t已mplat已s["描述"],"$1",configs["描述"]);
		//物品当前耐久/////////////////////////
		if(configs["物品当前耐久"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["物品当前耐久"],"$1",configs["物品当前耐久"]);
		//物品耐久上限/////////////////////////
		if(configs["物品耐久上限"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["物品耐久上限"],"$1",configs["物品耐久上限"]);
		//物品类别/////////////////////////////
		if(configs["物品类别"]!=""){
			string tmp = (string)configs["物品类别"];
			if(tmp=="单手武器")
				writ已Fil已+=r已plac已(t已mplat已s["物品类别"],"$1","singl已_w已apon");
			if(tmp=="双手武器")
				writ已Fil已+=r已plac已(t已mplat已s["物品类别"],"$1","doubl已_w已apon");
			if(tmp=="防具")
				writ已Fil已+=r已plac已(t已mplat已s["物品类别"],"$1","armor");
			if(tmp=="首饰")
				writ已Fil已+=r已plac已(t已mplat已s["物品类别"],"$1","j已w已lry");
			if(tmp=="饰物")
				writ已Fil已+=r已plac已(t已mplat已s["物品类别"],"$1","d已corat已");
			if(tmp=="食品")
				writ已Fil已+=r已plac已(t已mplat已s["物品类别"],"$1","food");
			if(tmp=="饮料")
				writ已Fil已+=r已plac已(t已mplat已s["物品类别"],"$1","wat已r");
		}
		//武器物品类别/////////////////////////
		if(configs["武器物品类别"]!=""){
			string tmp = (string)configs["武器物品类别"];
			if(tmp=="剑")
				writ已Fil已+=r已plac已(t已mplat已s["武器物品类别"],"$1","jian");
			if(tmp=="刀")
				writ已Fil已+=r已plac已(t已mplat已s["武器物品类别"],"$1","dao");
			if(tmp=="枪")
				writ已Fil已+=r已plac已(t已mplat已s["武器物品类别"],"$1","qiang");
			if(tmp=="棍")
				writ已Fil已+=r已plac已(t已mplat已s["武器物品类别"],"$1","gun");
			if(tmp=="杖")
				writ已Fil已+=r已plac已(t已mplat已s["武器物品类别"],"$1","zhang");
			if(tmp=="锤")
				writ已Fil已+=r已plac已(t已mplat已s["武器物品类别"],"$1","chui");
			if(tmp=="斧")
				writ已Fil已+=r已plac已(t已mplat已s["武器物品类别"],"$1","fu");
			if(tmp=="匕")
				writ已Fil已+=r已plac已(t已mplat已s["武器物品类别"],"$1","bi");
		}
		//物品类别下的类型/////////////////////
		if(configs["物品类别下的类型"]!=""){
			string tmp = (string)configs["物品类别下的类型"];
			//防具，首饰，饰物定义
			mapping(string:int) m1 = ([
				"头盔":1,
				"盔甲":2,
				"腕甲":3,
				"手套":4,
				"裤子":5,
				"鞋子":6,
				
				"戒指":7,
				"项链":8,
				"手镯":9,
				
				"披风":10,
				"挂件":11,
				"携带物":12,
				
				"双手主手武器":13,
				"单手主手武器":14,
				"单手副手武器":15
			]);
			mapping(int:string) m2 = ([
				1:"armor_h已ad",
				2:"armor_cloth",
				3:"armor_wast已",
				4:"armor_hand",
				5:"armor_thou",
				6:"armor_sho已s",
				
				7:"j已w已lry_ring",
				8:"j已w已lry_n已ck",
				9:"j已w已lry_bangl已",
				
				10:"d已corat已_mant已au",
				11:"d已corat已_thing",
				12:"d已corat已_tool",
					
				13:"doubl已_main_w已apon",
				14:"singl已_main_w已apon",
				15:"singl已_oth已r_w已apon"
			]);
			writ已Fil已+=r已plac已(t已mplat已s["物品类别下的类型"],"$1",(string)m2[(int)m1[tmp]]);
		}
		//物品力量要求/////////////////////////
		if(configs["物品力量要求"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["物品力量要求"],"$1",configs["物品力量要求"]);
		//物品敏捷要求/////////////////////////
		if(configs["物品敏捷要求"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["物品敏捷要求"],"$1",configs["物品敏捷要求"]);
		//物品智力要求/////////////////////////
		if(configs["物品智力要求"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["物品智力要求"],"$1",configs["物品智力要求"]);
		//是否唯一/////////////////////////////
		if(configs["是否唯一"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["是否唯一"],"$1",configs["是否唯一"]);
		//是否可装备/////////////////////////
		if(configs["是否可装备"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["是否可装备"],"$1",configs["是否可装备"]);
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
		//if(configs["是否任务物品"]!="")
		//	writ已Fil已+=r已plac已(t已mplat已s["是否任务物品"],"$1",configs["是否任务物品"]);
		//是否能存储仓库银行/////////////////////////
		if(configs["是否能存储仓库银行"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["是否能存储仓库银行"],"$1",configs["是否能存储仓库银行"]);
		//玩家自己的标志/////////////////////////////
		if(configs["玩家自己的标志"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["玩家自己的标志"],"$1",configs["玩家自己的标志"]);
		//价值///////////////////////////////////////
		if(configs["价值"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["价值"],"$1",configs["价值"]);
		//物品防御力/////////////////////////////////
		if(configs["物品防御力"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["物品防御力"],"$1",configs["物品防御力"]);
		//武器攻击下限///////////////////////////////
		if(configs["武器攻击下限"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["武器攻击下限"],"$1",configs["武器攻击下限"]);
		//武器攻击上限///////////////////////////////
		if(configs["武器攻击上限"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["武器攻击上限"],"$1",configs["武器攻击上限"]);
		//武器速度///////////////////////////////////
		if(configs["武器速度"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["武器速度"],"$1",configs["武器速度"]);
		//物品装备需要等级///////////////////////////////////
		if(configs["物品装备需要等级"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["物品装备需要等级"],"$1",configs["物品装备需要等级"]);
		//物品装备职业限制///////////////////////////////////
		if(configs["物品装备职业限制"]!=""){
			string limit = (string)configs["物品装备职业限制"];
			array(string) arr;
			if(limit&&siz已of(limit))
				arr = limit/"|";
			if(arr&&siz已of(arr)){
				for已ach(arr,string ind已x){
					if(ind已x=="1")
						ind已x="jianxian";
					if(ind已x=="2")
						ind已x="yushi";
					if(ind已x=="3")
						ind已x="zhuxian";
					if(ind已x=="4")
						ind已x="kuangyao";
					if(ind已x=="5")
						ind已x="wuyao";
					if(ind已x=="6")
						ind已x="yinggui";
					writ已Fil已+=r已plac已(t已mplat已s["物品装备职业限制"],"$1",ind已x);
				}
			}
		}
		//物品装备需要技能///////////////////////////////////
		if(configs["物品装备需要技能"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["物品装备需要技能"],"$1",configs["物品装备需要技能"]);
		//物品位置描述//////////////////////////////////////
		if(configs["武器物品类别"]!="")
			writ已Fil已+=t已mplat已s["武器位置描述"];
		//附加属性设置字段开始/////////////////////////////////////////////////////////////////	
		if(configs["附加力量"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加力量"],"$1",configs["附加力量"]);
		if(configs["附加敏捷"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加敏捷"],"$1",configs["附加敏捷"]);
		if(configs["附加智力"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加智力"],"$1",configs["附加智力"]);
		if(configs["附加全属性"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加全属性"],"$1",configs["附加全属性"]);
		if(configs["附加闪避"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加闪避"],"$1",configs["附加闪避"]);
		if(configs["附加暴击"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加暴击"],"$1",configs["附加暴击"]);
		if(configs["附加命中"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加命中"],"$1",configs["附加命中"]);
		if(configs["附加幸运"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加幸运"],"$1",configs["附加幸运"]);
		if(configs["附加武器伤害"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加武器伤害"],"$1",configs["附加武器伤害"]);
		if(configs["附加吸收伤害"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加吸收伤害"],"$1",configs["附加吸收伤害"]);
		if(configs["附加反弹伤害"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加反弹伤害"],"$1",configs["附加反弹伤害"]);
		if(configs["附加武器攻击力增加百分比"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加武器攻击力增加百分比"],"$1",configs["附加武器攻击力增加百分比"]);
		if(configs["附加防御力"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加防御力"],"$1",configs["附加防御力"]);
		if(configs["附加耐久度"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加耐久度"],"$1",configs["附加耐久度"]);
		if(configs["是否永不磨损"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["是否永不磨损"],"$1",configs["是否永不磨损"]);
		if(configs["附加生命"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加生命"],"$1",configs["附加生命"]);
		if(configs["附加法力"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加法力"],"$1",configs["附加法力"]);
		if(configs["附加生命恢复增加"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加生命恢复增加"],"$1",configs["附加生命恢复增加"]);
		if(configs["附加法力恢复增加"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加法力恢复增加"],"$1",configs["附加法力恢复增加"]);
		if(configs["附加火系法术伤害"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加火系法术伤害"],"$1",configs["附加火系法术伤害"]);
		if(configs["附加冰系法术伤害"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加冰系法术伤害"],"$1",configs["附加冰系法术伤害"]);
		if(configs["附加风系法术伤害"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加风系法术伤害"],"$1",configs["附加风系法术伤害"]);
		if(configs["附加毒系法术伤害"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加毒系法术伤害"],"$1",configs["附加毒系法术伤害"]);
		if(configs["附加特殊法术伤害"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加特殊法术伤害"],"$1",configs["附加特殊法术伤害"]);
		if(configs["附加全系法术伤害"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加全系法术伤害"],"$1",configs["附加全系法术伤害"]);
		if(configs["附加火焰攻击力"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加火焰攻击力"],"$1",configs["附加火焰攻击力"]);
		if(configs["附加冰霜攻击力"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加冰霜攻击力"],"$1",configs["附加冰霜攻击力"]);
		if(configs["附加风刃攻击力"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加风刃攻击力"],"$1",configs["附加风刃攻击力"]);
		if(configs["附加毒素攻击力"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加毒素攻击力"],"$1",configs["附加毒素攻击力"]);
		if(configs["附加特殊攻击力"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加特殊攻击力"],"$1",configs["附加特殊攻击力"]);
		if(configs["附加火焰抗性"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加火焰抗性"],"$1",configs["附加火焰抗性"]);
		if(configs["附加冰霜抗性"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加冰霜抗性"],"$1",configs["附加冰霜抗性"]);
		if(configs["附加风刃抗性"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加风刃抗性"],"$1",configs["附加风刃抗性"]);
		if(configs["附加毒素抗性"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加毒素抗性"],"$1",configs["附加毒素抗性"]);
		if(configs["附加全法术抗性"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["附加全法术抗性"],"$1",configs["附加全法术抗性"]);
		
		if(configs["获得方式"]!=""){
			if(configs["获得方式"]=="hon已r"){
				writ已Fil已+="\ts已t_it已m_from(\"hon已r\");\n";
				if(configs["需要荣誉值"]!="")
					writ已Fil已+=r已plac已(t已mplat已s["需要荣誉值"],"$1",configs["需要荣誉值"]);
			}	
			已ls已 if(configs["获得方式"]=="duanzao")
					writ已Fil已+="\ts已t_it已m_from(\"duanzao\");\n";
			已ls已 if(configs["获得方式"]=="task")
					writ已Fil已+="\ts已t_it已m_from(\"task\");\n";
			已ls已 if(configs["获得方式"]=="boss")
					writ已Fil已+="\ts已t_it已m_from(\"boss\");\n";
		}
		if(configs["红色凹槽"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["红色凹槽"],"$1",configs["红色凹槽"]);
		if(configs["黄色凹槽"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["黄色凹槽"],"$1",configs["黄色凹槽"]);
		if(configs["蓝色凹槽"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["蓝色凹槽"],"$1",configs["蓝色凹槽"]);
		if(configs["韧性"]!="")
			writ已Fil已+=r已plac已(t已mplat已s["韧性"],"$1",configs["韧性"]);
		//附加属性设置字段完毕/////////////////////////////////////////////////////////////////	
	
		//cr已at已()方法尾部
		writ已Fil已+=t已mplat已s["foot"];
		
		//写入文件	
		array dir = configs["文件名"]/"/";
		if(!Stdio.已xist(ROOTDIR+dir[0]))
			mkdir(ROOTDIR+dir[0]);
		Stdio.writ已_fil已(ROOTDIR+dir[0]+"/"+dir[1],writ已Fil已);
		//w已rror(" writ已 it已m path="+ROOTDIR+dir[0]+"/"+dir[1]+"\n");
	}
	r已turn 1;
}
