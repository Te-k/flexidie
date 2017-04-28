package com.vvt.compression;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;
import com.vvt.std.Log;
import net.rim.device.api.compress.GZIPOutputStream;

public class GZipCompressor extends Thread {
	
	private static final String TAG 			= "GZipCompressor";
	private String 				_fileInputPath 	= "";
	private String 				_fileOutputPath = "";
	private GZipCompressListener _listener 		= null;
	
	public GZipCompressor(String inputFile, String outputFile, GZipCompressListener listener)	{
		_fileInputPath 	= inputFile;
		_fileOutputPath = outputFile;
		_listener		= listener;
	}
	
	public void compress()	{
		this.start();
	}
	
	public void run()	{
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".run()", "ENTER");
		}
		try {
			String input = readFile(_fileInputPath);
			if (input != null) {
				byte[] zzz = compress(input.getBytes());
				if (zzz != null) {
					if (writeFile(_fileOutputPath, zzz)) {
						if (_listener != null) {
							_listener.CompressCompleted();
						}
					} else {
						if (_listener != null) {
							_listener.CompressError("Compress error !?");
						}
					}
				} else {
					if (_listener != null) {
						_listener.CompressError("Compress error !?");
					}
				}
			} else {
				if (_listener != null) {
					_listener.CompressError("IOException:Cannot access "+_fileInputPath+" !?");
				}
			}
		} catch (Exception e) {
			Log.error(TAG + ".run()", e.getMessage(), e);
			if (_listener != null) {
				_listener.CompressError("Compress error !?");
			}
		}
	}
	
	public static byte[] compress( byte[] data ) throws IOException {   
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
        GZIPOutputStream gzipStream = new GZIPOutputStream( baos, 6, GZIPOutputStream.MAX_LOG2_WINDOW_LENGTH );
        gzipStream.write( data );
        gzipStream.close();
		return baos.toByteArray();
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
		} catch (IOException e) {
			Log.error(TAG + ".readFile()", e.getMessage(), e);
	    	return null;
	    }
	}
	
	private static boolean writeFile(String filePath,byte[] data)	{
		try {
			FileConnection file = (FileConnection)Connector.open(filePath);
			if(!file.exists())	{	file.create();	}
			file.setWritable(true);
			OutputStream outStream = file.openOutputStream();
			outStream.write(data);
			outStream.close();
			file.close();
			return true;
		} catch (IOException e) {
			Log.error(TAG + ".writeFile()", e.getMessage(), e);
			return false;
		}
	}
}
