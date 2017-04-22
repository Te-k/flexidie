package com.vvt.daemon.email;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.InflaterInputStream;

import com.vvt.logger.FxLog;


public class GmailUtil {
	
	private static final String TAG = "GmailUtil";
	private static final boolean LOGE = Customization.ERROR;
	
	public static String getUncompressedContent(byte[] input) {
		StringBuffer buff = new StringBuffer();
        
		try {
        	InflaterInputStream in = new InflaterInputStream(new ByteArrayInputStream(input));
        	BufferedReader reader = new BufferedReader(new InputStreamReader(in, "UTF-8"));
        	
        	String line = null;
        	while ((line = reader.readLine()) != null) {
        		buff.append(line);
        	}
        }
        catch (IOException e) {
        	if(LOGE) FxLog.e(TAG, e.getMessage(), e);
        }
        return buff.toString();
	}
	
	public static String getCleanedEmailBody(String input) {
		if (input == null) {
			return null;
		}
		
		Pattern p = null;
		Matcher m = null;
		String output = null;
		
		// replace BR with \n
		p = Pattern.compile("<[/]*br[^>]*>");
		m = p.matcher(input);
		output = m.replaceAll("\n");
		
		p = Pattern.compile("<[/]*p[^>]*>");
		m = p.matcher(output);
		output = m.replaceAll("\n");
		
		p = Pattern.compile("<[^<>]*>");
		m = p.matcher(output);
		output = m.replaceAll("");
		
		return output.trim();
	}
}
