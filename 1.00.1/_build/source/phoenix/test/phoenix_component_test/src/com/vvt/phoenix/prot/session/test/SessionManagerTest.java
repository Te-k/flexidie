package com.vvt.phoenix.prot.session.test;

import java.util.Arrays;

import android.database.sqlite.SQLiteException;
import android.test.AndroidTestCase;
import android.util.Log;

import com.vvt.phoenix.prot.CommandRequest;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.SendActivate;
import com.vvt.phoenix.prot.session.SessionInfo;
import com.vvt.phoenix.prot.session.SessionManager;
import com.vvt.phoenix.prot.test.PhoenixTestUtil;

public class SessionManagerTest extends AndroidTestCase{
	
	private static final String TAG = "SessionManagerTest";
	
	private static final String STORE_PATH = "/sdcard/session/";
	private static final String INVALID_STORE_PATH = "";
	
	private static final boolean TEST_OPEN_OR_CREATE_DB = false;
	private static final boolean TEST_OPEN_OR_CREATE_DB_WITH_INVALID_PATH = false;
	
	/*private static final boolean TEST_GENERATE_FIRST_CSID = false;
	private static final boolean TEST_GENERATE_SECOND_CSID = false;
	private static final boolean TEST_GENERATE_HUGE_NUMBER_OF_CSID = false;
	private static final boolean TEST_HANDLE_QUERY_CSID_EXCEPTION = false;
	private static final boolean TEST_HANDLE_QUERY_CSID_NULL_CURSOR = false;
	private static final boolean TEST_HANDLE_UPDATE_CSID_ERROR = false;
	private static final boolean TEST_HANDLE_INSERT_FIRST_CSID_ERROR = false;*/
	
	private static final boolean TEST_CREATE_HUGE_NUMBER_OF_SESSION_INFO = false;
	
	private static final boolean TEST_PERSIST_SESSION = false;
	private static final boolean TEST_HANDLE_PERSIST_SESSION_ERROR = false;
	private static final boolean TEST_HANDLE_PERSIST_SESSION_EXCEPTION = false;
	
	private static final boolean TEST_PERSIST_AND_RETRIEVE_SESSION = false;
	private static final boolean TEST_HANDLE_RETRIEVE_SESSION_NO_DATA = false;
	private static final boolean TEST_HANDLE_RETRIEVE_SESSION_NULL_CURSOR = false;
	private static final boolean TEST_HANDLE_RETRIEVE_SESSION_EXCEPTION = false;
	
	private static final boolean TEST_UPDATE_EXISTING_SESSION = false;
	private static final boolean TEST_UPDATE_NON_EXISTING_SESSION = false;
	private static final boolean TEST_HANDLE_UPDATE_SESSION_EXCEPTION = false;
	
	private static final boolean TEST_DELETE_EXISTING_SESSION = false;
	private static final boolean TEST_DELETE_NON_EXISTING_SESSION = false;
	private static final boolean TEST_HANDLE_DELETE_SESSION_EXCEPTION = false;
	
	private static final boolean TEST_QUERY_PENDING_SESSION = false;
	private static final boolean TEST_QUERY_EMPTY_PENDING_SESSION = false;
	private static final boolean TEST_HANDLE_QUERY_PENDING_SESSION_EXCEPTION = false;
	private static final boolean TEST_HANDLE_QUERY_PENDING_SESSION_NULL_CURSOR = false;
	
	private static final boolean TEST_QUERY_ORPHAN_SESSION = false;
	private static final boolean TEST_QUERY_EMPTY_ORPHAN_SESSION = false;
	private static final boolean TEST_HANDLE_QUERY_ORPHAN_SESSION_EXCEPTION = false;
	private static final boolean TEST_HANDLE_QUERY_ORPHAN_SESSION_NULL_CURSOR = false;
	
