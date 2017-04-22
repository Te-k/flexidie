package com.vvt.bbm;

import java.util.Enumeration;
import java.util.Vector;
import net.rim.device.api.util.Persistable;

public class Conversations implements Persistable {

	public 	static	long tooOld			= 2*24*3600*1000; 
	private String 	PIN 				= "";
	private String 	ownerDisplayName	= "";
	private int	 	hashCode 			= 0;
	private Vector	participants		= new Vector();
	private Vector	lastParticipants	= new Vector();
	private long	lastUpdate			= 0;
	private Vector	lastConversations	= new Vector();
	private boolean	isConference		= false;

	public Conversations(String pin, int code)	{
		lastUpdate	= System.currentTimeMillis();
		PIN 		= pin;
		updateHashcode(code);
	}

	public void updateHashcode(int code)	{
		hashCode = code;
	}
	
	public String getPIN()	{
		return PIN;
	}

	public int getHashcode()	{
		return hashCode;
	}

	public boolean isPIN(String pin)	{
		return PIN.equals(pin);
	}

	public boolean isHashCode(int code)	{
		return hashCode == code;
	}

	public void setOwnerDisplayName(String name)	{
		ownerDisplayName = name;
	}
	
	public String getOwnerDisplayName()	{
		return ownerDisplayName;
	}

	public boolean isSameParticipants(Vector participantName)	{
		boolean same  = (lastParticipants.size() == participantName.size());
		Enumeration e = participantName.elements();
		while (e.hasMoreElements())	{
			String name = (String) e.nextElement();
			if (!lastParticipants.contains(name))	{
				same = false;
			}
		}
		return same;
	}

	public void updateMaxParticipants(Vector participantName)	{
		lastParticipants.removeAllElements();
		Enumeration e = participantName.elements();
		while (e.hasMoreElements())	{
			String name = (String) e.nextElement();
			if (!participants.contains(name))	{
				participants.addElement(name);
			}
			lastParticipants.addElement(name);
		}
	}

	public Vector getMaximumParticipants()	{
		return participants;
	}
	
	public boolean isTooOld()	{
		long now	= System.currentTimeMillis();
		if (now-lastUpdate>tooOld)	{
			return true;
		}
		return false;
	}
	
	public Vector getLastConversations()	{
		return lastConversations;
	}
	
	public void updateStatusToConferenceChat()	{
		isConference	= true;
		PIN 			= "";
	}

	public boolean isConferenceChat()	{
		return isConference;
	}
	
	public void updateSentences(Vector text)	{
		lastConversations 	= text;
		lastUpdate			= System.currentTimeMillis();
	}
	
}
