package com.daemon_bridge;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import android.net.LocalServerSocket;
import android.net.LocalSocket;

import com.vvt.logger.FxLog;

public abstract class ClientCommandLister extends Thread {
	private static final String TAG = "ClientCommandLister";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private LocalServerSocket mServer;
	public abstract void onReceiveMessage(SocketCommandBase commandBase);
	public abstract CommandResponseBase getResponseMessage();
	
	public ClientCommandLister (LocalServerSocket server) {
		mServer = server;
	}
	@Override
	public void run() {
		FxLog.v(TAG, "run # ENTER ...");
		
		LocalSocket client = null;
		ObjectInputStream ois = null;
		ObjectOutputStream oos = null;
		   
		try {
			
			if(mServer == null) {
				if(LOGE) FxLog.e(TAG, "# mServer is null !");
				return;
			}
			
			while (true) {
				if(LOGD) FxLog.d(TAG, "# Ready to accept new client ...");
				
				client = mServer.accept();
				if (client == null) {
					if(LOGD) FxLog.d(TAG, "# Server accept error!!");
					break;
				}
				else {
					if(LOGD) FxLog.d(TAG, "# A new client is being accepted!");
				}
				
				try {
					
					ois = new ObjectInputStream(client.getInputStream());
					oos = new ObjectOutputStream(client.getOutputStream());
					
					SocketCommandBase baseCommand = (SocketCommandBase) ois.readObject();
					onReceiveMessage(baseCommand);
					CommandResponseBase commandResponseBase = getResponseMessage();
					
					if(commandResponseBase != null) {
						oos.writeObject(commandResponseBase);
						oos.flush();
					}
					
				} catch (Exception e1) {
					if(LOGE) FxLog.e(TAG, "# server FAILED", e1);
				}
				finally {
					
					if(ois != null)
						ois.close();
					
					if(oos != null)
						oos.close();
					
					try {
						client.close();
					} catch (Exception e) {
						if(LOGE) FxLog.e(TAG, e.getMessage());
					}
					
				}

				
			} // Exit while loop
			
			if (mServer != null) {
				mServer.close();
				if(LOGD) FxLog.d(TAG, "# Server is closed!");
			}
		}
		catch(IOException e) {
			if(LOGE) FxLog.e(TAG, "# Creating server FAILED", e);
		}

		if(LOGV) FxLog.v(TAG, "run # EXIT ...");
	}
}