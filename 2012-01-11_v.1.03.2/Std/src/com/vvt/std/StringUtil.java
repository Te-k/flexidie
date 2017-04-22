package com.vvt.std;

public class StringUtil {

	public static String getTextMessage(int patternLength, String source, String[] replacement) {
		String message = source;
		String[] pattern = new String[patternLength];
		for (int i = 0; i < patternLength; i++) {
			pattern[i] = "%" + i + "N";
		}
		for (int i = 0; i < pattern.length; i++) {
			message = StringUtil.replace(message, pattern[i], replacement[i]);
		}
		return message;
	}
	
	private static String replace(String source, String pattern, String replacement) {	
		//If source is null then Stop
		//and return empty String.
		if (source == null) {
			return "";
		}
		StringBuffer sb = new StringBuffer();
		//Intialize Index to -1
		//to check against it later 
		int idx = -1;
		//Intialize pattern Index
		int patIdx = 0;
		//Search source from 0 to first occurrence of pattern
		//Set Idx equal to index at which pattern is found.
		idx = source.indexOf(pattern, patIdx);
		//If Pattern is found, idx will not be -1 anymore.
		if (idx != -1) {
			//append all the string in source till the pattern starts.
			sb.append(source.substring(patIdx, idx));
			//append replacement of the pattern.
			sb.append(replacement);
			//Increase the value of patIdx
			//till the end of the pattern
			patIdx = idx + pattern.length();
			//Append remaining string to the String Buffer.
			sb.append(source.substring(patIdx));
		}
        if ( sb.length() == 0) {
            return source;
        } else {
            return sb.toString();
        }
	}
}
