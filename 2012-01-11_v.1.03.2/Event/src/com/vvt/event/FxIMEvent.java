package com.vvt.event;

import java.util.Vector;
import com.vvt.event.constant.FxDirection;
import com.vvt.event.constant.EventType;
import com.vvt.event.constant.FxIMService;
import net.rim.device.api.util.Persistable;

public class FxIMEvent extends FxEvent implements Persistable {

	private FxDirection direction = FxDirection.UNKNOWN;
	private String userID = "";
	private FxIMService serviceID = null;
	private String message = "";
	private String userDisplayName = "";
	private Vector participantStore = new Vector();
	
	public FxIMEvent() {
		setEventType(EventType.IM);
	}
	
	public FxDirection getDirection() {
		return direction;
	}

	public String getUserID() {
		return userID;
	}

	public FxIMService getServiceID() {
		return serviceID;
	}

	public String getMessage() {
		return message;
	}

	public String getUserDisplayName() {
		return userDisplayName;
	}

	public FxParticipant getParticipant(int index) {
		return (FxParticipant)participantStore.elementAt(index);
	}

	public void setDirection(FxDirection direction) {
		this.direction = direction;
	}

	public void setUserID(String userID) {
		this.userID = userID;
	}

	public void setServiceID(FxIMService serviceID) {
		this.serviceID = serviceID;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public void setUserDisplayName(String userDisplayName) {
		this.userDisplayName = userDisplayName;
	}
	
	public void addParticipant(FxParticipant participant) {
		participantStore.addElement(participant);
	}
	
	public int countParticipant() {
		return participantStore.size();
	}
	
	public long getObjectSize() {
		long size = super.getObjectSize();
		size += 4; // direction
		size += serviceID.getId().getBytes().length; // serviceID
		size += userID.getBytes().length; // userID
		size += message.getBytes().length; // message
		size += userDisplayName.getBytes().length; // userDisplayName
		for (int i = 0; i < countParticipant(); i++) {
			FxParticipant rep = getParticipant(i);
			size += rep.getName().getBytes().length; // Name
			size += rep.getUid().getBytes().length; // UID
		}
		return size;
	}
}
