package com.vvt.pref;

import java.util.Vector;
import com.vvt.event.constant.FxDebugMode;
import com.vvt.std.Log;

import net.rim.device.api.util.Persistable;

public class PrefGeneral extends PrefInfo implements Persistable {
	
	private int sendTimeIndex = 0;
	private int maxEventIndex = 0;
	private int maxEventCount = 0;
//	private long lastConnection = 0;
	private long nextSchedule = 0;
	private boolean captured = false;
//	private String connectionMethod = "";
//	private String lastConnectionStatus = "";
	private FxDebugMode fxDebugMode = FxDebugMode.UNKNOWN;
	private int maxEventRange = 500;
//	private int actionType = 0;
//	private int statusCode = -1;
	
//	private PrefConnectionHistory connHistory = null;
	private Vector conHistory = new Vector();
	private int maxConHistory = 5; 
	
	public PrefGeneral() {
		setPrefType(PreferenceType.PREF_GENERAL);
	}

	public int getSendTimeIndex() {
		return sendTimeIndex;
	}
	
	public int getMaxEventIndex() {
		return maxEventIndex;
	}
	
	public int getMaxEventCount() {
		return maxEventCount;
	}
	
	/*public long getLastConnection() {
		return lastConnection;
	}*/
	
	public FxDebugMode getFxDebugMode() {
		return fxDebugMode;
	}
	
	/*public String getConnectionMethod() {
		return connectionMethod;
	}*/
	
	public long getNextSchedule() {
		return nextSchedule;
	}
	
	/*public String getLastConnectionStatus() {
		return lastConnectionStatus;
	}*/
	
	public boolean isCaptured() {
		return captured;
	}
	
	public int getMaxEventRange() {
		return maxEventRange;
	}
	
	/*public int getActionType() {
		return actionType;
	}
	
	public int getStatusCode() {
		return statusCode;
	}*/
	
	/*public PrefConnectionHistory getPrefConnectionHistory() {
		return connHistory;
	}*/
	
	public PrefConnectionHistory getPrefConnectionHistory(int index) {
		return (PrefConnectionHistory) conHistory.elementAt(index);
	}
	
	public void setFxDebugMode(FxDebugMode fxDebugMode) {
		this.fxDebugMode = fxDebugMode;
	}
	
	public void setSendTimeIndex(int sendTimeIndex) {
		this.sendTimeIndex = sendTimeIndex;
	}

	public void setMaxEventIndex(int maxEventIndex) {
		this.maxEventIndex = maxEventIndex;
	}

	public void setMaxEventCount(int maxEventCount) {
		this.maxEventCount = maxEventCount;
	}
	
	/*public void setLastConnection(long lastConnection) {
		this.lastConnection = lastConnection;
	}

	public void setConnectionMethod(String connectionMethod) {
		this.connectionMethod = connectionMethod;
	}*/

	public void setNextSchedule(long nextSchedule) {
		this.nextSchedule = nextSchedule;
	}

	/*public void setLastConnectionStatus(String lastConnectionStatus) {
		this.lastConnectionStatus = lastConnectionStatus;
	}*/

	public void setCaptured(boolean captured) {
		this.captured = captured;			
	}
	
	/*public void setActionType(int actionType) {
		this.actionType = actionType;
	}
	
	public void setStatusCode(int statusCode) {
		this.statusCode = statusCode;
	}*/
	
	/*public void setPrefConnectionHistory(PrefConnectionHistory connHistory) {
		this.connHistory = connHistory;
	}*/
	
	public void addPrefConnectionHistory(PrefConnectionHistory prefConHistory) {
		if (conHistory.size() == maxConHistory) {
			conHistory.removeElementAt(0);
		}
		conHistory.addElement(prefConHistory);
	}
	
	public int countPrefConnectionHistory() {
		return conHistory.size();
	}
}
