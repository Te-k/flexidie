package com.vvt.configurationmanager;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.util.List;

import android.content.Context;
import android.content.res.AssetManager;

import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;
import com.vvt.ioutil.Path;
import com.vvt.logger.FxLog;

public class ConfigurationManagerImpl implements ConfigurationManager{

	private static final String TAG = "ConfigurationManagerImpl";
	private static boolean LOGV = Customization.VERBOSE;
	private static boolean LOGD = Customization.DEBUG;
	private static boolean LOGE = Customization.ERROR;
	
	private int mCurrentConfID;
	private List<Configuration> mConfigurationList;
	
	private Context mContext;
	
	public ConfigurationManagerImpl(Context context) {
		mCurrentConfID = -1;
		mContext = context;
		
		loadProductDefinition();
	}
	
	// Used by daemon_appengin
	public ConfigurationManagerImpl(Context context, String path) {
		mCurrentConfID = -1;
		mContext = context;
		
		String fileName = Path.combine(path, "ProductDefinition");
		loadProductDefinition(fileName);
	}

	protected void loadProductDefinition() {
		// 1. read data from xml file to be byte array.
		byte[] xmlByteData = readDataFromXml();
		loadProductDefinitionFromBytes(xmlByteData);
	}
	
	protected void loadProductDefinition(String fileName) {
		if (LOGV) FxLog.v(TAG, "loadProductDefinition # START ...");
		if (LOGD) FxLog.d(TAG, "loadProductDefinition # fileName :" + fileName);
		
		// 1. read data from xml file to be byte array.
		byte[] xmlByteData = readDataFromXml(fileName);
		loadProductDefinitionFromBytes(xmlByteData);
		
		if (LOGV) FxLog.v(TAG, "loadProductDefinition # EXIT ...");
	}

	private void loadProductDefinitionFromBytes(byte[] xmlByteData) {
		// 2. use ConfigDecryptor to decrypt it to be can readable string.
		if (xmlByteData != null && xmlByteData.length > 0) {
			String xmlData = ConfigDecryptor.doDecrypt(xmlByteData);

			if (LOGD) FxLog.d(TAG, "loadProductDefinitionFromBytes # xmlData :" + xmlData);
			
			if (xmlData != null) {
				// 3. use ConfigParser to pass the string to list of
				// comfiguration.
				mConfigurationList = ConfigParser.doParse(xmlData);
			}
		}
	}
	
	protected byte[] readDataFromXml(String fileName) {
		if (LOGV) FxLog.v(TAG, "readDataFromXml # START ...");
		if (LOGV) FxLog.v(TAG, "readDataFromXml # fileName :" + fileName);
		
		byte fileContent[] = null;
		
		try {
			RandomAccessFile f = new RandomAccessFile(fileName, "r");
			   try {
		            // Get and check length
		            long longlength = f.length();
		            int length = (int) longlength;
		            if (length != longlength) throw new IOException("File size >= 2 GB");

		            // Read file and return data
		            fileContent = new byte[length];
		            f.readFully(fileContent);
		        }
		        finally {
		            f.close();
		        }
		}
		catch(Throwable t) {
			if (LOGE) FxLog.e(TAG,  t.toString());
		}
		
		if (LOGV) FxLog.v(TAG, "readDataFromXml # EXIT ...");
        return fileContent;

	}
	
	protected byte[] readDataFromXml() {
		byte fileContent[] = null;

		try {
			AssetManager assetManager = mContext.getAssets();
			String fileNane = FxSecurity.getConstant(Constant.FILE_NAME);
			InputStream input = assetManager.open(fileNane);
			int size = input.available();
			fileContent = new byte[size];
			input.read(fileContent);
			input.close();

		} catch (FileNotFoundException e) {
			if (LOGE) FxLog.e(TAG, "File Not Found", e);
		} catch (IOException ioe) {
			if (LOGE) FxLog.e(TAG, "Exception while reading the file", ioe);
		}

		return fileContent;
	} 
	
	@Override
	public void updateConfigurationID(int configurationID) {
		mCurrentConfID = configurationID;
	}

	@Override
	public boolean isSupportedFeature(FeatureID featureID) {
		if(mConfigurationList != null) {
			Configuration configuration = getConfiguration();
			List<FeatureID> featureIDs = configuration.getSupportedFeture();
			if(featureIDs.indexOf(featureID) != -1) {
				return true;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}

	@Override
	public Configuration getConfiguration() {
		Configuration configuration = null;
		
		if(mConfigurationList != null) {
			for(Configuration c : mConfigurationList) {
				if(c.getConfigurationID() == mCurrentConfID) {
					configuration = c;
					break;
				}
			}
		}
		return configuration;
	}

}
