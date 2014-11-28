package util;

import javax.servlet.http.HttpServletRequest;

public class ResponsePage {
	/**
	 *请求返回信息页面
	 * @return
	 */
    private String getAjaxResponsePage() {
        return "ajax_result/ajax_result";
    }
    
    public String responseAjax(HttpServletRequest request,
            String strJson) {
        request.setAttribute("result", strJson);
        return getAjaxResponsePage();
    }
}
