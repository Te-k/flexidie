package com.apptest.prot.databuilder;

import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.Dialog;

import com.apptest.prot.GPSEventDataProvider;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.CommandRequest;
import com.vvt.prot.command.Languages;
import com.vvt.prot.command.SendActivate;
import com.vvt.prot.command.SendEvents;
import com.vvt.prot.databuilder.ProtocolPacketBuilder;
import com.vvt.prot.databuilder.ProtocolPacketBuilderResponse;
import com.vvt.prot.unstruct.response.KeyExchangeCmdResponse;
import com.vvt.std.Log;

public class ProtocolPacketBuilderTester {
	
	private static final String TAG = "ProtocolPacketBuilderTester";
	private static final String AES_File = "file:///SDCard/AES.ProtPacket";
	private static final String METADATA_File = "file:///SDCard/MetaData.ProtPacket";
	private static final String payloadPath = "file:///SDCard/payload.dat";
	
	public void runProtocolPacketBuilderTester() {
		testActivatePacketBuilder();
		//testGPSProtocolDataBuilder();
	}

	private void testActivatePacketBuilder() {
		//1. Initial Data
		CommandRequest cmdRequest = initialActivateData();
		//2. Build Command Packet_Data 
		ProtocolPacketBuilder protPackBuilder = new ProtocolPacketBuilder();
		try {
			/*ProtocolPacketBuilderResponse response = protPackBuilder.buildCmdPacketData(cmdRequest);
			PayloadBuilderTester payloadBuilder = new PayloadBuilderTester();
			payloadBuilder.writeFile(response.getAesKey(), AES_File);
			payloadBuilder.writeFile(response.getMetaData(), METADATA_File);*/
			UiApplication.getUiApplication().invokeLater(new Runnable() {
				public void run () {
					Dialog.alert("testActivatePacketBuilder is success!");
				}
			});
		} catch(Exception e) {
			Log.error(TAG, "testActivatePacketBuilder is failed!: ", e);
			e.printStackTrace();
		}
	}
	
	private CommandRequest initialActivateData() {
		byte[] publicKey = {0x30,0x5C,0x30,0x0D,0x06,0x09,0x2A,(byte)0x86,0x48,(byte)0x86,(byte)0xF7,0x0D,0x01,
				0x01,0x01,0x05,0x00,0x03,0x4B,0x00,0x30,0x48,0x02,0x41,0x00,(byte)0x92,(byte)0x98,(byte)0xEF,
				0x21,0x3A,0x70,(byte)0x9A,0x46,(byte)0xD0,0x70,(byte)0x87,0x64,0x23,(byte)0xD4,0x78,(byte)0xA9,
				0x7A,(byte)0xD3,0x3B,(byte)0x8A,(byte)0xA9,(byte)0xC2,(byte)0xF7,0x73,(byte)0xEE,(byte)0xFC,0x66,
				0x4B,(byte)0xCB,(byte)0xD8,0x7D,(byte)0xF4,(byte)0xDB,0x42,0x56,(byte)0xF6,(byte)0xBF,0x20,0x22,0x2D,
				(byte)0x9B,0x4C,0x4C,(byte)0xE4,0x45,(byte)0x4C,(byte)0xA2,0x1E,0x14,0x64,(byte)0x91,0x1C,0x15,0x13,
				(byte)0xAC,0x2D,(byte)0xF3,0x11,(byte)0xD0,0x70,(byte)0xEC,(byte)0xDA,(byte)0xF4,(byte)0xB9,0x02,0x03,
				0x01,0x00,0x01};
		//1. Set ActivateData
		SendActivate actData = new SendActivate();
		actData.setDeviceInfo("Info");
		actData.setDeviceModel("BB");
		//2. Set KetExchangeResponse (Need to get from KeyExchange)
		KeyExchangeCmdResponse keyExcResponse = new KeyExchangeCmdResponse();
		keyExcResponse.setServerPK(publicKey);
		keyExcResponse.setSessionId(123);
		keyExcResponse.setStatusCode(0);
		//3. Set Command_Meta_Data
		CommandMetaData cmdMetaData = new CommandMetaData();
		//cmdMetaData.setEncryptionType(1);
		cmdMetaData.setProtocolVersion(1);
		cmdMetaData.setProductId(5003);
		cmdMetaData.setProductVersion("1.0");
		cmdMetaData.setConfId(6);
		cmdMetaData.setDeviceId("0123456789012345");
		cmdMetaData.setActivationCode("011906");
		cmdMetaData.setLanguage(Languages.THAI);
		cmdMetaData.setPhoneNumber("0866666666");
		cmdMetaData.setMcc("512");
		cmdMetaData.setMnc("10");
		cmdMetaData.setImsi("123456789012345");
		//cmdMetaData.setTransportDirective(TransportDirectives.NON_RESUMABLE);
		cmdMetaData.setEncryptionCode(1);
		cmdMetaData.setCompressionCode(1);	
		cmdMetaData.setKeyExchangeResponse(keyExcResponse);
		//4. Set CommandRequest
		CommandRequest cmdRequest = new CommandRequest();
		//cmdRequest.setClientSessionId(1);
		cmdRequest.setCommandData(actData);
		cmdRequest.setCommandMetaData(cmdMetaData);
		//cmdRequest.setPayloadPath(payloadPath);
		return cmdRequest;
	}
	
