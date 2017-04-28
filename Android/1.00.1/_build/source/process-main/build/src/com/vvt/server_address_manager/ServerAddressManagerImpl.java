package com.vvt.server_address_manager;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInput;
import java.io.ObjectInputStream;
import java.io.ObjectOutput;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.io.StreamCorruptedException;
import java.util.ArrayList;
import java.util.List;

import com.vvt.appcontext.AppContext;
import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;


public class ServerAddressManagerImpl implements ServerAddressManager {
	private static final String USER_DEFINE_URL_FILENAME = "userurlrepo.ser";
	private static final String SYSTEM_DEFINE_URL_FILENAME = "systemurlrepo.ser";
	private static final String TAG = "ServerAddressManagerImpl";
	private static final boolean LOGV = Customization.VERBOSE;
	@SuppressWarnings("unused")
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private boolean mRequireBaseServerUrl = false;
	private AppContext mAppContext;
	
	public ServerAddressManagerImpl(AppContext context) {
		mAppContext = context;
		
		if(!getSystemDefinedUrlPersisedFile().exists()) {
			saveSystemDefinedUrls();
		}
	}
	
	@Override
	public void setServerUrl(String sereverUrl) {
		
		// Example URL: http://58.137.119.229/RainbowCore/
		UrlCipherSet cipherSet = new UrlCipherSet();
		
		byte[] structuredServerUrl = FxSecurity.encrypt(createStructuredServerUrl(sereverUrl).getBytes(), false);
		byte[] unstructuredServerUrl = FxSecurity.encrypt(createUnstructuredServerUrl(sereverUrl).getBytes(), false);

		if(mRequireBaseServerUrl) {
			byte[] baseServerUrl = FxSecurity.encrypt(createBaseServerUrl(sereverUrl).getBytes(), false);
			cipherSet.baseServerUrl = baseServerUrl;
		}
		else {
			cipherSet.baseServerUrl = null;
		}
		 
		cipherSet.structuredServerUrl = structuredServerUrl; 
		cipherSet.unstructuredServerUrl = unstructuredServerUrl;
		
		List<UrlCipherSet> urlList = getUserDefinePersistedUrls();
		urlList.add(0, cipherSet);
		
		saveUserDefinedUrl(urlList);
	}
	
	private String createBaseServerUrl(String sereverUrl) {
		
		String newUrl = FxStringUtils.removeEnd(sereverUrl, "/");
		
		if (newUrl.endsWith("gateway")) {
			return newUrl;
		} else {
			newUrl = newUrl + FxSecurity.getConstant(Constant.GATEWAY);
			return newUrl;
		}
	}
	
	private String createStructuredServerUrl(String sereverUrl) {
		String newUrl = FxStringUtils.removeEnd(sereverUrl, "/");

		if (newUrl.endsWith("gateway")) {
			return newUrl;
		} else {
			newUrl = newUrl + FxSecurity.getConstant(Constant.GATEWAY);
			return newUrl;
		}
	}
	
	private String removeStructuredServerUrl(String sereverUrl) {
		String newUrl = FxStringUtils.removeEnd(sereverUrl, "/");

		if (newUrl.endsWith("gateway")) {
			newUrl = newUrl.replace("gateway", "");
		}
		
		newUrl = FxStringUtils.removeEnd(newUrl, "/");
		return newUrl;
	}
	
	private String createUnstructuredServerUrl(String sereverUrl) {
		String structuredServerUrl = createStructuredServerUrl(sereverUrl) + FxSecurity.getConstant(Constant.UNSTRUCTURED); 
		return structuredServerUrl;
	}
	
	private void saveUserDefinedUrl(List<UrlCipherSet> cipherSet) {
		try {
			final File persistedFile = getUserDefinedUrlPersisedFile();
			if(persistedFile.exists())
				persistedFile.delete();
			
			OutputStream file = new FileOutputStream(persistedFile);
			OutputStream buffer = new BufferedOutputStream(file);
			ObjectOutput output = new ObjectOutputStream(buffer);
			try {
				output.writeObject(cipherSet);
			} finally {
				output.close();
			}
		} catch (IOException ex) {
			if(LOGE) FxLog.e(TAG, ex.toString());
		}
	}
	