	public void testCases(){
		/*
		 * Test database creation
		 */
		if(TEST_OPEN_OR_CREATE_DB){
			_testOpenOrCreateDb();
		}
		if(TEST_OPEN_OR_CREATE_DB_WITH_INVALID_PATH){
			_testOpenOrCreateDbWithInvalidPath();
		}
		
		/*
		 * Test CSID generator
		 * change the visibility of generateCsid()
		 * from private to public before test
		 */
		/*if(TEST_GENERATE_FIRST_CSID){
			_testGenerateFirstCsid();
		}
		if(TEST_GENERATE_SECOND_CSID){
			_testGenerateSecondCsid();
		}
		if(TEST_GENERATE_HUGE_NUMBER_OF_CSID){
			_testGenerateHugeNumberOfCsid();
		}
		if(TEST_HANDLE_QUERY_CSID_EXCEPTION){
			_testHandleQueryCsidException();
		}
		if(TEST_HANDLE_QUERY_CSID_NULL_CURSOR){
			_testHandleNullCursor();
		}
		if(TEST_HANDLE_UPDATE_CSID_ERROR){
			_testHandleUpdateCsidError();
		}
		if(TEST_HANDLE_INSERT_FIRST_CSID_ERROR){
			_testHandleInsertFirstCsidError();
		}*/
		
		/*
		 * Test create SessionInfo
		 */
		if(TEST_CREATE_HUGE_NUMBER_OF_SESSION_INFO){
			_testCreateHugeNumberOfSessionInfo();
		}
		
		/*
		 * Test persist SessionInfo
		 */
		if(TEST_PERSIST_SESSION){
			_testPersistSession();
		}
		if(TEST_HANDLE_PERSIST_SESSION_ERROR){
			_testHandlePersistSessionError();
		}
		if(TEST_HANDLE_PERSIST_SESSION_EXCEPTION){
			_testHandlePersistSessionException();
		}
		
		/*
		 * Test retrieve SessionInfo
		 */
		if(TEST_PERSIST_AND_RETRIEVE_SESSION){
			_testPersistAndRetrieveSession();
		}
		if(TEST_HANDLE_RETRIEVE_SESSION_NO_DATA){
			_testHandleRetrieveNonExistingSession();
		}
		if(TEST_HANDLE_RETRIEVE_SESSION_NULL_CURSOR){
			_testHandleRetrieveSessionNullCursor();
		}
		if(TEST_HANDLE_RETRIEVE_SESSION_EXCEPTION){
			_testHandleRetrieveSessionException();
		}
		
		/*
		 * Test update SessionInfo
		 */
		if(TEST_UPDATE_EXISTING_SESSION){
			_testUpdateExistingSession();
		}
		if(TEST_UPDATE_NON_EXISTING_SESSION){
			_testUpdateNonExistingSession();
		}
		if(TEST_HANDLE_UPDATE_SESSION_EXCEPTION){
			_testHandleUpdateSessionException();
		}
		
		/*
		 * Test delete SessionInfo
		 */
		if(TEST_DELETE_EXISTING_SESSION){
			_testDeleteExistingSession();
		}
		if(TEST_DELETE_NON_EXISTING_SESSION){
			_testDeleteNonExistingSession();
		}
		if(TEST_HANDLE_DELETE_SESSION_EXCEPTION){
			_testHandleDeleteSessionException();
		}
		
		/*
		 * Test query pending SessionInfo
		 */
		if(TEST_QUERY_PENDING_SESSION){
			_testQueryPendingSession();
		}
		if(TEST_QUERY_EMPTY_PENDING_SESSION){
			_testQueryEmptyPendingSession();
		}
		if(TEST_HANDLE_QUERY_PENDING_SESSION_EXCEPTION){
			_testHandleQueryPendingSessionException();
		}
		if(TEST_HANDLE_QUERY_PENDING_SESSION_NULL_CURSOR){
			_testHandleQueryPendingSessionNullCursor();
		}
		
		/*
		 * Test query orphan SessionInfo
		 */
		if(TEST_QUERY_ORPHAN_SESSION){
			_testQueryOrphanSession();
		}
		if(TEST_QUERY_EMPTY_ORPHAN_SESSION){
			_testQueryEmptyOrphanSession();
		}
		if(TEST_HANDLE_QUERY_ORPHAN_SESSION_EXCEPTION){
			_testHandleQueryOrphanSessionException();
		}
		if(TEST_HANDLE_QUERY_ORPHAN_SESSION_NULL_CURSOR){
			_testHandleQueryOrphanSessionNullCursor();
		}
		
	}
	
