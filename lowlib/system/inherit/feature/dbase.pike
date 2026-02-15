mapping data=([]);
mapping data_tmp=([]);
string tmp;


mixed `[](string key, void|mixed n)
{
	// Pike 9: Second parameter controls access mode
	// n == 2 or n == "RAW" means bypass operator overload, access raw variable value directly
	// This is used by pikenv_save_object() to prevent saving computed property values
	if((intp(n) && n == 2) || (stringp(n) && n == "RAW")){
		// Return raw variable value directly, without calling -> operator
		return ::`[](key, 2);
	}

	if(key&&sizeof(key)&&key[0]=='/'){
		array a=key[1..]/"/";
		if(!data)data=([]);
		if(!data_tmp)data_tmp=([]);
		mapping m=data;
		int start_idx=0;
		if(sizeof(a)>0&&a[0]=="tmp"){
			m=data_tmp;
			start_idx=1;
		}
		for(int i=start_idx;i<sizeof(a)-1;i++){
			string s=a[i];
			if(!mappingp(m[s])){
				return 0;
			}
			m=m[s];
		}
		return m[a[-1]];
	}else{
		// 直接返回变量值，不调用->操作符（避免触发query_xxx方法）
		// 修复name_cn等变量被query方法修改后读取的问题
		return ::`[](key,2);
	}
}

mixed `[]=(string key, mixed val, void|mixed n)
{
	// Pike 9: Third parameter controls access mode
	// n == 2 or n == "RAW" means bypass operator overload, set raw variable directly
	if((intp(n) && n == 2) || (stringp(n) && n == "RAW")){
		// Set raw variable value directly, without calling ->= operator
		return ::`[]=(key,val,2);
	}
	if(key&&sizeof(key)&&key[0]=='/'){
		array a=key[1..]/"/";
		if(!data)data=([]);
		if(!data_tmp)data_tmp=([]);
		mapping m=data;
		int start_idx=0;
		if(sizeof(a)>0&&a[0]=="tmp"){
			m=data_tmp;
			start_idx=1;
		}
		for(int i=start_idx;i<sizeof(a)-1;i++){
			string s=a[i];
			if(!mappingp(m[s])){
				m[s]=([]);
			}
			m=m[s];
		}
		return m[a[-1]]=val;

	}
	else{
		// 直接设置变量，不调用->=操作符（避免触发setter方法）
		// 修复name_cn等变量被setter方法修改后保存的问题
		return ::`[]=(key,val,2);
	}
}

mixed _m_delete(string key)
{
	if(key&&sizeof(key)&&key[0]=='/'){
		array a=key[1..]/"/";
		if(!data)data=([]);
		if(!data_tmp)data_tmp=([]);
		mapping m=data;
		int start_idx=0;
		if(sizeof(a)>0&&a[0]=="tmp"){
			m=data_tmp;
			start_idx=1;
		}
		for(int i=start_idx;i<sizeof(a)-1;i++){
			string s=a[i];
			if(!mappingp(m[s])){
				m[s]=([]);
			}
			m=m[s];
		}
		return m_delete(m,a[-1]);
	}
	else{
		return 0;
	}
}

void set_tmp(string s)
{
	tmp=s;
}
int cat_tmp()
{
	write(tmp);
	return 1;
}
string query_tmp()
{
	return tmp;
}

/*
string test;
void main()
{
	this_object()["/tmp/xixi/haha"]="faint";
	write(this_object()["/tmp/xixi"]["haha"]);
	this_object()["test"]="faint";
	write(this_object()["test"]);
}
*/