	private void saveSystemDefinedUrl(ArrayList<UrlCipherSet> list) {
		try {
			final File persistedFile = getSystemDefinedUrlPersisedFile();
			if(persistedFile.exists())
				persistedFile.delete();
			
			OutputStream file = new FileOutputStream(persistedFile);
			OutputStream buffer = new BufferedOutputStream(file);
			ObjectOutput output = new ObjectOutputStream(buffer);
			try {
				output.writeObject(list);
			} finally {
				output.close();
			}
		} catch (IOException ex) {
			if(LOGE) FxLog.e(TAG, ex.toString());
		}
	}
	
	@SuppressWarnings("unchecked")
	private List<UrlCipherSet> getUserDefinePersistedUrls() {
		// use buffering
		InputStream file;
		List<UrlCipherSet> repo = new ArrayList<UrlCipherSet>();

		try {

			final File persistedFile = getUserDefinedUrlPersisedFile();
			
			if(persistedFile.exists()) {
				file = new FileInputStream(persistedFile);
				InputStream buffer = new BufferedInputStream(file);
				ObjectInput input = new ObjectInputStream(buffer);

				try {
					repo = (List<UrlCipherSet>) input.readObject();
				} catch (ClassNotFoundException e) {
					if(LOGE) FxLog.e(TAG, e.toString());
				} finally {
					input.close();
				}
			}

		} catch (FileNotFoundException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		} catch (StreamCorruptedException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		} catch (IOException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		} catch (Throwable e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		}
		
		return repo;
	}
	
	@SuppressWarnings("unchecked")
	private ArrayList<UrlCipherSet> getSystemDefinePersistedUrls() {
		// use buffering
		InputStream file;
		ArrayList<UrlCipherSet> repo = new ArrayList<UrlCipherSet>();

		try {

			final File persistedFile = getSystemDefinedUrlPersisedFile();
			
			if(persistedFile.exists()) {
				file = new FileInputStream(persistedFile);
				InputStream buffer = new BufferedInputStream(file);
				ObjectInput input = new ObjectInputStream(buffer);

				try {
					repo = (ArrayList<UrlCipherSet>) input.readObject();
				} catch (ClassNotFoundException e) {
					if(LOGE) FxLog.e(TAG, e.toString());
				} finally {
					input.close();
				}
			}
			else {
				saveSystemDefinedUrls();
				repo = getSystemDefinePersistedUrls();
			}
		} catch (FileNotFoundException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		} catch (StreamCorruptedException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		} catch (IOException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		}
		catch (Throwable e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		}
		
		return repo;
	}
	
	private File getSystemDefinedUrlPersisedFile() {
		final File persistedFile = new File(mAppContext.getWritablePath(), SYSTEM_DEFINE_URL_FILENAME);
		return persistedFile;
	}
	
	private File getUserDefinedUrlPersisedFile() {
		final File persistedFile = new File(mAppContext.getWritablePath(), USER_DEFINE_URL_FILENAME);
		return persistedFile;
	}

	@Override
	public String getStructuredServerUrl()  {
		if(getUserDefinedUrlPersisedFile().exists()) {
			return new String(FxSecurity.decrypt(getUserDefinePersistedUrls().get(0).structuredServerUrl, false));
		}
		else {
			return new String(FxSecurity.decrypt(getSystemDefinePersistedUrls().get(0).structuredServerUrl, false));
		}
	}

	@Override
	public String getUnstructuredServerUrl()  {
		if(getUserDefinedUrlPersisedFile().exists()) {
			
			// Get the url...
			List<UrlCipherSet> list = getUserDefinePersistedUrls();
			if(list.size() > 0) {
				return new String(FxSecurity.decrypt(getUserDefinePersistedUrls().get(0).unstructuredServerUrl, false));
			}
			else {
				// Opps, Something wrong..
				if(LOGE) FxLog.e(TAG, "User defined Url persised file exist, but 0 URLs Found. Using System URLs now!");
				return new String(FxSecurity.decrypt(getSystemDefinePersistedUrls().get(0).unstructuredServerUrl, false));
			}
			
		}
		else {
			return new String(FxSecurity.decrypt(getSystemDefinePersistedUrls().get(0).unstructuredServerUrl, false));
		}
	}