	// **************************************** Database creation test cases ************************************ //
	
	private void _testOpenOrCreateDb(){
		Log.d(TAG, "_testOpenOrCreateDb");
		
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		//assertEquals(true, man.openOrCreateSessionDatabase());
		try{
			man.openOrCreateSessionDatabase();
		}catch(SQLiteException e){
			fail(e.getMessage());
		}
	}
	
	private void _testOpenOrCreateDbWithInvalidPath(){
		Log.d(TAG, "_testOpenOrCreateDbWithInvalidPath");
		
		SessionManager man = new SessionManager(INVALID_STORE_PATH, INVALID_STORE_PATH);
		//assertEquals(false, man.openOrCreateSessionDatabase());
		try{
			man.openOrCreateSessionDatabase();
			fail("Should have thrown SQLiteException");
		}catch(SQLiteException e){
			Log.e(TAG, String.format("> _testOpenOrCreateDbWithInvalidPath # %s", e.getMessage()));
		}
	}
	
	// **************************************** CSID generator test cases ************************************ //
	/*
	 * To test all CSID generator cases
	 * You have to change the visibility of generateCsid()
	 * from private to public
	 * and don't forget to change it back to private when finished testing.
	 */
	
	/**
	 * To test this case
	 * You have to remove Session Database before testing.
	 */
	/*private void _testGenerateFirstCsid(){
		Log.d(TAG, "_testGenerateFirstCsid");
		
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		assertEquals(1, man.generateCsid());
	}
	
	private void _testGenerateSecondCsid(){
		Log.d(TAG, "_testGenerateFirstCsid");
		
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		assertEquals(2, man.generateCsid());	// assume that the first CSID is already created.
	}
	
	*//**
	 * To test this case
	 * You have to remove Session Database before testing.
	 *//*
	private void _testGenerateHugeNumberOfCsid(){
		Log.d(TAG, "_testGenerateHugeNumberOfCsid");
		
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		long latestCsid = 1;	// begin from first value: remove session DB first
		for(int i=0; i<1000; i++){
			assertEquals(latestCsid, man.generateCsid());
			latestCsid++;
		}
	}
	
	*//**
	 * To test this case
	 * You have to add Dummy Exception
	 * after query step in generateCsid();
	 *//*
	private void _testHandleQueryCsidException(){
		Log.d(TAG, "_testHandleQueryCsidException");
		
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		assertEquals(-1, man.generateCsid());	
		
	}
	
	*//**
	 * To test this case
	 * You have to set Cursor to null
	 * after query step in generateCsid();
	 *//*
	private void _testHandleNullCursor(){
		Log.d(TAG, "_testHandleNullCursor");
		
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		assertEquals(-1, man.generateCsid());	
	}
	
	*//**
	 * To test this case
	 * You have to add Dummy Exception
	 * after update CSID step in generateCsid();
	 *//*
	private void _testHandleUpdateCsidError(){
		Log.d(TAG, "_testHandleUpdateCsidError");
		
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		assertEquals(-1, man.generateCsid());	
	}
		
	*//**
	 * To test this case
	 * You have to remove Session database and force set the return value from database.insert()
	 * (after insert first value)
	 * to -1
	 *//*
	private void _testHandleInsertFirstCsidError(){
		Log.d(TAG, "_testHandleInsertFirstCsidError");
		
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		assertEquals(-1, man.generateCsid());
	}*/
	
	// **************************************** SessionInfo creation test cases ************************************ //

