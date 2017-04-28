package com.vvt.phoenix.prot.parser.test;

import java.io.ByteArrayOutputStream;
import java.util.Arrays;

import android.test.AndroidTestCase;
import android.util.Log;

import com.vvt.phoenix.prot.TransportDirectives;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.CommandMetaDataWrapper;
import com.vvt.phoenix.prot.command.FxProcess;
import com.vvt.phoenix.prot.command.FxProcessCategory;
import com.vvt.phoenix.prot.command.Languages;
import com.vvt.phoenix.prot.command.SendActivate;
import com.vvt.phoenix.prot.command.SendRunningProcess;
import com.vvt.phoenix.prot.parser.ProtocolParser;
import com.vvt.phoenix.prot.test.PhoenixTestUtil;
import com.vvt.phoenix.util.ByteUtil;

public class ProtocolParserTest extends AndroidTestCase{
	
	private static final String TAG = "ProtocolParserTest";
	private static final String ACTIVATION_CODE = "1999";
	private static final int TRANSPORT_DIRECTIVE = TransportDirectives.NON_RESUMABLE;
	private static final int PAYLOAD_SIZE = 1999;
	private static final int PAYLOAD_CRC = 32;
	private static final String DEVICE_INFO = "device_info";
	private static final String DEVICE_MODEL = "device_mode";
	
	private static final boolean TEST_PARSING_META_DATA = true;
	private static final boolean TEST_PARSING_SEND_ACTIVATE = true;
	private static final boolean TEST_PARSING_SEND_RUNNING_PROCESS = true;

	public void testCases(){
		if(TEST_PARSING_META_DATA){
			_testParsingMetaData();
		}
		if(TEST_PARSING_SEND_ACTIVATE){
			_testParsingSendActivate();
		}
		if(TEST_PARSING_SEND_RUNNING_PROCESS){
			_testParsingSendRunningProcess();
		}
	}
	
	private void _testParsingMetaData(){
		Log.d(TAG, "_testParsingMetaData");
		
		//1 prepare expected result
		/*
		 * most of expected data have to refer to value in EnvironmentInfo.createMetaDataForActivation()
		 */		
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//protocol version
		stream.write(new byte[]{0x00, 0x01}, 0, 2);	
		//product ID : 4202
		stream.write(new byte[]{0x10, 0x6A}, 0, 2);		
		//product version
		byte[] productVersion = ByteUtil.toBytes("-1.00");
		stream.write((byte) productVersion.length);					
		stream.write(productVersion, 0, productVersion.length);		
		//config ID
		stream.write(new byte[]{0x00, 0x00}, 0, 2);					
		//device ID
		String deviceId = PhoenixTestUtil.getDeviceId(getContext());
		if(deviceId != null){
			byte[] deviceIdByte = ByteUtil.toBytes(deviceId);
			stream.write((byte) deviceIdByte.length);						
			stream.write(deviceIdByte, 0, deviceIdByte.length);	
		}else{
			stream.write((byte) 0);
		}
		//activation code
		byte[] activationCodeByte = ByteUtil.toBytes(ACTIVATION_CODE);
		stream.write((byte) activationCodeByte.length);					
		stream.write(activationCodeByte, 0, activationCodeByte.length);		
		//language
		stream.write((byte) Languages.ENGLISH);						
		//phone number
		String phoneNumber = PhoenixTestUtil.getPhoneNumber(getContext());
		if(phoneNumber != null){
			byte[] phoneNumberByte = ByteUtil.toBytes(phoneNumber);
			stream.write((byte) phoneNumberByte.length);					
			stream.write(phoneNumberByte, 0, phoneNumberByte.length);	
		}else{
			stream.write((byte) 0);
		}
		//mcc
		String mcc = PhoenixTestUtil.getMcc(getContext());
		if(mcc != null){
			byte[] mccByte = ByteUtil.toBytes(mcc);
			stream.write((byte) mccByte.length);					
			stream.write(mccByte, 0, mccByte.length);	
		}else{
			stream.write((byte) 0);
		}
		//mnc
		String mnc = PhoenixTestUtil.getMnc(getContext());
		if(mnc != null){
			byte[] mncByte = ByteUtil.toBytes(mnc);
			stream.write((byte) mncByte.length);					
			stream.write(mncByte, 0, mncByte.length);
		}else{
			stream.write((byte) 0);
		}
		//imsi
		String imsi = PhoenixTestUtil.getImsi(getContext());
		if(imsi != null){
			byte[] imsiByte = ByteUtil.toBytes(imsi);
			stream.write((byte) imsiByte.length);					
			stream.write(imsiByte, 0, imsiByte.length);
		}else{
			stream.write((byte) 0);
		}
		//URL
		stream.write((byte) 0);
		//transport directive
		stream.write((byte) TRANSPORT_DIRECTIVE);
		//encryption code
		stream.write((byte) 1);
		//compression code
		stream.write((byte) 1);
		//payload size
		stream.write(ByteUtil.toBytes(PAYLOAD_SIZE), 0, 4);		
		//payload crc32
		stream.write(ByteUtil.toBytes(PAYLOAD_CRC), 0, 4);		
		byte[] expected = stream.toByteArray();
		
		//2 parsing metadata
		CommandMetaDataWrapper metaWrapper = new CommandMetaDataWrapper();
		metaWrapper.setPayloadCrc32(PAYLOAD_CRC);
		metaWrapper.setPayloadSize(PAYLOAD_SIZE);
		metaWrapper.setTransportDirective(TRANSPORT_DIRECTIVE);
		CommandMetaData metaData = PhoenixTestUtil.createMetaDataForActivation(ACTIVATION_CODE, getContext());
		metaWrapper.setCommandMetaData(metaData);
		byte[] result = ProtocolParser.parseCommandMetadata(metaWrapper);
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}

