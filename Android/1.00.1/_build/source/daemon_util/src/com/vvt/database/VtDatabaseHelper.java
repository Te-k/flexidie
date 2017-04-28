package com.vvt.database;

import java.io.File;

public class VtDatabaseHelper {
	
	public static final String SAMSUNG_SYSTEM_DB = "/dbdata/databases";
	public static final String GENERAL_SYSTEM_DB = "/data/data";

	/**
	 * Return absolute databases path of the specific package
	 * @param packageName
	 * @return NULL if databases for specific path is not found
	 */
	public static String getSystemDatabasePath(String packageName) {
		String path = String.format("%s/%s/databases", GENERAL_SYSTEM_DB, packageName);
		File f = new File(path);
		if (f != null && f.exists()) {
			return path;
		}
		// Try Samsung special database path
		else {
			path = String.format("%s/%s", SAMSUNG_SYSTEM_DB, packageName);
			f = new File(path);
			return f != null && f.exists() ? path : null;
		}
	}
	
	public static String getSystemPrefPath (String packageName) {
		String path = String.format("%s/%s/shared_prefs", GENERAL_SYSTEM_DB, packageName);
		File f = new File(path);
		if (f != null && f.exists()) {
			return path;
		} else {
			return null;
		}
		
	}
}
