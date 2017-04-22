package com.vvt.remotecommandmanager.processor.keywordlist;

import java.util.ArrayList;

import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.appcontext.AppContext;
import com.vvt.appcontext.AppContextImpl;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.license.LicenseInfo;
import com.vvt.preference_manager.Preference;
import com.vvt.preference_manager.PreferenceManager;
import com.vvt.preference_manager.PreferenceType;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.RemoteCommandType;
import com.vvt.remotecommandmanager.Remote_command_manager_testsActivity;
import com.vvt.remotecommandmanager.TEST_EventRepositoryMock;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;

public class AddKeywordProcessorTestCase extends ActivityInstrumentationTestCase2<Remote_command_manager_testsActivity> {

	private Context mTestContext;
	private AppContext mAppContext;
	private FxEventRepository mEventRepository;
	
	public AddKeywordProcessorTestCase() {
		super("com.vvt.remotecommandmanager", Remote_command_manager_testsActivity.class);
	}
	
	@Override
	protected void setUp()  throws Exception {
		super.setUp();
		mTestContext = this.getInstrumentation().getContext();

		mEventRepository = new TEST_EventRepositoryMock(DataProviderType.DATA_PROVIDER_TYPE_NONE);
		mAppContext = new AppContextImpl(mTestContext);
	}
	
	public void test_AddKeyword() throws RemoteCommandException {
		LicenseInfo licenseInfo = new LicenseInfo();
		licenseInfo.setActivationCode("000001");
		
		PreferenceManagerMock preferenceManager = new PreferenceManagerMock();
		
		AddKeywordProcessor proc  = new AddKeywordProcessor(mAppContext, mEventRepository, licenseInfo, preferenceManager);
		
		RemoteCommandData commandData = new RemoteCommandData();
		commandData.setCommandCode("73");
		commandData.setRmtCommandType(RemoteCommandType.SMS_COMMAND);
		commandData.setSenderNumber("0820223268");
		commandData.setSmsReplyRequired(false);
		ArrayList<String> args = new ArrayList<String>();
		args.add("000001");
		args.add("KW1"); 
		commandData.setArguments(args);
		
		proc.doProcessCommand(commandData);
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
}

class PreferenceManagerMock implements PreferenceManager {

	@Override
	public Preference getPreference(PreferenceType type) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void savePreferenceAndNotifyChange(Preference preference) {
		// TODO Auto-generated method stub
		
	}

}

