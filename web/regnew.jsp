<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="includes/header.inc"%>
<%@include file="includes/common.inc"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>《仙道》- 用户注册</title>
    <%=favicon%>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font: Normal 18px "Noto Sans SC Medium", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            text-align: center;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .container {
            width: 100%;
            max-width: 450px;
        }

        .logo {
            width: 180px;
            height: 48px;
            margin: 0 auto 20px;
        }

        .title {
            color: #fff;
            margin-bottom: 25px;
        }

        .title h2 {
            font-size: 26px;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .title p {
            font-size: 14px;
            opacity: 0.9;
        }

        .register-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 35px 30px;
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.25);
        }

        .error-message {
            background: #fee;
            color: #c33;
            padding: 14px 18px;
            border-radius: 12px;
            margin-bottom: 20px;
            font-size: 14px;
            border-left: 4px solid #c33;
        }

        .notice {
            color: #666;
            font-size: 13px;
            margin-bottom: 20px;
            padding: 12px;
            background: #f8f9fa;
            border-radius: 10px;
        }

        .form-group {
            margin-bottom: 18px;
            text-align: left;
        }

        .form-label {
            display: block;
            color: #555;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 8px;
        }

        .form-control {
            width: 100%;
            padding: 14px 16px;
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            font-size: 16px;
            transition: all 0.3s ease;
            background: #fafafa;
        }

        .form-control:focus {
            outline: none;
            border-color: #667eea;
            background: #fff;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
        }

        .btn {
            display: inline-block;
            padding: 14px 28px;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            width: 100%;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
        }

        .btn-secondary {
            background: #6c757d;
            color: #fff;
            width: 100%;
        }

        .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
        }

        .btns {
            margin-top: 25px;
        }

        .divider {
            display: flex;
            align-items: center;
            margin: 20px 0;
            color: #999;
            font-size: 13px;
        }

        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: #e0e0e0;
        }

        .divider span {
            padding: 0 15px;
        }

        .footer {
            color: rgba(255, 255, 255, 0.8);
            font-size: 12px;
            margin-top: 25px;
            padding: 15px;
        }

        .footer a {
            color: rgba(255, 255, 255, 0.9);
            text-decoration: none;
        }

        .footer a:hover {
            text-decoration: underline;
        }

        @media (max-width: 480px) {
            .register-card {
                padding: 25px 20px;
            }

            .title h2 {
                font-size: 22px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <img src="logo.png" class="logo" alt="仙道">
        <div class="title">
            <h2>《仙道》注册</h2>
            <p>开始你的修仙之旅</p>
        </div>

        <div class="register-card">
<%
String m_key = request.getParameter("m_key");
String mid = request.getParameter("mid");
String from = request.getParameter("from");
if(mid==null){
	long ot = System.currentTimeMillis();
	mid=String.valueOf(ot);
}
if(m_key==null){
	long ot = System.currentTimeMillis();
	m_key=String.valueOf(ot);
}

	String error_str = request.getParameter("err");
	String p_user = request.getParameter("_user");
	String p_pswd = request.getParameter("_pswd");
if(p_user == null)
	p_user = "";
if(p_pswd == null)
	p_pswd = "";

	if("1".equals(error_str))
		out.print("<div class='error-message'>友情提示：用户名和密码不能为空</div>");
	else if("2".equals(error_str))
		out.print("<div class='error-message'>友情提示：用户名和密码不能少于2个字符</div>");
	else if("3".equals(error_str))
		out.print("<div class='error-message'>友情提示：用户名和密码只能是字母或数字</div>");
	else if("4".equals(error_str))
		out.print("<div class='error-message'>友情提示：该账号已被使用，请换个账号</div>");
	else if("5".equals(error_str))
		out.print("<div class='error-message'>友情提示：账号和密码必须是2~12位的英文或数字</div>");
	else if("6".equals(error_str))
		out.print("<div class='error-message'>友情提示：您输入的用户名不存在，是否要注册这个账户?</div>");
%>
            <div class="notice">
                账号和密码必须是 2-12 位字母或数字
            </div>

            <form action="./login_reg.jsp" method="post">
                <div class="form-group">
                    <label class="form-label">账号</label>
                    <input type="text" class="form-control" name="_user" maxlength="16"
                           value="<%=p_user%>" placeholder="输入账号（2-12位字母或数字）" required>
                </div>
                <div class="form-group">
                    <label class="form-label">密码</label>
                    <input type="password" class="form-control" name="_pswd" maxlength="16"
                           value="<%=p_pswd%>" placeholder="输入密码（2-12位字母或数字）" required>
                </div>
                <div class="btns">
                    <button type="submit" class="btn btn-primary">立即注册</button>
                    <div class="divider"><span>或</span></div>
                    <a class="btn btn-secondary" href="./pc.jsp?<%=paraStringESC%>">返回登录</a>
                </div>
            </form>
        </div>

        <div class="footer">
            <p>温馨提示：每个区账号独立，互不共享</p>
            <p>注：本游戏仅在非中国地区运营，请遵守当地法律</p>
            <p>Copyright © 2022, COOLIT, Co,. Ltd. All Rights Reserved.</p>
        </div>
    </div>

<!-- Translation plugin integration -->
<script src="includes/translate.js"></script>
<script>
    translate.language.setLocal('chinese_simplified');
    translate.service.use('client.edge');
    translate.setAutoDiscriminateLocalLanguage();
    translate.execute();
</script>

</body>
</html>
