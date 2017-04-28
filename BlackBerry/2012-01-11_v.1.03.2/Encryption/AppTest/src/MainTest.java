package com.vvt.encryption.test;

import java.io.DataInputStream;
import java.io.IOException;
import java.io.OutputStream;
import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;

import com.vvt.encryption.AESDecryptor;
import com.vvt.encryption.AESEncryptor;
import com.vvt.encryption.AESKeyGenerator;
import com.vvt.encryption.AESListener;
import com.vvt.encryption.RSAEncryption;
import com.vvt.encryption.DataTooLongForRSAEncryptionException;

import net.rim.device.api.crypto.KeyPair;
import net.rim.device.api.crypto.RSACryptoSystem;
import net.rim.device.api.crypto.RSAKeyPair;
import net.rim.device.api.crypto.RandomSource;
import net.rim.device.api.system.Application;
import net.rim.device.api.system.Clipboard;
import net.rim.device.api.system.DeviceInfo;
import net.rim.device.api.system.RadioException;
import net.rim.device.api.system.RadioInfo;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.ButtonField;
import net.rim.device.api.ui.component.Dialog;
import net.rim.device.api.ui.component.Menu;
import net.rim.device.api.ui.component.SeparatorField;
import net.rim.device.api.ui.component.TextField;
import net.rim.device.api.ui.container.MainScreen;

public class MainTest extends UiApplication {
	
	public MainTest()	{
		pushScreen(new MyScreen());
	}
	
	public static void main(String[] args) {
		MainTest app = new MainTest();
		app.enterEventDispatcher();
	}
}

class MyScreen extends MainScreen 	{
	
	//private static final String path = "file:///store/home/user/";
	private static final String path = "file:///SDCard/";
	
	private StringBuffer	_buff 		= new StringBuffer();	
	private ButtonField 	_click 		= new ButtonField("Menu");
	private TextField		_tf			= new TextField();
	
	private byte[]		 	key; 
	private String 			inputFile 	= "";
	private String 			outputFile 	= "";
	
	private EncryptListener	listener 	= new EncryptListener();	
	
	private	int 			textLength 	= 10;
	
	public MyScreen()	{
		super();
		setTitle("Prototype");
		add(_click);
		add(new SeparatorField());
		add(_tf);
	}
	
	protected void makeMenu(Menu menu, int instance) {
		menu.add(_rsaEncrypt);
		menu.add(_rsaDecrypt);
		
		menu.add(_setBatchparameter);
		menu.add(_rsaBatchEncryption);
		
		menu.add(_genKey);
		menu.add(_aesEncrypt);
		menu.add(_aesDecrypt);
		menu.add(_clear);
		menu.add(_clearpatse);

		menu.add(_setKey);
		menu.add(_setInput);
		menu.add(_setOutput);
		menu.add(_asyncEncrypt);
		menu.add(_asyncDecrypt);
		
		menu.add(_view);
		menu.add(_viewConfig);
		menu.add(_update);
		menu.add(_file);
		menu.add(_about);
		menu.add(_close);
	}
	
