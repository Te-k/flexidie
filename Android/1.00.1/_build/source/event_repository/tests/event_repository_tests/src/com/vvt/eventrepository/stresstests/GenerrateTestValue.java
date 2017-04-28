package com.vvt.eventrepository.stresstests;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.events.FxAlertGpsEvent;
import com.vvt.events.FxAttachment;
import com.vvt.events.FxAudioFileThumnailEvent;
import com.vvt.events.FxCallLogEvent;
import com.vvt.events.FxCameraImageThumbnailEvent;
import com.vvt.events.FxEmailEvent;
import com.vvt.events.FxEmbededCallInfo;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxGeoTag;
import com.vvt.events.FxIMEvent;
import com.vvt.events.FxIMServiceType;
import com.vvt.events.FxLocationEvent;
import com.vvt.events.FxLocationMapProvider;
import com.vvt.events.FxLocationMethod;
import com.vvt.events.FxMMSEvent;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxPanicGpsEvent;
import com.vvt.events.FxPanicImageEvent;
import com.vvt.events.FxPanicStatusEvent;
import com.vvt.events.FxParticipant;
import com.vvt.events.FxRecipient;
import com.vvt.events.FxRecipientType;
import com.vvt.events.FxSMSEvent;
import com.vvt.events.FxSettingElement;
import com.vvt.events.FxSettingEvent;
import com.vvt.events.FxSystemEvent;
import com.vvt.events.FxSystemEventCategories;
import com.vvt.events.FxThumbnail;
import com.vvt.events.FxVideoFileThumbnailEvent;

public class GenerrateTestValue {
	
	@SuppressWarnings("unused")
	private static final String TAG = "GenerrateTestValue";
	
	
	public static List<FxEvent> getEvents(FxEventType eventType, int number){
		List<FxEvent> events = null;
		
		switch(eventType) {
			case ALERT_GPS : 
				events =  getAlertGpsEvent(number);
				break;
			case AUDIO_FILE_THUMBNAIL :
				events = getAudioFileThumbnailEvent(number);
				break;
			case CALL_LOG : 
				events = getCallLogEvent(number);
				break;
			case CAMERA_IMAGE_THUMBNAIL :
				events = getCameraImageThumbnailEvent(number);
				break;
			case LOCATION : 
				events = getLocationEvent(number);
				break;
			case MAIL : 
				events = getEmailEvent(number);
				break;
			case MMS : 
				events = getMmsEvent(number);
				break;
			case PANIC_IMAGE :
				events = getPanicImageEvent(number);
				break;
			case PANIC_STATUS : 
				events = getPanicStatusEvent(number);
				break;
			case PANIC_GPS :
				events = getPanicGpsEvent(number);
				break;
			case SMS : 
				events = getSmsEvent(number);
				break;
			case SYSTEM :
				events = getSystemEvent(number);
				break;
			case SETTINGS :
				events = getSettingEvent(number);
				break;
			case VIDEO_FILE_THUMBNAIL :
				events = getVideoFileThumbnailEvent(number);
				break;
			case IM :
				events = getIMEvent(number);
				break;
			default : 
				break;
		}
		
		return events;
	}
	
	 public static FxEvent getRandomEvent() {

		  FxEvent rndEvent = null;
		  List<FxEvent> lst = null;
		  RandomEnum<FxEventType> r = new RandomEnum<FxEventType>(FxEventType.class);
		  
		  
		  while (lst == null) {
		   FxEventType eventType = r.random();
		   lst = getEvents(eventType, 1);
		  }

		  rndEvent = lst.get(0);
		  return rndEvent;
		 }

	 
	private static List<FxEvent> getVideoFileThumbnailEvent(int number) {
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxVideoFileThumbnailEvent videoFileThumbnailEvent = null;
		for(int i=0 ; i<number ; i++){
			videoFileThumbnailEvent = new FxVideoFileThumbnailEvent();
			videoFileThumbnailEvent.setActualDuration(getRandomInteger(100, 1000));
			videoFileThumbnailEvent.setActualFileSize(getRandomLong(getRandomInteger(3,10)));
			videoFileThumbnailEvent.setActualFullPath(getRandomPath());
			videoFileThumbnailEvent.setEventTime(System.currentTimeMillis());
			videoFileThumbnailEvent.setFormat(getRandomMediaType());
			videoFileThumbnailEvent.addThumbnail(getGemThumbnail());
			videoFileThumbnailEvent.setVideoData(getRandomByte());
			events.add(videoFileThumbnailEvent);
		}
		return events;
	}
	