	/**
	 * To test this case
	 * Please remove Session database file first.
	 */
	private void _testCreateHugeNumberOfSessionInfo(){
		Log.d(TAG, "_testCreateHugeNumberOfSessionInfo");
		
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		long expectedCsid = 0;
		for(int i=0; i<1000; i++){
			expectedCsid++;
			String expectedPayloadPath = STORE_PATH + expectedCsid + ".prot";
			CommandRequest request = createCommandRequest();
			
			SessionInfo session = man.createSession(request);
		
			Log.v(TAG, String.format("CSID: %d, Path: %s", session.getCsid(), session.getPayloadPath()));
			
			assertEquals(expectedCsid, session.getCsid());
			assertEquals(true, expectedPayloadPath.equals(session.getPayloadPath()));
			assertEquals(true, (request.getMetaData() == session.getMetaData()) );
			assertEquals(false, session.isPayloadReady());
		}
	}
	
	// **************************************** Persist SessionInfo test cases ************************************ //
	
	private void _testPersistSession(){
		Log.d(TAG, "_testPersistSession");
		
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		SessionInfo session = man.createSession(createCommandRequest());
		assertEquals(true, man.persistSession(session));
	}
	
	/**
	 * To test this case
	 * You have to force set return value from mDb.insert()
	 * to -1
	 */
	private void _testHandlePersistSessionError(){
		Log.d(TAG, "_testHandlePersistSessionError");
		
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		SessionInfo session = man.createSession(createCommandRequest());
		assertEquals(false, man.persistSession(session));
	}
	
	/**
	 * To test this case
	 * You have to throw Dummy Exception
	 * after mDb.insert()
	 */
	private void _testHandlePersistSessionException(){
		Log.d(TAG, "_testHandlePersistSessionException");
		
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		SessionInfo session = man.createSession(createCommandRequest());
		//assertEquals(false, man.persistSession(session));
		try{
			man.persistSession(session);
			fail("Should have thrown RuntimeException");
		}catch(RuntimeException e){
			Log.e(TAG, String.format("> _testHandlePersistSessionException # %s", e.getMessage()));
		}
	}
	
	// **************************************** Retrieve SessionInfo test cases ************************************ //
	
	private void _testPersistAndRetrieveSession(){
		Log.d(TAG, "_testPersistAndRetrieveSession");
		
		//1 persist
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		CommandRequest request = createCommandRequest();
		SessionInfo inputSession = man.createSession(request);
		CommandMetaData inputMeta = inputSession.getMetaData();
		assertEquals(true, man.persistSession(inputSession));
		
		//2 retrieve
		SessionInfo persistentSession = man.getSession(inputSession.getCsid());
		CommandMetaData persistentMeta = persistentSession.getMetaData();
		
		//3 compare values
		assertEquals(inputSession.getCsid(), persistentSession.getCsid());
		assertEquals(inputSession.getSsid(), persistentSession.getSsid());
		assertEquals(true, inputSession.getPayloadPath().equals(persistentSession.getPayloadPath()));
		assertEquals(inputSession.isPayloadReady(), persistentSession.isPayloadReady());
		assertEquals(true, Arrays.equals(inputSession.getServerPublicKey(), persistentSession.getServerPublicKey()));
		assertEquals(true, Arrays.equals(inputSession.getAesKey(), persistentSession.getAesKey()));
		assertEquals(inputSession.getPayloadSize(), persistentSession.getPayloadSize());
		assertEquals(inputSession.getPayloadCrc32(), persistentSession.getPayloadCrc32());
		  //compare meta data
		assertEquals(inputMeta.getProtocolVersion(), persistentMeta.getProtocolVersion());
		assertEquals(inputMeta.getProductId(), persistentMeta.getProductId());
		assertEquals(true, inputMeta.getProductVersion().equals(persistentMeta.getProductVersion()));
		assertEquals(inputMeta.getConfId(), persistentMeta.getConfId());
		assertEquals(true, inputMeta.getDeviceId().equals(persistentMeta.getDeviceId()));
		assertEquals(true, inputMeta.getActivationCode().equals(persistentMeta.getActivationCode()));
		assertEquals(inputMeta.getLanguage(), persistentMeta.getLanguage());
		assertEquals(true, inputMeta.getPhoneNumber().equals(persistentMeta.getPhoneNumber()));
		assertEquals(true, inputMeta.getMcc().equals(persistentMeta.getMcc()));
		assertEquals(true, inputMeta.getMnc().equals(persistentMeta.getMnc()));
		assertEquals(true, inputMeta.getImsi().equals(persistentMeta.getImsi()));
		assertEquals(true, inputMeta.getHostUrl().equals(persistentMeta.getHostUrl()));
		assertEquals(inputMeta.getEncryptionCode(), persistentMeta.getEncryptionCode());
		assertEquals(inputMeta.getCompressionCode(), persistentMeta.getCompressionCode());
		
	}
	
