package com.vvt.compression;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;

import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;

import net.rim.device.api.compress.GZIPInputStream;
import net.rim.device.api.compress.GZIPOutputStream;
import net.rim.device.api.io.IOUtilities;
import net.rim.device.api.util.DataBuffer;

public class GZipDecompressor extends Thread {
	
	private String 				_fileInputPath 	= "";
	private String 				_fileOutputPath = "";
	private GZipDecompressListener _listener 		= null;
	
	public GZipDecompressor(String inputFile, String outputFile, GZipDecompressListener listener)	{
		_fileInputPath 	= inputFile;
		_fileOutputPath = outputFile;
		_listener		= listener;
	}
	
	public void decompress()	{
		this.start();
	}
	
	public void run()	{
		try {
			String input = readFile(_fileInputPath);
			if (input != null) {
				byte[] zzz = decompress(input.getBytes());
				if (zzz != null) {
					writeFile(_fileOutputPath, zzz);
					_listener.DecompressCompleted();
				}			
			}
			else {
				_listener.DecompressError("IOException:Cannot access "+_fileInputPath+" !?");
			}
		} catch (IOException e) {
			_listener.DecompressError("Compress error !?");
		}
	}
		
	public static byte[] decompress(byte[] data) throws IOException	
	{
		GZIPInputStream gin = new GZIPInputStream(new ByteArrayInputStream(data));
		byte[] bytes = IOUtilities.streamToBytes(gin);
		DataBuffer db = new DataBuffer();
		db.setData(bytes, 0, bytes.length);
		return db.getArray();
	}

	private static String readFile(String filePath) {
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
	    	return null;
	    }
	}
	
	private static boolean writeFile(String filePath,byte [] data)	{
		try {
			FileConnection file = (FileConnection)Connector.open(filePath);
			if(!file.exists())	{	file.create();	}
			file.setWritable(true);
			OutputStream outStream = file.openOutputStream();
			outStream.write(data);
			outStream.close();
			file.close();
			return true;
		}
		catch (IOException e) {
			return false;
		}
	}
	
}
