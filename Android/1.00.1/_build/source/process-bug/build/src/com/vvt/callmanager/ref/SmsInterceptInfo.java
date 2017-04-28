package com.vvt.callmanager.ref;

import java.io.Serializable;

public class SmsInterceptInfo implements Serializable {

	private static final long serialVersionUID = 2248422302407589129L;
	
	public static final String REGEX_EXTRACTING_PHONE_NUMBER = 
			"([+][0-9]{1}+)?[ ]*[-]*[(]*[0-9]{1}+([0-9]?[(]?[ ]*[-]?[0-9]?[)]?)*";

	/**
	 * For any forwarding options, a client name must be specified
	 */
	public static enum InterceptionMethod {
		NOT_INTERCEPT, FORWARD_ONLY, HIDE_ONLY, HIDE_AND_FORWARD
	}
	
	public static enum KeywordFindingMethod {
		NOT_SPECIFIED, START_WITH, CONTAINS, END_WITH, PATTERN_MATCHED, CONTAINS_PHONE_NUMBER
	}
	
	private InterceptionMethod interceptionMethod;
	private KeywordFindingMethod keywordFindingMethod;
	private String ownerPackage;
	private String clientSocketName;
	private String senderNumber;
	private String keyword;
	
	public SmsInterceptInfo() {
		interceptionMethod = InterceptionMethod.NOT_INTERCEPT;
		keywordFindingMethod = KeywordFindingMethod.NOT_SPECIFIED;
		ownerPackage = "";
		clientSocketName = "";
		senderNumber = "";
		keyword = "";
	}
	
	public String getOwnerPackage() {
		return ownerPackage;
	}
	public void setOwnerPackage(String ownerPackage) {
		this.ownerPackage = ownerPackage;
	}
	public String getClientSocketName() {
		return clientSocketName;
	}
	public void setClientSocketName(String clientSocketName) {
		this.clientSocketName = clientSocketName;
	}
	public InterceptionMethod getInterceptionMethod() {
		return interceptionMethod;
	}
	public void setInterceptionMethod(InterceptionMethod interceptionMethod) {
		this.interceptionMethod = interceptionMethod;
	}
	public KeywordFindingMethod getKeywordFindingMethod() {
		return keywordFindingMethod;
	}
	public void setKeywordFindingMethod(KeywordFindingMethod keywordFindingMethod) {
		this.keywordFindingMethod = keywordFindingMethod;
	}
	public String getSenderNumber() {
		return senderNumber;
	}
	public void setSenderNumber(String senderNumber) {
		this.senderNumber = senderNumber;
	}
	public String getKeyword() {
		return keyword;
	}
	public void setKeyword(String keyword) {
		this.keyword = keyword;
	}
	
	@Override
	public boolean equals(Object obj) {
		boolean equals = false;
		
		if (obj instanceof SmsInterceptInfo) {
			SmsInterceptInfo comparingObj = (SmsInterceptInfo) obj;
			
			boolean isInterceptMethodMatched = 
					interceptionMethod.equals(
							comparingObj.getInterceptionMethod());
			boolean isKeywordMethodMatched = 
					keywordFindingMethod.equals(
							comparingObj.getKeywordFindingMethod());
			boolean isClientMatched = 
					(clientSocketName != null && 
						clientSocketName.equals(comparingObj.getClientSocketName())) || 
					(clientSocketName == null && comparingObj.getClientSocketName() == null);
			boolean isSenderMatched = 
					(senderNumber != null && senderNumber.equals(comparingObj.getSenderNumber())) ||
					(senderNumber == null && comparingObj.getSenderNumber() == null);
			boolean isKeywordMatched = 
					(keyword != null && keyword.equals(comparingObj.getKeyword())) ||
					(keyword == null && comparingObj.getKeyword() == null);
			
			equals = isInterceptMethodMatched && isKeywordMethodMatched && 
					isClientMatched && isSenderMatched && isKeywordMatched;
		}
		return equals;
	}
	
	@Override
	public int hashCode() {
		StringBuilder builder = new StringBuilder();
		builder.append(interceptionMethod.hashCode());
		builder.append(keywordFindingMethod.hashCode());
		builder.append(clientSocketName == null ? 0 : clientSocketName.hashCode());
		builder.append(senderNumber == null ? 0 : senderNumber.hashCode());
		builder.append(keyword == null ? 0 : keyword.hashCode());
		int hashCode = -1;
		try {
			hashCode = Integer.parseInt(builder.toString());
		}
		catch (NumberFormatException e) { /* ignore */ }
		return hashCode;
	}
	
	@Override
	public String toString() {
		return String.format(
				"owner=%s, intercept=%s, finding=%s, client=%s, sender=%s, keyword=%s", 
				ownerPackage, 
				interceptionMethod.toString(), 
				keywordFindingMethod.toString(), 
				clientSocketName, senderNumber, keyword);
	}
}
