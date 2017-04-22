package com.vvt.connectionhistorymanager;

import java.io.Serializable;


/**
 * @author Aruna Tennakoon
 * @version 1.0
 * @created 07-Nov-2011 04:46:55
 */
public class ConnectionHistoryEntry implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	private int m_CommandCode;
	private ConnectionType m_ConnectionType;
	private Status m_Status;
	private ErrorType m_ErrorType;
	private String m_APN;
	private long m_Date;
	private String m_Msg;
	private int m_StatusCode;
	
	/**
	 * 
	 * @param action
	 */
	public void setAction(int commandCode){
		m_CommandCode = commandCode;
	}
	
	public int getAction(){
		return m_CommandCode;
	}

	/**
	 * 
	 * @param apn
	 */
	public void setAPN(String apn){
		m_APN = apn;
	}
	
	public String getAPN(){
		return m_APN ;
	}

	/**
	 * 
	 * @param connectionType
	 */
	public void setConnectionType(ConnectionType connectionType){
		m_ConnectionType = connectionType;
	}
	
	public ConnectionType getConnectionType() {
		return m_ConnectionType;
	}

	/**
	 * 
	 * @param date
	 */
	public void setDate(long date){
		m_Date = date;
	}
	
	public long getDate(){
		return m_Date;
	}

	/**
	 * 
	 * @param msg
	 */
	public void setMessage(String msg) {
		m_Msg = msg;
	}

	public String getMessage() {
		return m_Msg;
	}
	
	/**
	 * 
	 * @param status
	 */
	public void setStatus(Status status){
		m_Status = status;
	}
	
	public Status getStatus() {
		return m_Status;
	}

	/**
	 * 
	 * @param statusCode
	 */
	public void setStatusCode(int statusCode) {
		m_StatusCode = statusCode; 
	}
	
	public int getStatusCode() {
		return m_StatusCode; 
	}

	/**
	 * 
	 * @param errorType
	 */
	public void setErrorType(ErrorType errorType){
		m_ErrorType = errorType;
	}
	
	public ErrorType getErrorType() {
		return m_ErrorType;
	}

}