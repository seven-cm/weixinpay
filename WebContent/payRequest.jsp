<%@page import="java.util.Date"%>
<%@page import="com.tenpay.AccessTokenRequestHandler"%>
<%@ page language="java" contentType="text/html; charset=GBK"
	pageEncoding="GBK"%>
<%@ page import="com.tenpay.ClientRequestHandler"%>
<%@ page import="com.tenpay.PackageRequestHandler"%>
<%@ page import="com.tenpay.PrepayIdRequestHandler"%>
<%@ page import="com.tenpay.util.TenpayUtil"%>
<%@ page import="com.tenpay.util.MD5Util"%>
<%@ page import="com.tenpay.util.WXUtil"%>
<%@ page import="com.tenpay.util.ConstantUtil"%>
<%@ page import="com.tenpay.RequestHandler"%>
<%@ page import="com.tenpay.ResponseHandler"%>
<%@ page import="com.tenpay.client.TenpayHttpClient"%>
<%@ page import="java.io.BufferedWriter"%>
<%@ page import="java.io.BufferedOutputStream"%>
<%@ page import="java.io.OutputStream"%>
<%@ page import="com.tenpay.util.Sha1Util"%>
<%@ page import="java.util.SortedMap"%>
<%@ page import="java.util.TreeMap"%>

<%
	response.resetBuffer();
	response.setHeader("ContentType", "text/xml");
	out.println("<?xml version=\"1.0\" encoding=\"GBK\"?>");
	out.println("<root>");
	//---------------------------------------------------------
	//微信支付请求示例，商户按照此文档进行开发即可 
	//---------------------------------------------------------

	//接收财付通通知的URL
	String notify_url = "http://127.0.0.1:8180/tenpay_api_b2c/payNotifyUrl.jsp";

	//---------------生成订单号 开始------------------------
	//当前时间 yyyyMMddHHmmss
	String currTime = TenpayUtil.getCurrTime();
	//8位日期
	String strTime = currTime.substring(8, currTime.length());
	//四位随机数
	String strRandom = TenpayUtil.buildRandom(4) + "";
	//10位序列号,可以自行调整。
	String strReq = strTime + strRandom;
	//订单号，此处用时间加随机数生成，商户根据自己情况调整，只要保持全局唯一就行
	String out_trade_no = strReq;
	//---------------生成订单号 结束------------------------

	PackageRequestHandler packageReqHandler = new PackageRequestHandler(request, response);//生成package的请求类 
	PrepayIdRequestHandler prepayReqHandler = new PrepayIdRequestHandler(request, response);//获取prepayid的请求类
	ClientRequestHandler clientHandler = new ClientRequestHandler(request, response);//返回客户端支付参数的请求类
	packageReqHandler.setKey(ConstantUtil.PARTNER_KEY);

	int retcode;
	String retmsg = "";
	String xml_body = "";
	//获取token值 
	String token = AccessTokenRequestHandler.getAccessToken();
	if (!"".equals(token)) {
		//设置package订单参数
		packageReqHandler.setParameter("bank_type", "WX");//银行渠道
		packageReqHandler.setParameter("body", "测试"); //商品描述   
		packageReqHandler.setParameter("notify_url", notify_url); //接收财付通通知的URL  
		packageReqHandler.setParameter("partner", ConstantUtil.PARTNER); //商户号    
		packageReqHandler.setParameter("out_trade_no", out_trade_no); //商家订单号   
		packageReqHandler.setParameter("total_fee", "1"); //商品金额,以分为单位  
		packageReqHandler.setParameter("spbill_create_ip",request.getRemoteAddr()); //订单生成的机器IP，指用户浏览器端IP  
		packageReqHandler.setParameter("fee_type", "1"); //币种，1人民币   66
		packageReqHandler.setParameter("input_charset", "GBK"); //字符编码

		//获取package包
		String packageValue = packageReqHandler.getRequestURL();

		String noncestr = WXUtil.getNonceStr();
		String timestamp = WXUtil.getTimeStamp();
		String traceid = "";
		////设置获取prepayid支付参数
		prepayReqHandler.setParameter("appid", ConstantUtil.APP_ID);
		prepayReqHandler.setParameter("appkey", ConstantUtil.APP_KEY);
		prepayReqHandler.setParameter("noncestr", noncestr);
		prepayReqHandler.setParameter("package", packageValue);
		prepayReqHandler.setParameter("timestamp", timestamp);
		prepayReqHandler.setParameter("traceid", traceid);

		//生成获取预支付签名
		String sign = prepayReqHandler.createSHA1Sign();
		//增加非参与签名的额外参数
		prepayReqHandler.setParameter("app_signature", sign);
		prepayReqHandler.setParameter("sign_method",
				ConstantUtil.SIGN_METHOD);
		String gateUrl = ConstantUtil.GATEURL + token;
		prepayReqHandler.setGateUrl(gateUrl);

		//获取prepayId
		String prepayid = prepayReqHandler.sendPrepay();
		//吐回给客户端的参数
		if (null != prepayid && !"".equals(prepayid)) {
			//输出参数列表
			clientHandler.setParameter("appid", ConstantUtil.APP_ID);
			clientHandler.setParameter("appkey", ConstantUtil.APP_KEY);
			clientHandler.setParameter("noncestr", noncestr);
			//clientHandler.setParameter("package", "Sign=" + packageValue);
			clientHandler.setParameter("package", "Sign=WXPay");
			clientHandler.setParameter("partnerid", ConstantUtil.PARTNER);
			clientHandler.setParameter("prepayid", prepayid);
			clientHandler.setParameter("timestamp", timestamp);
			//生成签名
			sign = clientHandler.createSHA1Sign();
			clientHandler.setParameter("sign", sign);

			xml_body = clientHandler.getXmlBody();
			retcode = 0;
			retmsg = "OK";
		} else {
			retcode = -2;
			retmsg = "错误：获取prepayId失败";
		}
	} else {
		retcode = -1;
		retmsg = "错误：获取不到Token";
	}
	/**
		打印debug信息
	 */
	System.out.println("\r\ndebuginfo:\r\n" + new Date());
	System.out.println(packageReqHandler.getDebugInfo());
	System.out.println(prepayReqHandler.getDebugInfo());
	System.out.println(clientHandler.getDebugInfo());
	out.println("<retcode>" + retcode + "</retcode");
	out.println("<retmsg>" + retmsg + "<retmsg>");
	if (!"".equals(xml_body)) {
		out.println(xml_body);
	}
	out.println("</root>");
%>
