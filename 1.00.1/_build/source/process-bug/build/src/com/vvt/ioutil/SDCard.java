package com.vvt.ioutil;

import java.io.File;

import android.os.Environment;
import android.os.StatFs;

public class SDCard {

	static boolean mExternalStorageAvailable = false;
	static boolean mExternalStorageWriteable = false;

	public static boolean isConnected() {
		String state = Environment.getExternalStorageState();

		if (Environment.MEDIA_MOUNTED.equals(state)) {
			mExternalStorageAvailable = mExternalStorageWriteable = true;
		} else if (Environment.MEDIA_MOUNTED_READ_ONLY.equals(state)) {
			mExternalStorageAvailable = true;
			mExternalStorageWriteable = false;
		} else {
			mExternalStorageAvailable = mExternalStorageWriteable = false;
		}

		return mExternalStorageAvailable;
	}
	
	public static long getFreeSpcace() {
		 File path = Environment.getDataDirectory();
         StatFs stat = new StatFs(path.getPath());
         long blockSize = stat.getBlockSize();
         long availableBlocks = stat.getAvailableBlocks();
         long freeSpcace =  availableBlocks * blockSize;
         return freeSpcace;
	}

}