	private static FxThumbnail  getGemThumbnail() {
		FxThumbnail thumbnail = new FxThumbnail();
		thumbnail.setImageData(new byte[]{});
		thumbnail.setThumbnailPath(getRandomPath());
		return thumbnail;
	}
	
	private static List<FxEvent> getSystemEvent(int number) {
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxSystemEvent systemEvent = null;
		for(int i=0 ; i<number ; i++){
			systemEvent = new FxSystemEvent();
			systemEvent.setDirection(getRandomDirection(false));
			systemEvent.setEventTime(System.currentTimeMillis());
			systemEvent.setLogType(getRandomLogType());
			systemEvent.setMessage(getRandomString(getRandomInteger(3, 500)));
			events.add(systemEvent);
		}
		return events;
	}
	
	private static List<FxEvent> getSettingEvent(int number) {
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxSettingEvent settingEvent = null;
		FxSettingElement settingElement = null;
		for(int i=0 ; i<number ; i++){
			settingEvent = new FxSettingEvent();
			settingEvent.setEventTime(System.currentTimeMillis());
			
			int round = getRandomInteger(1, 10);
			
			for(int j = 1 ; j<= round ; j++){
				settingElement = new FxSettingElement();
				settingElement.setSettingID(j);
				settingElement.setSettingValue(Integer.toString(j%2));
				settingEvent.addSettingElement(settingElement);
			}
			events.add(settingEvent);
		}
		return events;
	}
	
	private static List<FxEvent> getSmsEvent(int number) {
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxSMSEvent smsEvent = null;
		for(int i=0 ; i<number ; i++){
			smsEvent = new FxSMSEvent();
			smsEvent.setContactName(getRandomString(getRandomInteger(3, 10)));
			smsEvent.setDirection(getRandomDirection(false));
			smsEvent.setEventTime(System.currentTimeMillis());
			smsEvent.setSenderNumber(getRandomPhoneNumber(10));
			smsEvent.setSMSData(getRandomString(getRandomInteger(3, 500)));
			smsEvent.addRecipient(getRandomRecipients());
			events.add(smsEvent);
		}
		return events;
	}
	
	private static List<FxEvent> getPanicGpsEvent(int number) {
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxPanicGpsEvent panicGpsEvent = null;
		for(int i=0 ; i<number ; i++){
			panicGpsEvent = new FxPanicGpsEvent();
			panicGpsEvent.setAltitude(getRandomDouble());
			panicGpsEvent.setAreaCode(getRandomLong(getRandomInteger(1, 10)));
			panicGpsEvent.setCellId(getRandomLong(getRandomInteger(1, 10)));
			panicGpsEvent.setCellName(getRandomString(getRandomInteger(1, 10)));
			panicGpsEvent.setEventTime(System.currentTimeMillis());
			panicGpsEvent.setHeading(getRamdomFloat());
			panicGpsEvent.setHeadingAccuracy(getRamdomFloat());
			panicGpsEvent.setHorizontalAccuracy(getRamdomFloat());
			panicGpsEvent.setIsMockLocaion(false);
			panicGpsEvent.setLatitude(getRandomDouble());
			panicGpsEvent.setLatitude(getRandomDouble());
			panicGpsEvent.setMapProvider(getRandomMapProvider());
			panicGpsEvent.setMethod(getRandomLocationMethod());
			panicGpsEvent.setMobileCountryCode(getRandomString(getRandomInteger(1, 10)));
			panicGpsEvent.setNetworkId(getRandomString(getRandomInteger(1, 10)));
			panicGpsEvent.setNetworkName(getRandomString(getRandomInteger(1, 10)));
			panicGpsEvent.setSpeed(getRamdomFloat());
			panicGpsEvent.setSpeedAccuracy(getRamdomFloat());
			panicGpsEvent.setVerticalAccuracy(getRamdomFloat());
			events.add(panicGpsEvent);
			
		}
		return events;
	}
	