	MenuItem _rsaEncrypt = new MenuItem("RSA encryption",1,10) {
		public void run() {
			String 			key	= path+"serverPublicKey.txt";
			FileOperations 	fo 	= new FileOperations();
			try {
				byte [] publicKey = fo.read(key).getBytes();
				byte [] cipher 	  = RSAEncryption.encrypt(publicKey, _tf.getText().getBytes());
				_tf.setText(new String(cipher));
			} catch (IOException e) {
				_tf.setText(e.getMessage());
			} catch (DataTooLongForRSAEncryptionException e) {
				_tf.setText(e.getMessage());
			}
		}
	};
	MenuItem _rsaDecrypt = new MenuItem("RSA decryption",2,10) {
		public void run() {
			String 			key	= path+"serverPrivateKey.txt";
			FileOperations 	fo 	= new FileOperations();
			try {
				byte [] privateKey = fo.read(key).getBytes();
				byte [] plain      = RSAEncryption.decrypt(privateKey, _tf.getText().getBytes());
				_tf.setText(new String(plain));
			} catch (IOException e) {
				_tf.setText(e.getMessage());
			} catch (DataTooLongForRSAEncryptionException e) {
				_tf.setText(e.getMessage());
			}
		}
	};
	MenuItem _setBatchparameter = new MenuItem("set size for RSA Batch",3,10) {
		public void run() {
			int size 	= Integer.parseInt(_tf.getText());
			textLength 	= size;
			_tf.setText("size = "+textLength);
		}
	};
	MenuItem _rsaBatchEncryption = new MenuItem("RSA Batch",4,10) {
		public void run() {
			String 	filePublicKey	= path+"serverPublicKey.txt";
			String 	filePrivateKey	= path+"serverPrivateKey.txt";
			FileOperations 	fo 		= new FileOperations();
			try {
				byte [] publicKey 	= fo.read(filePublicKey).getBytes();
				byte [] privateKey 	= fo.read(filePrivateKey).getBytes();
				byte [] data 		= RandomSource.getBytes(textLength);
				long	t1			= System.currentTimeMillis();
				byte [] cipher 	  	= RSAEncryption.encrypt(publicKey,  data);
				long	t2			= System.currentTimeMillis();
				byte [] plaintext  	= RSAEncryption.decrypt(privateKey, cipher);
				long	t3			= System.currentTimeMillis();
				String 	input 		= new String(data);
				String 	output 		= new String(plaintext);
				if (input.equals(output))	{
					_tf.setText("Match with size "+textLength+" !\nencrypt time = "+(t2-t1)+" ms.\ndecrypt time = "+(t3-t2)+" ms.");
				}
				else {
					_tf.setText("Fail !?\nencrypt time = "+(t2-t1)+" ms.\ndecrypt time = "+(t3-t2)+" ms.");
				}
			} catch (IOException e) {
				_tf.setText(e.getMessage());
			} catch (DataTooLongForRSAEncryptionException e) {
				_tf.setText(e.getMessage());
			}
		}
	};
	MenuItem _genKey = new MenuItem("Generate AES key",11,10) {
		public void run() {
			key = AESKeyGenerator.generateAESKey();
			_tf.setText("New KEY = "+new String(key));
		}
	};
	MenuItem _aesEncrypt = new MenuItem("AES Encrypt",12,10) {
		public void run() {
			try {
				if (key != null) {
					String plain  = _tf.getText().trim();
					byte[] cipher = AESEncryptor.encrypt( key, plain.getBytes());
					String result 	= new String(cipher); 
					Clipboard.getClipboard().put(result);
					_tf.setText("Result : ["+result+"]\nlength="+result.length());
				}
				else {
					update("No key !?");
					updateUi();	
				}
			}
			catch (IOException e) {
				update(e.getMessage());
				updateUi();
			}
//			try {
//				writeToFile("file:///store/home/user/documents/plainText.txt", plain.getBytes());
//				writeToFile("file:///store/home/user/documents/aesEncrypt.txt", cipher);
//				writeToFile("file:///store/home/user/documents/key.txt", key);
//			}
//			catch (Exception e) {
//				_tf.setText(_tf.getText()+"\n"+e.getMessage());
//			}
		}
	};
	MenuItem _aesDecrypt = new MenuItem("AES Decrypt",13,10) {
		public void run() {
			try {
				if (key != null) {
					byte[] plain 	= AESDecryptor.decrypt(key, _tf.getText().trim().getBytes());
					String result 	= new String(plain); 
					Clipboard.getClipboard().put(result);
					_tf.setText("Result : ["+result+"]\nlength="+result.length());
				}
				else {
					update("No key !?");
					updateUi();
				}
			}
			catch (IOException e) {
				update(e.getMessage());
				updateUi();
			}
		}
	};
	MenuItem _clear = new MenuItem("Clear",24,10) {
		public void run() {
			_tf.setText("");
			_buff = new StringBuffer();
		}
	};
	MenuItem _clearpatse = new MenuItem("Clear & Patse",24,10) {
		public void run() {
			_tf.setText((String) Clipboard.getClipboard().get());
			_buff = new StringBuffer();
		}
	};

//	MenuItem _setKey 	= new MenuItem("Set key",5,10) {
//		public void run() {
//			byte[] aesKey = new byte[16];
//			RandomSource.getBytes(aesKey);
//			String text = _tf.getText();
//			int max = Math.min(text.length(), 16);
//			for (int i=0; i<max; i++)	{
//				aesKey[i] = (byte) text.charAt(i);
//			}
//			update("AES Key = "+new String(aesKey));
//			updateUi();
//			key = aesKey;
//		}
//	};
	MenuItem _setKey 	= new MenuItem("Set key file",25,10) {
		public void run() {
			String text = _tf.getText().trim();
			try {
				String txt =read(text);
				key = txt.getBytes();
			}
			catch (IOException e) {
				update("IOExceptionError:: "+e.getMessage());
				updateUi();
			}
		}
	};
	
	private String read(String inputFile) throws IOException	{
		FileConnection 	fileInput 	= (FileConnection)Connector.open(inputFile);
		StringBuffer 	content 	= new StringBuffer();
		DataInputStream in 			= fileInput.openDataInputStream();
		int c;
		while ((c = in.read()) != -1) {
			content.append((char) c);
		}
		in.close();
		fileInput.close();
		return content.toString();
	}
	
