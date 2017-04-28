import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.OutputStream;

import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;

import com.vvt.prot.event.CallLogEvent;
import com.vvt.prot.event.Direction;
import com.vvt.prot.parser.ProtocolParser;
import com.vvt.std.IOUtil;


public class PEventTester {

	public void callLogMenu() {
		CallLogEvent callEvent = new CallLogEvent();
		ProtocolParser parser = new ProtocolParser();
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		DataOutputStream dos = new DataOutputStream(bos);
		FileConnection fCon = null;
		OutputStream os = null;
		try {
			fCon = (FileConnection)Connector.open("file:///SDCard/CallLogEvent.prot", Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
			fCon.create();
			os = fCon.openOutputStream();
			int eventId = 1;
			callEvent.setEventId(eventId);
			String eventTime = "2010-05-13 09:41:22";
			callEvent.setEventTime(eventTime);
			String address = "0851234567";
			callEvent.setAddress(address);
			String contactName = "Alex";
			callEvent.setContactName(contactName);
			callEvent.setDirection(Direction.IN);
			int duration = 9000;
			callEvent.setDuration(duration);
			//parser.parseEvent(callEvent);
			// 2.) CallLogEvent
			callEvent = new CallLogEvent();
			eventId = 2;
			callEvent.setEventId(eventId);
			eventTime = "2010-05-13 15:36:41";
			callEvent.setEventTime(eventTime);
			address = "0814756954";
			callEvent.setAddress(address);
			contactName = "Unkung";
			callEvent.setContactName(contactName);
			//direction = (short)Direction.OUT.getId();
			callEvent.setDirection(Direction.OUT);
			duration = 15000;
			callEvent.setDuration(duration);
			//parser.parseEvent(callEvent, os);
			// 3.) CallLogEvent
			callEvent = new CallLogEvent();
			eventId = 3;
			callEvent.setEventId(eventId);
			eventTime = "2010-05-13 21:14:09";
			callEvent.setEventTime(eventTime);
			address = "089-687-7454";
			callEvent.setAddress(address);
			//direction = (short)Direction.MISSED_CALL.getId();
			callEvent.setDirection(Direction.MISSED_CALL);
			duration = 1000;
			callEvent.setDuration(duration);
			//parser.parseEvent(callEvent, os);
			// 4.) CallLogEvent
			callEvent = new CallLogEvent();
			eventId = 4;
			callEvent.setEventId(eventId);
			eventTime = "2010-05-14 21:14:09";
			callEvent.setEventTime(eventTime);
			address = "66845789633";
			callEvent.setAddress(address);
			//direction = (short)Direction.IN.getId();
			callEvent.setDirection(Direction.IN);
			duration = 1000;
			callEvent.setDuration(duration);
			//parser.parseEvent(callEvent, os);
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		finally {
			IOUtil.close(bos);
			IOUtil.close(dos);
			IOUtil.close(os);
			IOUtil.close(fCon);
		}
	}
	
}
