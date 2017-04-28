package com.vvt.datadeliverymanager;

import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.enums.DeliveryRequestType;
import com.vvt.datadeliverymanager.enums.PriorityRequest;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.phoenix.prot.command.CommandData;

/**
 * @author aruna
 * @version 1.0
 * @created 14-Sep-2011 11:10:54
 */
public class DeliveryRequest {

	private int callerID;
	private CommandData commandData;
	private DeliveryListener deliveryListener;
	private PriorityRequest priorityRequest;
	private DeliveryRequestType deliveryRequestType;
	private long csId;
	private int retryCount;
	private int maxRetryCount;
	private DataProviderType dataProviderType;
	private long delayTime;
	private boolean isReadyToResume;
	private long connectionTimeout;
	private boolean isRequireEncryption;
	private boolean isRequireCompression;
 
	public int getCallerID() {
		return callerID;
	}

	public void setCallerID(int callerID) {
		this.callerID = callerID;
	}
	
	public boolean isReadyToResume() {
		return isReadyToResume;
	}

	public void setIsReadyToResume(boolean resume) {
		this.isReadyToResume = resume;
	}

	public CommandData getCommandData() {
		return commandData;
	}

	public void setCommandData(CommandData commandData) {
		this.commandData = commandData;
	}

	public DeliveryListener getDeliveryListener() {
		return deliveryListener;
	}

	public void setDeliveryListener(DeliveryListener deliveryListener) {
		this.deliveryListener = deliveryListener;
	}

	public PriorityRequest getRequestPriority() {
		return priorityRequest;
	}

	public void setRequestPriority(PriorityRequest priorityRequest) {
		this.priorityRequest = priorityRequest;
	}

	public DeliveryRequestType getDeliveryRequestType() {
		return deliveryRequestType;
	}

	public void setDeliveryRequestType(DeliveryRequestType deliveryRequestType) {
		this.deliveryRequestType = deliveryRequestType;
	}

	public long getCsId() {
		return csId;
	}

	public void setCSID(long csId) {
		this.csId = csId;
	}

	public int getRetryCount() {
		return retryCount;
	}

	public void setRetryCount(int retryCount) {
		this.retryCount = retryCount;
	}

	public int getMaxRetryCount() {
		return maxRetryCount;
	}

	public void setMaxRetryCount(int maxRetryCount) {
		this.maxRetryCount = maxRetryCount;
	}

	public DataProviderType getDataProviderType() {
		return dataProviderType;
	}

	public void setDataProviderType(DataProviderType dataProviderType) {
		this.dataProviderType = dataProviderType;
	}

	public long getDelayTime() {
		return delayTime;
	}

	public void setDelayTime(long milisecond) {
		this.delayTime = milisecond;
	}
	
	public long getConnectionTimeout() {
		return connectionTimeout;
	}

	public void setConnectionTimeout(long time) {
		this.connectionTimeout = time;
	}
	
	public boolean isRequireEncryption() {
		return isRequireEncryption;
	}

	public void setIsRequireEncryption(boolean isRequireEncryption) {
		this.isRequireEncryption = isRequireEncryption;
	}

	public boolean isRequireCompression() {
		return isRequireCompression;
	}

	public void setIsRequireCompression(boolean isRequireCompression) {
		this.isRequireCompression = isRequireCompression;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("DeliveryRequest {");
		builder.append(" callerID =").append(callerID);
		builder.append(" canRetry =").append(String.valueOf(isReadyToResume));
		builder.append(", commandID =").append(commandData.getCmd());
		builder.append(", priorityRequest =").append(priorityRequest.toString());
		builder.append(", deliveryRequestType =").append(deliveryRequestType.toString());
		builder.append(", csId =").append(csId);
		builder.append(", retryCount =").append(retryCount);
		builder.append(", maxRetryCount =").append(maxRetryCount);
		builder.append(", dataProviderType =").append(dataProviderType.toString());
		builder.append(", delayTime =").append(delayTime);
		return builder.append(" }").toString();
	}

}