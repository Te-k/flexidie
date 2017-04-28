package com.daemon_bridge;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

import android.net.LocalSocket;
import android.net.LocalSocketAddress;

import com.vvt.logger.FxLog;

public abstract class SocketCommandBase  implements Serializable {
	public static String TAG = "SocketCommandBase";
	public static String SOCKET_ADDRESS = "your.local.socket.address";
	private static final long serialVersionUID = 116295272086725737L;
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	public static final int SEND_ACTIVATE = 1;
	public static final int GET_LICENSE_STATUS = 2;
	public static final int GET_CURRENT_SETTINGS = 3;
	public static final int GET_CONNECTION_HISTORY = 4;
	public static final int GET_PRODUCT_INFO = 5;
	public static final int DEACTIVATE = 6;
	public static final int UNINSTALL = 7;
	public static final int SET_PACKAGE_NAME = 8;
	
	public abstract int getCommandId();
	public abstract CommandResponseBase execute();
	
	protected CommandResponseBase writeSocket() throws IOException {
		if(LOGV) FxLog.v(TAG, "writeSocket # START ..");
		
		CommandResponseBase commandResponseBase = null;
		ObjectOutputStream oos = null;
		ObjectInputStream ois = null;

		LocalSocket sender = new LocalSocket();
	

		try {
			
			sender.connect(new LocalSocketAddress(SOCKET_ADDRESS));
			if(LOGD) FxLog.d(TAG, "writeSocket # Sending: " + this.toString());
			
			oos = new ObjectOutputStream(sender.getOutputStream());
			oos.writeObject(this);
			oos.flush();

			ois = new ObjectInputStream(sender.getInputStream());
			commandResponseBase = (CommandResponseBase) ois.readObject();

		} catch (Throwable t) {
			if(LOGE) FxLog.e(TAG, "# writeSocket Error: " + t.toString());
		} finally {

			if (oos != null)
				oos.close();

			if (ois != null)
				ois.close();
		}

		if (commandResponseBase != null)
			if(LOGD) FxLog.d(TAG, "writeSocket # commandResponseBase :" + commandResponseBase.toString());

		if(LOGV) FxLog.v(TAG, "writeSocket EXIT ..");
		return commandResponseBase;
	}
}
