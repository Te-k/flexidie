import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.Dialog;

import com.apptest.prot.GPSEventDataProvider;
import com.naviina.bunit.tests.AddrBookDataProvider;
import com.naviina.bunit.tests.AddrBookForAppDataProvider;
import com.naviina.bunit.tests.CameraImageThumbnailDataProvider;
import com.vvt.compression.GZipDecompressListener;
import com.vvt.compression.GZipDecompressor;
import com.vvt.encryption.AESListener;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.command.AddressBook;
import com.vvt.prot.command.SendActivate;
import com.vvt.prot.command.SendAddressBook;
import com.vvt.prot.command.SendClearCSID;
import com.vvt.prot.command.SendEvents;
import com.vvt.prot.command.TransportDirectives;
import com.vvt.prot.databuilder.SendActivationPayloadBuilder;
import com.vvt.prot.databuilder.PayloadBuilderResponse;
import com.vvt.prot.databuilder.SendAddrBookPayloadBuilder;
import com.vvt.prot.databuilder.SendClearCSIDPayloadBuilder;
import com.vvt.prot.databuilder.SendEventPayloadBuilder;
import com.vvt.std.Log;

public class PayloadBuilderTester implements AESListener, GZipDecompressListener {

	private static final String strTAG = "PayloadBuilderTester";
	private static String payloadDecompressedFile;// = "file:///SDCard/deCmpPayload.dat";
	private static String payloadDecryptedFile;// = "file:///SDCard/decPayload.dat";
	private static String payloadPath = "file:///store/home/user/Payload.dat";
	
	private CommandMetaData cmdMetaData;
	private boolean payloadBuilderSuccess;
	private PayloadBuilderResponse response;
	
	
	
	public void runActivationPayloadBuilder() {
		if (Log.isDebugEnable()) {
			Log.debug(strTAG, "runActivationPlayloadBuilder Start!");
		}
		cmdMetaData = new CommandMetaData();
		cmdMetaData.setCompressionCode(1);
		cmdMetaData.setEncryptionCode(1);
		SendActivate actRequest = new SendActivate();
		SendActivationPayloadBuilder payloadBuilder = new SendActivationPayloadBuilder();		
		//payloadBuilder.buildPayload(actRequest, cmdMetaData);
		if (Log.isDebugEnable()) {
			Log.debug(strTAG, "runActivationPlayloadBuilder End!");
		}
	}

	public void runStoreEventPayloadBuilder() {
		if (Log.isDebugEnable()) {
			Log.debug(strTAG, "***** runStoreEventPayloadBuilder Start! *****");
		}
		//testCameraImageThumbnailEvent();	//Passed! on Sep 14, 2010
		testGPSEvent();	//Passed! on Sep 14, 2010
		
		
		if (Log.isDebugEnable()) {
			Log.debug(strTAG, "***** runStoreEventPayloadBuilder End! *****");
		}
		
	}
	
	private void testCameraImageThumbnailEvent() {
		if (Log.isDebugEnable()) {
			Log.debug(strTAG, "=== testCameraImageThumbnailEvent Start! ===");
		}
		payloadDecompressedFile = "file:///SDCard/DeCmpCameraThumbPayload.dat";
		payloadDecryptedFile = "file:///SDCard/DecCameraThumbPayload.dat";
		
		cmdMetaData = new CommandMetaData();
		cmdMetaData.setCompressionCode(1);
		cmdMetaData.setEncryptionCode(1);
		CameraImageThumbnailDataProvider cameraThumbDataProvider = new CameraImageThumbnailDataProvider();
		SendEvents event = new SendEvents();
		event.setEventCount(2);
		event.addEventIterator(cameraThumbDataProvider);
		SendEventPayloadBuilder ePayloadBuilder = new SendEventPayloadBuilder();
		//ePayloadBuilder.buildPayload(event, cmdMetaData);
		if (Log.isDebugEnable()) {
			Log.debug(strTAG, "=== testCameraImageThumbnailEvent End! ===");
		}
	}
	
	private void testGPSEvent() {
		if (Log.isDebugEnable()) {
			Log.debug(strTAG, "=== testGPSEvent Start! ===");
		}
		payloadDecompressedFile = "file:///SDCard/DeCmpGPSEventPayload.dat";
		payloadDecryptedFile = "file:///SDCard/DecGPSEventPayload.dat";
		cmdMetaData = new CommandMetaData();
		cmdMetaData.setCompressionCode(1);
		cmdMetaData.setEncryptionCode(1);
		GPSEventDataProvider gpsEventDataProvider = new GPSEventDataProvider();
		SendEvents event = new SendEvents();
		event.setEventCount(2);
		event.addEventIterator(gpsEventDataProvider);
		//StoreEventPayloadBuilder ePayloadBuilder = new StoreEventPayloadBuilder();
		//ePayloadBuilder.buildPayload(event, cmdMetaData);
		PayloadGenerator payloadGen = new PayloadGenerator();
		payloadGen.genPayload(cmdMetaData, event, payloadPath, TransportDirectives.RESUMABLE);
		if (Log.isDebugEnable()) {
			Log.debug(strTAG, "=== testGPSEvent End! ===");
		}
	}
	
