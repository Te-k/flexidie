import java.util.Vector;
import com.vvt.event.CallLogEvent;
import com.vvt.event.CellInfoEvent;
import com.vvt.event.EmailEvent;
import com.vvt.event.GPSEvent;
import com.vvt.event.GPSField;
import com.vvt.event.Recipient;
import com.vvt.event.SMSEvent;
import com.vvt.event.constant.Direction;
import com.vvt.event.constant.EventType;
import com.vvt.event.constant.GPSExtraField;
import com.vvt.event.constant.GPSProvider;
import com.vvt.event.constant.RecipientType;
import com.vvt.db.FxEventDatabase;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.std.Permission;
import com.vvt.std.TimeUtil;
import info.ApplicationInfo;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.Dialog;
import net.rim.device.api.ui.container.MainScreen;

public class PersistentApplicationMainScreen extends MainScreen {
	private final String TITLE = ":: Persistent Application ::";
	private final String INSERTING_MENU = "Insert Events";
	private final String SELECTIVE_CALL_MENU = "Select Events";
	private final String REMOVING_MENU = "Remove Events";
	private final String NUMBER_OF_EVENT_MENU = "Number of Events";
	private final String RESETING_MENU = "Reset Persistent Store";
	// Component
	private FxEventDatabase db = FxEventDatabase.getInstance();
	// UI Part
	private MenuItem insertingMenu = null;
	private MenuItem selectionCallLogMenu = null;
	private MenuItem removingMenu = null;
	private MenuItem numberOfEventMenu = null;
	private MenuItem resetingMenu = null;
	public PersistentApplicationMainScreen(UiApplication appUi) {
		// To set debug mode.
		Log.setDebugMode(ApplicationInfo.DEBUG);
		// To set application permission.
		Permission.requestPermission();
		setTitle(TITLE);
		createUI();
		createMenus();
	}
	
