package com.vvt.checksum.test;
import java.util.Random;
import java.util.Timer;

import com.vvt.checksum.CRC32;
import com.vvt.checksum.CRC32Listener;


import net.rim.device.api.crypto.RandomSource;
import net.rim.device.api.system.Application;
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

public class Main extends UiApplication {

	public Main()	{
		pushScreen(new MyScreen());
	}
	
	public static void main(String[] args) {
		Main app = new Main();
		app.enterEventDispatcher();
	}

}

class MyScreen extends MainScreen 	{
	
	private StringBuffer	_buff 	= new StringBuffer();	
	private ButtonField 	_click 	= new ButtonField("Menu");
	private TextField		_tf		= new TextField();
	
	private MyCRC32Listener	_listen = new MyCRC32Listener();
	
	public MyScreen()	{
		super();
		setTitle("Prototype");
		add(_click);
		add(new SeparatorField());
		add(_tf);
	}
	
	protected void makeMenu(Menu menu, int instance) {
		menu.add(_test1);
		menu.add(_test2);
		menu.add(_test3);
		menu.add(_clear);
		menu.add(_about);
		menu.add(_close);
	}
	
	MenuItem _test1 = new MenuItem("Calculate CRC32",1,10) {
		public void run() {
			test1();
		}
	};
	MenuItem _test2 = new MenuItem("Calculate from file",2,10) {
		public void run() {
			test2();
		}
	};
	MenuItem _test3 = new MenuItem("Create a file",3,10) {
		public void run() {
			test3();
		}
	};
	MenuItem _clear = new MenuItem("Clear",8,10) {
		public void run() {
			_tf.setText("");
			_buff = new StringBuffer();
		}
	};
	MenuItem _about = new MenuItem("About",9,10) {
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
		}
	};
	MenuItem _close = new MenuItem("Close",10,10) {
		public void run() {
			onClose();
		}
	};
	
	public void test1()	{
		String 	input = _tf.getText();
		long result = CRC32.calculate(input.getBytes());
		String hex	= Integer.toHexString((int) result).toUpperCase();
		if (input.length() == 0)	{
			update("CRC32 initialization = "+hex);
		}
		else {
			update("Input = "+input+"\nCRC32 = "+hex);
		}
	}
	public void test2()	{
		String dataFile = "file:///SDCard/random.txt";
		//String dataFile = "file:///SDCard/bb.bat";
		//String dataFile = "file:///store/home/user/documents/test.txt";
		update("Filename "+dataFile);
		CRC32 crcThread = new CRC32(dataFile, _listen);
		crcThread.start();
	}
	public void test3()	{
		//String dataFile = "file:///store/home/user/documents/test.txt";
		String dataFile = "file:///SDCard/random.txt";
		String text		= new String(RandomSource.getBytes(90000));
		boolean createFile = FileManager.writeFile(dataFile, text);
		if (createFile)	{
			update(dataFile+" is created.");
		}
		else {
			update("Cannot create "+dataFile+" !?");
		}
	}
	
	public void update(final String txt)	{
		Application.getApplication().invokeLater(new Runnable() {
			public void run() {
				_buff.append(txt+"\n");
				_tf.setText(_buff.toString());
			}
		});		
	}
	
	public boolean onClose()	{
		Dialog.alert("Quit ?");
		System.exit(0);
		return true;
	}
	
	class MyCRC32Listener implements CRC32Listener	{

		public void CRC32Completed(long value) {
			update("Checksum = "+Integer.toHexString((int)value).toUpperCase());
		}

		public void CRC32Error(String errorMsg) {
			update("Error : "+errorMsg);			
		}
		
	}
	
}


