package com.vvt.base;

/**
 * @author aruna
 * @version 1.0
 * @created 13-Jul-2011 10:52:38
 */

/**
 * Gives version of the product
 */

public class FxProductVersion {
	private final static String major = "1";
	private final static String minor = "00";
	private final static String build = "0";
	private final static boolean isTestBuild = true;

	public String getVersion() {
		if (isTestBuild)
			return new StringBuilder().append("-").append(major).append(".")
					.append(minor).append(".").append(build).toString();
		else
			return new StringBuilder().append(major).append(".").append(minor)
					.append(".").append(build).toString();
	}

	public String getVersionAsString() {
		return new StringBuilder().append("Version :").append(major)
				.append(".").append(minor).append(".").append(build).toString();
	}

}