package com.vvt.data_delivery_manager.testsfunctional;

import java.util.Random;

import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.enums.DeliveryRequestType;
import com.vvt.datadeliverymanager.enums.PriorityRequest;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.phoenix.prot.command.CommandData;

public class GenerateTestValue {
	
	public static int getRandomInteger(int min, int max) {
		Random r = new Random();
		return r.nextInt(max - min + 1) + min;
	}

	public static String getRandomString(int length) {
		String str = new String(
				"QAa0bcLdUK2eHfJgTP8XhiFj61DOklNm9nBoI5pGqYVrs3CtSuMZvwWx4yE7zR_");
		StringBuffer sb = new StringBuffer();
		Random r = new Random();
		int te = 0;
		for (int i = 1; i <= length; i++) {
			te = r.nextInt(63);
			sb.append(str.charAt(te));
		}
		return sb.toString();
	}

	public static PriorityRequest getRandomPriorityRequestType() {

		RandomEnum<PriorityRequest> r = new RandomEnum<PriorityRequest>(PriorityRequest.class);
		PriorityRequest priority = r.random();
		return priority;
	}
	
	public static DataProviderType getRandomDataProviderType() {

		RandomEnum<DataProviderType> r = new RandomEnum<DataProviderType>(DataProviderType.class);
		DataProviderType provider = r.random();
		return provider;
	}

	@SuppressWarnings("rawtypes")
	private static class RandomEnum<E extends Enum> {

		private static final Random RND = new Random();
		private final E[] values;

		public RandomEnum(Class<E> token) {
			values = token.getEnumConstants();
		}

		public E random() {
			return values[RND.nextInt(values.length)];
		}
	}
	
	public static DeliveryRequest createDeliveryRequest(
			DeliveryListener deliveryListener, CommandData commandData, DataProviderType dataProviderType) {
		
		DeliveryRequest deliveryRequest = new DeliveryRequest();
		deliveryRequest.setCallerID(GenerateTestValue.getRandomInteger(0,1000000));
		deliveryRequest.setCommandData(commandData);
		deliveryRequest.setDataProviderType(dataProviderType);
		deliveryRequest.setDelayTime(GenerateTestValue.getRandomInteger(30*1000,60*1000)); // 1-5 minute  
		deliveryRequest.setDeliveryListener(deliveryListener);
		deliveryRequest.setIsReadyToResume(false);
		deliveryRequest.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		deliveryRequest.setMaxRetryCount(0);
		deliveryRequest.setRetryCount(0);
		deliveryRequest.setRequestPriority(GenerateTestValue.getRandomPriorityRequestType());
		deliveryRequest.setIsRequireCompression(true);
		deliveryRequest.setIsRequireEncryption(true);
		
		return deliveryRequest;
		
	}
}
