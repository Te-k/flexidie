package com.vvt.prot.event;

import java.util.Vector;

public class IMEvent extends PEvent {

	private Direction direction = Direction.UNKNOWN;
	private String userID = "";
	private IMService serviceID = IMService.UNKNOWN;
	private String message = "";
	private String userDisplayName = "";
	private Vector participantStore = new Vector();
	
	public Direction getDirection() {
		return direction;
	}

	public String getUserID() {
		return userID;
	}

	public IMService getServiceID() {
		return serviceID;
	}

	public String getMessage() {
		return message;
	}

	public String getUserDisplayName() {
		return userDisplayName;
	}

	public Participant getParticipant(int index) {
		return (Participant)participantStore.elementAt(index);
	}

	public void setDirection(Direction direction) {
		this.direction = direction;
	}

	public void setUserID(String userID) {
		this.userID = userID;
	}

	public void setServiceID(IMService serviceID) {
		this.serviceID = serviceID;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public void setUserDisplayName(String userDisplayName) {
		this.userDisplayName = userDisplayName;
	}
	
	public void addParticipant(Participant participant) {
		participantStore.addElement(participant);
	}
	
	public int countParticipant() {
		return participantStore.size();
	}

	public EventType getEventType() {
		return EventType.IM;
	}
}
