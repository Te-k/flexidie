package com.fx.util;

public class ProductInfo {

	private String displayName;
	private String buildDate;
	private String versionName;
	private String versionMajor;
	private String versionMinor;
	private String versionBuild;
	private String pkgName;
	
	public ProductInfo(String displayName, String buildDate,
			String versionName, String versionMajor, String versionMinor,
			String versionBuild, String pkgName) {
	 
		this.displayName = displayName;
		this.buildDate = buildDate;
		this.versionName = versionName;
		this.versionMajor = versionMajor;
		this.versionMinor = versionMinor;
		this.versionBuild = versionBuild;
		this.pkgName = pkgName;
	}
	
	public String getDisplayName() {
		return displayName;
	}

	public String getBuildDate() {
		return buildDate;
	}
	
	public String getVersionName() {
		return versionName;
	}

	public String getVersionMajor() {
		return versionMajor;
	}

	public String getVersionMinor() {
		return versionMinor;
	}

	public String getVersionBuild() {
		return versionBuild;
	}

	public String getPackageName() {
		return pkgName;
	}
}
