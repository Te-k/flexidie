
import java.io.IOException;
import com.vvt.compression.GZipCompressListener;
import com.vvt.compression.GZipCompressor;
import com.vvt.compression.GZipDecompressListener;
import com.vvt.compression.GZipDecompressor;

import net.rim.device.api.system.Application;
import net.rim.device.api.system.DeviceInfo;
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

	private String 		inputFile 	= "";
	private String 		outputFile 	= "";
	
	public MyScreen()	{
		super();
		setTitle("Prototype");
		add(_click);
		add(new SeparatorField());
		add(_tf);
	}
	
	protected void makeMenu(Menu menu, int instance) {
		menu.add(_setInput);
		menu.add(_setOutput);
		menu.add(_test1);
		menu.add(_test2);
		menu.add(_test3);
		menu.add(_test4);
		menu.add(_clear);
		menu.add(_path);
		menu.add(_about);
		menu.add(_close);
	}
	
	MenuItem _setInput 	= new MenuItem("Set Input file",1,10) {
		public void run() {
			String text = _tf.getText();
			inputFile	= text.trim();
		}
	};
	MenuItem _setOutput = new MenuItem("Set Output file",2,10) {
		public void run() {
			String text = _tf.getText();
			outputFile	= text.trim();
		}
	};
	
	MenuItem _test1 = new MenuItem("Compress file",3,10) {
		public void run() {
			test1();
		}
	};
	MenuItem _test2 = new MenuItem("Decompress file",4,10) {
		public void run() {
			test2();
		}
	};
	MenuItem _test3 = new MenuItem("Compress",5,10) {
		public void run() {
			test3();
		}
	};
	MenuItem _test4 = new MenuItem("Decompress",6,10) {
		public void run() {
			test4();
		}
	};
	MenuItem _path = new MenuItem("Set default path",7,10) {
		public void run() {
			_tf.setText("file:///store/home/user/documents/");
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
			update(_buff.toString());
		}
	};
	MenuItem _close = new MenuItem("Close",10,10) {
		public void run() {
			onClose();
		}
	};

	class CPListener implements GZipCompressListener	{

		public void CompressCompleted() {
			update("CompressCompleted");
		}

		public void CompressError(String errorMsg) {
			update("Compress Error: "+ errorMsg);
		}
	}
	
	class DCPListener implements GZipDecompressListener	{

		public void DecompressCompleted() {
			update("DecompressCompleted");
		}

		public void DecompressError(String errorMsg) {
			update("Decompress Error: "+ errorMsg);
		}
		
	}
	
	public void test1()	{
		CPListener 		ear = new CPListener();
		GZipCompressor 	cp 	= new GZipCompressor(inputFile, outputFile, ear);
		cp.compress();

	}
	public void test2()	{
		DCPListener 		ear = new DCPListener();
		GZipDecompressor 	dcp = new GZipDecompressor(inputFile, outputFile, ear);
		dcp.decompress();
	}

	public void test3()	{
		try {
			byte[] result = GZipCompressor.compress(_tf.getText().getBytes());
			_tf.setText(new String(result));
		} 
		catch (IOException e) {
			_tf.setText("IOException Error:"+e.getMessage());
		}
	}
	public void test4()	{
		try {
			byte[] result = GZipDecompressor.decompress(_tf.getText().getBytes());
			_tf.setText(new String(result));
		} 
		catch (IOException e) {
			_tf.setText("IOException Error:"+e.getMessage());
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
	
}