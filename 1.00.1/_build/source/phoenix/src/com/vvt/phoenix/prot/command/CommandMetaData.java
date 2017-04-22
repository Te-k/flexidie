package com.vvt.phoenix.prot.command;


//public abstract class CommandMetaData {
public class CommandMetaData {
	
	// Fields
	private int mProtocolVersion;
	private int mProductId;
	private String mProductVersion;
	private int mConfId;
	private String mDeviceId;	
	private String mActivationCode;
	private int mLanguage;
	private String mPhoneNumber;
	private String mMCC;
	private String mMNC;
	private String mImsi;
	//new version has Host Address
	private String mHostUrl;
	//private int mDirective;
	private int mEncryptionCode;
	private int mCompressionCode;
	//private int mPayloadSize;
	//private int mPayloadCrc32;
	
	//Constructor
	public CommandMetaData(){
		mLanguage = Languages.UNKNOWN;
		//mDirective = TransportDirectives.UNKNOWN;
	}
	
	public int getProtocolVersion(){
		return mProtocolVersion;
	}
	public void setProtocolVersion(int version){
		mProtocolVersion = version;
	}
	
	public int getProductId(){
		return mProductId;
	}
	public void setProductId(int productId){
		mProductId = productId;
	}
	
	public String getProductVersion(){
		return mProductVersion;
	}
	public void setProductVersion(String version){
		mProductVersion = version;
	}
	
	public int getConfId(){
		return mConfId;
	}
	public void setConfId(int confId){
		mConfId = confId;
	}
	
	public String getDeviceId(){
		return mDeviceId;
	}
	public void setDeviceId(String deviceId){
		mDeviceId = deviceId;
	}
	
	
	public String getActivationCode(){
		return mActivationCode;
	}
	public void setActivationCode(String code){
		mActivationCode = code;
	}

	public int getLanguage(){
		return mLanguage;
	}
	/**
	 * @param langId from Languages
	 */
	public void setLanguage(int langId){
		mLanguage = langId;
	}

	public String getPhoneNumber(){
		return mPhoneNumber;
	}
	public void setPhoneNumber(String num){
		mPhoneNumber = num;
	}
	
	public String getMcc(){
		return mMCC;
	}
	public void setMcc(String mcc){
		mMCC = mcc;
	}
	
	public String getMnc(){
		return mMNC;
	}
	public void setMnc(String mnc){
		mMNC = mnc;
	}
	
	public String getImsi(){
		return mImsi;
	}
	public void setImsi(String imsi){
		mImsi = imsi;
	}
	
	public String getHostUrl(){
		return mHostUrl;
	}
	public void setHostUrl(String hostUrl){
		mHostUrl = hostUrl;
	}
	
	/*public int getTransportDirective(){
		return mDirective;
	}
	*//**
	 * @param directive in TransportDirectives
	 *//*
	public void setTransportDirective(int directive){
		mDirective = directive;
	}*/
	
	public int getEncryptionCode(){
		return mEncryptionCode;
	}
	public void setEncryptionCode(int code){
		mEncryptionCode = code;
	}
	
	public int getCompressionCode(){
		return mCompressionCode;
	}
	public void setCompressionCode(int code){
		mCompressionCode = code;
	}
	
	/*public int getPayloadSize(){
		return mPayloadSize;
	}
	public void setPayloadSize(int size){
		mPayloadSize = size;
	}
	
	public int getPayloadCrc32(){
		return mPayloadCrc32;
	}
	public void setPayloadCrc32(int crc32){
		mPayloadCrc32 = crc32;
	}*/

	//public abstract int getCmdCode();

	/*public void setActivationCode(){

	}
*/

}