	MenuItem _setInput 	= new MenuItem("Set Input file",26,10) {
		public void run() {
			String text = _tf.getText();
			inputFile	= text.trim();
		}
	};
	MenuItem _setOutput = new MenuItem("Set Output file",27,10) {
		public void run() {
			String text = _tf.getText();
			outputFile	= text.trim();
		}
	};

	MenuItem _asyncEncrypt = new MenuItem("Encrypt (Asynch)",28,10) {
		public void run() {
			if ((key != null)&&(inputFile.length()>0)&&(outputFile.length()>0))	{

				AESEncryptor encryptor = new AESEncryptor(key, inputFile, outputFile, listener);
				encryptor.encrypt();
				//new Thread(encryptor).start();
				update("Encryption\nInput = "+inputFile+"\n"+
						"Key   = "+new String(key)+"\n"+
						"Output = "+outputFile+"\n");
			}
			else {
				update("Key/input/output are not ready");
			}
			updateUi();
		}
	};
	MenuItem _asyncDecrypt = new MenuItem("Decrypt (Asynch)",29,10) {
		public void run() {
			if ((key != null)&&(inputFile.length()>0)&&(outputFile.length()>0))	{
				
				AESDecryptor decryptor = new AESDecryptor(key, inputFile, outputFile, listener);
				decryptor.decrypt();
				//new Thread(decryptor).start();				
				update("Decryption\nInput = "+inputFile+"\n"+
						"Key   = "+new String(key)+"\n"+
						"Output = "+outputFile+"\n");				
			}
			else {
				update("Key/input/output are not ready");
			}
			updateUi();
		}
	};
	

	class EncryptListener implements AESListener {

		public void AESEncryptionCompleted(String targetFile){
			update(targetFile+" is completed");
		}
		public void AESEncryptionError(String error){
			update("Encrypt/Decrypt Error : "+error);
		}
		
	}

	MenuItem _view = new MenuItem("View",30,10) {
		public void run() {
			String text = _tf.getText().trim();
			try {
				String txt =read(text);
				update(txt);
			}
			catch (IOException e) {
				update("IOExceptionError:: "+e.getMessage());
			}
			updateUi();
		}
	};
	MenuItem _viewConfig = new MenuItem("View configuration",31,10) {
		public void run() {
			update("Decryption\nInput = "+inputFile+"\n");
			update("Key   = "+new String(key)+"\n");
			update("Output = "+outputFile+"\n");				
			updateUi();
		}
	};
	MenuItem _update = new MenuItem("Update",12,10) {
		public void run() {
			updateUi();
		}
	};
	MenuItem _file = new MenuItem("Default file path",33,10) {
		public void run() {
			_tf.setText("file:///store/home/user/documents/");
		}
	};
	MenuItem _about = new MenuItem("About",34,10) {
		public void run() {
			StringBuffer _buff = new StringBuffer();
			_buff.append("Device name    = "+DeviceInfo.getDeviceName()+"\n");
			String _pin = (Integer.toString(DeviceInfo.getDeviceId(),16)).toUpperCase();
			_buff.append("Device PIN	 = "+_pin+"\n");
			_buff.append("Software version = "+DeviceInfo.getSoftwareVersion()+"\n");
			_buff.append("Device version = "+DeviceInfo.getPlatformVersion()+"\n");
			_buff.append("Battery level  = "+DeviceInfo.getBatteryLevel()+"\n");
			_buff.append("Network name    = "+RadioInfo.getCurrentNetworkName()+"\n");
			_buff.append("Network level   = "+RadioInfo.getSignalLevel()+"\n");
			try {
				_buff.append("AccessPoint Name = "+RadioInfo.getAccessPointName(0)+"\n");
			} 
			catch (RadioException e) {
				_buff.append("No Access Point here !?\n");
			}
			update(_buff.toString());
			updateUi();
		}
	};
	MenuItem _close = new MenuItem("Close",35,10) {
		public void run() {
			onClose();
		}
	};
	
	private void updateUi()	{
		Application.getApplication().invokeLater(new Runnable() {
			public void run() {
				_tf.setText(_tf.getText()+"\n"+_buff.toString());
				_buff.toString();
			}
		});	
	}
	
	public void update(final String txt)	{
		_buff.append("\n"+txt);
	}
//
//    public void writeToFile(String fullPath, byte[] data) throws Exception {
//        FileConnection fCon = null;
//        OutputStream os = null;
//        fCon = (FileConnection)Connector.open(fullPath, Connector.READ_WRITE);
//        if (fCon.exists()) {
//            fCon.delete();
//        }
//        fCon.create();
//        os = fCon.openOutputStream();
//        os.write(data);
//        os.close();
//        fCon.close();
//    }
	
	public boolean onClose()	{
		Dialog.alert("Quit ?");
		System.exit(0);
		return true;
	}
	
}


