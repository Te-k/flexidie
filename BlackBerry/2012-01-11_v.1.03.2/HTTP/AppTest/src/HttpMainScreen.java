//package com.vvt.http.test;

import com.vvt.std.Log;

import net.rim.device.api.ui.component.TextField;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.Dialog;
import net.rim.device.api.ui.component.LabelField;
import net.rim.device.api.ui.component.Menu;
import net.rim.device.api.ui.container.MainScreen;

public class HttpMainScreen extends UiApplication {
	
		
	public HttpMainScreen()    {
		pushScreen(new MyScreen());
	}
	
	public static void main(String[] args) {
		HttpMainScreen app = new HttpMainScreen();
		app.enterEventDispatcher();
	}
}

final class MyScreen extends MainScreen {
	
	private final String strLabel = "Http Component Testing";  
	private TextField tf = new TextField();
	private static final String strTAG = "MySceen";
	
	public MyScreen() {
		super();
		LabelField title = new LabelField(strLabel,LabelField.ELLIPSIS | LabelField.USE_ALL_WIDTH);
		setTitle(title);		
		add(tf);
	}
	
	public boolean onClose() {
		Log.close();
		Dialog.alert("Bye Bye");
		System.exit(0);
		return true;
	}
	
	protected void makeMenu(Menu menu, int instance) {
		menu.add(testPostItem);
		menu.add(testHttpRequest);
		menu.add(testDataSupplier);		
		menu.add(testGetMethod);
		menu.add(testPostMethod);		
		menu.add(testWifi);
		menu.add(testBIS);
		menu.add(testBES);
		menu.add(testTCPIP);
		menu.add(testGetImage);
	}
	
	private MenuItem testWifi = new MenuItem("Test WIFI", 110, 10) {
		public void run() {
			Dialog.alert("Start!");
			TransportTester p = new TransportTester();
			Log.setDebugMode(true);
			try {
				p.testWifi();
				Dialog.alert("End!");
			} catch (Exception e) {
				Log.error(strTAG, "WIFI Error: ", e);
				e.printStackTrace();
			} 
		}
	};
	
	private MenuItem testBIS = new MenuItem("Test BIS", 110, 10) {
		public void run() {
			Dialog.alert("Start!");
			TransportTester p = new TransportTester();
			Log.setDebugMode(true);
			try {
				p.testBis();
				Dialog.alert("End!");
			} catch (Exception e) {
				Log.error(strTAG, "BIS Error: ", e);
				e.printStackTrace();
			} 
		}
	};
	
	private MenuItem testBES = new MenuItem("Test BES", 110, 10) {
		public void run() {
			Dialog.alert("Start!");
			TransportTester p = new TransportTester();
			Log.setDebugMode(true);
			try {
				p.testBes();
				Dialog.alert("End!");
			} catch (Exception e) {
				Log.error(strTAG, "BES Error: ", e);
				e.printStackTrace();
			} 
		}
	};
	
	private MenuItem testTCPIP = new MenuItem("Test TCP/IP", 110, 10) {
		public void run() {
			Dialog.alert("Start!");
			TransportTester p = new TransportTester();
			Log.setDebugMode(true);
			try {
				p.testTcpIp();
				Dialog.alert("End!");
			} catch (Exception e) {
				Log.error(strTAG, "TCP/IP Error: ", e);
				e.printStackTrace();
			} 
		}
	};
	
	private MenuItem testGetMethod = new MenuItem("Test GET Method", 110, 10) {
		
		public void run() {
			Log.setDebugMode(true);
			Dialog.alert("Start!");
			HttpTester p = new HttpTester();
			p.testGetHtml();
		}
	};
	
	private MenuItem testGetImage = new MenuItem("Test GET Image", 110, 10) {
		
		public void run() {
			Log.setDebugMode(true);
			Dialog.alert("Start!");
			HttpTester p = new HttpTester();
			p.testGetImage();
		}
	};
	
	private MenuItem testPostMethod = new MenuItem("Test POST Method", 110, 10) {
		
		public void run() {
			Log.setDebugMode(true);
			Dialog.alert("Start!");
			HttpTester p = new HttpTester();
			p.testPost();
		}
	};
	
	private MenuItem testDataSupplier = new MenuItem("Test DataSupplier", 110, 10) {
		
		public void run() {
			Log.setDebugMode(true);
			Dialog.alert("Start!");
			DataSupplierTester dataSupplier = new DataSupplierTester();
			dataSupplier.testDataSupplier();			
		}
	};
	
	private MenuItem testPostItem = new MenuItem("Test PostItem", 110, 10) {
		
		public void run() {
			Log.setDebugMode(true);
			Dialog.alert("Start!");
			PostItemTester p = new PostItemTester();
			p.testPostItem();
			tf.setText("Finished!");			
		}
	};
	
	private MenuItem testHttpRequest = new MenuItem("Test HttpRequest", 110, 10) {
		
		public void run() {
			Log.setDebugMode(true);
			Dialog.alert("Start!");
			HttpRequestTester p = new HttpRequestTester();
			p.testHttpRequest();
			tf.setText("Finished!");			
		}
	};
	
}

