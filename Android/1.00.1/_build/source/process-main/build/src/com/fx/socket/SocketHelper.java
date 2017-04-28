package com.fx.socket;

import java.io.IOException;
import java.io.OutputStream;

import android.net.LocalSocket;
import android.net.LocalSocketAddress;
import android.net.LocalSocketAddress.Namespace;
import android.os.Parcel;

import com.fx.daemon.Customization;
import com.vvt.logger.FxLog;

public class SocketHelper {
	
	private static final String TAG = "SocketHelper";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	public static final String ERROR_ADDR_IN_USE = "Address already in use";
	public static final String ERROR_BAD_FILE_NUMBER = "Bad file number";
	
	public static boolean isSocketAvailable(String name, Namespace namespace) {
		boolean isSocketAvailable = false;
		
		if (namespace == null) {
			namespace = Namespace.ABSTRACT;
		}
		
		LocalSocket client = new LocalSocket();
		LocalSocketAddress addr = new LocalSocketAddress(name, namespace);
		
		try {
			client.connect(addr);
			isSocketAvailable = true;
		}
		catch (IOException e) {
			isSocketAvailable = false;
		}
		finally {
			try { client.close(); }
			catch (IOException ioe) { /*ignore*/ }
		}
		
		return isSocketAvailable;
	}
	
	/**
	 * Get connected local socket for specified name
	 * @param name
	 * @param namespace
	 * @return
	 */
	public static LocalSocket getSocketClient(String name, Namespace namespace) throws IOException {
		if (LOGV) FxLog.v(TAG, "getSocketClient # ENTER ...");
		
		if (namespace == null) {
			namespace = Namespace.ABSTRACT;
		}
		
		if (LOGV) FxLog.v(TAG, String.format(
				"getSocketClient # name: %s, namespace: %s", name, namespace));
		
		LocalSocket client = new LocalSocket();
		LocalSocketAddress addr = new LocalSocketAddress(name, namespace);
		
		client.connect(addr);
		if (LOGV) FxLog.v(TAG, "getSocketClient # Connection successful");
		
		if (LOGV) FxLog.v(TAG, "getSocketClient # EXIT ...");
		return client;
	}
	
	public static boolean write(LocalSocket socket, Parcel p) {
		boolean isSuccess = false;
		
		if (socket == null) {
			if (LOGE) FxLog.e(TAG, "write # Socket is NULL!!");
		}
		else {
			try {
				OutputStream os = socket.getOutputStream();
				if (os != null) {
					os.write(p.marshall());
					os.flush();
					isSuccess = true;
				}
			}
			catch (IOException e) {
				if (LOGE) FxLog.e(TAG, String.format("write # Error: %s", e));
				// DON'T CLOSE THE OUTPUT STREAM
			}
			// DON'T CLOSE THE OUTPUT STREAM
		}
		// DON'T CLOSE THE SOCKET
		return isSuccess;
	}
	
	public static void updateParcelLength(Parcel p) {
		Parcel temp = Parcel.obtain();
		temp.writeInt(p.dataSize() - 4);
		byte[] buffer = temp.marshall();
		
		int altered = ((buffer[0] & 0xff) << 24) 
				| ((buffer[1] & 0xff) << 16) 
				| ((buffer[2] & 0xff) << 8)
				| (buffer[3] & 0xff);
		
		p.setDataPosition(0);
		p.writeInt(altered);
	}
	
}