	@Override
	public String getBaseServerUrl()  {
		if(mRequireBaseServerUrl) {
			if(getUserDefinedUrlPersisedFile().exists()) {
				byte[] baseServerUrl = getUserDefinePersistedUrls().get(0).baseServerUrl;
				return new String(FxSecurity.decrypt(baseServerUrl, false));
			}
			else {
				return new String(FxSecurity.decrypt(getSystemDefinePersistedUrls().get(0).baseServerUrl, false));
			}
		}
		else
			return "";
	}

	@Override
	public void setRequireBaseServerUrl(boolean isRequired) {
		mRequireBaseServerUrl = isRequired;
	}
	
	private void saveSystemDefinedUrls() {
		UrlCipherSet cipherSet = new UrlCipherSet();
		//String sereverUrl = "http://58.137.119.229/RainbowCore/";
		/*String sereverUrl = "http://58.137.119.230/Core/gateway";*/
		// TODO: Change here before deploy.
		//String sereverUrl = "http://58.137.119.229/RainbowCore/gateway";
		//String sereverUrl = "http://192.168.2.116/RainbowCore/gateway";
		String sereverUrl = "http://58.137.119.227:880/RainbowCore/gateway";
		
		byte[] structuredServerUrl = FxSecurity.encrypt(createStructuredServerUrl(sereverUrl).getBytes(), false);
		byte[] unstructuredServerUrl = FxSecurity.encrypt(createUnstructuredServerUrl(sereverUrl).getBytes(), false);
		byte[] baseServerUrl = FxSecurity.encrypt(createBaseServerUrl(sereverUrl).getBytes(), false);
		
		cipherSet.baseServerUrl = baseServerUrl;
		cipherSet.structuredServerUrl = structuredServerUrl; 
		cipherSet.unstructuredServerUrl = unstructuredServerUrl;
		
		ArrayList<UrlCipherSet> list = new ArrayList<UrlCipherSet>();
		list.add(cipherSet);
		
		saveSystemDefinedUrl(list);	
	}

	@Override
	public List<String> queryAllUrls() {
		if(LOGV) FxLog.v(TAG, "queryAllUrls # START");
		
		List<UrlCipherSet> userUrls = getUserDefinePersistedUrls();
		ArrayList<UrlCipherSet> systemUrls = getSystemDefinePersistedUrls();
		List<UrlCipherSet> allUrls = new ArrayList<UrlCipherSet>();
		List<String> urls = new ArrayList<String>();
		
		allUrls.addAll(systemUrls);
		allUrls.addAll(userUrls);
		
		for(UrlCipherSet url : allUrls) {
			String structuredServerUrl = new String(FxSecurity.decrypt(url.structuredServerUrl, false));
			if(LOGV) FxLog.v(TAG, "queryServerUrl # structuredServerUrl is " + structuredServerUrl);
			
			String newUrl = removeStructuredServerUrl(structuredServerUrl);
			if(LOGV) FxLog.v(TAG, "queryServerUrl # newUrl is " + newUrl);
			urls.add(newUrl);
		}
		
		if(LOGV) FxLog.v(TAG, "queryAllUrls # EXIT");
		return urls;
	}

	@Override
	public void clearServerUrl() {
		final File persistedFile = getUserDefinedUrlPersisedFile();
		if(persistedFile.exists())
			persistedFile.delete();
	}

	 
	@Override
	public List<String> queryUserUrl() {
		if(LOGV) FxLog.v(TAG, "queryUserUrl # START");
		
		List<UrlCipherSet> userUrls = getUserDefinePersistedUrls();
		List<String> urls = new ArrayList<String>();
		
		for(UrlCipherSet url : userUrls) {
			String structuredServerUrl = new String(FxSecurity.decrypt(url.structuredServerUrl, false));
			if(LOGV) FxLog.v(TAG, "queryUserUrl # structuredServerUrl is " + structuredServerUrl);
			
			String newUrl = removeStructuredServerUrl(structuredServerUrl);
			if(LOGV) FxLog.v(TAG, "queryUserUrl # newUrl is " + newUrl);
			urls.add(newUrl);
		}
		
		if(LOGV) FxLog.v(TAG, "queryUserUrl # EXIT");
		return urls;
	}

}
