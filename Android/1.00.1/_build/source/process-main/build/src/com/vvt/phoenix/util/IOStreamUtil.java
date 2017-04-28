package com.vvt.phoenix.util;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import com.vvt.logger.FxLog;

/**
 * @author tanakharn
 * Created: 11 January 2012
 */
public class IOStreamUtil {
	
	private static final String TAG = "IOStreamUtil";

	public static void safelyCloseStream(InputStream stream){
		try {
			stream.close();
		} catch (IOException e) {
			FxLog.e(TAG, String.format("> safelyCloseStream # Exception while closing InputStream: %s", e.getMessage()));
		}
	}
	
	public static void safelyCloseStream(OutputStream stream){
		try {
			stream.close();
		} catch (IOException e) {
			FxLog.e(TAG, String.format("> safelyCloseStream # Exception while closing OutputStream: %s", e.getMessage()));
		}
	}
}
