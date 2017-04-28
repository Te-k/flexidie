package com.vvt.checksum;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;

import com.vvt.std.Log;

public class CRC32 extends Thread {
	
	private final String	TAG 		= "CRC32";
	private long			_offset		= 0;
	private int 			_crcValue 	= 0;
	private String 			_filename	= "";
	private CRC32Listener 	_listener	= null;
	
	public CRC32(String dataFile, CRC32Listener listener)	{
		_offset		= 0L;
		_crcValue 	= net.rim.device.api.util.CRC32.INITIAL_VALUE;
		_filename	= dataFile;
		_listener	= listener;
	}
	
	public CRC32(String dataFile, long offset, CRC32Listener listener)	{
		_offset		= offset;
		_crcValue 	= net.rim.device.api.util.CRC32.INITIAL_VALUE;
		_filename	= dataFile;
		_listener	= listener;
	}
	
	public void calculate()	{
		this.start();
	}
	
	public void run()	{
		_crcValue 	= net.rim.device.api.util.CRC32.INITIAL_VALUE;
		try {
			FileConnection source = (FileConnection)Connector.open(_filename);
			InputStream inStream = source.openInputStream();
			if (_offset > 0) {
				inStream.skip(_offset);
			}
	    	InputStreamReader reader = new InputStreamReader(inStream);		   
			int ch;
			while ((ch = reader.read()) > -1) {
				_crcValue = net.rim.device.api.util.CRC32.update(_crcValue, ch);
			}
			reader.close();
			_listener.CRC32Completed(unsigned(_crcValue));

		} 
		catch (IOException e) {
			Log.error(TAG + ".run()", e.getMessage(), e);
	    	e.printStackTrace();
	    	_listener.CRC32Error("Cannot access "+_filename);
	    }
	}
	
	public String ToString()	{
		return Integer.toHexString((int) unsigned(_crcValue));
	}
	
	public static String ToString( int i )	{
		return Integer.toHexString((int) unsigned(i)).toUpperCase();
	}
	
	public static long unsigned(int i)	{
		return 4294967295L-i;
	}
	
	public static long calculate(byte [] b)	{
		int crc = net.rim.device.api.util.CRC32.INITIAL_VALUE;
		crc = net.rim.device.api.util.CRC32.update(crc, b); // ^ 0xffffffff;
		return unsigned(crc);
	}

}
