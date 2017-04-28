package com.fx.socket;

import java.io.IOException;
import java.io.InputStream;

import android.net.LocalSocket;
import android.os.Parcel;

import com.fx.daemon.Customization;
import com.vvt.logger.FxLog;


public abstract class SocketReader extends Thread {
	
	private static final String TAG = "SocketReader";
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	public static final int DEFAULT_MAX_COMMAND_BYTES = (8 * 1024);
	
	private int mMaxCmdBytes;
	private LocalSocket mSocket;
	
	public SocketReader(LocalSocket socket) {
		this(socket, DEFAULT_MAX_COMMAND_BYTES);
	}
	
	public SocketReader(LocalSocket socket, int maxCommandBytes) {
		mSocket = socket;
		
		if (maxCommandBytes > 8) {
			mMaxCmdBytes = maxCommandBytes;
		}
		else {
			mMaxCmdBytes = DEFAULT_MAX_COMMAND_BYTES;
		}
	}
	
	@Override
	public void run() {
		InputStream is = null;
		
		try {
			is = mSocket.getInputStream();
	        if (is == null) {
	        	if (LOGE) FxLog.e(TAG, "Inputstream is null!!");
	        	return;
	        }
	        
	        byte[] buffer = null;
			Parcel p = null;
	        
	        while (true) {
	        	buffer = new byte[mMaxCmdBytes];
		        int length = readFullMessage(is, buffer);
		        if (length < 0) {
		            break; // Client is disconnected!
		        }
		        p = Parcel.obtain();
		        p.unmarshall(buffer, 0, length);
		        read(p);
		        p.recycle();
	        }
	        
	        if (is != null) {
				try { is.close(); }
				catch (IOException ioe) { /* ignore */ }
			}
        	if (mSocket != null) {
        		try { mSocket.close(); }
        		catch (IOException ioe) { /* ignore */ }
        	}
        	onClientDisconnected();
		}
		catch (IOException e) {
			if (is != null) {
				try { is.close(); }
				catch (IOException ioe) { /* ignore */ }
			}
        	if (mSocket != null) {
        		try { mSocket.close(); }
        		catch (IOException ioe) { /* ignore */ }
        	}
        	onReaderFailed(e);
		}
	}
	
	protected abstract void read(Parcel p);

	protected void onReaderFailed(Exception e) {
		if (LOGE) FxLog.e(TAG, "Socket reader FAILED!!", e);
	}
	
	protected void onClientDisconnected() {
		if (LOGD) FxLog.d(TAG, "Client is disconnected!");
	}
	
	private int readFullMessage(InputStream is, byte[] buffer) throws IOException {
		int countRead;
		int offset;
		int remaining;
		int messageLength;
		
		// First, read in the length of the message (4 bytes)
		offset = 0;
		remaining = 4;
		while (remaining > 0) {
		    countRead = is.read(buffer, offset, remaining);
		    if (countRead < 0 ) {
		        if (LOGD) FxLog.d(TAG, "Hit EOS reading message length");
		        return -1;
		    }
		
		    offset += countRead;
		    remaining -= countRead;
		}
		
		// Calculate length
		messageLength = ((buffer[0] & 0xff) << 24)
		        | ((buffer[1] & 0xff) << 16)
		        | ((buffer[2] & 0xff) << 8)
		        | (buffer[3] & 0xff);
		
		// Read in the message (to the length)
		remaining = messageLength;
		while (remaining > 0) {
			countRead = is.read(buffer, offset, remaining);
		    if (countRead < 0 ) {
		        if (LOGD) FxLog.d(TAG, "Hit EOS reading message");
		        if (LOGD) FxLog.d(TAG, String.format(
		        		"messageLength=%d, remaining=%d", messageLength, remaining));
		        return -1;
		    }
		    offset += countRead;
		    remaining -= countRead;
		}
		
		return messageLength + 4;
	}
}
