package com.tenpay.util;

import org.json.JSONObject;

public class JsonUtil {

	public static String getJsonValue(String rescontent, String key) {
		JSONObject jsonObject;
		String v = null;
		try {
			jsonObject = new JSONObject(rescontent);
			v = jsonObject.getString(key);
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		return v;
	}
}
