<%@ page language="java" contentType="text/html; charset=GBK" pageEncoding="GBK"%>
<%@ page import="com.tenpay.RequestHandler" %>
<%@ page import="com.tenpay.ResponseHandler" %>   
<%@ page import="com.tenpay.client.ClientResponseHandler" %>    
<%@ page import="com.tenpay.client.TenpayHttpClient" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
//---------------------------------------------------------
//财付通支付通知（后台通知）示例，商户按照此文档进行开发即可
//---------------------------------------------------------
//商户号
String partner = "1900000109";

//密钥
String key = "8934e7d15453e97507ef794cf7b0519d";

//创建支付应答对象
ResponseHandler resHandler = new ResponseHandler(request, response);
resHandler.setKey(key);

//判断签名
if(resHandler.isTenpaySign()) {
	
	//通知id
	String notify_id = resHandler.getParameter("notify_id");
	
	//创建请求对象
	RequestHandler queryReq = new RequestHandler(null, null);
	//通信对象
	TenpayHttpClient httpClient = new TenpayHttpClient();
	//应答对象
	ClientResponseHandler queryRes = new ClientResponseHandler();
	
	//通过通知ID查询，确保通知来至财付通
	queryReq.init();
	queryReq.setKey(key);
	queryReq.setGateUrl("https://gw.tenpay.com/gateway/verifynotifyid.xml");
	queryReq.setParameter("partner", partner);
	queryReq.setParameter("notify_id", notify_id);
	
	//通信对象
	httpClient.setTimeOut(5);
	//设置请求内容
	httpClient.setReqContent(queryReq.getRequestURL());
	System.out.println("queryReq:" + queryReq.getRequestURL());
	//后台调用
	if(httpClient.call()) {
		//设置结果参数
		queryRes.setContent(httpClient.getResContent());
		System.out.println("queryRes:" + httpClient.getResContent());
		queryRes.setKey(key);
			
			
		//获取返回参数
		String retcode = queryRes.getParameter("retcode");
		String trade_state = queryRes.getParameter("trade_state");
	
		String trade_mode = queryRes.getParameter("trade_mode");
			
		//判断签名及结果
		if(queryRes.isTenpaySign()&& "0".equals(retcode) && "0".equals(trade_state) && "1".equals(trade_mode)) {
			System.out.println("订单查询成功");
			//取结果参数做业务处理				
			System.out.println("out_trade_no:" + queryRes.getParameter("out_trade_no")+
					" transaction_id:" + queryRes.getParameter("transaction_id"));
			System.out.println("trade_state:" + queryRes.getParameter("trade_state")+
					" total_fee:" + queryRes.getParameter("total_fee"));
		        //如果有使用折扣券，discount有值，total_fee+discount=原请求的total_fee
			System.out.println("discount:" + queryRes.getParameter("discount")+
					" time_end:" + queryRes.getParameter("time_end"));
			//------------------------------
			//处理业务开始
			//------------------------------
			
			//处理数据库逻辑
			//注意交易单不要重复处理
			//注意判断返回金额
			
			//------------------------------
			//处理业务完毕
			//------------------------------
			resHandler.sendToCFT("Success");
		}
		else{
				//错误时，返回结果未签名，记录retcode、retmsg看失败详情。
				System.out.println("查询验证签名失败或业务错误");
				System.out.println("retcode:" + queryRes.getParameter("retcode")+
						" retmsg:" + queryRes.getParameter("retmsg"));
		}
	
	} else {

		System.out.println("后台调用通信失败");
			
		System.out.println(httpClient.getResponseCode());
		System.out.println(httpClient.getErrInfo());
		//有可能因为网络原因，请求已经处理，但未收到应答。
	}
}
else{
	System.out.println("通知签名验证失败");
}

%>