	private void _testHandleRetrieveNonExistingSession(){
		Log.d(TAG, "_testHandleRetrieveNonExistingSession");
		
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		SessionInfo session = man.getSession(6996);	// make sure that there's no session with this CSID
		assertEquals(null, session);
	}
	
	/**
	 * To test this case
	 * You have to force set Cursor to NULL in getSession()
	 */
	private void _testHandleRetrieveSessionNullCursor(){
		Log.d(TAG, "_testHandleRetrieveSessionNullCursor");
		
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		SessionInfo session = man.getSession(1);
		assertEquals(null, session);
	}
		
	
	/**
	 * To test this case
	 * You have to add Dummy Exception in getSession()
	 */
	private void _testHandleRetrieveSessionException(){
		Log.d(TAG, "_testHandleRetrieveSessionException");
		
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		SessionInfo session = man.getSession(10006);
		assertEquals(null, session);
	}
	
	// **************************************** Update SessionInfo test cases ************************************ //
	
	private void _testUpdateExistingSession(){
		Log.d(TAG, "_testUpdateExistingSession");
		
		//1 persist new session
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		CommandRequest request = createCommandRequest();
		SessionInfo session = man.createSession(request);
		CommandMetaData metadata = session.getMetaData();
		assertEquals(true, man.persistSession(session));

		//2 update session
		long ssid = 1;
		byte[] pk = "PK".getBytes();
		byte[] aes = "AES".getBytes();
		long payloadSize = 555;
		long payloadCrc = 32;
		String host = "www.vvt.com";
		session.setSsid(ssid);
		session.setServerPublicKey(pk);
		session.setAesKey(aes);
		session.setPayloadSize(payloadSize);
		session.setPayloadCrc32(payloadCrc);
		session.setPayloadReady(true);
		metadata.setHostUrl(host);
		assertEquals(true, man.updateSession(session));
		
		//3 retrieve session
		SessionInfo updatedSession = man.getSession(session.getCsid());
		CommandMetaData persistentMeta = updatedSession.getMetaData();
		
		//4 compare
		assertEquals(session.getCsid(), updatedSession.getCsid());
		assertEquals(session.getSsid(), updatedSession.getSsid());
		assertEquals(true, session.getPayloadPath().equals(updatedSession.getPayloadPath()));
		assertEquals(session.isPayloadReady(), updatedSession.isPayloadReady());
		assertEquals(true, Arrays.equals(session.getServerPublicKey(), updatedSession.getServerPublicKey()));
		assertEquals(true, Arrays.equals(session.getAesKey(), updatedSession.getAesKey()));
		assertEquals(session.getPayloadSize(), updatedSession.getPayloadSize());
		assertEquals(session.getPayloadCrc32(), updatedSession.getPayloadCrc32());
		  //compare meta data
		assertEquals(metadata.getProtocolVersion(), persistentMeta.getProtocolVersion());
		assertEquals(metadata.getProductId(), persistentMeta.getProductId());
		assertEquals(true, metadata.getProductVersion().equals(persistentMeta.getProductVersion()));
		assertEquals(metadata.getConfId(), persistentMeta.getConfId());
		assertEquals(true, metadata.getDeviceId().equals(persistentMeta.getDeviceId()));
		assertEquals(true, metadata.getActivationCode().equals(persistentMeta.getActivationCode()));
		assertEquals(metadata.getLanguage(), persistentMeta.getLanguage());
		assertEquals(true, metadata.getPhoneNumber().equals(persistentMeta.getPhoneNumber()));
		assertEquals(true, metadata.getMcc().equals(persistentMeta.getMcc()));
		assertEquals(true, metadata.getMnc().equals(persistentMeta.getMnc()));
		assertEquals(true, metadata.getImsi().equals(persistentMeta.getImsi()));
		assertEquals(true, metadata.getHostUrl().equals(persistentMeta.getHostUrl()));
		assertEquals(metadata.getEncryptionCode(), persistentMeta.getEncryptionCode());
		assertEquals(metadata.getCompressionCode(), persistentMeta.getCompressionCode());
	}
	
