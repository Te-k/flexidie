package com.vvt.remotecommandmanager;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.appcontext.AppContext;
import com.vvt.appcontext.AppContextImpl;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.eventrepository.FxEventRepositoryManager;
import com.vvt.phoenix.prot.command.response.PCC;
import com.vvt.remotecommandmanager.exceptions.CommandNotRegisteredException;
import com.vvt.remotecommandmanager.exceptions.InvalidCommandFormatException;
import com.vvt.remotecommandmanager.exceptions.NotSmsCommandException;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.RemoteCommandFactory;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;
import com.vvt.remotecommandmanager.utils.RemoteCommandParser;
import com.vvt.smscommandreceiver.SmsCommand;

public class RemoteCommandManagerTestCase extends
		ActivityInstrumentationTestCase2<Remote_command_manager_testsActivity> {
	
	private int mCountSync = 0;
	private int mCountHttp = 0;	
	private int mCountNonHttp = 0;		
			
			
	private FxEventRepository mEventRepository;

	public RemoteCommandManagerTestCase() {
		super("com.vvt.remotecommandmanager", Remote_command_manager_testsActivity.class);
	}
	
	private Context mTestContext;
	private AppContext mAppContext;
	
	@Override
	protected void setUp()  throws Exception {
		super.setUp();
		mTestContext = this.getInstrumentation().getContext();

		mEventRepository = new FxEventRepositoryManager(mTestContext);
		mAppContext = new AppContextImpl(mTestContext);
	}
	
	@Override
	protected void tearDown() throws Exception {
		super.tearDown();
	}

	public void setTestContext(Context context) {
		mTestContext = context;
	}

	public Context getTestContext() {
		return mTestContext;
	}
	
	public void test_pccParser() {
		
		String cmdCode = "64";
		
		PCC pcc = new PCC(Integer.parseInt(cmdCode));
		pcc.addArgument("arg_1");
		pcc.addArgument("arg_2");
		
		RemoteCommandData commandData = RemoteCommandParser.parse(pcc);
		
		
		assertEquals(cmdCode, commandData.getCommandCode());
		assertEquals(RemoteCommandType.PCC, commandData.getRmtCommandType());
		assertEquals(pcc.getArgumentCount(), commandData.getArguments().size());
		assertEquals(false, commandData.isSmsReplyRequired());
		assertEquals(null, commandData.getSenderNumber());
		for(int i = 0; i<commandData.getArguments().size() ;i++) {
			assertEquals(pcc.getArgument(i), commandData.getArguments().get(i));
		}
	}
	
	public void test_smsParser() {
		
		/**
		 * Perfect case.
		 */
		String message = "<*#123><AC><arg1><arg2><D>";
		String senderNumber = "0123456789";
		
		SmsCommand smsCommand = new SmsCommand();
		smsCommand.setMessage(message);
		smsCommand.setSenderNumber(senderNumber);
		
		try {
			smsParserValidate(smsCommand);
		} catch (RemoteCommandException e) {
			assertFalse(true);
		}
		
		//have space 
		message = " <*#123><AC><arg1><arg2><D> ";
		smsCommand = new SmsCommand();
		smsCommand.setMessage(message);
		smsCommand.setSenderNumber(senderNumber);
		
		try {
			smsParserValidate(smsCommand);
		} catch (RemoteCommandException e) {
			assertFalse(true);
		}
		
		// No <D>
		message = "<*#123><AC><arg1><arg2>";
		smsCommand = new SmsCommand();
		smsCommand.setMessage(message);
		smsCommand.setSenderNumber(senderNumber);
		
		try {
			RemoteCommandData commandData = RemoteCommandParser.parse(smsCommand);
			assertEquals("123", commandData.getCommandCode());
			assertEquals(3,commandData.getArguments().size());
			assertEquals(RemoteCommandType.SMS_COMMAND, commandData.getRmtCommandType());
			assertEquals(false,commandData.isSmsReplyRequired());
			assertEquals(smsCommand.getSenderNumber().trim(),commandData.getSenderNumber());
				
			assertEquals("AC",commandData.getArguments().get(0));
			assertEquals("arg1",commandData.getArguments().get(1));
			assertEquals("arg2",commandData.getArguments().get(2));
		} catch (RemoteCommandException e) {
			assertFalse(true);
		}

		/**
		 * Unperfect case.
		 */
		
		//prefix wrong
		message = "<*_#123><AC><arg1><arg2><D>";
		senderNumber = "0123456789";
		smsCommand = new SmsCommand();
		smsCommand.setMessage(message);
		smsCommand.setSenderNumber(senderNumber);
		
		try {
			smsParserValidate(smsCommand);
		} catch (RemoteCommandException e) {
			assertTrue(true);
			RemoteCommandException ex = new NotSmsCommandException();
			assertEquals(ex.getErrorCode(), e.getErrorCode());
		}
		
		// "<" wrong
		message = "<*#123><<AC><arg1><arg2><D>";
		senderNumber = "0123456789";
		smsCommand = new SmsCommand();
		smsCommand.setMessage(message);
		smsCommand.setSenderNumber(senderNumber);
		
		try {
			smsParserValidate(smsCommand);
		} catch (RemoteCommandException e) {
			assertTrue(true);
			RemoteCommandException ex = new InvalidCommandFormatException();
			assertEquals(ex.getErrorCode(), e.getErrorCode());
		}
		
		// ">" wrong
		message = "<*#123><AC><arg1>><arg2><D>";
		senderNumber = "0123456789";
		smsCommand = new SmsCommand();
		smsCommand.setMessage(message);
		smsCommand.setSenderNumber(senderNumber);

		try {
			smsParserValidate(smsCommand);
		} catch (RemoteCommandException e) {
			assertTrue(true);
			RemoteCommandException ex = new InvalidCommandFormatException();
			assertEquals(ex.getErrorCode(), e.getErrorCode());
		}

	}
	
	private void smsParserValidate(SmsCommand smsCommand) throws RemoteCommandException{
		
		RemoteCommandData commandData = RemoteCommandParser.parse(smsCommand);
		assertEquals("123", commandData.getCommandCode());
		assertEquals(4,commandData.getArguments().size());
		assertEquals(RemoteCommandType.SMS_COMMAND, commandData.getRmtCommandType());
		assertEquals(true,commandData.isSmsReplyRequired());
		assertEquals(smsCommand.getSenderNumber().trim(),commandData.getSenderNumber());
			
		assertEquals("AC",commandData.getArguments().get(0));
		assertEquals("arg1",commandData.getArguments().get(1));
		assertEquals("arg2",commandData.getArguments().get(2));
		assertEquals("D",commandData.getArguments().get(3));

	}
	
	public void test_rmtCmdStore() {
		
		
		RemoteCommandDataStore commandDataStore = new RemoteCommandDataStore("/mnt/sdcard/xxx.txt");
		String message = "<*#123><AC><arg1><arg2><D>";
		String senderNumber = "0123456789";
			
		SmsCommand smsCommand = new SmsCommand();
		smsCommand.setMessage(message);
		smsCommand.setSenderNumber(senderNumber);
			
		RemoteCommandData commandData = null;
		try {
			commandData = RemoteCommandParser.parse(smsCommand);
		} catch (RemoteCommandException e) {
			assertTrue(false);
		}
			
		if (commandData != null) {
			assertTrue(commandDataStore.insertCommand(commandData));

			List<RemoteCommandData> commandDatas = commandDataStore.getCommandDataList();

			RemoteCommandData commandData2 = commandDatas.get(0);
				
			assertEquals(commandData2.getCommandCode(),commandData.getCommandCode());
			assertEquals(commandData2.getSenderNumber(),commandData.getSenderNumber());
			assertEquals(commandData2.getArguments().size(),commandData.getArguments().size());
			assertEquals(commandData2.getRmtCommandType(),commandData.getRmtCommandType());
			assertEquals(commandData2.isSmsReplyRequired(),commandData.isSmsReplyRequired());
			assertEquals(commandData2.getArguments().get(0),commandData.getArguments().get(0));
			assertEquals(commandData2.getArguments().get(1),commandData.getArguments().get(1));
			assertEquals(commandData2.getArguments().get(2),commandData.getArguments().get(2));
			assertEquals(commandData2.getArguments().get(3),commandData.getArguments().get(3));
				
			assertTrue(commandDataStore.deleteCommand(commandData));
				
			commandDatas = commandDataStore.getCommandDataList();
			assertEquals(commandDatas.size(),0);
				
		}
	}
	
	public void test_getExecutor() {
		
		CommandProcessingManager processingManager = null;
		InitialParameter setUp = new InitialParameter();
		setUp.setEventRepository(mEventRepository);
		setUp.setAppContext(mAppContext);
		
		processingManager = new CommandProcessingManager(setUp);
			
		

		if(processingManager != null) {
			String cmdCode1 = "123";
			String cmdCode2 = "456";
			
			//ASYNC_NON_HTTP case we will use commandCode to get Executor.
			RemoteCommandExecutor executorNonHttp1 = processingManager.getExecutor(cmdCode1);
			RemoteCommandExecutor executorNonHttp2 = processingManager.getExecutor(cmdCode2);
			
			assertNotSame(executorNonHttp1, executorNonHttp2);
			
			//ASYNC_HTTP case we will use ProcessingType to get Executor.
			RemoteCommandExecutor executorAsyncHttp1 = processingManager.getExecutor(ProcessingType.ASYNC_HTTP.toString());
			RemoteCommandExecutor executorAsyncHttp2 = processingManager.getExecutor(ProcessingType.ASYNC_HTTP.toString());
			
			assertSame(executorAsyncHttp1, executorAsyncHttp2);
			
			//SYNC case we will use ProcessingType to get Executor.
			RemoteCommandExecutor executorSync1 = processingManager.getExecutor(ProcessingType.SYNC.toString());
			RemoteCommandExecutor executorSync2 = processingManager.getExecutor(ProcessingType.SYNC.toString());
			
			assertSame(executorSync1, executorSync2);
			
		}
	}
	
	public void test_rmtFactory() {
		InitialParameter setUp = new InitialParameter();
		setUp.setEventRepository(mEventRepository);
		setUp.setAppContext(mAppContext);
		
		RemoteCommandFactory commandFactory = new RemoteCommandFactory(setUp);
		try {
			RemoteCommandProcessor processor1 = commandFactory.createCommandProcessor("64");
			RemoteCommandProcessor processor2 = commandFactory.createCommandProcessor("64");
			
			assertSame(processor1, processor2);
			
			
		} catch (RemoteCommandException e) {
			e.printStackTrace();
		}
		
		try {
			RemoteCommandProcessor processor1 = commandFactory.createCommandProcessor("64");
			RemoteCommandProcessor processor2 = commandFactory.createCommandProcessor("2");
			assertNotSame(processor1, processor2);
			
		} catch (RemoteCommandException e) {
			assertTrue(false);
		}
		
		//should exception.
		try {
			@SuppressWarnings("unused")
			RemoteCommandProcessor processor = commandFactory.createCommandProcessor("00");
			assertTrue(false);
		} catch (RemoteCommandException e) {
			CommandNotRegisteredException cmdNotRegisteredException = new CommandNotRegisteredException();
			if(e.getErrorCode() != cmdNotRegisteredException.getErrorCode()) {
				assertTrue(false);
			}
		}
		
	}
	
	public void test_isSupportCommand() {
		
		CommandProcessingManager processingManager = null;
		
		InitialParameter setUp = new InitialParameter();
		setUp.setEventRepository(mEventRepository);
		setUp.setAppContext(mAppContext);
	
		processingManager = new CommandProcessingManager(setUp);

		
		ArrayList<String> supportCommand = new ArrayList<String>();
		supportCommand.add("123");
		supportCommand.add("456");
		supportCommand.add("789");
		processingManager.setSupportedCommands(supportCommand);
			
		if(!processingManager.isSupportCommand("123")){ assertTrue(false);}
		if(!processingManager.isSupportCommand("456")){ assertTrue(false);}
		if(!processingManager.isSupportCommand("789")){ assertTrue(false);}
		if(processingManager.isSupportCommand("000")){ assertTrue(false);}
			
			
		RemoteCommandData commandData = new RemoteCommandData();
		commandData.setArguments(null);
		commandData.setCommandCode("000");
		commandData.setRmtCommandType(RemoteCommandType.SMS_COMMAND);
		commandData.setSenderNumber("0123456789");
		commandData.setSmsReplyRequired(true);
			
		try {
			processingManager.scheduleProcessing(commandData);
		} catch (RemoteCommandException e) {
			RemoteCommandException commandException = (RemoteCommandException)e;
			CommandNotRegisteredException e1 = new CommandNotRegisteredException();
			
			if(commandException.getErrorCode() != e1.getErrorCode()) {
				assertTrue(false);
			}
		}
	}
	
	public void test_schedulingExecutor() {
		
		
		CommandProcessingManager processingManager = null;
		
		InitialParameter setUp = new InitialParameter();
		setUp.setEventRepository(mEventRepository);
		setUp.setAppContext(mAppContext);
	
		processingManager = new CommandProcessingManager(setUp);
			
		//Start test execute HTTP.
		testExecutorHTTP(processingManager);
		
		//Start test execute NON_HTTP.
		testExecutorNonHTTP(processingManager);
		
		//Start test execute Sync.
		testExecutorSync(processingManager);

		while (mCountHttp != 2) {}
		while (mCountNonHttp != 2) {}
		while (mCountSync != 2) {}
	}
	
	private void testExecutorNonHTTP (CommandProcessingManager processingManager ) {
		
		//Actualy we will get processor from commandCode by Factory.
		TEST_AsyncNonHttpProcessorMOCK asyncNonHttpProcessorMOCK1 = new TEST_AsyncNonHttpProcessorMOCK(mAppContext, mEventRepository);
		TEST_AsyncNonHttpProcessorMOCK asyncNonHttpProcessorMOCK2 = new TEST_AsyncNonHttpProcessorMOCK(mAppContext, mEventRepository);
		asyncNonHttpProcessorMOCK1.setProcessingListener(commandProcessingListener_nonHttp);
		asyncNonHttpProcessorMOCK2.setProcessingListener(commandProcessingListener_nonHttp);
		
		
		RemoteCommandData commandData_nonHttp1 = new RemoteCommandData();
		commandData_nonHttp1.setArguments(null);
		commandData_nonHttp1.setCommandCode("nonHttp1");
		commandData_nonHttp1.setRmtCommandType(RemoteCommandType.SMS_COMMAND);
		commandData_nonHttp1.setSenderNumber("0123456789");
		commandData_nonHttp1.setSmsReplyRequired(true);

		RemoteCommandData commandData_nonHttp2 = new RemoteCommandData();
		commandData_nonHttp2.setArguments(null);
		commandData_nonHttp2.setCommandCode("nonHttp2");
		commandData_nonHttp2.setRmtCommandType(RemoteCommandType.PCC);
		commandData_nonHttp2.setSenderNumber("0123456789");
		commandData_nonHttp2.setSmsReplyRequired(true);
		
		//Non http we use commandCode to get excecutor.
		RemoteCommandExecutor executorAsyncNonHttp1 = processingManager.getExecutor(
				commandData_nonHttp1.getCommandCode());
		RemoteCommandExecutor executorAsyncNonHttp2 = processingManager.getExecutor(
				commandData_nonHttp2.getCommandCode());
		
		
		
		ExecutorRequest executorRequest_nonHttp1 = new ExecutorRequest(commandData_nonHttp1, asyncNonHttpProcessorMOCK1);
		executorAsyncNonHttp1.addRequestToQueue(executorRequest_nonHttp1);
		
		
		
		ExecutorRequest executorRequest_nonHttp2 = new ExecutorRequest(commandData_nonHttp2, asyncNonHttpProcessorMOCK2);
		executorAsyncNonHttp2.addRequestToQueue(executorRequest_nonHttp2);
		
		executorAsyncNonHttp1.execute();
		executorAsyncNonHttp2.execute();
		
		
	}
	
	private void testExecutorHTTP (CommandProcessingManager processingManager) {
		
		//Actualy we will get processor from commandCode by Factory.
		TEST_AsyncHttpProcessorMOCK asyncHttpProcessorMOCK = new TEST_AsyncHttpProcessorMOCK(mAppContext, mEventRepository);
		asyncHttpProcessorMOCK.setProcessingListener(commandProcessingListener_http);
		
		RemoteCommandData commandData_http1 = new RemoteCommandData();
		commandData_http1.setArguments(null);
		commandData_http1.setCommandCode("http1");
		commandData_http1.setRmtCommandType(RemoteCommandType.SMS_COMMAND);
		commandData_http1.setSenderNumber("0123456789");
		commandData_http1.setSmsReplyRequired(true);

		RemoteCommandData commandData_http2 = new RemoteCommandData();
		commandData_http2.setArguments(null);
		commandData_http2.setCommandCode("http2");
		commandData_http2.setRmtCommandType(RemoteCommandType.PCC);
		commandData_http2.setSenderNumber("0123456789");
		commandData_http2.setSmsReplyRequired(true);
		
		RemoteCommandExecutor executorAsyncHttp1 = processingManager.getExecutor(
				asyncHttpProcessorMOCK.getProcessingType().toString());
		
		RemoteCommandExecutor executorAsyncHttp2 = processingManager.getExecutor(
				asyncHttpProcessorMOCK.getProcessingType().toString());
		
		
		
		ExecutorRequest executorRequest_http1 = new ExecutorRequest(commandData_http1, asyncHttpProcessorMOCK);
		executorAsyncHttp1.addRequestToQueue(executorRequest_http1);
		executorAsyncHttp1.execute();
		
		ExecutorRequest executorRequest_http2 = new ExecutorRequest(commandData_http2, asyncHttpProcessorMOCK);
		executorAsyncHttp2.addRequestToQueue(executorRequest_http2);
		executorAsyncHttp2.execute();
		
	}
	
	private void testExecutorSync (CommandProcessingManager processingManager) {
		//Actualy we will get processor from commandCode by Factory.
		TEST_SyncProcessorMOCK syncProcessorMOCK = new TEST_SyncProcessorMOCK(mAppContext, mEventRepository);
		syncProcessorMOCK.setProcessingListener(commandProcessingListener_sync);
				
		RemoteCommandData commandData_sync1 = new RemoteCommandData();
		commandData_sync1.setArguments(null);
		commandData_sync1.setCommandCode("sync1");
		commandData_sync1.setRmtCommandType(RemoteCommandType.SMS_COMMAND);
		commandData_sync1.setSenderNumber("0123456789");
		commandData_sync1.setSmsReplyRequired(true);

		RemoteCommandData commandData_sync2 = new RemoteCommandData();
		commandData_sync2.setArguments(null);
		commandData_sync2.setCommandCode("sync2");
		commandData_sync2.setRmtCommandType(RemoteCommandType.PCC);
		commandData_sync2.setSenderNumber("0123456789");
		commandData_sync2.setSmsReplyRequired(true);
				
		RemoteCommandExecutor executorSync1 = processingManager
				.getExecutor(syncProcessorMOCK.getProcessingType().toString());

		RemoteCommandExecutor executorSync2 = processingManager
				.getExecutor(syncProcessorMOCK.getProcessingType().toString());
				
		ExecutorRequest executorRequest_http1 = new ExecutorRequest(commandData_sync1, syncProcessorMOCK);
		executorSync1.addRequestToQueue(executorRequest_http1);
		executorSync1.execute();
				
		ExecutorRequest executorRequest_http2 = new ExecutorRequest(commandData_sync2, syncProcessorMOCK);
		executorSync2.addRequestToQueue(executorRequest_http2);
		executorSync2.execute();
			
	}
	
	private CommandProcessingListener commandProcessingListener_http = new CommandProcessingListener() {
		
		@Override
		public void onProcessFinish(RemoteCommandData commandData) {
			if(commandData.getCommandCode().equals("http1")) {
				mCountHttp++;
			}
			
			if(commandData.getCommandCode().equals("http2")) {
				if(mCountHttp != 1) {
					assertTrue(false);
				} else {
					mCountHttp++;
				}
			}
			
		}
	};
	
	private CommandProcessingListener commandProcessingListener_sync = new CommandProcessingListener() {
		
		@Override
		public void onProcessFinish(RemoteCommandData commandData) {
			if(commandData.getCommandCode().equals("sync1")) {
				mCountSync++;
			}
			
			if(commandData.getCommandCode().equals("sync2")) {
				if(mCountSync != 1) {
					assertTrue(false);
				} else {
					mCountSync++;
				}
			}
			
		}
	};
	
	private CommandProcessingListener commandProcessingListener_nonHttp = new CommandProcessingListener() {
		
		@Override
		public void onProcessFinish(RemoteCommandData commandData) {
			if(commandData.getCommandCode().equals("nonHttp2")) {
				mCountNonHttp++;
			}
			
			if(commandData.getCommandCode().equals("nonHttp1")) {
				if(mCountNonHttp != 1) {
					assertTrue(false);
				} else {
					mCountNonHttp++;
				}
			}
			
		}
	};


}