	private static List<FxEvent> getPanicStatusEvent(int number) {
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxPanicStatusEvent panicStatusEvent = null;
		for(int i=0 ; i<number ; i++){
			panicStatusEvent = new FxPanicStatusEvent();
			panicStatusEvent.setEventTime(System.currentTimeMillis());
			panicStatusEvent.setStatus(getRamdomBoolean());
			events.add(panicStatusEvent);
		}
		return events;
	}
	
	private static List<FxEvent> getPanicImageEvent(int number) {
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxPanicImageEvent panicImageEvent = null;
		for(int i=0 ; i<number ; i++){
			panicImageEvent = new FxPanicImageEvent();
			panicImageEvent.setActualDuration(getRandomInteger(10, 1000));
			panicImageEvent.setActualFullPath(getRandomPath());
			panicImageEvent.setActualSize(getRandomInteger(10, 5000));
			panicImageEvent.setAreaCode(getRandomString(getRandomInteger(3, 10)));
			panicImageEvent.setCellId(getRandomInteger(3, 10));
			panicImageEvent.setCellName(getRandomString(getRandomInteger(0, 10)));
			panicImageEvent.setCountryCode(getRandomString(getRandomInteger(0, 10)));
			panicImageEvent.setEventTime(System.currentTimeMillis());
			panicImageEvent.setFormat(getRandomMediaType());
			panicImageEvent.setGeoTag(getRandomGeoTag());
			panicImageEvent.setImageData(getRandomByte());
			panicImageEvent.setNetworkId(getRandomString(getRandomInteger(0, 10)));
			panicImageEvent.setNetworkName(getRandomString(getRandomInteger(0, 10)));
			events.add(panicImageEvent);
		}
		return events;
	}
	
	private static List<FxEvent> getMmsEvent(int number) {
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxMMSEvent mmsEvent = null;
		for(int i=0 ; i<number ; i++){
			mmsEvent = new FxMMSEvent();
			mmsEvent.setContactName(getRandomString(getRandomInteger(3, 10)));
			mmsEvent.setDirection(getRandomDirection(false));
			mmsEvent.setEventTime(System.currentTimeMillis());
			mmsEvent.setSenderNumber(getRandomPhoneNumber(10));
			mmsEvent.setSubject(getRandomString(getRandomInteger(3, 100)));
			mmsEvent.addAttachment(getRandomAttachments());
			mmsEvent.addRecipient(getRandomRecipients());
			events.add(mmsEvent);
		}
		return events;
	}
	
	private static List<FxEvent> getIMEvent(int number) {
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxIMEvent imEvent = null;
		for(int i=0 ; i<number ; i++){
			imEvent = new FxIMEvent();
			imEvent.setUserDisplayName(getRandomString(getRandomInteger(3, 10)));
			imEvent.setEventDirection(getRandomDirection(false));
			imEvent.setEventTime(System.currentTimeMillis());
			imEvent.setUserId(getRandomPhoneNumber(10));
			imEvent.setMessage(getRandomString(getRandomInteger(3, 100)));
			imEvent.setImServiceId(FxIMServiceType.IM_WHATSAPP.getValue());
			imEvent.addParticipant(getRandomParticipants());
			events.add(imEvent);
		}
		return events;
	}
	
	private static List<FxEvent> getEmailEvent(int number) {
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxEmailEvent emailEvent = null;
		for(int i=0 ; i<number ; i++){
			emailEvent = new FxEmailEvent();
			emailEvent.setDirection(getRandomDirection(false));
			emailEvent.setEMailBody(getRandomString(getRandomInteger(1, 500)));
			emailEvent.setEventTime(System.currentTimeMillis());
			emailEvent.setSenderContactName(getRandomString(getRandomInteger(3, 10)));
			emailEvent.setSenderEMail(getRandomEmail(getRandomInteger(15, 20)));
			emailEvent.setSubject(getRandomString(getRandomInteger(3, 10)));
			emailEvent.addRecipient(getRandomRecipients());
			emailEvent.addAttachment(getRandomAttachments());
			events.add(emailEvent);
			
		}
		return events;
	}
	
