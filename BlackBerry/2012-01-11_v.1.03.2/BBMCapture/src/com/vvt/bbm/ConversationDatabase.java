package com.vvt.bbm;

import java.util.Enumeration;
import java.util.Vector;


import net.rim.device.api.util.Persistable;

public class ConversationDatabase implements Persistable {
	
	private Vector conversations = new Vector();
	
	public boolean containsPIN(String pin)	{
		Enumeration convs = conversations.elements();
		while (convs.hasMoreElements())	{
			Conversations conv = (Conversations) convs.nextElement();
			if (conv.isPIN(pin))	{
				return true;
			}
		}
		return false;
	}

	public boolean containsHashCode(int hashCode)	{
		Enumeration convs = conversations.elements();
		while (convs.hasMoreElements())	{
			Conversations conv = (Conversations) convs.nextElement();
			if (conv.isHashCode(hashCode))	{
				return true;
			}
		}
		return false;
	}
	
	public Conversations get(String pin)	{
		Enumeration convs = conversations.elements();
		while (convs.hasMoreElements())	{
			Conversations conv = (Conversations) convs.nextElement();
			if (conv.isPIN(pin))	{
				return conv;
			}
		}
		return null;
	}

	public Conversations get(int hashCode)	{
		Enumeration convs = conversations.elements();
		while (convs.hasMoreElements())	{
			Conversations conv = (Conversations) convs.nextElement();
			if (conv.isHashCode(hashCode))	{
				return conv;
			}
		}
		return null;
	}
	
	public Vector findConversationByParticipant(Vector participants)	{
		Vector cons = new Vector();
		Enumeration convs = conversations.elements();
		while (convs.hasMoreElements())	{
			Conversations conv = (Conversations) convs.nextElement();
			if (conv.isSameParticipants(participants))	{
				cons.addElement(conv);
			}
		}
		return cons;
	}
	
	public void clear() {
		conversations.removeAllElements();
	}
	
	public void add(Conversations conv)	{
		conversations.addElement(conv);
	}

	public void cleanOldConferences()	{
		Vector 		temp 	= new Vector();
		Enumeration convs 	= conversations.elements();
		while (convs.hasMoreElements())	{
			Conversations conv = (Conversations) convs.nextElement();
			if (conv.isConferenceChat())	{
				temp.addElement(conv);
			}
		}
		for (int i=0; i<temp.size(); i++)	{
			conversations.removeElement((Conversations) temp.elementAt(i));
		}
		temp.removeAllElements();
	}
	
	public int size()	{
		return conversations.size();
	}

}
