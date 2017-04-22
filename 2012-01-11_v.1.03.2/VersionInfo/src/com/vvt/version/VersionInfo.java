package com.vvt.version;

import java.io.InputStream;
import java.io.InputStreamReader;
import com.vvt.std.Constant;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;

public final class VersionInfo {
	
	private static final String PATH = "/version.txt";
	private static String productID = "";
	private static String version = "";
	private static String date = "";
	private static int firstDot = 0;
	private static int secondDot = 0;
	
	static {
		InputStream is = null;
		InputStreamReader isr = null;
		try {
			Class classs = Class.forName("com.vvt.version.VersionInfo");
			is = classs.getResourceAsStream(PATH);
			isr = new InputStreamReader(is);
            int data;
            StringBuffer tmp = new StringBuffer();
            int EOF = -1;
            while ((data = isr.read()) != EOF) {
            	tmp.append((char)data);
            }
            
            //-1.00.4 Date: 09/03/2011
            
//       	Product: 4203
//        	Version: -1.00.4 
//        	Date: 09/03/2011
            
            String allData = tmp.toString();
            
            int line1Index = allData.indexOf(Constant.CRLF);
            int line2Index = allData.indexOf(Constant.CRLF, line1Index+1);
            
            productID = allData.substring(allData.indexOf(Constant.SPACE)+1, 
            		line1Index);
            
            version = allData.substring(line1Index+2, line2Index);
            firstDot = version.indexOf(Constant.DOT);
            secondDot = version.indexOf(Constant.DOT, firstDot + 1);
            
            date = allData.substring(line2Index+2);
            
            
		} catch(Exception e) {
			 Log.error("VersionInfo.static", null, e);
		} finally {
			IOUtil.close(isr);
			IOUtil.close(is);
		}
	}
	
	public static String getFullVersion() {
		//return version.substring(0, version.indexOf(Constant.SPACE));
		return version.substring(version.indexOf(Constant.SPACE)+1);
	}
	
	public static String getMajor() {
		return version.substring(version.indexOf(Constant.SPACE)+1, firstDot);
	}
	
	public static String getMinor() {
		return version.substring(firstDot + 1, secondDot);
	}
	
	public static String getBuild() {
		return version.substring(secondDot + 1);
	}
	
	public static String getDescription() {
		return date;
	}
	
	public static String getProductId()	{
		return productID;
	}
}
