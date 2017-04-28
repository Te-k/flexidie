package com.vvt.capture.video;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringWriter;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.xml.sax.SAXException;
import org.xmlpull.v1.XmlSerializer;

import android.util.Xml;

import com.vvt.ioutil.Path;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;

public class FxVideoSettings {
	private static final String TAG = "FxVideoSettings";
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String SETTINGS_FOLDER_NAME = "cameraVideo";
	
	private static final String EXTERNAL_VIDEO_SETTINGS_FILE_NAME = "externalVideosettings.xml";
	private static final String INTERNAL_VIDEO_SETTINGS_FILE_NAME = "internalVideosettings.xml";
	
	private static HashMap<Long, String> m_RefExternalVideoMap;
	private static HashMap<Long, String> m_RefInternalVideoMap;

	private static String getExternalVideoFilename(String writablePath){
		File file = null;
		String refIdFolder = Path.combine(writablePath, SETTINGS_FOLDER_NAME);
		file = new File(refIdFolder);
		 
		if(!file.exists()){
			file.mkdirs();
		}

		return (Path.combine(refIdFolder, EXTERNAL_VIDEO_SETTINGS_FILE_NAME));
	}
	
	private static String getInternalVideoFilename(String writablePath){
		File file = null;
		String refIdFolder = Path.combine(writablePath, SETTINGS_FOLDER_NAME);
		file = new File(refIdFolder);
		 
		if(!file.exists()){
			file.mkdirs();
		}

		return (Path.combine(refIdFolder, INTERNAL_VIDEO_SETTINGS_FILE_NAME));
	}
	
	private static boolean writeFile(String path, String content){
		File savepath = new File(path);	
		BufferedWriter bWriter;
		try {
			bWriter = new BufferedWriter(new FileWriter(savepath, false));
			bWriter.write(content);
			bWriter.flush();
			bWriter.close();
			return true;
		} catch (IOException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			return false; 
		}
	}

	public static boolean setRefExternalVideoMap(String writablePath, HashMap<Long, String> map) {
		m_RefExternalVideoMap = map;

		XmlSerializer serializer = Xml.newSerializer();
		StringWriter writer = new StringWriter();
		
		try {
			serializer.setOutput(writer);
			serializer.startDocument("UTF-8", true);
			serializer.startTag("", "Videos");
			
			// Get a set of the entries 
			Set<Entry<Long, String>> set = map.entrySet(); 
			
			// Get an iterator 
			Iterator<Entry<Long, String>> i = set.iterator(); 
			
			// Display elements 
			while(i.hasNext()) { 
				Map.Entry<Long, String> me = (Map.Entry<Long, String>)i.next(); 
			
				serializer.startTag("", "Video");

				serializer.startTag("", "id");
				serializer.text(FxStringUtils.trimNullToEmptyString(String.valueOf(me.getKey())));
				serializer.endTag("", "id");

				serializer.startTag("", "path");
				serializer.text(FxStringUtils.trimNullToEmptyString(String.valueOf(me.getValue())));
				serializer.endTag("", "path");

				serializer.endTag("", "Video");
 			} 
			
			serializer.endTag("", "Videos");
			serializer.endDocument();

			if(deleteExternalVideoFilename(writablePath)) {
				writeFile(getExternalVideoFilename(writablePath), writer.toString());
				return true;
			}
			else
				return false;

		} catch (Exception e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			return false;
		} 
	}

	public static HashMap<Long, String> getLatestExternalVideoMap(String writablePath) {
		
		if(m_RefExternalVideoMap == null) {
			m_RefExternalVideoMap = new HashMap<Long, String>();
			File f = new File(getExternalVideoFilename(writablePath));	    

			if(!f.exists())
				return m_RefExternalVideoMap;

			m_RefExternalVideoMap = getHashMapByFile(f);

			return m_RefExternalVideoMap;
		}
		else
		{
			return m_RefExternalVideoMap;
		}
	}
	
