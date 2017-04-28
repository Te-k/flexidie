package com.vvt.std;

import java.io.ByteArrayInputStream;
import java.io.InputStreamReader;

public class HtmlParser {
	
   public String convert(String source) throws Exception {
	  String result = "";
	  InputStreamReader input = null;
	  try {
		 byte[] sourceAsBytes = source.getBytes();
		 input = new InputStreamReader(new ByteArrayInputStream(sourceAsBytes));
		 int c = input.read();
		 int index = 0;
		 while (c != -1) {
			try {
			   if (c == '<') {
				  int level = 1;
				  while (level > 0) {
					 c = input.read();
					 index++;
					 if (c == -1)
						break;
					 if (c == '<') {
						level++;
					 } else if (c == '>') {
						level--;
					 }
				  }
			   } else if (c == '&') {
				  int indexAtMark = index;
				  input.mark(1);
				  c = input.read();
				  index++;
				  while (Character.isLowerCase((char) c) || Character.isUpperCase((char) c)) {
					 input.mark(1);
					 indexAtMark = index;
					 c = input.read();
					 index++;
				  }
				  if (c != ';') {
					 input.reset();
					 index = indexAtMark;
				  }
			   } else {
				  if (result.endsWith("\n")) {
					 if (c!=10)
						result += source.substring(index, index + 1);
				  }
				  else
					 result += source.substring(index, index + 1);
				  
			   }
			} catch (Exception e) {}
			c = input.read();
			index++;
		 }
	  } catch (Exception e) {
		 if (input != null) {
			 input.close();
		 }
		 throw e;
	  }
	  return result;
   }
}