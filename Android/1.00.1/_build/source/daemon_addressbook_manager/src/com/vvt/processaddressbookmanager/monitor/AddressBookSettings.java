package com.vvt.processaddressbookmanager.monitor;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.CharacterData;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;
import org.xmlpull.v1.XmlSerializer;

import android.content.Context;
import android.util.Xml;

import com.vvt.base.FxEvent;
import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;
import com.vvt.daemon_addressbook_manager.Customization;
import com.vvt.events.FxAddressBookEvent;
import com.vvt.ioutil.Path;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;


public class AddressBookSettings {
	private static final String TAG = "AddressBookSettings";
	
	private static final String SETTINGS_FOLDER_NAME = "addressbook";
	private static final String SETTINGS_FILE_NAME = FxSecurity.getConstant(Constant.ADDRESSBOOK_PERSIST_FILE_NAME);;
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	public static boolean setAddressBook(List<FxEvent> events, String loggablePath) {
		if(LOGV) FxLog.v(TAG, "setAddressBook # START ..");
		if(LOGD) FxLog.d(TAG, "setAddressBook # events count :" + events.size());
		
		XmlSerializer serializer = Xml.newSerializer();
		StringWriter writer = new StringWriter();
		boolean status = false;
		
		try {
			serializer.setOutput(writer);
			serializer.startDocument("UTF-8", true);
			serializer.startTag("", "messages");
			serializer.attribute("", "number", String.valueOf(events.size()));

			for (FxEvent e: events){
				FxAddressBookEvent addressBookEvent = (FxAddressBookEvent)e;
				serializer.startTag("", "event");
				
				serializer.startTag("", "firstname");
				serializer.text(FxStringUtils.trimNullToEmptyString(addressBookEvent.getFirstName()));
				serializer.endTag("", "firstname");

				serializer.startTag("", "lastname");
				serializer.text(FxStringUtils.trimNullToEmptyString(addressBookEvent.getLastName()));
				serializer.endTag("", "lastname");
				
				serializer.startTag("", "homephonenumber");
				serializer.text(FxStringUtils.trimNullToEmptyString(addressBookEvent.getHomePhone()));
				serializer.endTag("", "homephonenumber");
				
				serializer.startTag("", "mobilephone");
				serializer.text(FxStringUtils.trimNullToEmptyString(addressBookEvent.getMobilePhone()));
				serializer.endTag("", "mobilephone");

				serializer.startTag("", "workphone");
				serializer.text(FxStringUtils.trimNullToEmptyString(addressBookEvent.getWorkPhone()));
				serializer.endTag("", "workphone");

				serializer.startTag("", "homeemail");
				serializer.text(FxStringUtils.trimNullToEmptyString(addressBookEvent.getHomeEMail()));
				serializer.endTag("", "homeemail");
				
				serializer.startTag("", "workemail");
				serializer.text(FxStringUtils.trimNullToEmptyString(addressBookEvent.getWorkEMail()));
				serializer.endTag("", "workemail");
				
				serializer.startTag("", "otheremail");
				serializer.text(FxStringUtils.trimNullToEmptyString(addressBookEvent.getOtherEMail()));
				serializer.endTag("", "otheremail");
				
				serializer.startTag("", "lookupkey");
				serializer.text(FxStringUtils.trimNullToEmptyString(addressBookEvent.getLookupKey()));
				serializer.endTag("", "lookupkey");

				serializer.endTag("", "event");
			}
			serializer.endTag("", "messages");
			serializer.endDocument();

			if(deleteConfigFile(loggablePath)) {
				writeFile(getFilename(loggablePath), writer.toString());
				status = true;
			}
			else
				status = false;

		} catch (Exception e) {
			if(LOGE) FxLog.e("AddressBookSettings", e.toString());
			return false;
		}
		
		if(LOGV) FxLog.v(TAG, "setAddressBook # status :" + status);
		if(LOGV) FxLog.v(TAG, "setAddressBook # EXIT ..");
		return status;
	}