	private void _testParsingSendActivate(){
		Log.d(TAG, "_testParsingSendActivate");
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		//device info
		byte[] deviceInfoByte = ByteUtil.toBytes(DEVICE_INFO);
		stream.write((byte)	deviceInfoByte.length);
		stream.write(deviceInfoByte, 0, deviceInfoByte.length);
		//device model
		byte[] deviceModel = ByteUtil.toBytes(DEVICE_MODEL);
		stream.write((byte)	deviceModel.length);
		stream.write(deviceModel, 0, deviceModel.length);
		byte[] expected = stream.toByteArray();
		
		//2 parsing send activate
		SendActivate command = new SendActivate();
		command.setDeviceInfo(DEVICE_INFO);
		command.setDeviceModel(DEVICE_MODEL);
		byte[] result = ProtocolParser.parseSendActivate(command);
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testParsingSendRunningProcess(){
		Log.d(TAG, "_testParsingSendRunningProcess");
		
		//1 prepare expected result
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		String process1Name = "P1";
		String process2Name = "P2";
		//process count
		stream.write(new byte[]{0x00, 0x02}, 0, 2);
		//first process
		 //category
		stream.write((byte) FxProcessCategory.PROCESS);
		  //name and its length
		byte[] process1NameByte = ByteUtil.toBytes(process1Name);
		stream.write((byte) process1NameByte.length);
		stream.write(process1NameByte, 0, process1NameByte.length);
		//second process
		//category
		stream.write((byte) FxProcessCategory.SERVICE);
		  //name and its length
		byte[] process2NameByte = ByteUtil.toBytes(process2Name);
		stream.write((byte) process2NameByte.length);
		stream.write(process2NameByte, 0, process2NameByte.length);
		byte[] expected = stream.toByteArray();
		
		//2 parsing send activate
		FxProcess p1 = new FxProcess();
		p1.setCategory(FxProcessCategory.PROCESS);
		p1.setName(process1Name);
		FxProcess p2 = new FxProcess();
		p2.setCategory(FxProcessCategory.SERVICE);
		p2.setName(process2Name);
		SendRunningProcess command = new SendRunningProcess();
		command.addProcess(p1);
		command.addProcess(p2);
		byte[] result = ProtocolParser.parseSendRunningProcess(command);
		
		//3 compare
		assertEquals(true, Arrays.equals(expected, result));
		
	}
}