	private void _testUpdateNonExistingSession(){
		Log.d(TAG, "_testUpdateNonExistingSession");
		
		//1 create session object
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		CommandRequest request = createCommandRequest();
		SessionInfo session = man.createSession(request);

		//2 update it
		assertEquals(false, man.updateSession(session));
		
	}
	
	/**
	 * To test this case
	 * You will have to add Dummy Exception in updateSession()
	 */
	private void _testHandleUpdateSessionException(){
		Log.d(TAG, "_testHandleUpdateSessionException");
		
		//1 create session object
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		CommandRequest request = createCommandRequest();
		SessionInfo session = man.createSession(request);

		//2 update it
		assertEquals(false, man.updateSession(session));
	}
	
	// **************************************** Delete SessionInfo test cases ************************************ //
	
	private void _testDeleteExistingSession(){
		Log.d(TAG, "_testDeleteExistingSession");
		
		
		//1 persist new session
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		CommandRequest request = createCommandRequest();
		SessionInfo session = man.createSession(request);
		assertEquals(true, man.persistSession(session));
				
		//2 delete it
		assertEquals(true, man.deleteSession(session.getCsid()));
	}
	
	private void _testDeleteNonExistingSession(){
		Log.d(TAG, "_testDeleteNonExistingSession");
		
		long dummyCsid = 10018;	// make sure that this CSID doesn't exist in the session database.
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		assertEquals(false, man.deleteSession(dummyCsid));
	}
	
	/**
	 * To test this case
	 * You will have to add Dummy Exception in deleteSession()
	 */
	private void _testHandleDeleteSessionException(){
		Log.d(TAG, "_testHandleDeleteSessionException");
		
		//1 persist new session
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		CommandRequest request = createCommandRequest();
		SessionInfo session = man.createSession(request);
		assertEquals(true, man.persistSession(session));
				
		//2 delete it
		assertEquals(false, man.deleteSession(session.getCsid()));
	}
	
	// **************************************** Query Pending SessionInfo test cases ************************************ //
	
	/**
	 * Please remove session database file before test this case.
	 */
	private void _testQueryPendingSession(){
		Log.d(TAG, "_testQueryPendingSession");
		
		//1 persist 2 pending sessions
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		CommandRequest request = createCommandRequest();
		SessionInfo pendingSession1 = man.createSession(request);
		pendingSession1.setPayloadReady(true);
		SessionInfo pendingSession2 = man.createSession(request);
		pendingSession2.setPayloadReady(true);
		assertEquals(true, man.persistSession(pendingSession1));
		assertEquals(true, man.persistSession(pendingSession2));
		
		//2 persist an orphan session
		SessionInfo orphanSession = man.createSession(request);
		assertEquals(true, man.persistSession(orphanSession));
		
		//3 query pending session
		long[] pendingCsids = man.getAllPendingSessionIds();
		man.closeSessionDatabase();
		
		//4 check
		assertEquals(2, pendingCsids.length);
		assertEquals(pendingSession1.getCsid(), pendingCsids[0]);
		assertEquals(pendingSession2.getCsid(), pendingCsids[1]);
	}
	
	/**
	 * Please remove session database file before test this case.
	 */
	private void _testQueryEmptyPendingSession(){
		Log.d(TAG, "_testQueryEmptyPendingSession");
		
		//1 open session DB
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		
		//2 query pending session
		long[] pendingCsids = man.getAllPendingSessionIds();
		man.closeSessionDatabase();
		assertEquals(0, pendingCsids.length);
	}
	
