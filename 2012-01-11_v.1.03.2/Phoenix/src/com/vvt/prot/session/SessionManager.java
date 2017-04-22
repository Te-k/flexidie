package com.vvt.prot.session;

import java.io.IOException;
import java.util.Enumeration;
import java.util.Hashtable;
import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;
import net.rim.device.api.system.RuntimeStore;
import net.rim.device.api.util.Persistable;
import com.vvt.prot.CommandRequest;
import com.vvt.std.Log;

public class SessionManager {

	private static final  long		guid				= 0x348674638c3c2b9bL;
//	private static final long 		SESSION_MANGER_KEY 	= 0xaeae0d296b1b01caL;
	private static SessionManager 	_sm 				= null;
	private String 					TAG 				= "SessionManager";	
	private PersistentObject		store;
	private Sessions				sessions;
	private String					defaultPath			= "file:///store/home/user/";
	
//	static {
//		// com.vvt.prot.session.SessionManager -> 0x348674638c3c2b9bL
//	}
	
	private SessionManager()	{
		store = PersistentStore.getPersistentObject(guid);
		synchronized (store) {
			if (store.getContents() == null) {
				sessions  = new Sessions();
				store.setContents(sessions);
				store.commit();
			}
		}
		sessions = (Sessions) store.getContents();
		// set counter for csid after loading
		SessionInfo.setCsidCounter(sessions.getCsid());
	}
	
	private void commit()	{
		synchronized (store) {
			store.setContents(sessions);
			store.commit();
		}
	}
	
	public static SessionManager getInstance()	{
		if(_sm == null)	{
			_sm = (SessionManager)RuntimeStore.getRuntimeStore().get(guid);
			if (_sm == null) {
				SessionManager sessionMng = new SessionManager();
				RuntimeStore.getRuntimeStore().put(guid, sessionMng);
				_sm = sessionMng;
			}
		}
		return _sm;
	}
	
	public void setPath(String path)	{
		defaultPath = path;
		if (!defaultPath.endsWith("/")) {
			defaultPath = defaultPath+"/";
		}
	}
	
	public synchronized SessionInfo createSession(CommandRequest request) throws IOException	{
		SessionInfo session = createSession();		
		setMetaDataToSession(request, session);
		setPath(session);
		persistSession(session);
		return session; 
	}
	
	private SessionInfo createSession()	{
		return new SessionInfo();
	}
	
	public SessionInfo getSession(long csid)	{
		return sessions.getSession(csid);
	}
	
	public void deleteSession(long csid)	{
		sessions.deleteSession(csid);
		commit();
	}
	
	public void persistSession(SessionInfo session)	{
		sessions.saveSession(session);
		// update present csidCounter
		sessions.setCsid(SessionInfo.getCsidCounter()); 
		commit();
	}
	
	private void setPath(SessionInfo session) throws IOException {
		String path = defaultPath+session.getCsid()+".payload";
		session.setPayloadPath(path);
	}
	
	private void setMetaDataToSession(CommandRequest cmdRequest, SessionInfo session)	{
		session.setProtocolVersion(	cmdRequest.getCommandMetaData().getProtocolVersion());
		session.setProductId(		cmdRequest.getCommandMetaData().getProductId());
		session.setProductVersion(	cmdRequest.getCommandMetaData().getProductVersion());
		session.setConfiguration(	cmdRequest.getCommandMetaData().getConfId());
		session.setDeviceId(		cmdRequest.getCommandMetaData().getDeviceId());
		session.setActivationCode(	cmdRequest.getCommandMetaData().getActivationCode());
		session.setLanguage(		cmdRequest.getCommandMetaData().getLanguage());
		session.setPhoneNumber(		cmdRequest.getCommandMetaData().getPhoneNumber());
		session.setMcc(				cmdRequest.getCommandMetaData().getMcc());
		session.setMnc(				cmdRequest.getCommandMetaData().getMnc());
		session.setImsi(			cmdRequest.getCommandMetaData().getImsi());
		session.setBaseServerUrl(   cmdRequest.getCommandMetaData().getBaseServerUrl());
		session.setEncryptionCode(	cmdRequest.getCommandMetaData().getEncryptionCode());
		session.setCompressionCode(	cmdRequest.getCommandMetaData().getCompressionCode());
	}
	
	public boolean isSessionPending(long csid)	{
		return sessions.isSessionPending(csid);
	}
	
	public Enumeration getAllSessions()	{
		return sessions.getAllSessions();
	}

	public void cleanAllSessions()	{
		sessions.cleanAllSessions();
		commit();
	}
}

class Sessions implements Persistable {
	
	private static final String TAG = "Sessions";
	private long	  	_csid		= 0;		
	private Hashtable 	_sessions 	= new Hashtable();
	
	public Sessions()	{
	}
		
	public void setCsid(long csid)	{
		_csid = csid;
	}
	
	public long getCsid()	{
		return _csid;
	}
	
	public boolean isSessionPending(long csid)	{
		boolean pending = false;
		Long _csid = new Long(csid);
		if (_sessions.containsKey(_csid))	{
			SessionInfo session = (SessionInfo) _sessions.get(_csid);
			if (session.isPayloadReady())	{
				pending = true;
			}
		}
		return pending;
	}
	
	public SessionInfo getSession(long csid)	{
		return (SessionInfo) _sessions.get(new Long(csid));
	}
	
	public void saveSession(SessionInfo session)	{
		if (session != null)	{
			Long csid = new Long(session.getCsid());
			_sessions.put(csid, session);
		}
		else {
			Log.error(TAG, "save null Session !?");
		}
	}
	
	public void deleteSession(long csid)	{
		_sessions.remove(new Long(csid));
	}
	public Enumeration getAllSessions()	{
		return _sessions.elements(); 
	}

	public void cleanAllSessions()	{
		_sessions.clear();
	}
}