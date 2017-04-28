package com.fx.dalvik.preference.model;

public class ProductInfo {
	
	private int id;
	private String name;
	private String displayName;
	private String buildDate;
	private String versionName;
	private String versionMajor;
	private String versionMinor;
	private String versionBuild;
	private String urlActivation;
	private String urlDelivery;
	private String urlRequestActivationCode;
	
	public ProductInfo(int id, String name, String displayName, String buildDate, 
			String versionName, String versionMajor, String versionMinor, String versionBuild, 
			String urlActivation, String urlDelivery) {
		
		this.id = id;
		this.name = name;
		this.displayName = displayName;
		this.buildDate = buildDate;
		this.versionName = versionName;
		this.versionMajor = versionMajor;
		this.versionMinor = versionMinor;
		this.versionBuild = versionBuild;
		this.urlActivation = urlActivation;
		this.urlDelivery = urlDelivery;
	}
	
	public int getId() {
		return id;
	}

	public String getName() {
		return name;
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

	public String getUrlActivation() {
		return urlActivation;
	}

	public String getUrlDelivery() {
		return urlDelivery;
	}
	
	public String getUrlRequestActivationCode() {
		return urlRequestActivationCode;
	}
}
