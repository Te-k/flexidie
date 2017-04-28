package com.fx.preference.model;

public class ProductInfo {
	
	public static enum ProductServer { RETAIL, RESELLER, TEST };
	public static enum ProductEdition { PROX, PRO, LIGHT };
	
	private ProductEdition edition;
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
	private String pkgName;
	
	public ProductInfo(ProductEdition edition, int id, String name, String displayName, String buildDate, 
			String versionName, String versionMajor, String versionMinor, String versionBuild, 
			String urlActivation, String urlDelivery, String pkgName) {
		
		this.edition = edition;
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
		this.pkgName = pkgName;
	}
	
	public ProductEdition getEdition() {
		return edition;
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
	
	public String getPackageName() {
		return pkgName;
	}
	
	@Override
	public String toString() {
		return String.format("ProductInfo[id: %d, name: %s, edition: %s]", id, name, edition);
	}
}
