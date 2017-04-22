package com.vvt.bbm;

import java.util.Vector;

public class Conversation {

	// Log Event Direction 
	public final static int UNKNOWN 	= 0;
	public final static int RECEIVED	= 1;	// in
	public final static int SENT 	 	= 2;	// out

	private	int		direction	= UNKNOWN;
	private String 	owner;
	private String 	talker;
	private String 	txt;
	private Vector 	participants;
	private Vector 	PINs;
	private long	captureTime;
	private boolean conferenceChat = false;

	public Conversation(String _owner, String _speaker, Vector _participants, Vector _pins, String _txt)	{
		owner			= _owner;
		participants 	= _participants;
		PINs			= _pins;
		talker			= _speaker;
		txt 			= _txt;
		captureTime 	= System.currentTimeMillis();
		conferenceChat 	= false;
		if (participants.size()>2)	{
			conferenceChat = true;
		}
	}

	public void setDirection(int dir)	{
		if (dir>=UNKNOWN && dir <= SENT){
			direction = dir;
		}
		else {
			direction = UNKNOWN;
		}
	}

	public String getOwnerDisplayName()	{
		return owner;
	}

	public int getDirection()	{
		return direction;
	}
	
	public String getContent()	{
		return txt;
	}
	
	public Vector getParticipants()	{
		return participants;
	}

	public Vector getPINs()	{
		return PINs;
	}
	
	/*
	public String getPINs()	{
		if (PINs.size()>0)	{
			StringBuffer tmp = new StringBuffer();
			for (int i=0; i<PINs.size(); i++)	{
				if (i>0) {
					tmp.append(",");
				}
				tmp.append(PINs.elementAt(i).toString());
			}
			return tmp.toString();
		}
		return "";
	}*/
	
	public long getCaptureTime()	{
		return captureTime;
	}
	
	public String getSender()	{
		return talker;
	}
	
	private String getParticipantStr()	{
		StringBuffer tmp = new StringBuffer();
		for (int i=0; i<participants.size(); i++)	{
			String man = (String) participants.elementAt(i);
			if (i>0)	tmp.append(",");
			tmp.append(man);
		}
		return tmp.toString();
	} 
	
	private String getPinStr()	{
		StringBuffer tmp = new StringBuffer();
		for (int i=0; i<PINs.size(); i++)	{
			String man = (String) PINs.elementAt(i);
			if (i>0)	tmp.append(";");
			tmp.append(man);
		}
		return tmp.toString();
	}

	public String toString()	{
		String dirStr = "--";
		if (getDirection() == SENT)	{
			dirStr = "->";
		}
		if  (getDirection() == RECEIVED)	{
			dirStr = "<-";
		}
		return getSender()+dirStr+"("+getOwnerDisplayName()+"["+getPinStr()+"],"+
			   getParticipantStr()+"):"+getContent()+"\n-------------";
	}
	
	public boolean isConferenceChat()	{
		return conferenceChat;
	}
}