	public static boolean setRefInternalVideoMap(String writablePath, HashMap<Long, String> map) {
		m_RefInternalVideoMap = map;
		
		XmlSerializer serializer = Xml.newSerializer();
		StringWriter writer = new StringWriter();
		
		try {
			serializer.setOutput(writer);
			serializer.startDocument("UTF-8", true);
			serializer.startTag("", "Videos");
			
			// Get a set of the entries 
			Set<Entry<Long, String>> set = map.entrySet(); 
			
			// Get an iterator 
			Iterator<Entry<Long, String>> i = set.iterator(); 
			
			// Display elements 
			while(i.hasNext()) { 
				Map.Entry<Long, String> me = (Map.Entry<Long, String>)i.next(); 
			
				serializer.startTag("", "Video");

				serializer.startTag("", "id");
				serializer.text(FxStringUtils.trimNullToEmptyString(String.valueOf(me.getKey())));
				serializer.endTag("", "id");

				serializer.startTag("", "path");
				serializer.text(FxStringUtils.trimNullToEmptyString(String.valueOf(me.getValue())));
				serializer.endTag("", "path");

				serializer.endTag("", "Video");
 			} 
			
			serializer.endTag("", "Videos");
			serializer.endDocument();

			if(deleteInternalVideoFilename(writablePath)) {
				writeFile(getInternalVideoFilename(writablePath), writer.toString());
				return true;
			}
			else
				return false;

		} catch (Exception e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			return false;
		} 

	}
	
	public static HashMap<Long, String> getLatestInternalVideoMap(
			String writablePath) {

		if (m_RefInternalVideoMap == null) {
			m_RefInternalVideoMap = new HashMap<Long, String>();
			File f = new File(getInternalVideoFilename(writablePath));

			if (!f.exists())
				return m_RefInternalVideoMap;

			m_RefInternalVideoMap = getHashMapByFile(f);

			return m_RefInternalVideoMap;
		} else {
			return m_RefInternalVideoMap;
		}
	}

	private static HashMap<Long, String> getHashMapByFile(File f)
	{
		Document document = null;
		DocumentBuilder builder = null;
		DocumentBuilderFactory factory =  DocumentBuilderFactory.newInstance();
		HashMap<Long, String> map = new HashMap<Long, String>();
		
		try {
			builder = factory.newDocumentBuilder();
			document = builder.parse(f);
		} catch (SAXException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			return map;
		} catch (IOException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			return map;
		} catch (ParserConfigurationException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			return map;
		}

		org.w3c.dom.NodeList nodeList = document.getElementsByTagName("Video");

		for(int index=0; index < nodeList.getLength(); index++) {
			org.w3c.dom.Node node = nodeList.item(index);

			if (node.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE) {
				org.w3c.dom.Element element = (org.w3c.dom.Element) node;
				
				String id = "";
				org.w3c.dom.NodeList emailNode = element.getElementsByTagName("id");
				if(((org.w3c.dom.Element) emailNode.item(0)).hasChildNodes())
					id = ((org.w3c.dom.Element) emailNode.item(0)).getFirstChild().getNodeValue().trim();
				
				String path  = "";
				org.w3c.dom.NodeList firstNameNode = element.getElementsByTagName("path");
				if(((org.w3c.dom.Element) firstNameNode.item(0)).hasChildNodes())
					path = ((org.w3c.dom.Element) firstNameNode.item(0)).getFirstChild().getNodeValue().trim();
			 
				map.put(Long.valueOf(id), path);
			}
		}
		
		return map;
	}
 
	private static boolean deleteInternalVideoFilename(String writablePath) {
		File f = new File(getInternalVideoFilename(writablePath));	    

		if(f.exists())
			return f.delete();
		else
			return true;
	}
	
	private static boolean deleteExternalVideoFilename(String writablePath) {
		File f = new File(getExternalVideoFilename(writablePath));	    

		if(f.exists())
			return f.delete();
		else
			return true;
	}
 
}