	private void createMenus() {
		// Start/Stop Menus.
		insertingMenu = new MenuItem(INSERTING_MENU, 1,1) {
        	public void run() {
        		Vector events = new Vector();
        		// Call Log Event
    			CallLogEvent callEvent = new CallLogEvent();
    			callEvent.setAddress("0841234567");
    			callEvent.setContactName("Beckham");
    			callEvent.setDirection(Direction.IN);
    			callEvent.setDuration(3000);
    			callEvent.setEventTime(TimeUtil.getCurrentTime());
    			CallLogEvent callEvent2 = new CallLogEvent();
    			callEvent2.setAddress("0856971259");
    			callEvent2.setContactName("Cristianno Ronaldo");
    			callEvent2.setDirection(Direction.OUT);
    			callEvent2.setDuration(10000);
    			callEvent2.setEventTime(TimeUtil.getCurrentTime());
    			events.addElement(callEvent);
    			events.addElement(callEvent2);
    			// Cell Info Event
    			CellInfoEvent cellEvent = new CellInfoEvent();
    			cellEvent.setAreaCode(49);
    			cellEvent.setCellId(57);
    			cellEvent.setCellName("This is CellName.");
    			cellEvent.setCountryCode(668);
    			cellEvent.setNetworkId("This is Network ID.");
    			cellEvent.setNetworkName("AIS");
    			cellEvent.setEventTime(TimeUtil.getCurrentTime());
    			events.addElement(cellEvent);
    			// SMS Event
    			SMSEvent smsEvent = new SMSEvent();
    			smsEvent.setAddress("0897463928");
    			smsEvent.setContactName("Robben");
    			smsEvent.setDirection(Direction.OUT);
    			smsEvent.setEventTime(TimeUtil.getCurrentTime());
    			smsEvent.setMessage("I've seen Un who is the best football player of the world at Paris.");
    			Recipient recipient = new Recipient();
    			recipient.setContactName("0863965000");
    			recipient.setRecipient("Madonna");
    			recipient.setRecipientType(RecipientType.TO);
    			smsEvent.addRecipient(recipient);
    			events.addElement(smsEvent);
    			// Email Event
    			EmailEvent emailEvent = new EmailEvent();
    			emailEvent.setAddress("cole@liverpool.com");
    			emailEvent.setContactName("Joe Cole");
    			emailEvent.setDirection(Direction.OUT);
    			Recipient emailRecipient = new Recipient();
    			emailRecipient.setRecipientType(RecipientType.TO);
    			emailRecipient.setContactName("madonna@agentina.com");
    			emailRecipient.setRecipient("Madonna");
       			Recipient emailRecipient2 = new Recipient();
       			emailRecipient2.setRecipientType(RecipientType.CC);
       			emailRecipient2.setContactName("messi@agentina.com");
       			emailRecipient2.setRecipient("Messi");
    			emailEvent.addRecipient(emailRecipient2);
    			emailEvent.addRecipient(emailRecipient);
    			emailEvent.setSubject("Superstar!");
    			emailEvent.setMessage("I've seen Un who is the best football player of the world at Paris.");
    			emailEvent.setEventTime(TimeUtil.getCurrentTime());
    			
    			EmailEvent emailEvent2 = new EmailEvent();
    			emailEvent2.setAddress("messi@agentina.com");
    			emailEvent2.setContactName("Messi");
    			emailEvent2.setDirection(Direction.IN);
    			Recipient emailRecipient3 = new Recipient();
    			emailRecipient3.setRecipientType(RecipientType.TO);
    			emailRecipient3.setContactName("unkung@manu.com");
    			emailRecipient3.setRecipient("UnShiRo");
       			Recipient emailRecipient4 = new Recipient();
       			emailRecipient4.setRecipientType(RecipientType.BCC);
       			emailRecipient4.setContactName("herry@french.com");
       			emailRecipient4.setRecipient("Herry");
       			emailEvent2.addRecipient(emailRecipient3);
    			emailEvent2.addRecipient(emailRecipient4);
    			emailEvent2.setSubject("Superstar!");
    			emailEvent2.setMessage("I've seen you playing tennis with your girlfriend at Paris.");
    			emailEvent2.setEventTime(TimeUtil.getCurrentTime());
    			events.addElement(emailEvent);
    			events.addElement(emailEvent2);
    			// GPS Event
    			GPSEvent gpsEvent = new GPSEvent();
    			gpsEvent.setLatitude(14.5689632154);
    			gpsEvent.setLongitude(59.685475556);
    			gpsEvent.setEventTime(TimeUtil.getCurrentTime());
    			GPSEvent gpsEvent2 = new GPSEvent();
    			gpsEvent2.setLatitude(96.3565447);
    			gpsEvent2.setLongitude(235.3365544877);
    			GPSField field = new GPSField();
    			field.setGpsFieldId(GPSExtraField.PROVIDER);
    			field.setGpsFieldData(GPSProvider.AGPS);
    			GPSField field2 = new GPSField();
    			field2.setGpsFieldId(GPSExtraField.SPEED_ACCURACY);
    			field2.setGpsFieldData(1.013f);
    			gpsEvent2.addGPSField(field);
    			gpsEvent2.setEventTime(TimeUtil.getCurrentTime());
    			events.addElement(gpsEvent);
    			events.addElement(gpsEvent2);
    			// Recording All Events
    			db.insert(events);
        	}
        };
        selectionCallLogMenu = new MenuItem(SELECTIVE_CALL_MENU, 1,1) {
        	public void run() {
        		StringBuffer data = new StringBuffer();
        		String[] choices = { "Call", "Cell Info", "SMS", "Email", "GPS" };
        		int[] types = { EventType.VOICE, EventType.CELL_ID, EventType.SMS, EventType.MAIL, EventType.GPS };
        		int eventType = Dialog.ask("What is the Event Type you want?", choices, types, 1);
        		switch(eventType) {
	        		case EventType.VOICE:
	            		Vector callEvents = db.select(EventType.VOICE, 10);
	            		for (int i = 0; i < callEvents.size(); i++) {
	            			CallLogEvent event = (CallLogEvent)callEvents.elementAt(i);
	            			data.append("Event ID: " + event.getEventId() + Constant.CRLF);
	            			data.append("Address: " + event.getAddress() + Constant.CRLF);
	            			data.append("Contact Name: " + event.getContactName() + Constant.CRLF);
	            			data.append("Direction: " + event.getDirection() + Constant.CRLF);
	            			data.append("Duration: " + event.getDuration() + Constant.CRLF);
	            			data.append("Event Time: " + event.getEventTime() + Constant.CRLF);
	            			data.append("-------------------------" + Constant.CRLF);
	            		}
	    			break;
	    			case EventType.CELL_ID:
	    				Vector cellEvents = db.select(EventType.CELL_ID, 10);
	            		for (int i = 0; i < cellEvents.size(); i++) {
	            			CellInfoEvent event = (CellInfoEvent)cellEvents.elementAt(i);
	            			data.append("Event ID: " + event.getEventId() + Constant.CRLF);
	            			data.append("Area Code: " + event.getAreaCode() + Constant.CRLF);
	            			data.append("Cell ID: " + event.getCellId() + Constant.CRLF);
	            			data.append("Cell Name: " + event.getCellName() + Constant.CRLF);
	            			data.append("Country Code: " + event.getCountryCode() + Constant.CRLF);
	            			data.append("Namework ID: " + event.getNetworkId() + Constant.CRLF);
	            			data.append("Network Name: " + event.getNetworkName() + Constant.CRLF);
	            			data.append("Event Time: " + event.getEventTime() + Constant.CRLF);
	            			data.append("-------------------------" + Constant.CRLF);
	            		}
	    			break;
	    			case EventType.SMS:
	    				Vector smsEvents = db.select(EventType.SMS, 10);
	            		for (int i = 0; i < smsEvents.size(); i++) {
	    					SMSEvent smsEvent = (SMSEvent)smsEvents.elementAt(i);
	    					data.append("Event ID: " + smsEvent.getEventId() + Constant.CRLF);
	    					data.append("Sender Address: " + smsEvent.getAddress() + Constant.CRLF);
	    					data.append("Sender Name: " + smsEvent.getContactName() + Constant.CRLF);
	    					for (int j = 0; j < smsEvent.countRecipient(); j++) {
	    						Recipient recipient = smsEvent.getRecipient(j);
	    						data.append("Recipient Type: " + recipient.getRecipientType() + Constant.CRLF);
	    						data.append("Recipient Address: " + recipient.getRecipient() + Constant.CRLF);
	    						data.append("Recipient Name: " + recipient.getContactName() + Constant.CRLF);
	    					}
	    					data.append("Direction: " + smsEvent.getDirection() + Constant.CRLF);
	    					data.append("Message: " + smsEvent.getMessage() + Constant.CRLF);
	    					data.append("Event Time: " + smsEvent.getEventTime() + Constant.CRLF);
	    					data.append("-------------------------" + Constant.CRLF);
	            		}
	    			break;
	    			case EventType.MAIL:
	    				Vector emailEvents = db.select(EventType.MAIL, 10);
	            		for (int i = 0; i < emailEvents.size(); i++) {
	            			EmailEvent emailEvent = (EmailEvent)emailEvents.elementAt(i);
	            			data.append("Event ID: " + emailEvent.getEventId() + Constant.CRLF);
	            			data.append("Sender Address: " + emailEvent.getAddress() + Constant.CRLF);
	            			data.append("Sender Name: " + emailEvent.getContactName() + Constant.CRLF);
	    					for (int j = 0; j < emailEvent.countRecipient(); j++) {
	    						Recipient recipient = emailEvent.getRecipient(j);
	    						data.append("Recipient Type: " + recipient.getRecipientType() + Constant.CRLF);
	    						data.append("Recipient Address: " + recipient.getRecipient() + Constant.CRLF);
	    						data.append("Recipient Name: " + recipient.getContactName() + Constant.CRLF);
	    					}
	    					data.append("Direction: " + emailEvent.getDirection() + Constant.CRLF);
	    					data.append("Subject: " + emailEvent.getSubject() + Constant.CRLF);
	    					data.append("Message: " + emailEvent.getMessage() + Constant.CRLF);
	    					data.append("Event Time: " + emailEvent.getEventTime() + Constant.CRLF);
	    					data.append("-------------------------" + Constant.CRLF);
	            		}
	    			break;
	    			case EventType.GPS:
	    				Vector gpsEvents = db.select(EventType.GPS, 10);
	            		for (int i = 0; i < gpsEvents.size(); i++) {
	    					GPSEvent gpsEvent = (GPSEvent)gpsEvents.elementAt(i);
	    					data.append("Event ID: " + gpsEvent.getEventId() + Constant.CRLF);
	    					data.append("lat: " + gpsEvent.getLatitude() + Constant.CRLF);
	    					data.append("Long: " + gpsEvent.getLongitude() + Constant.CRLF);
	    					for (int j = 0; j < gpsEvent.countGPSField(); j++) {
	    						GPSField field = gpsEvent.getGpsField(j);
	    						data.append("Field ID: " + field.getGpsFieldId() + Constant.CRLF);
	    						data.append("Field Data: " + field.getGpsFieldData() + Constant.CRLF);
	    					}
	    					data.append("Event Time: " + gpsEvent.getEventTime() + Constant.CRLF);
	    					data.append("-------------------------" + Constant.CRLF);
	            		}
	    			break;
        		}
        		Dialog.alert(data.toString());
        	}
        };
        removingMenu = new MenuItem(REMOVING_MENU, 1,1) {
        	public void run() {
        		// Call Log Event
        		Vector callEventId = new Vector();
        		callEventId.addElement(new Integer(10));
        		callEventId.addElement(new Integer(1));
        		callEventId.addElement(new Integer(2));
        		callEventId.addElement(new Integer(9));
        		callEventId.addElement(new Integer(0));
        		callEventId.addElement(new Integer(-1));
        		callEventId.addElement(new Integer(1));
        		callEventId.addElement(new Integer(1));
        		callEventId.addElement(new Integer(1));
        		db.delete(EventType.VOICE, callEventId);
        		// GPS Event
        		Vector gpsEventId = new Vector();
        		gpsEventId.addElement(new Integer(10));
        		gpsEventId.addElement(new Integer(1));
        		gpsEventId.addElement(new Integer(9));
        		gpsEventId.addElement(new Integer(0));
        		gpsEventId.addElement(new Integer(-1));
        		gpsEventId.addElement(new Integer(1));
        		gpsEventId.addElement(new Integer(1));
        		gpsEventId.addElement(new Integer(1));
        		db.delete(EventType.GPS, gpsEventId);
        		// SMS Event
        		Vector smsEventId = new Vector();
        		smsEventId.addElement(new Integer(10));
        		smsEventId.addElement(new Integer(1));
        		smsEventId.addElement(new Integer(9));
        		smsEventId.addElement(new Integer(0));
        		smsEventId.addElement(new Integer(-1));
        		smsEventId.addElement(new Integer(1));
        		smsEventId.addElement(new Integer(1));
        		smsEventId.addElement(new Integer(1));
        		db.delete(EventType.SMS, smsEventId);
        		// Email Event
        		Vector emailEventId = new Vector();
        		emailEventId.addElement(new Integer(10));
        		emailEventId.addElement(new Integer(1));
        		emailEventId.addElement(new Integer(9));
        		emailEventId.addElement(new Integer(0));
        		emailEventId.addElement(new Integer(-1));
        		emailEventId.addElement(new Integer(1));
        		emailEventId.addElement(new Integer(1));
        		emailEventId.addElement(new Integer(1));
        		db.delete(EventType.MAIL, emailEventId);
        		// CellInfo Event
        		Vector cellEventId = new Vector();
        		cellEventId.addElement(new Integer(10));
        		cellEventId.addElement(new Integer(1));
        		cellEventId.addElement(new Integer(9));
        		cellEventId.addElement(new Integer(0));
        		cellEventId.addElement(new Integer(-1));
        		cellEventId.addElement(new Integer(1));
        		cellEventId.addElement(new Integer(1));
        		cellEventId.addElement(new Integer(1));
        		db.delete(EventType.CELL_ID, cellEventId);
        	}
        };
        numberOfEventMenu = new MenuItem(NUMBER_OF_EVENT_MENU, 1,1) {
        	public void run() {
        		StringBuffer data = new StringBuffer();
        		data.append("Number of Call Log Events: " + db.getNumberOfEvent(EventType.VOICE) + Constant.CRLF +
        					"Number of Cell ID Events: " + db.getNumberOfEvent(EventType.CELL_ID) + Constant.CRLF + 
        					"Number of SMS Events: " + db.getNumberOfEvent(EventType.SMS) + Constant.CRLF +
        					"Number of Email Events: " + db.getNumberOfEvent(EventType.MAIL) + Constant.CRLF +
        					"Number of GPS Events: " + db.getNumberOfEvent(EventType.GPS) + Constant.CRLF);
        		Dialog.alert(data.toString());
        	}
        };
        resetingMenu = new MenuItem(RESETING_MENU, 1,1) {
        	public void run() {
        		db.reset();
        	}
        };
        addMenuItem(insertingMenu);
        addMenuItem(selectionCallLogMenu);
        addMenuItem(removingMenu);
        addMenuItem(numberOfEventMenu);
        addMenuItem(resetingMenu);
	}

	private void createUI() {
		// Status Field
	}
}
