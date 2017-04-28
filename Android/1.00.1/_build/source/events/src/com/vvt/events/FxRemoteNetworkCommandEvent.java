	
package com.vvt.events;

import java.util.ArrayList;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 03:27:36
 */
public class FxRemoteNetworkCommandEvent extends FxEvent {

	private int m_PccCode;
	private ArrayList<String> m_ArgumentList;

	public FxRemoteNetworkCommandEvent()
	{
		m_ArgumentList = new ArrayList<String>();
	}
	
	@Override
	public FxEventType getEventType(){
		return FxEventType.NETWORK_REMOTE_COMMAND;
	}
	
 	/**
	 * 
	 * @param pccCode    pccCode
	 */
	public void setPccCode(int pccCode){
		m_PccCode = pccCode;
	}

	public int getPccCode(){
		return m_PccCode;
	}

 	public int getArgumentCount(){
		return m_ArgumentList.size();
	}
	
	public String getArgument(int index){
		return m_ArgumentList.get(index);
	}
	
	public void addArgument(String arg){
		m_ArgumentList.add(arg);
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		
		builder.append("FxRemoteNetworkCommandEvent {");
		builder.append(" pccCode =").append(getPccCode());
		builder.append(", Arguments =");
		
		for(int i=0; i < getArgumentCount(); i++) {
			String arg = getArgument(i);
			builder.append("Argument " + i).append(" - ").append("Value:").append(arg);
			builder.append("\n");
		}
		
		
		return builder.append(" }").toString();
	}
}