	private static List<FxEvent> getLocationEvent(int number) {
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxLocationEvent locationEvent = null;
		for(int i=0 ; i<number ; i++){
			locationEvent = new FxLocationEvent();
			locationEvent.setAltitude(getRandomDouble());
			locationEvent.setAreaCode(getRandomLong(getRandomInteger(1, 10)));
			locationEvent.setCellId(getRandomLong(getRandomInteger(1, 10)));
			locationEvent.setCellName(getRandomString(getRandomInteger(1, 10)));
			locationEvent.setEventTime(System.currentTimeMillis());
			locationEvent.setHeading(getRamdomFloat());
			locationEvent.setHeadingAccuracy(getRamdomFloat());
			locationEvent.setHorizontalAccuracy(getRamdomFloat());
			locationEvent.setIsMockLocaion(false);
			locationEvent.setLatitude(getRandomDouble());
			locationEvent.setLatitude(getRandomDouble());
			locationEvent.setMapProvider(getRandomMapProvider());
			locationEvent.setMethod(getRandomLocationMethod());
			locationEvent.setMobileCountryCode(getRandomString(getRandomInteger(1, 10)));
			locationEvent.setNetworkId(getRandomString(getRandomInteger(1, 10)));
			locationEvent.setNetworkName(getRandomString(getRandomInteger(1, 10)));
			locationEvent.setSpeed(getRamdomFloat());
			locationEvent.setSpeedAccuracy(getRamdomFloat());
			locationEvent.setVerticalAccuracy(getRamdomFloat());
			events.add(locationEvent);
			
		}
		return events;
	}
	
	private static List<FxEvent> getCameraImageThumbnailEvent(int number) {
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxCameraImageThumbnailEvent cameraImageThumbnailEvent = null;
		for(int i=0 ; i<number ; i++){
			cameraImageThumbnailEvent = new FxCameraImageThumbnailEvent();
			cameraImageThumbnailEvent.setActualFullPath(getRandomPath());
			cameraImageThumbnailEvent.setActualSize(getRandomLong(getRandomInteger(3, 8)));
			cameraImageThumbnailEvent.setData(getRandomByte());
			cameraImageThumbnailEvent.setEventTime(System.currentTimeMillis());
			cameraImageThumbnailEvent.setFormat(getRandomMediaType());
			cameraImageThumbnailEvent.setGeo(getRandomGeoTag());
			cameraImageThumbnailEvent.setThumbnailFullPath(getRandomPath());
			events.add(cameraImageThumbnailEvent);
		}
		return events;
	}
	
	private static List<FxEvent> getCallLogEvent(int number) {
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxCallLogEvent callLogEvent = null;
		for(int i=0 ; i<number ; i++){
			callLogEvent = new FxCallLogEvent();
			callLogEvent.setContactName(getRandomString(10));
			callLogEvent.setDirection(getRandomDirection(true));
			callLogEvent.setDuration(getRandomLong(getRandomInteger(3, 10)));
			callLogEvent.setEventTime(System.currentTimeMillis());
			callLogEvent.setNumber(getRandomPhoneNumber(10));
			events.add(callLogEvent);
		}
		return events;
	}
	
	private static List<FxEvent> getAudioFileThumbnailEvent(int number) {
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxAudioFileThumnailEvent audioFileThumnailEvent = null;
		for(int i=0 ; i<number ; i++){
			audioFileThumnailEvent = new FxAudioFileThumnailEvent();
			audioFileThumnailEvent.setActualDuration(getRandomInteger(1,1000));
			audioFileThumnailEvent.setActualFileSize(getRandomInteger(1,5000));
			audioFileThumnailEvent.setActualFullPath(getRandomPath());
			audioFileThumnailEvent.setAudioData(getRandomByte());
			audioFileThumnailEvent.setEventTime(System.currentTimeMillis());
			audioFileThumnailEvent.setFormat(getRandomMediaType());
			events.add(audioFileThumnailEvent);
		}
		return events;

	}
	
