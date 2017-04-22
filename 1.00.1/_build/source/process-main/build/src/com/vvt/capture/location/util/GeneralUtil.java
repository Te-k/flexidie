package com.vvt.capture.location.util;

import java.text.DateFormat;
import java.text.SimpleDateFormat;

public class GeneralUtil {
	
	private static DateFormat sDateFormat;
	
	 public static DateFormat getDateFormatter() {
	        if (sDateFormat == null) {
	            sDateFormat = new SimpleDateFormat("dd/MM/yy HH:mm:ss");
	        }
	        return sDateFormat;
	    }
}
