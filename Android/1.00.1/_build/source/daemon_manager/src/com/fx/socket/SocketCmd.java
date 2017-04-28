package com.fx.socket;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

import android.net.LocalSocket;
import android.net.LocalSocketAddress;

import com.fx.daemon.Customization;
import com.vvt.logger.FxLog;

public abstract class SocketCmd<I, O> implements Serializable {
	
	private static final long serialVersionUID = -4869566531156547295L;
	
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	private Class<O> mResponseKeyClass;
	private I mData;
	
	protected abstract String getTag();
	protected abstract String getServerName();
	
	public SocketCmd(I data, Class<O> responseKeyClass) {
		mData = data;
		mResponseKeyClass = responseKeyClass;
	}
	
	public I getData() {
		return mData;
	}
	
	public O execute() throws IOException {
		if (LOGV) FxLog.v(getTag(), "execute # ENTER ...");
		
		O response = null;
		
		ObjectOutputStream oos = null;
		ObjectInputStream ois = null;
		
		Exception error = null;

		try {
			LocalSocket client = new LocalSocket();
			
			if (LOGV) FxLog.v(getTag(), "execute # Connect to the server");
			client.connect(new LocalSocketAddress(getServerName()));
			
			// The command is sent (instead of the data)
			// The server will choose the operation to process the data
			if (LOGV) FxLog.v(getTag(), "execute # Send the command");
			oos = new ObjectOutputStream(client.getOutputStream());
			oos.writeObject(this);
			oos.flush();
			
			if (LOGV) FxLog.v(getTag(), "execute # Retrieve the response");
			ois = new ObjectInputStream(client.getInputStream());
			Object obj = ois.readObject();
			
			if (LOGV) FxLog.v(getTag(), "execute # Response is received");
			
			response = mResponseKeyClass.cast(obj);
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(getTag(), String.format("execute # Error: %s", e));
			error = e;
		}
		finally {
			try {
				if (oos != null) oos.close();
				if (ois != null) ois.close();
			}
			catch (IOException e) {
				if (LOGE) FxLog.e(getTag(), String.format("execute # Close failed: %s", e));
			}
		}
		
		if (error != null) {
			throw new IOException(error.toString());
		}
		
		if (LOGV) FxLog.v(getTag(), "execute # EXIT ...");
		return response;
	}
}