	private static List<FxEvent> getAlertGpsEvent (int number) {
		List<FxEvent> alertGpsEvents = new ArrayList<FxEvent>();
		FxAlertGpsEvent alertGpsEvent = null;
		for(int i=0 ; i<number ; i++){
			alertGpsEvent = new FxAlertGpsEvent();
			alertGpsEvent.setAltitude(getRandomDouble());
			alertGpsEvent.setAreaCode(getRandomLong(5));
			alertGpsEvent.setCellId(getRandomLong(5));
			alertGpsEvent.setCellName(getRandomString(10));
			alertGpsEvent.setEventTime(System.currentTimeMillis());
			alertGpsEvent.setHeading(getRamdomFloat());
			alertGpsEvent.setHeadingAccuracy(getRamdomFloat());
			alertGpsEvent.setHorizontalAccuracy(getRamdomFloat());
			alertGpsEvent.setIsMockLocaion(false);
			alertGpsEvent.setLatitude(getRandomDouble());
			alertGpsEvent.setLatitude(getRandomDouble());
			alertGpsEvent.setMapProvider(getRandomMapProvider());
			alertGpsEvent.setMethod(getRandomLocationMethod());
			alertGpsEvent.setMobileCountryCode(getRandomString(10));
			alertGpsEvent.setNetworkId(getRandomString(5));
			alertGpsEvent.setNetworkName(getRandomString(5));
			alertGpsEvent.setSpeed(getRamdomFloat());
			alertGpsEvent.setSpeedAccuracy(getRamdomFloat());
			alertGpsEvent.setVerticalAccuracy(getRamdomFloat());
			alertGpsEvents.add(alertGpsEvent);
		}
		
		return alertGpsEvents;
	}
	

	private static byte[] getRandomByte() {
		int size = getRandomInteger(10,5000);
		byte[] data = new byte[size];
		for(int i = 0 ; i<size ;i++){
			data[i] = (byte)getRandomInteger(0,1);
		}
		return data;
	}
	
	
	
	private static String getRandomString (int length) {
		String str=new  String("QAa0bcLdUK2eHfJgTP8XhiFj61DOklNm9nBoI5pGqYVrs3CtSuMZvwWx4yE7zR_");
	 	StringBuffer sb=new StringBuffer();
	 	Random r = new Random();
	 	int te=0;
	 	for (int i=1 ; i<=length ; i++) {
	 		te=r.nextInt(63);
	 		sb.append(str.charAt(te));
	 	}
	 	return sb.toString();
	}

	private static String getRandomPath() {
		int subDir = getRandomInteger(1,5);
		String path = "";
		
		for(int i=0 ;i<=subDir ;i++) {
			path += "/"+getRandomString(getRandomInteger(1,10));
		}
		return path;
		
	}
	
	private static int getRandomInteger (int min,int max) {
	 	Random r = new Random();
	 	return r.nextInt(max-min+1)+min;
	}
	
	
	private static long getRandomLong (int length) {
		String numList = new  String("0123456789");
		String b_numList = new  String("123456789");
	 	StringBuffer sb=new StringBuffer();
	 	Random r = new Random();
	 	int te = r.nextInt(9);
	 	sb.append(b_numList.charAt(te));
	 	
	 	for(int i=1;i<=length-1;i++){
	 		te = r.nextInt(10);
	 		sb.append(numList.charAt(te));
	 	}
	 	return Long.parseLong(sb.toString());
	}
	
	private static String getRandomPhoneNumber(int length) {
		String numList = new  String("0123456789");
	 	StringBuffer sb=new StringBuffer();
	 	Random r = new Random();
	 	int te = 0;
	 	for(int i=1;i<=length;i++){
	 		te = r.nextInt(10);
	 		sb.append(numList.charAt(te));
	 	}
	 	return sb.toString();
	}
	
	private static boolean getRamdomBoolean () {
		boolean result = false;
		Random r = new Random();
		int te = r.nextInt(2);
		if(te == 1) {
			result = true;
		}
		
		return result;
	}
	
	private static float getRamdomFloat() {
		Random r = new Random();
		float x = r.nextFloat();
		int power = r.nextInt(4);
		float y = (float) (x*Math.pow(10, power));
		return y;
	}
	
	private static double getRandomDouble() {
		Random r = new Random();
		double x = r.nextDouble();
		int power = r.nextInt(4);
		double y = x*Math.pow(10, power);
		return y;
	}
	
	
	/**
	 * namelength Should MORE THAM 10  
	 * @param namelength
	 * @return
	 */
	private static String getRandomEmail (int length) {
		
		String com = ".com";
		int fixLength = com.length()+1;
		int useLength = length - fixLength;
		int n_Length = (int)Math.ceil(useLength/2.0);
		int typeLength = useLength - n_Length;
		
		System.out.println(useLength +":" + n_Length +":" + typeLength);
		
		StringBuffer sb=new StringBuffer();
		sb.append(getRandomString(n_Length));
		sb.append("@");
		sb.append(getRandomString(typeLength));
		sb.append(com);
		
		return sb.toString();
	}
	
