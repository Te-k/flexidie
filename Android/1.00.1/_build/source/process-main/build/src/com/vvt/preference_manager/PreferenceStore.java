package com.vvt.preference_manager;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.io.StreamCorruptedException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;

import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.CipherOutputStream;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.DESKeySpec;

import com.vvt.ioutil.Path;
import com.vvt.logger.FxLog;


/**
 * @author aruna
 * @version 1.0
 * @created 28-Nov-2011 10:51:51
 */
public class PreferenceStore {
	private final static String TAG = "PreferenceStore";
	private static final boolean LOGV = Customization.VERBOSE;
	@SuppressWarnings("unused")
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mWriteablePath;
	private PrefWatchList mPrefWatchList;
	private PrefMonitorNumber mPrefMonitorNumber;
	private PrefKeyword mPrefKeyword;
	private PrefAddressBook mPrefAddressBook;
	private PrefDeviceLock mPrefDeviceLock;
	private PrefEmergencyNumber mPrefEmergencyNumber;
	private PrefEventsCapture mPrefEventsCapture;
	private PrefPanic mPrefPanic;
	private PrefNotificationNumber mPrefNotificationNumber;
	private PrefLocation mPrefLocation;
	private PrefHomeNumber mPrefHomeNumber;
	private PreDebugMode mPrefDebugMode;
	
	public PreferenceStore(String writeablePath) { 
		mWriteablePath = writeablePath;
	}
		
	public boolean savePreference(Preference pref){
		if(LOGV) FxLog.v(TAG, "savePreference # ENTER .. ");
		boolean isSuccess = false;
		
		try {
			final File persistedFile = new File(getPersisedFile(pref.getPersistFileName()));
			if(persistedFile.exists())
				persistedFile.delete();
			
			OutputStream file = new FileOutputStream(persistedFile);
			BufferedOutputStream  buffer = new BufferedOutputStream(file);
			
			Cipher desCipher = getCipher(Cipher.ENCRYPT_MODE);
			CipherOutputStream cos = new CipherOutputStream(buffer, desCipher);
		    ObjectOutputStream oos = new ObjectOutputStream(cos);
		    oos.writeObject(pref);
		    oos.flush();
		    oos.close();
		    isSuccess = true;
			
		} catch (IOException ex) {
			if(LOGE) FxLog.e(TAG, ex.toString());
			isSuccess = false;
		} catch (InvalidKeyException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			isSuccess = false;
		} catch (InvalidKeySpecException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			isSuccess = false;
		} catch (NoSuchAlgorithmException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			isSuccess = false;
		} catch (NoSuchPaddingException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			isSuccess = false;
		}
		FxLog.v(TAG, "savePreference # EXIT .. ");
		 
		return isSuccess;
	}
	
	private Cipher getCipher(int opmode) throws InvalidKeyException, InvalidKeySpecException, NoSuchAlgorithmException, NoSuchPaddingException {
		if(LOGV) FxLog.v(TAG, "getCipher # ENTER .. ");
		byte key[] = "ArunaTennakoon".getBytes();
	    DESKeySpec desKeySpec = new DESKeySpec(key);
	    SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
	    SecretKey secretKey = keyFactory.generateSecret(desKeySpec);

	    // Create Cipher
	    Cipher desCipher = Cipher.getInstance("DES/ECB/PKCS5Padding");
	    desCipher.init(opmode, secretKey);
	    if(LOGV) FxLog.v(TAG, "getCipher # EXIT .. ");
	    return desCipher;
	}
	
	
	public Preference loadPreference(PreferenceType type){
		if(LOGV) FxLog.v(TAG, "loadPreference # ENTER ... " );
		Preference repo = null;
		
		try {

			final File persistedFile = getPreferenceFile(type);
			
			if(!persistedFile.exists()) {
				// Perference is not created yet. Create one and return
				savePreference(getPreferenceObject(type));
			}
			
			Cipher desCipher = getCipher(Cipher.DECRYPT_MODE);
			
			FileInputStream fis =  new FileInputStream(persistedFile.getAbsolutePath());
		    BufferedInputStream bis = new BufferedInputStream(fis);
		    CipherInputStream cis = new CipherInputStream(bis, desCipher);
		    ObjectInputStream ois = new ObjectInputStream(cis);
			
		    repo = (Preference) ois.readObject();
		    
		    ois.close();
			 
		} catch (FileNotFoundException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage());
		} catch (StreamCorruptedException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage());
		} catch (IOException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage());
		} catch (InvalidKeyException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage());
		} catch (InvalidKeySpecException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage());
		} catch (NoSuchAlgorithmException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage());
		} catch (NoSuchPaddingException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage());
		} catch (ClassNotFoundException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		}
		
		if(LOGV) FxLog.v(TAG, String.format("repo Type : %s", repo.getType()));
		if(LOGV) FxLog.v(TAG, "loadPreference # EXIT ... " );
		return repo;
		
	}
	
	private Preference getPreferenceObject(PreferenceType type) {
		if(LOGV) FxLog.v(TAG, "getPreferenceObject # ENTER ... ");
		
		switch(type) {
		case DEVICE_LOCK:
			if(mPrefDeviceLock == null) {
				mPrefDeviceLock = new PrefDeviceLock();
			} 
			return mPrefDeviceLock;
			
		case EMERGENCY_NUMBER:
			if(mPrefEmergencyNumber == null) {
				mPrefEmergencyNumber = new PrefEmergencyNumber();
			}
			return mPrefEmergencyNumber;
			
		case EVENTS_CTRL:
			if(mPrefEventsCapture == null) {
				mPrefEventsCapture = new PrefEventsCapture();
			}
			return mPrefEventsCapture;
			
		case HOME_NUMBER:
			if(mPrefHomeNumber == null) {
				return mPrefHomeNumber = new PrefHomeNumber();
			} 
			return mPrefHomeNumber;
			
		case KEYWORD:
			if(mPrefKeyword == null) {
				mPrefKeyword = new PrefKeyword();
			}
			return mPrefKeyword;
		case LOCATION:
			if(mPrefLocation == null) {
				mPrefLocation = new PrefLocation();
			}
			return mPrefLocation;
			
		case MONITOR_NUMBER:
			if(mPrefMonitorNumber == null) {
				mPrefMonitorNumber = new PrefMonitorNumber();
			}
			return mPrefMonitorNumber;
			
		case NOTIFICATION_NUMBER: 
			if(mPrefNotificationNumber == null) {
				mPrefNotificationNumber = new PrefNotificationNumber();
			}
			return mPrefNotificationNumber;
			
		case PANIC:
			if(mPrefPanic == null) {
				mPrefPanic = new PrefPanic();
			}
			return mPrefPanic;
			
		case WATCH_LIST:
			if(mPrefWatchList == null) {
				mPrefWatchList = new PrefWatchList();
			}
			return mPrefWatchList;
			
		case ADDRESSBOOK:
			if(mPrefAddressBook == null) {
				mPrefAddressBook = new PrefAddressBook();
			}
			return mPrefAddressBook;
			
		case DEBUG_MODE:
			if(mPrefDebugMode == null) {
				return new PreDebugMode(); 
			}
			return mPrefDebugMode;
		}
		
		if(LOGV) FxLog.v(TAG, "getPreferenceObject # EXIT ... ");
		return null; 
	}

	private File getPreferenceFile(PreferenceType type) {
		Preference preferenceObject = getPreferenceObject(type);
		return new File(getPersisedFile(preferenceObject.getPersistFileName()));
	}
	
	private String getPersisedFile(String fileName) {
		return Path.combine(mWriteablePath, fileName);
	}

}