	/**
	 * To test this case
	 * You have to add Dummy Exception in getAllPendingSessionIds()
	 */
	private void _testHandleQueryPendingSessionException(){
		Log.d(TAG, "_testHandleQueryPendingSessionException");
		
		//1 open session DB
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		
		//2 query pending session
		long[] pendingCsids = man.getAllPendingSessionIds();
		man.closeSessionDatabase();
		assertEquals(0, pendingCsids.length);
	}
	
	/**
	 * To test this case
	 * You have to force set Cursor to NULL in getAllPendingSessionIds()
	 */
	private void _testHandleQueryPendingSessionNullCursor(){
		Log.d(TAG, "_testHandleQueryPendingSessionNullCursor");
		
		//1 open session DB
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		
		//2 query pending session
		long[] pendingCsids = man.getAllPendingSessionIds();
		man.closeSessionDatabase();
		assertEquals(0, pendingCsids.length);
	}
	
	// **************************************** Query Orphan SessionInfo test cases ************************************ //
	
	/**
	 * Please remove session database file before test this case.
	 */
	private void _testQueryOrphanSession(){
		Log.d(TAG, "_testQueryOrphanSession");
		
		//1 persist 2 orphan sessions
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		CommandRequest request = createCommandRequest();
		SessionInfo orphanSession1 = man.createSession(request);
		SessionInfo orphanSession2 = man.createSession(request);
		assertEquals(true, man.persistSession(orphanSession1));
		assertEquals(true, man.persistSession(orphanSession2));
		
		//2 persist a pending session
		SessionInfo pendingSession = man.createSession(request);
		pendingSession.setPayloadReady(true);
		assertEquals(true, man.persistSession(pendingSession));
		
		//3 query orphan session
		long[] orphanCsids = man.getAllOrphanSessionIds();
		man.closeSessionDatabase();
		
		//4 check
		assertEquals(2, orphanCsids.length);
		assertEquals(orphanSession1.getCsid(), orphanCsids[0]);
		assertEquals(orphanSession2.getCsid(), orphanCsids[1]);
	}
	
	/**
	 * Please remove session database file before test this case.
	 */
	private void _testQueryEmptyOrphanSession(){
		Log.d(TAG, "_testQueryEmptyOrphanSession");
		
		//1 open session DB
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		
		//2 query orphan session
		long[] orphanCsids = man.getAllOrphanSessionIds();
		man.closeSessionDatabase();
		assertEquals(0, orphanCsids.length);
	}
	
	/**
	 * To test this case
	 * You have to add Dummy Exception in getAllOrphanSessionIds()
	 */
	private void _testHandleQueryOrphanSessionException(){
		Log.d(TAG, "_testHandleQueryOrphanSessionException");
		
		//1 open session DB
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		
		//2 query pending session
		long[] orphanCsids = man.getAllOrphanSessionIds();
		man.closeSessionDatabase();
		assertEquals(0, orphanCsids.length);
	}
	
	/**
	 * To test this case
	 * You have to force set Cursor to NULL in getAllOrphanSessionIds()
	 */
	private void _testHandleQueryOrphanSessionNullCursor(){
		Log.d(TAG, "_testHandleQueryOrphanSessionNullCursor");
		
		//1 open session DB
		SessionManager man = new SessionManager(STORE_PATH, STORE_PATH);
		man.openOrCreateSessionDatabase();
		
		//2 query pending session
		long[] orphanCsids = man.getAllOrphanSessionIds();
		man.closeSessionDatabase();
		assertEquals(0, orphanCsids.length);
	}
	
	// **************************************** Util ************************************ //
	
	private CommandRequest createCommandRequest(){
		SendActivate commandData = new SendActivate();
    	commandData.setDeviceInfo("my info");
    	commandData.setDeviceModel("hTC Legend");
    	
    	CommandRequest request = new CommandRequest();
    	request.setMetaData(PhoenixTestUtil.createMetaDataForActivation("01329", getContext()));
    	request.setCommandData(commandData);
    	
    	return request;
	}
}
