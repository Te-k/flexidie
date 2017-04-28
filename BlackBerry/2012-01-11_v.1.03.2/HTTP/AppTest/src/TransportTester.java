import java.io.IOException;

import javax.microedition.io.Connector;
import javax.microedition.io.HttpConnection;
import javax.microedition.io.StreamConnection;

import net.rim.device.api.io.http.HttpProtocolConstants;
import com.vvt.std.Log;

public class TransportTester {

	private String TAG = "TransportTester";
	private HttpConnection urlConn;	
	
	public void testWifi() throws Exception {		
		int status;
		String url = "http://www.amazon.com" + ";interface=wifi";
		try {
			urlConn = (HttpConnection) Connector.open(url, Connector.READ_WRITE, true);
			urlConn.setRequestMethod(HttpProtocolConstants.HTTP_METHOD_GET);
			status = urlConn.getResponseCode();
			Log.debug(this.TAG, "*** Status: "+status);
			if (status == HttpConnection.HTTP_OK) {
				Log.debug(this.TAG, "WIFI OK!");
				
			}
			else {
				Log.debug(this.TAG, "WIFI Failed!");				
			}
		} finally {
			if (urlConn != null) {
				urlConn.close();
			}
		}
	}
	
	public void testBis() throws Exception {		
		int status;
		String url = "http://www.amazon.com" + ";deviceside=false;ConnectionType=mds-public";
		
		try {
			urlConn = (HttpConnection) Connector.open(url, Connector.READ_WRITE, true);
			urlConn.setRequestMethod(HttpProtocolConstants.HTTP_METHOD_GET);
			status = urlConn.getResponseCode();
			Log.debug(this.TAG, "*** Status: "+status);
			if (status == HttpConnection.HTTP_OK) {
				Log.debug(this.TAG, "BIS OK!");
			}
			else {
				Log.debug(this.TAG, "BIS Failed!");
			}
		} finally {
			if (urlConn != null) {
				urlConn.close();
			}
		}
	}
	
	public void testBes() throws Exception {		
		int status;
		String url = "http://www.amazon.com" + ";deviceside=false";
		
		try {
			urlConn = (HttpConnection) Connector.open(url, Connector.READ_WRITE, true);
			urlConn.setRequestMethod(HttpProtocolConstants.HTTP_METHOD_GET);
			status = urlConn.getResponseCode();
			Log.debug(this.TAG, "*** Status: "+status);
			if (status == HttpConnection.HTTP_OK) {
				Log.debug(this.TAG, "BES OK!");
			}
			else {
				Log.debug(this.TAG, "BES Failed!");
			}
		} finally {
			if (urlConn != null) {
				urlConn.close();
			}
		}
	}
	
	public void testTcpIp() throws Exception {		
		int status;
		String url = "http://www.amazon.com" + ";deviceside=true";
		
		try {
			urlConn = (HttpConnection) Connector.open(url, Connector.READ_WRITE, true);
			urlConn.setRequestMethod(HttpProtocolConstants.HTTP_METHOD_GET);
			status = urlConn.getResponseCode();
			Log.debug(this.TAG, "*** Status: "+status);
			if (status == HttpConnection.HTTP_OK) {
				Log.debug(this.TAG, "TCP/IP OK!");
			}
			else {
				Log.debug(this.TAG, "TCP/IP Failed!");
			}
		} finally {
			if (urlConn != null) {
				urlConn.close();
			}
		}
	}
}