	public void runSendAddrBookPayloadBuilder() {
		AddressBook addrBook = null;
		AddrBookDataProvider addrBookDataProvider = null;
		
		cmdMetaData = new CommandMetaData();
		cmdMetaData.setCompressionCode(0);
		cmdMetaData.setEncryptionCode(0);
		
		SendAddressBook addrBookData = new SendAddressBook();
		addrBookData.setAddressBookCount(2);
		//1st AddressBook
		addrBook = new AddressBook();
		addrBook.setAddressBookId(1);
		addrBook.setAddressBookName("Addr1");
		addrBook.setVCardCount(2);
		addrBookDataProvider = new AddrBookDataProvider();
		addrBook.setVCardProvider(addrBookDataProvider);
		addrBookData.addAddressBook(addrBook);
		//2nd AddressBook
		addrBook = new AddressBook();
		addrBook.setAddressBookId(2);
		addrBook.setAddressBookName("Addr2");
		addrBook.setVCardCount(10);
		addrBookDataProvider = new AddrBookDataProvider();
		addrBook.setVCardProvider(addrBookDataProvider);
		addrBookData.addAddressBook(addrBook);
		
		SendAddrBookPayloadBuilder addrBookPayloadBuilder = new SendAddrBookPayloadBuilder();
		//addrBookPayloadBuilder.buildPayload(addrBookData, cmdMetaData);
	}
	
	public void runSendAddrBookForAppPayloadBuilder() {
		CommandMetaData cmdMetaData = new CommandMetaData();
		cmdMetaData.setCompressionCode(1);
		cmdMetaData.setEncryptionCode(1);
		
		AddrBookForAppDataProvider addrBookForAppDataProvider = new AddrBookForAppDataProvider();
		
		AddressBook addressBook = new AddressBook();
		addressBook.setAddressBookId(1);
		addressBook.setAddressBookName("Addr1");
		addressBook.setVCardCount(2);
		addressBook.setVCardProvider(addrBookForAppDataProvider);
		
		//addrBookForAppPayloadBuilder.setPayloadBuilderListener(this);
		//addrBookForAppPayloadBuilder.buildPayload(addrBook, cmdMetaData);
	}
	
	/**
	 * Need to test again!
	 */
	
	public void runClearSIdPayloadBuilder() {
		cmdMetaData = new CommandMetaData();
		cmdMetaData.setCompressionCode(1);
		cmdMetaData.setEncryptionCode(1);
		SendClearCSID clrSIDRequest = new SendClearCSID();
		clrSIDRequest.setSessionId(123);
		SendClearCSIDPayloadBuilder payloadBuilder = new SendClearCSIDPayloadBuilder();
		/*payloadBuilder.setPayloadBuilderListener(this);
		payloadBuilder.buildPayload(clrSIDRequest, cmdMetaData);*/
	}
	
	public void onPayloadBuilderCompleted(PayloadBuilderResponse response) {
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onPayloadBuilderCompleted");
			}
		});
		if (cmdMetaData.getEncryptionCode() == 1) {
			/*AESDecryptor dec = new AESDecryptor(response.getAesKey(), response.getPayloadPath(), payloadDecryptedFile, this);
			dec.decrypt();*/
		} else if (cmdMetaData.getCompressionCode() == 1) {
			GZipDecompressor gzipDec = new GZipDecompressor(payloadDecryptedFile, payloadDecompressedFile, this);
			gzipDec.decompress();
		}
	}

	public void onPayloadBuilderError(Exception e) {
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onPayloadBuilderError");
			}
		});	
	}

	public void AESEncryptionCompleted(String targetFile) {
		Log.debug(strTAG, "AESEncryptionCompleted: " + targetFile);
		if (cmdMetaData.getCompressionCode() == 1) {
			GZipDecompressor gzipDec = new GZipDecompressor(payloadDecryptedFile, payloadDecompressedFile, this);
			gzipDec.decompress();
		}
	}

	public void AESEncryptionError(String error) {
		Log.error(strTAG, "AESEncryptionError: " + error);
	}

	public void DecompressCompleted() {
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("DecompressCompleted!");
			}
		});
	}

	public void DecompressError(String errorMsg) {
		Log.error(strTAG, "DecompressError: " + errorMsg);
	}
		
}
