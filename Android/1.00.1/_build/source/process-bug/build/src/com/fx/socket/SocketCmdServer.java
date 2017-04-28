package com.fx.socket;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import android.net.LocalServerSocket;
import android.net.LocalSocket;

import com.fx.daemon.Customization;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;

public abstract class SocketCmdServer extends Thread {
	
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mTag;
	private LocalServerSocket mServer;
	private int mServerFd;
	
	public abstract Object process(SocketCmd<?, ?> command);
	
	public SocketCmdServer (String tag, String serverName) throws IOException {
		mTag = tag;
		mServer = new LocalServerSocket(serverName);
		mServerFd = FileUtil.getFileDescriptor(mServer.getFileDescriptor());
	}
	
	@Override
	public void run() {
		if (LOGV) FxLog.v(mTag, "ServerThread # ENTER ...");
		
		LocalSocket client = null;
		try {
			while (true) {
				if (LOGV) FxLog.v(mTag, "ServerThread # Ready to accept new client ...");
				
				client = mServer.accept();
				if (client == null) {
					if (LOGE) FxLog.e(mTag, "ServerThread # Server accept error!!");
					break;
				}
				else {
					if (LOGV) FxLog.v(mTag, "ServerThread # A new client is being accepted!");
				}
				
				processData(client);
				client.close();
				
			} // Exit while loop
			
			if (mServer != null) {
				mServer.close();
				if (LOGV) FxLog.v(mTag, "ServerThread # Server is closed!");
			}
		}
		catch(Exception e) {
			if (LOGE) FxLog.e(mTag, "ServerThread # Creating server FAILED", e);
		}
		if (LOGV) FxLog.v(mTag, "ServerThread # EXIT ...");
	}
	
	public int getFd() {
		return mServerFd;
	}
	
	public void closeServer() {
		if (mServer != null) {
			try {
				mServer.close();
			}
			catch (Exception e) { 
				if (LOGE) FxLog.e(mTag, String.format("Close server FAILED!! %s", e.toString()));
			}
		}
	}
	
	private void processData(LocalSocket client) {
		if (LOGV) FxLog.v(mTag, "processData # ENTER ...");
		
		ObjectInputStream ois = null;
		ObjectOutputStream oos = null;
		
		try {
			ois = new ObjectInputStream(client.getInputStream());
			oos = new ObjectOutputStream(client.getOutputStream());
			
			SocketCmd<?, ?> command = (SocketCmd<?, ?>) ois.readObject();
			if (LOGV) FxLog.v(mTag, "processData # Data is retrieved");
			
			Object responseData = process(command);
			if (LOGV) FxLog.v(mTag, "processData # Data is processed");
			
			if (responseData == null) responseData = new Exception();
			
			oos.writeObject(responseData);
			oos.flush();
			
		} catch (Exception e) {
			if (LOGE) FxLog.e(mTag, "processData # Error!!", e);
		}
		finally {
			try {
				if(ois != null) ois.close();
				if(oos != null) oos.close();
			}
			catch (IOException e) { 
				if (LOGE) FxLog.e(mTag, String.format("processData # Close failed!! %s", e));
			}
		}
		
		if (LOGV) FxLog.v(mTag, "processData # EXIT ...");
	}

}
