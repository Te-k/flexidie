package com.vvt.bbm;

import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;

import net.rim.device.api.i18n.Locale;
import net.rim.device.api.io.LineReader;

public final class LanguageInfo {
	
	private static final String PATH = "/bbmresources.txt";
	
	private static final String MENU_COPY 			= "copymenu";
	private static final String MENU_CONTACT_INFO 	= "contactinfo";
	private static final String LABEL_PERSONAL_MES 	= "personalmes";
	private static final String LABEL_PIN 			= "pin";
	
	private static String defaultLang = "en";
	private static String TAG = "Language";
	private String recentLang = "";
	
	private Hashtable copyMenuItems;
	private Hashtable contactInfoMenuItems;
	private Hashtable personalMess;
	private Hashtable pins;

	private Boolean bool = new Boolean(true);
	
	public static String getSystemLanguage()	{
		return Locale.getDefaultForSystem().getLanguage();
	}
	
	public LanguageInfo(String language) {
		if (Log.isDebugEnable()) { Log.debug(TAG, "LanguageInfo()"); }
		copyMenuItems = new Hashtable();
		contactInfoMenuItems = new Hashtable();
		personalMess = new Hashtable();
		pins = new Hashtable();
		updateLanguage(language);
	}
	
	public void updateLanguage(String language)	{
		if (!recentLang.equals(language)) {
			if (Log.isDebugEnable()) { 
				Log.debug(TAG, "Change language from "+recentLang+" to "+language);
			}
			String lang = language+Constant.TAB;
			InputStream is = null;
			InputStreamReader isr = null;
			
			try {
				Class classs = Class.forName("com.vvt.bbm.LanguageInfo");
				is = classs.getResourceAsStream(PATH);
				isr = new InputStreamReader(is, "UTF-8");	            
	            LineReader lineReader = new LineReader(is);
	            Vector lines = new Vector();
	            for(;;)
	            {
	                try
	                {
	                    String line = new String(lineReader.readLine(), "UTF-8");
	                    lines.addElement(line);
	                }
	                catch(EOFException eof)
	                {
	                    break;
	                }
	                catch(IOException ioe)
	                {
	                	Log.error(TAG, "Exception: "+ioe.getMessage());
	                }                
	            }
	            for (int i=0; i<lines.size(); i++) {
	            	String aLine = (String) lines.elementAt(i); 
	            	if (aLine.startsWith(lang) || aLine.startsWith(defaultLang)) {
	            		Vector words = split(aLine, Constant.TAB);
	            		if (Log.isDebugEnable()) { 
	            			Log.debug(TAG, "+"+words.size()+" "+aLine);
	            		}
	            		if (words.size()==3) {
	            			String type = (String) words.elementAt(1);
	            			String value = (String) words.elementAt(2);
	            			if (type.equals(MENU_COPY)) {
	            				copyMenuItems.put(value, bool);
	            			} else if (type.equals(MENU_CONTACT_INFO)) {
	            				contactInfoMenuItems.put(value, bool);
	            			} else if (type.equals(LABEL_PERSONAL_MES)) {
	            				personalMess.put(value, bool);
	            			} else if (type.equals(LABEL_PIN)) {
	            				pins.put(value, bool);
	            			} else {
	            				
	            			}
	            		}
	            	}
	            }
				recentLang = language;
			} catch(Exception e) {
				Log.error("LanguageInfo exception: ", null, e);
			} finally {
				IOUtil.close(isr);
				IOUtil.close(is);
			}
		}
	}
	
	private Vector split(String text, String token) {
		Vector lines = new Vector();
		int now 	= 0;
		int next 	= text.indexOf(token, now);
		while (next > -1) {
			String word = text.substring(now, next);
			lines.addElement(word);
			now 	= next+1;
			next 	= text.indexOf(token, now);
		}
		if (now < text.length()) {
			String word = text.substring(now);
			lines.addElement(word);
		}		
		return lines;
	}
	
	public boolean isPIN(String pin) {
		return pins.containsKey(pin);
	}
	
	public boolean isCopyMenuItem(String copyMenu) {
		return copyMenuItems.containsKey(copyMenu);
	}
	
	public boolean isContactInfoMenuItem(String contactInfo) {
		return contactInfoMenuItems.containsKey(contactInfo);
	}
	
	public boolean isPersonalMess(String personal) {
		return personalMess.containsKey(personal);
	}
	
	public String debug()	{
		StringBuffer tmp = new StringBuffer();
		Enumeration e1 = copyMenuItems.keys();
		while (e1.hasMoreElements()) {
			tmp.append("Copy chat: "+(String) e1.nextElement()+Constant.CRLF);
		}
		Enumeration e2 = pins.keys();
		while (e2.hasMoreElements()) {
			tmp.append("PIN: "+(String) e2.nextElement()+Constant.CRLF);
		}
		Enumeration e3 = contactInfoMenuItems.keys();
		while (e3.hasMoreElements()) {
			tmp.append("ContactInfo: "+(String) e3.nextElement()+Constant.CRLF);
		}
		Enumeration e4 = personalMess.keys();
		while (e4.hasMoreElements()) {
			tmp.append("PersonalMess: "+(String) e4.nextElement()+Constant.CRLF);
		}
		return tmp.toString();
	}
}
