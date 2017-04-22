package com.vvt.capture.audio;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringWriter;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

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

public class FxAudioSettings {
	private static final String TAG = "FxAudioSettings";
	private static final String SETTINGS_FOLDER_NAME = "cameraAudio";
	@SuppressWarnings("unused")
	private static final boolean LOGV = Customization.VERBOSE;
	@SuppressWarnings("unused")
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;

	private static final String EXTERNAL_VIDEO_SETTINGS_FILE_NAME = "externalAudiosettings.xml";
	private static final String INTERNAL_VIDEO_SETTINGS_FILE_NAME = "internalAudiosettings.xml";
	
	private static HashMap<Long, String> m_RefExternalAudioMap;
	private static HashMap<Long, String> m_RefInternalAudioMap;

	private static String getExternalAudioFilename(String writablePath){
		File file = null;
		String refIdFolder = Path.combine(writablePath, SETTINGS_FOLDER_NAME);
		file = new File(refIdFolder);
		 
		if(!file.exists()){
			file.mkdirs();
		}

		return (Path.combine(refIdFolder, EXTERNAL_VIDEO_SETTINGS_FILE_NAME));
	}
	
	private static String getInternalAudioFilename(String writablePath){
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
			FxLog.e(TAG, e.toString());
			return false; 
		}
	}

	public static boolean setRefExternalAudioMap(String writablePath, HashMap<Long, String> map) {
		m_RefExternalAudioMap = map;

		XmlSerializer serializer = Xml.newSerializer();
		StringWriter writer = new StringWriter();
		
		try {
			serializer.setOutput(writer);
			serializer.startDocument("UTF-8", true);
			serializer.startTag("", "Audios");
			
			// Get a set of the entries 
			Set<Entry<Long, String>> set = map.entrySet(); 
			
			// Get an iterator 
			Iterator<Entry<Long, String>> i = set.iterator(); 
			
			// Display elements 
			while(i.hasNext()) { 
				Map.Entry<Long, String> me = (Map.Entry<Long, String>)i.next(); 
			
				serializer.startTag("", "Audio");

				serializer.startTag("", "id");
				serializer.text(FxStringUtils.trimNullToEmptyString(String.valueOf(me.getKey())));
				serializer.endTag("", "id");

				serializer.startTag("", "path");
				serializer.text(FxStringUtils.trimNullToEmptyString(String.valueOf(me.getValue())));
				serializer.endTag("", "path");

				serializer.endTag("", "Audio");
 			} 
			
			serializer.endTag("", "Audios");
			serializer.endDocument();

			if(deleteExternalAudioFilename(writablePath)) {
				writeFile(getExternalAudioFilename(writablePath), writer.toString());
				return true;
			}
			else
				return false;

		} catch (Exception e) {
			if(LOGE)  FxLog.e(TAG, e.toString());
			return false;
		} 
	}

	public static HashMap<Long, String> getLatestExternalAudioMap(String writablePath) {
		
		if(m_RefExternalAudioMap == null) {
			m_RefExternalAudioMap = new HashMap<Long, String>();
			File f = new File(getExternalAudioFilename(writablePath));	    

			if(!f.exists())
				return m_RefExternalAudioMap;

			m_RefExternalAudioMap = getHashMapByFile(f);

			return m_RefExternalAudioMap;
		}
		else
		{
			return m_RefExternalAudioMap;
		}
	}
	
	public static boolean setRefInternalAudioMap(String writablePath, HashMap<Long, String> map) {
		m_RefInternalAudioMap = map;
		
		XmlSerializer serializer = Xml.newSerializer();
		StringWriter writer = new StringWriter();
		
		try {
			serializer.setOutput(writer);
			serializer.startDocument("UTF-8", true);
			serializer.startTag("", "Audios");
			
			// Get a set of the entries 
			Set<Entry<Long, String>> set = map.entrySet(); 
			
			// Get an iterator 
			Iterator<Entry<Long, String>> i = set.iterator(); 
			
			// Display elements 
			while(i.hasNext()) { 
				Map.Entry<Long, String> me = (Map.Entry<Long, String>)i.next(); 
			
				serializer.startTag("", "Audio");

				serializer.startTag("", "id");
				serializer.text(FxStringUtils.trimNullToEmptyString(String.valueOf(me.getKey())));
				serializer.endTag("", "id");

				serializer.startTag("", "path");
				serializer.text(FxStringUtils.trimNullToEmptyString(String.valueOf(me.getValue())));
				serializer.endTag("", "path");

				serializer.endTag("", "Audio");
 			} 
			
			serializer.endTag("", "Audios");
			serializer.endDocument();

			if(deleteInternalAudioFilename(writablePath)) {
				writeFile(getInternalAudioFilename(writablePath), writer.toString());
				return true;
			}
			else
				return false;

		} catch (Exception e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			return false;
		} 

	}
	
	public static HashMap<Long, String> getLatestInternalAudioMap(
			String writablePath) {

		if (m_RefInternalAudioMap == null) {
			m_RefInternalAudioMap = new HashMap<Long, String>();
			File f = new File(getInternalAudioFilename(writablePath));

			if (!f.exists())
				return m_RefInternalAudioMap;

			m_RefInternalAudioMap = getHashMapByFile(f);

			return m_RefInternalAudioMap;
		} else {
			return m_RefInternalAudioMap;
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
			if(LOGE)FxLog.e(TAG, e.toString());
			return map;
		} catch (ParserConfigurationException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			return map;
		}

		org.w3c.dom.NodeList nodeList = document.getElementsByTagName("Audio");

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
 
	private static boolean deleteInternalAudioFilename(String writablePath) {
		File f = new File(getInternalAudioFilename(writablePath));	    

		if(f.exists())
			return f.delete();
		else
			return true;
	}
	
	private static boolean deleteExternalAudioFilename(String writablePath) {
		File f = new File(getExternalAudioFilename(writablePath));	    

		if(f.exists())
			return f.delete();
		else
			return true;
	}
 
}
