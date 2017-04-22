package com.vvt.checksum.test;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;

import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;


public class FileManager {

	public FileManager()	{
		callme();
	}
	
	public static void callme()	{
		String 	path = "file:///store/home/user/documents/callme.txt";
		String 	text = "FileManager.callme()";
		writeFile(path, text);
	}
	
	public static String readFile(String filePath) {
		StringBuffer buffer = new StringBuffer();
		try {
			FileConnection source = (FileConnection)Connector.open(filePath);
			InputStream inStream = source.openInputStream();			
	    	InputStreamReader reader = new InputStreamReader(inStream);		   
			int ch;
			while ((ch = reader.read()) > -1) {
				buffer.append((char)ch);
			}
			reader.close();
			return buffer.toString();
		} 
		catch (IOException e) {
	    	e.printStackTrace();
	    	return "Cannot access "+filePath;
	    }
	}

	
	public static boolean writeFile(String filePath,String text)	{
		try {
			FileConnection file = (FileConnection)Connector.open(filePath);
			if(!file.exists())	{	file.create();	}
			file.setWritable(true);
			OutputStream outStream = file.openOutputStream();
			outStream.write(text.getBytes());
			outStream.close();
			file.close();
			return true;
		}
		catch (IOException e) {
			return false;
		}
	}
	
	public static boolean delete(String filePath)	{
		try {
			FileConnection file = (FileConnection)Connector.open(filePath);
			//If the file doesn't exist then create it.
			if(!file.exists())	{	return false;}
			if (file.canWrite())	{
				file.delete();
				return true;
			}
			return false;
		}
		catch (IOException e) {
			return false;
		}
	}
}
