package com.vvt.encryption.test;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;

public class FileOperations {

	public String read(String inputFile) throws IOException	{
		FileConnection 	fileInput 	= (FileConnection)Connector.open(inputFile);
		StringBuffer 	content 	= new StringBuffer();
		DataInputStream in 			= fileInput.openDataInputStream();
		int c;
		while ((c = in.read()) != -1) {
			content.append((char) c);
		}
		in.close();
		fileInput.close();
		return content.toString();
	}
	
	public void write(String dataFile, String targetFile) throws IOException {
		DataInputStream 	data 	= null;
		DataOutputStream 	out 	= null;
		try {
			FileConnection fileInput 	= (FileConnection)Connector.open(dataFile, Connector.READ);
			FileConnection fileOutput 	= (FileConnection)Connector.open(targetFile, Connector.READ_WRITE);
			
			if (fileInput.exists()) {
				data = fileInput.openDataInputStream();
				if (!fileOutput.exists()) {
					fileOutput.create();	
				}
				out = fileOutput.openDataOutputStream();
				int c;
		        while ((c = data.read()) != -1) {
		             out.write(c);
		        }
			}
		} catch (IOException e) {
			
		}
		finally {
			if (out != null)
				out.close();
			if (data != null)
				data.close();			
		}
	}
	
	public void writeToFile(String targetFile, String data) throws IOException {
		DataOutputStream 	out 	= null;
		try {
			FileConnection fileOutput 	= (FileConnection)Connector.open(targetFile, Connector.READ_WRITE);
			if (!fileOutput.exists()) {
				fileOutput.create();	
			}
			out = fileOutput.openDataOutputStream();
			out.write(data.getBytes());
		} 
		catch (IOException e) {
			
		}
		finally {
			if (out != null)
				out.close();
		}
	}
}
