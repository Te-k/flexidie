package com.vvt.std;

import java.io.*;
import javax.microedition.io.DatagramConnection;
import javax.microedition.io.HttpConnection;
import javax.microedition.io.file.FileConnection;
import javax.wireless.messaging.MessageConnection;

public final class IOUtil {
	
	public static void close(InputStreamReader isr) {
		try {
			if (isr != null) {
				isr.close();
			}
		} catch (IOException e) {
			Log.error("IOUtil.close", "Closing InputStreamReader", e);
		}
	}
	
	public static void close(InputStream is) {
		try {
			if (is != null) {
				is.close();
			}
		} catch (IOException e) {
			Log.error("IOUtil.close", "Closing InputStream", e);
		}
	}
	
	public static void close(OutputStream os) {
		try {
			if (os != null) {
				os.close();
			}
		} catch (IOException e) {
			Log.error("IOUtil.close", "Closing OutputStream", e);
		}
	}
	
	public static void close(DatagramConnection dc) {
		try {
			if (dc != null) {
				dc.close();
			}
		} catch (IOException e) {
			Log.error("IOUtil.close", "Closing DatagramConnection", e);
		}
	}
	
	public static void close(MessageConnection mc) {
		try {
			if (mc != null) {
				mc.close();
			}
		} catch (IOException e) {
			Log.error("IOUtil.close", "Closing MessageConnection", e);
		}
	}

	public static void close(HttpConnection httpCon) {
		try {
			if (httpCon != null) {
				httpCon.close();
			}
		} catch (IOException e) {
			Log.error("IOUtil.close", "Closing HttpConnection", e);
		}
	}
	
	public static void close(FileConnection fcon) {
		try {
			if (fcon != null) {
				fcon.close();
			}
		} catch (IOException e) {
			Log.error("IOUtil.close", "Closing FileConnection", e);
		}
	}
}