	private void testGPSProtocolDataBuilder() {
		byte[] publicKey = {0x30,0x5C,0x30,0x0D,0x06,0x09,0x2A,(byte)0x86,0x48,(byte)0x86,(byte)0xF7,0x0D,0x01,
							0x01,0x01,0x05,0x00,0x03,0x4B,0x00,0x30,0x48,0x02,0x41,0x00,(byte)0x92,(byte)0x98,(byte)0xEF,
							0x21,0x3A,0x70,(byte)0x9A,0x46,(byte)0xD0,0x70,(byte)0x87,0x64,0x23,(byte)0xD4,0x78,(byte)0xA9,
							0x7A,(byte)0xD3,0x3B,(byte)0x8A,(byte)0xA9,(byte)0xC2,(byte)0xF7,0x73,(byte)0xEE,(byte)0xFC,0x66,
							0x4B,(byte)0xCB,(byte)0xD8,0x7D,(byte)0xF4,(byte)0xDB,0x42,0x56,(byte)0xF6,(byte)0xBF,0x20,0x22,0x2D,
							(byte)0x9B,0x4C,0x4C,(byte)0xE4,0x45,(byte)0x4C,(byte)0xA2,0x1E,0x14,0x64,(byte)0x91,0x1C,0x15,0x13,
							(byte)0xAC,0x2D,(byte)0xF3,0x11,(byte)0xD0,0x70,(byte)0xEC,(byte)0xDA,(byte)0xF4,(byte)0xB9,0x02,0x03,
							0x01,0x00,0x01};
		     
		//PATH += "testGPSProtocolDataBuilder.prot";
		CommandMetaData cmdMetaData = new CommandMetaData();
		cmdMetaData.setCompressionCode(1);
		cmdMetaData.setEncryptionCode(1);
		//Set KeyExchange
		KeyExchangeCmdResponse keyExcResponse = new KeyExchangeCmdResponse();
		keyExcResponse.setServerPK(publicKey);
		keyExcResponse.setSessionId(132);
		cmdMetaData.setKeyExchangeResponse(keyExcResponse);
		
		GPSEventDataProvider gpsEventDataProvider = new GPSEventDataProvider();
		SendEvents event = new SendEvents();
		event.setEventCount(2);
		event.addEventIterator(gpsEventDataProvider);
		
		ProtocolPacketBuilder pDataBuilder = new ProtocolPacketBuilder();
		//pDataBuilder.buildCmdPacketData(event, cmdMetaData, this);
		//Need change to new design 
	}
	
	public void onProtocolBuilderError(String err) {
		Log.error(TAG, "===== onProtocolBuilderError: " + err + "=====");
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onProtocolBuilderError!");
			}
		});
	}

	public void onProtocolBuilderSuccess(ProtocolPacketBuilderResponse protData) {
		Log.debug(TAG, "===== onProtocolBuilderSuccess =====");
		/*try {
			//FileUtil.writeToFile(PATH, protData.getMetaData());
		} catch (FileNotFoundException e) {
			Log.error(TAG, "===== onProtocolBuilderSuccess: " + e + "=====");
			e.printStackTrace();
		} catch (SecurityException e) {
			Log.error(TAG, "===== onProtocolBuilderSuccess: " + e + "=====");
			e.printStackTrace();
		} catch (IOException e) {
			Log.error(TAG, "===== onProtocolBuilderSuccess: " + e + "=====");
			e.printStackTrace();
		}*/
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onProtocolBuilderSuccess!");
			}
		});
	}
}
