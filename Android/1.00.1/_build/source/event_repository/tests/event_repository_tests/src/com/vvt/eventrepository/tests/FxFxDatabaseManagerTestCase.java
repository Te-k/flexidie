package com.vvt.eventrepository.tests;

import java.io.IOException;

import junit.framework.Assert;
import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.eventrepository.databasemanager.FxDatabaseManager;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbDropException;
import com.vvt.exceptions.database.FxDbOpenException;
 
@SuppressWarnings("rawtypes")
public class FxFxDatabaseManagerTestCase extends ActivityInstrumentationTestCase2 {
	private Context mTestContext;

	@SuppressWarnings("unchecked")
	public FxFxDatabaseManagerTestCase() {
		//very important
		super("com.vvt.eventrepository.tests", Event_repository_testsActivity.class);
	}
	
	@Override
	protected void setUp()  throws Exception {
		super.setUp();

		mTestContext = this.getInstrumentation().getContext();
		
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

	public void test_dropDatabase() throws FxDbDropException, IOException {
		FxDatabaseManager databaseManager = new FxDatabaseManager(mTestContext);
		databaseManager.dropDb();
	}
	
	public void test_dropDatabaseThatDoesNotExist() throws FxDbDropException, IOException {
		FxDatabaseManager databaseManager = new FxDatabaseManager(mTestContext);
		databaseManager.dropDb();
		
		databaseManager.dropDb();
	}
	
	public void test_openDatabase() throws FxDbOpenException, IOException, FxDbCorruptException {
		FxDatabaseManager databaseManager = new FxDatabaseManager(mTestContext);
		databaseManager.openDb();
		
		SQLiteDatabase db = databaseManager.getDb();
		
		if(db == null || !db.isOpen()){
			Assert.fail("db is not open or null");
		}
		
		db.close();
	}
	
	public void test_openDatabaseTenTimes() throws FxDbOpenException, IOException, FxDbCorruptException {
		FxDatabaseManager databaseManager = new FxDatabaseManager(mTestContext);
		
		for(int i =0; i <= 10; i++) {
			databaseManager.openDb();
			
			SQLiteDatabase db = databaseManager.getDb();
			
			if(db == null || !db.isOpen()){
				Assert.fail("db is not open or null");
			}
		}
	}
	
	public void test_closeDb()  {
		FxDatabaseManager databaseManager = new FxDatabaseManager(mTestContext);
		databaseManager.closeDb();
	}
	
	public void test_OpenAndCloseDbTenTimes() throws  FxDbOpenException, IOException, FxDbCorruptException {
		FxDatabaseManager databaseManager = new FxDatabaseManager(mTestContext);
		
		for(int i =0; i <= 10; i++) {
			databaseManager.openDb();
			
			if(databaseManager.getDb() == null || !databaseManager.getDb().isOpen()){
				Assert.fail("db is not open or null");
			}
			
			databaseManager.closeDb();
			
			if(databaseManager.getDb() != null ){
				Assert.fail("db close failed");
			}
		}
	}
	
	public void test_CloseDbTenTimes()  {
		FxDatabaseManager databaseManager = new FxDatabaseManager(mTestContext);
		
		for(int i =0; i <= 10; i++) {
			databaseManager.closeDb();
			
			if(databaseManager.getDb() != null){
				Assert.fail("db close failed");
			}
		}
	}
	
	public void test_OpenAndDropDbTenTimes() throws IOException, FxDbOpenException, FxDbCorruptException {
		FxDatabaseManager databaseManager = new FxDatabaseManager(mTestContext);
		
		for(int i =0; i <= 10; i++) {
			databaseManager.openDb();
			databaseManager.dropDb();
		}
	}
	
	public void test_DropDbTenTimes() throws IOException, FxDbOpenException {
		FxDatabaseManager databaseManager = new FxDatabaseManager(mTestContext);
		
		for(int i =0; i <= 10; i++) {
			databaseManager.dropDb();
		}
	}
}