	private static FxSystemEventCategories getRandomLogType(){
//		int type = getRandomInteger(1, 20);
//		FxSystemEventCategories logType = FxSystemEventCategories.forValue(type);
//		return logType;
		
		
		 RandomEnum<FxSystemEventCategories> r = new RandomEnum<FxSystemEventCategories>(FxSystemEventCategories.class);
		 FxSystemEventCategories logType = r.random();
		 return logType;
		
	}
	
	private static FxEventDirection getRandomDirection (boolean wantMiscallType) {
		Random r = new Random();
		int direction = 0;
		if(wantMiscallType) {
			direction =	r.nextInt(4);
		} else {
			direction =	r.nextInt(3);
		}
		FxEventDirection eventDirection = FxEventDirection.forValue(direction);
		return eventDirection;
	}
	
	private static FxLocationMapProvider getRandomMapProvider() {
//		Random r = new Random();
//		int providerId = r.nextInt(3);
//		FxLocationMapProvider provider = FxLocationMapProvider.forValue(providerId);
		
		RandomEnum<FxLocationMapProvider> r = new RandomEnum<FxLocationMapProvider>(FxLocationMapProvider.class);
		FxLocationMapProvider provider = r.random();
	
		return provider;
	}
	
	private static FxLocationMethod getRandomLocationMethod () {
//		Random r = new Random();
//		int providerId = r.nextInt(6);
//		FxLocationProvider provider = FxLocationProvider.forValue(providerId);
		RandomEnum<FxLocationMethod> r = new RandomEnum<FxLocationMethod>(FxLocationMethod.class);
		FxLocationMethod provider = r.random();
		return provider;
	}
	
	private static FxMediaType getRandomMediaType () {
//		Random r = new Random();
//		int[] listMediaType = new int [] {
//				0,1,2,3,4,5,6,7,8,9,10,11,12,
//				51,52,53,54,55,56,57,58,59,60,61,
//				101,102,103,104,105,106,107,
//				201,202,203,204,205,206,207,208,210,211,212,213,214,215,216,217}; 
//		int index = r.nextInt(listMediaType.length);
//		FxMediaType mediatype = FxMediaType.forValue(listMediaType[index]);
		RandomEnum<FxMediaType> r = new RandomEnum<FxMediaType>(FxMediaType.class);
		FxMediaType mediatype = r.random();
		return mediatype;
	}
	
	private static FxRecipient getRandomRecipients() {
		FxRecipient recipient = new FxRecipient();
		recipient.setContactName(getRandomString(10));
		recipient.setRecipient(getRandomEmail(20));
		recipient.setRecipientType(FxRecipientType.TO);

		return recipient;
		
	}
	
	private static FxParticipant getRandomParticipants() {
		FxParticipant participant = new FxParticipant();
		participant.setName(getRandomString(10));
		participant.setUid(getRandomPhoneNumber(10));
		return participant;
		
	}
	
	private static FxAttachment getRandomAttachments() {
		FxAttachment attachment = new FxAttachment();
		attachment.setAttachemntFullName(getRandomString(20));
		attachment.setAttachmentData(new byte[] {});		
		return attachment;
	}
	
	private static FxGeoTag getRandomGeoTag() {
		FxGeoTag geoTag = new FxGeoTag();
		geoTag.setAltitude(getRamdomFloat());
		geoTag.setLat(getRamdomFloat());
		geoTag.setLon(getRamdomFloat());
		return geoTag;
	}
	
	@SuppressWarnings("unused")
	private static FxEmbededCallInfo getRandomCallTag(int number) {
		FxEmbededCallInfo callInfo =  new FxEmbededCallInfo();
		callInfo.setContactName(getRandomString(20));
		callInfo.setDirection(getRandomDirection(false));
		callInfo.setDuration(getRandomLong(8));
		callInfo.setNumber(getRandomPhoneNumber(10));
		return callInfo;
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
	
	
}
