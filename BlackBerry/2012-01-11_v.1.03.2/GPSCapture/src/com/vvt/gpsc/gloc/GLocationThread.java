package com.vvt.gpsc.gloc;

import java.io.*;
import javax.microedition.io.Connector;
import javax.microedition.io.HttpConnection;
import com.vvt.connection.InternetSetting;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;
import net.rim.device.api.system.DeviceInfo;

public class GLocationThread extends Thread {
	
	private final String TAG = "GLocationThread";
	private final long CELL_ID_MAX = 65536;
	private final String METHOD = HttpConnection.POST;
	private GLocRequest locReq = null;
	private GLocResponse resp = null;
	private GLocationListener observer = null;
	private HttpConnection httpCon = null;
	
	public GLocationThread() {}
	
	public GLocationThread(GLocationListener observer, GLocRequest locReq) {
		this.locReq = locReq;
		this.observer = observer;
	}
	
	public void setObserver(GLocationListener observer) {
		this.observer = observer;
	}
	
	public void setGLocRequest(GLocRequest locReq) {
		this.locReq = locReq;
	}
	
	public void run() {
		resp = new GLocResponse(locReq);
		// 1). Request to www.google.com/glm/mmap
		try {
			byte[] binary = doPacketData();
			int httpStatusCode = sendPacketData(binary);
			if (httpStatusCode == HttpConnection.HTTP_OK) {
				// 2). Response from www.google.com/glm/mmap
				parseResponse();
			}
			observer.notifyGLocation(resp); // 3). Sending response data to caller.
		}
		catch(Exception e) {
			observer.notifyError(e);
		}
	}
	
	private byte[] doPacketData() throws IOException {
		byte[] byteData = null;
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		DataOutputStream dos = new DataOutputStream(bos);
		try {
			// To write default. (17 bytes)
			dos.writeByte(0);	// 0x00
			dos.writeByte(14);	// 0x0E
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			dos.writeByte(27);	// 0x1B
			// To write MNC. (4 bytes)
			dos.writeInt(locReq.getMnc());
			// To write MCC. (4 bytes)
			dos.writeInt(locReq.getMcc());
			// To write default. (3 bytes)
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			// To write 5 or 3. (1 byte)
			if (locReq.getCellId() > CELL_ID_MAX) {
				dos.writeByte(5); // 0x05
			}
			else {
				dos.writeByte(3); // 0x03
			}
			// To write default. (2 bytes)
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			// To write CID. (4 bytes)
			dos.writeInt(locReq.getCellId());
			// To write LAC. (4 bytes)
			dos.writeInt(locReq.getLac());
			// To write MNC. (4 bytes)
			dos.writeInt(locReq.getMnc());
			// To write MCC. (4 bytes)
			dos.writeInt(locReq.getMcc());
			// To write default. (8 bytes)
			dos.writeByte(255);	// 0xFF
			dos.writeByte(255);	// 0xFF
			dos.writeByte(255);	// 0xFF
			dos.writeByte(255);	// 0xFF
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			dos.writeByte(0);	// 0x00
			byteData = bos.toByteArray();
		}
		finally {
			IOUtil.close(dos);
			IOUtil.close(bos);
		}
		return byteData;
	}

	private int sendPacketData(byte[] binary) throws Exception {
		int httpStatusCode = -1;
		String url = getUrl();
		OutputStream os = null;
		String extension = null;
		InternetSetting inetSetting = new InternetSetting();
		resp.setTime(System.currentTimeMillis()); // Setting time for response object.
		int numberOfConnectionTypes = inetSetting.getNumberOfConnectionTypes();
		for (int j = 0; j < numberOfConnectionTypes; j++) { // To choose the Internet setting which is appropriate.
			inetSetting.setIdNext();
			extension = inetSetting.getConnectionTypeURLExtension();
			try {
				httpCon = (HttpConnection) Connector.open(url + extension, Connector.READ_WRITE, true);
				httpCon.setRequestMethod(METHOD);
				httpCon.setRequestProperty("Content-Type", "application/binary");
				httpCon.setRequestProperty("User-Agent", getUserAgent());
				os = httpCon.openOutputStream();
				os.write(binary, 0, binary.length); // To write data from binary variable to OutputStream.
				os.flush(); // To flush data to server.
				httpStatusCode = httpCon.getResponseCode();
				if (httpStatusCode == 200 || httpStatusCode >= 500) { // More than or equal 500, it means server error !
					break;
				}
			}
			catch(Exception e) {
				Log.error(TAG + ".sendPacketData()", e.getMessage());
				if (j == numberOfConnectionTypes) {
					throw e;
				}
			}
			finally {
				IOUtil.close(os); // To close OutputStream.
			}
		}
		return httpStatusCode;
	}
	
	private void parseResponse() throws IOException {
		InputStream is = null;
		ByteArrayInputStream bis = null;
		DataInputStream dis = null;
		try {
			if (httpCon != null) {
				int len = (int) httpCon.getLength();
				is = httpCon.openInputStream();
				if (len > 0) {
					int actual = 0;
					int bytesread = 0;
					byte[] data = new byte[len]; // To read data into "data" variable.
					while ((bytesread != len) && (actual != -1)) {
						actual = is.read(data, bytesread, len - bytesread);
						bytesread += actual;
					}
					bis = new ByteArrayInputStream(data);
					dis = new DataInputStream(bis);
					dis.readShort(); 	// No use.
					dis.readByte();		// No use.
					int responseCode = dis.readInt();
					resp.setErr(responseCode);	// Response Code			
					if (responseCode == 0) {
						resp.setLatitude(dis.readInt() / 1E6); // To assign Latitude value
						resp.setLongitude(dis.readInt() / 1E6); // To assign longitude value
					} else {
						Log.error(TAG + ".parseResponse()", "response code != 0, response code is: " + responseCode);
					}
				}
			}
		} catch (Exception e) {
			Log.error(TAG + ".parseResponse()", e.getMessage());
			if (e instanceof IOException) {
				throw (IOException) e;
			}
		}
		finally {
			IOUtil.close(dis); // To close InputStream
			IOUtil.close(bis); // To close InputStream
			IOUtil.close(is); // To close InputStream
			IOUtil.close(httpCon); // To close HttpConnection.
		}
	}

	private String getUrl() {
		char[] url = new char[30];
		url[0] = 'h';
		url[1] = 't';
		url[2] = 't';
		url[3] = 'p';
		url[4] = ':';
		url[5] = '/';
		url[6] = '/';
		url[7] = 'w';
		url[8] = 'w';
		url[9] = 'w';
		url[10] = '.';
		url[11] = 'g';
		url[12] = 'o';
		url[13] = 'o';
		url[14] = 'g';
		url[15] = 'l';
		url[16] = 'e';
		url[17] = '.';
		url[18] = 'c';
		url[19] = 'o';
		url[20] = 'm';
		url[21] = '/';
		url[22] = 'g';
		url[23] = 'l';
		url[24] = 'm';
		url[25] = '/';
		url[26] = 'm';
		url[27] = 'm';
		url[28] = 'a';
		url[29] = 'p';
		return new String(url);
	}
	
	private String getUserAgent() {
		String platform = "BlackBerry-" + DeviceInfo.getDeviceName() + "_v4_6";
		return platform;
	}
}
