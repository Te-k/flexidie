package com.apptest.prot.parser;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;

import net.rim.device.api.io.FileInputStream;
import net.rim.device.api.util.DataBuffer;

import com.vvt.prot.parser.ResponseParser;
import com.vvt.std.FileUtil;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;

public class ResponseParserTester {

	private static final String TAG = "ResponseParserTester";
	private static final String GET_COMMUNICATION_DIRECTIVES_RESPONSE_FILE = "file:///SDCard/GetCommunicationResponse.txt";
	
	public void testGetCommunicationDirectives() {
		try {
			int size = (int) FileUtil.getFileSize(GET_COMMUNICATION_DIRECTIVES_RESPONSE_FILE);
			byte[] data = readFile(GET_COMMUNICATION_DIRECTIVES_RESPONSE_FILE, size);
			ResponseParser.parseStructuredCmd(data);
		} catch (Exception e) {
			e.printStackTrace();
			Log.error(TAG + ".testGetCommunicationDirectives()", e.getMessage(), e);
		}
	}
	
	private byte[] readFile(String filename, int size) throws IOException {
		int EOF = -1; // End of File
		FileConnection fCon = null;
        InputStream is = null;
        byte[] data = null;
        try {
	        fCon = (FileConnection)Connector.open(filename, Connector.READ);
	        data = new byte[size];
        	is = fCon.openInputStream();
	        int status = 0;
	        while(status != EOF) {
	        	status = is.read(data);
	        }
	        return data;
		} finally {
	        IOUtil.close(is);
	        IOUtil.close(fCon);
		}		
	}
}
