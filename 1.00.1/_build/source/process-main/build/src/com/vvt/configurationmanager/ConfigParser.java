package com.vvt.configurationmanager;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;

public class ConfigParser {
	
	// keyword is "configuration", "id", "feature" and "cmd" .
	private static final String CONFIGURATION_KEYWORD = FxSecurity.getConstant(Constant.CONFIGURATION_KEYWORD);
	private static final String ID_KEYWORD = FxSecurity.getConstant(Constant.ID_KEYWORD);
	private static final String FEATURE_KEYWORD = FxSecurity.getConstant(Constant.FEATURE_KEYWORD);
	private static final String COMMAND_KEYWORD = FxSecurity.getConstant(Constant.COMMAND_KEYWORD);
	
	public static List<Configuration> doParse(String xmlData) {
		
		List<Configuration> configurations = new ArrayList<Configuration>();
	
		// convert String into InputStream
		InputStream is = new ByteArrayInputStream(xmlData.getBytes());
		try {
			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
			Document doc = dBuilder.parse(is);
			doc.getDocumentElement().normalize();
			
			NodeList nList = doc.getElementsByTagName(CONFIGURATION_KEYWORD);

			Configuration configuration = null;
			for (int temp = 0; temp < nList.getLength(); temp++) {

				configuration = new Configuration();
				
				Node nNode = nList.item(temp);
				Element cElement = (Element) nNode;
				Attr attr = cElement.getAttributeNode(ID_KEYWORD);
				int confID = Integer.parseInt(attr.getValue());
				configuration.setConfigurationID(confID);
				
				if (nNode.getNodeType() == Node.ELEMENT_NODE) {
					Element eElement = (Element) nNode;
					configuration.setSupportedFeture(getSupportedFeature(eElement));
					configuration.setSupportedRemoteCmd(getSupportedCommand(eElement));
					
				}
				
				configurations.add(configuration);
			}
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		return configurations;
	}
	
	protected static ArrayList<FeatureID> getSupportedFeature(Element eElement) {
		
		ArrayList<FeatureID> featureList = new ArrayList<FeatureID>();
		
		NodeList nList = eElement.getElementsByTagName(FEATURE_KEYWORD);
		for (int temp = 0; temp < nList.getLength(); temp++) {
			Node nNode = nList.item(temp);
			if (nNode.getNodeType() == Node.ELEMENT_NODE) {
				Element cElement = (Element) nNode;
				Attr attr = cElement.getAttributeNode(ID_KEYWORD);
				int value = Integer.parseInt(attr.getValue());
				FeatureID featureID = FeatureID.forValue(value);
				featureList.add(featureID);
			}
		}
		
		return featureList;
	}
	
	protected static ArrayList<String> getSupportedCommand(Element eElement) {
		
		ArrayList<String> cmdList = new ArrayList<String>();
		NodeList nList = eElement.getElementsByTagName(COMMAND_KEYWORD);
		for (int temp = 0; temp < nList.getLength(); temp++) {
			Node nNode = nList.item(temp);
			if (nNode.getNodeType() == Node.ELEMENT_NODE) {
				Element cElement = (Element) nNode;
				Attr attr = cElement.getAttributeNode(ID_KEYWORD);
				cmdList.add(attr.getValue());
			}
		}
		return cmdList;
	}
}
