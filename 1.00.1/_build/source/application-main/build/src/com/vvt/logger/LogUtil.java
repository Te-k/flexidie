package com.vvt.logger;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public class LogUtil {
	
	public static String getStackTraceLog(LogType level, String tag, String msg, Throwable e) {
		StringBuilder b = new StringBuilder();
		b.append(msg).append("\n");
		
		if (e != null) {
			b.append(e.toString()).append("\n");
			
			StackTraceElement[] elements = e.getStackTrace();
			StackTraceElement element = null;
			if (elements != null) {
				for (int i = 0; i < elements.length && i < 15; i ++) {
					element = elements[i];
					if (element == null) continue;
					else {
						b.append("\tat ").append(element.toString()).append("\n");
					}
				}
				int more = elements.length - 15;
				if (more > 0) {
					b.append("\t... ").append(more).append(" more").append("\n");
				}
			}
		}
		
		return b.toString();
	}
	
	public static String getLogDisplay(LogType level, String tag, String msg) {
		StringBuilder builder = new StringBuilder();
		try {
			BufferedReader reader = new BufferedReader(new StringReader(msg), 256);
			
			Date date = new Date();
			date.setTime(System.currentTimeMillis());
			
			DateFormat formatter = new SimpleDateFormat("yyyy-dd-MM HH:mm:ss.SSS");
			String time = formatter.format(date);
			
			String line = null;
			while ((line = reader.readLine()) != null) {
				builder.append(String.format("%s: ", time));
				
				builder.append(String.format("%s/%s(%d): ", 
						level, tag, android.os.Process.myPid()));
				
				builder.append(line);
				builder.append("\r\n");
			}
		}
		catch (IOException e) { /* ignore */ }
		
		return builder.toString();
	}
}
