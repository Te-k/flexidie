package com.fx.socket;

import java.io.IOException;

import android.net.LocalServerSocket;
import android.net.LocalSocket;
import android.os.Parcel;

import com.fx.daemon.Customization;
import com.vvt.logger.FxLog;

public abstract class SocketServerThread extends Thread {
	
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private int mMaxCmdBytes;
	private String mTag;
	private LocalServerSocket mServer;
	
	public abstract void onReceiveMessage(Parcel p);
	
	public SocketServerThread (String tag, LocalServerSocket server) {
		this(tag, server, SocketReader.DEFAULT_MAX_COMMAND_BYTES);
	}
	
	public SocketServerThread (String tag, LocalServerSocket server, int maxCmdBytes) {
		mTag = tag;
		mServer = server;
		
		if (maxCmdBytes > 8) {
			mMaxCmdBytes = maxCmdBytes;
		}
		else {
			mMaxCmdBytes = SocketReader.DEFAULT_MAX_COMMAND_BYTES;
		}
	}
	
	public void closeServer() {
		if (mServer != null) {
			try {
				mServer.close();
			}
			catch (Exception e) { 
				if (LOGE) FxLog.e(mTag, String.format(
						"ServerThread # Close server FAILED!! %s", e.toString()));
			}
		}
	}
	
	@Override
	public void run() {
		if (LOGD) FxLog.d(mTag, "ServerThread # ENTER ...");
		
		LocalSocket client = null;
		SocketReader reader = null;
		try {
			while (true) {
				if (LOGD) FxLog.d(mTag, "ServerThread # Ready to accept new client ...");
				
				client = mServer.accept();
				if (client == null) {
					if (LOGE) FxLog.e(mTag, "ServerThread # Server accept error!!");
					break;
				}
				else {
					if (LOGD) FxLog.d(mTag, "ServerThread # A new client is being accepted!");
				}
				reader = new SocketReader(client, mMaxCmdBytes) {
					@Override
					public void read(Parcel p) {
						onReceiveMessage(p);
					}
				};
				reader.start();
				
				if (LOGD) FxLog.d(mTag, "ServerThread # SocketReader is start");
			} // Exit while loop
			
			if (mServer != null) {
				mServer.close();
				if (LOGD) FxLog.d(mTag, "ServerThread # Server is closed!");
			}
		}
		catch(IOException e) {
			if (LOGE) FxLog.e(mTag, "ServerThread # Creating server FAILED", e);
		}
		if (LOGD) FxLog.d(mTag, "ServerThread # EXIT ...");
	}
}