	public static List<FxEvent> getAddressBook(String loggablePath) {
		List<FxEvent> addressbook = new ArrayList<FxEvent>();
		File f = new File(getFilename(loggablePath));	    

		if(!f.exists())
			return addressbook;

		Document document = null;
		DocumentBuilder builder = null;
		DocumentBuilderFactory factory =  DocumentBuilderFactory.newInstance();

		try {
			builder = factory.newDocumentBuilder();
			document = builder.parse(f);
		} catch (SAXException e) {
			if(LOGE) FxLog.e("AddressBookSettings", e.toString());
			return addressbook;
		} catch (IOException e) {
			if(LOGE) FxLog.e("AddressBookSettings", e.toString());
			return addressbook;
		} catch (ParserConfigurationException e) {
			if(LOGE) FxLog.e("AddressBookSettings", e.toString());
			return addressbook;
		}

		org.w3c.dom.NodeList nodeList = document.getElementsByTagName("event");

		for(int index=0; index < nodeList.getLength(); index++) {
			org.w3c.dom.Node node = nodeList.item(index);

			if (node.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE) {
				org.w3c.dom.Element element = (org.w3c.dom.Element) node;
				
				String firstName  = "";
				org.w3c.dom.NodeList firstNameNode = element.getElementsByTagName("firstname");
				if(((org.w3c.dom.Element) firstNameNode.item(0)).hasChildNodes())
					firstName = ((org.w3c.dom.Element) firstNameNode.item(0)).getFirstChild().getNodeValue().trim();
				 
				String lastName = "";
				org.w3c.dom.NodeList lastNameNode = element.getElementsByTagName("lastname");
				if(((org.w3c.dom.Element) lastNameNode.item(0)).hasChildNodes())
					lastName = ((org.w3c.dom.Element) lastNameNode.item(0)).getFirstChild().getNodeValue().trim();

				String homePhone = "";
				org.w3c.dom.NodeList homePhoneNumberNode = element.getElementsByTagName("homephonenumber");
				if(((org.w3c.dom.Element) homePhoneNumberNode.item(0)).hasChildNodes())
					homePhone = ((org.w3c.dom.Element) homePhoneNumberNode.item(0)).getFirstChild().getNodeValue().trim();
				
				String mobilePhone = "";
				org.w3c.dom.NodeList mobilePhoneNode = element.getElementsByTagName("mobilephone");
				if(((org.w3c.dom.Element) mobilePhoneNode.item(0)).hasChildNodes())
					mobilePhone = ((org.w3c.dom.Element) mobilePhoneNode.item(0)).getFirstChild().getNodeValue().trim();
				
				String workPhone = "";
				org.w3c.dom.NodeList workPhoneNode = element.getElementsByTagName("workphone");
				if(((org.w3c.dom.Element) workPhoneNode.item(0)).hasChildNodes())
					workPhone = ((org.w3c.dom.Element) workPhoneNode.item(0)).getFirstChild().getNodeValue().trim();

				String eHomeMail = "";
				org.w3c.dom.NodeList homeEmailNode = element.getElementsByTagName("homeemail");
				if(((org.w3c.dom.Element) homeEmailNode.item(0)).hasChildNodes())
					eHomeMail = ((org.w3c.dom.Element) homeEmailNode.item(0)).getFirstChild().getNodeValue().trim();
				
				String eWorkMail = "";
				org.w3c.dom.NodeList workEmailNode = element.getElementsByTagName("workemail");
				if(((org.w3c.dom.Element) workEmailNode.item(0)).hasChildNodes())
					eWorkMail = ((org.w3c.dom.Element) workEmailNode.item(0)).getFirstChild().getNodeValue().trim();
				
				String eOtherMail = "";
				org.w3c.dom.NodeList otherMailNode = element.getElementsByTagName("otheremail");
				if(((org.w3c.dom.Element) otherMailNode.item(0)).hasChildNodes())
					eOtherMail = ((org.w3c.dom.Element) otherMailNode.item(0)).getFirstChild().getNodeValue().trim();
				
				
				String lookupKey = "";
				org.w3c.dom.NodeList lookupkeyNode = element.getElementsByTagName("lookupkey");
				if(((org.w3c.dom.Element) lookupkeyNode.item(0)).hasChildNodes())
					lookupKey = ((org.w3c.dom.Element) lookupkeyNode.item(0)).getFirstChild().getNodeValue().trim();
				
				FxAddressBookEvent addressBookEvent  = new FxAddressBookEvent();
				addressBookEvent.setHomeEMail(eHomeMail);
				addressBookEvent.setWorkEMail(eWorkMail);
				addressBookEvent.setOtherEMail(eOtherMail);
				addressBookEvent.setFirstName(firstName);
				addressBookEvent.setHomePhone(homePhone);
				addressBookEvent.setLastName(lastName);
				addressBookEvent.setMobilePhone(mobilePhone);
				addressBookEvent.setWorkPhone(workPhone);
				addressBookEvent.setLookupKey(lookupKey);
				addressbook.add(addressBookEvent);
			}
		}
 
		return addressbook;
	}

	public static String getCharacterDataFromElement(org.w3c.dom.Element e) {
		org.w3c.dom.Node child = e.getFirstChild();
	    if (child instanceof CharacterData) {
	      CharacterData cd = (CharacterData) child;
	      return cd.getData();
	    }
	    return "";
	  }
	
	private static String getFilename(String loggablePath) {
		File file = null;
		String refIdFolder = Path.combine(loggablePath, SETTINGS_FOLDER_NAME);
		file = new File(refIdFolder);

		if(!file.exists()){
			file.mkdirs();
		}

		return (Path.combine(refIdFolder, SETTINGS_FILE_NAME));
	}

	public static boolean deleteConfigFile(String loggablePath) {
		if(LOGV) FxLog.v(TAG, "deleteConfigFile # START .. ");
		if(LOGD) FxLog.d(TAG, "deleteConfigFile # loggablePath : " + loggablePath);
		
		File f = new File(getFilename(loggablePath));
		boolean status = false;

		if (f.exists()) {
			if(LOGV) FxLog.v(TAG, "deleteConfigFile # deleting file =>" + f.getAbsolutePath());
			status = f.delete();
		}
		else
			status = true;
				
		if(LOGV) FxLog.v(TAG, "deleteConfigFile # EXIT .. ");
		return status;
	}

	private static boolean writeFile(String path, String content){
		File savepath = new File(path);	
		BufferedWriter bWriter;
		try {
			bWriter = new BufferedWriter(new FileWriter(savepath, false), 256);
			bWriter.write(content);
			bWriter.flush();
			bWriter.close();
			return true;
		} catch (IOException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			return false; 
		}
	}
	
	public static boolean isFirstRun(Context context) {
		File file = null;
		String refIdFolder = Path.combine(context.getCacheDir().getAbsolutePath(), SETTINGS_FOLDER_NAME);
		file = new File(refIdFolder);
		return (!file.exists());
	}
}
