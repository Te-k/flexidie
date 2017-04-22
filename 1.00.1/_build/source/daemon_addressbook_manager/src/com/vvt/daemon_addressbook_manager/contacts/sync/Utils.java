package com.vvt.daemon_addressbook_manager.contacts.sync;

import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.Text;
import org.xml.sax.SAXException;

import android.text.format.Time;
import android.util.Log;
import android.util.TimeFormatException;

public final class Utils {
	public static String join(final String delimiter, final Object[] objects) {
		if (objects.length == 0)
			return "";

		StringBuilder buffer = new StringBuilder(objects[0].toString());

		for (int i = 1; i < objects.length; i++)
			buffer.append(delimiter).append(objects[i]);

		return buffer.toString();
	}

	/**
	 * date format mask for Kolab's Datetime
	 */
	private static final SimpleDateFormat UTC_DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SS'Z'");
	private static final TimeZone utc = TimeZone.getTimeZone("UTC");

	public static String toUtc(Date date) {
		UTC_DATE_FORMAT.setTimeZone(utc);
		final String milliformat = UTC_DATE_FORMAT.format(date);
		return milliformat;
	}

	public static final void setXmlElementValue(Document xml, Element parent,
			String name, String value) {
		if (value == null || "".equals(value)) {
			deleteXmlElements(parent, name);
		} else {
			Element e = getOrCreateXmlElement(xml, parent, name);
			// Delete old text nodes
			NodeList nl = e.getChildNodes();
			for (int i = 0; i < nl.getLength(); i++) {
				e.removeChild(nl.item(i));
			}
			// add new text node
			Text t = xml.createTextNode(value);
			e.appendChild(t);
		}
	}

	public static final void addXmlElementValue(Document xml, Element parent,
			String name, String value) {
		Element e = xml.createElement(name);
		parent.appendChild(e);
		// add new text node
		Text t = xml.createTextNode(value);
		e.appendChild(t);
	}

	public static final void setXmlAttributeValue(Document xml, Element parent,
			String name, String value) {
		Attr a = xml.createAttribute(name);
		a.setValue(value);
		parent.getAttributes().setNamedItem(a);
	}

	public static final Element getOrCreateXmlElement(Document xml,
			Element parent, String name) {
		NodeList nl = parent.getElementsByTagName(name);
		if (nl.getLength() == 0) {
			Element e = xml.createElement(name);
			parent.appendChild(e);
			return e;
		} else {
			return (Element) nl.item(0);
		}
	}

	public static final Element createXmlElement(Document xml, Element parent,
			String name) {
		Element e = xml.createElement(name);
		parent.appendChild(e);
		return e;
	}

	public static final Element getXmlElement(Element parent, String name) {
		NodeList nl = parent.getElementsByTagName(name);
		if (nl.getLength() == 0) {
			return null;
		} else {
			return (Element) nl.item(0);
		}
	}

	public static final NodeList getXmlElements(Element parent, String name) {
		return parent.getElementsByTagName(name);
	}

	public static final String getXmlElementString(Element parent, String name) {
		Element e = getXmlElement(parent, name);
		return getXmlElementString(e);
	}

	public static final String getXmlElementString(Element e) {
		if (e == null)
			return null;
		NodeList nl = e.getChildNodes();
		if (nl.getLength() > 0) {
			return nl.item(0).getNodeValue();
		}
		return null;
	}

	public static final String getXmlAttributeString(Element parent, String name) {
		return parent.getAttribute(name);
	}

	public static final Time getXmlElementTime(Element parent, String name) {
		String value = getXmlElementString(parent, name);
		if (value == null || "".equals(value))
			return null;
		Time t = new Time();
		t.switchTimezone("UTC");
		try {
			t.parse3339(value);
		} catch (TimeFormatException tfe) {
			Log.e("sync", "Unable to parse DateTime " + value);
			tfe.printStackTrace();
			return null;
		}
		t.normalize(false);
		return t;
	}

	public static final int getXmlElementInt(Element parent, String name,
			int defaultValue) {
		String value = getXmlElementString(parent, name);
		if (value == null || "".equals(value))
			return defaultValue;
		try {
			return Integer.parseInt(value);
		} catch (TimeFormatException tfe) {
			Log.e("sync", "Unable to parse DateTime " + value);
			tfe.printStackTrace();
			return defaultValue;
		}
	}

	public static final void deleteXmlElements(Element parent, String name) {
		NodeList nl = parent.getElementsByTagName(name);
		for (int i = 0; i < nl.getLength(); i++) {
			parent.removeChild(nl.item(i));
		}
	}

	public final static Document getDocument(InputStream xmlinput)
			throws ParserConfigurationException, SAXException, IOException {
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		DocumentBuilder db = dbf.newDocumentBuilder();
		return db.parse(xmlinput);
	}

	public final static Document newDocument(String rootName)
			throws ParserConfigurationException {
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		DocumentBuilder db = dbf.newDocumentBuilder();
		Document xml = db.newDocument();
		Node root = xml.createElement(rootName);
		Attr a = xml.createAttribute("version");
		a.setValue("1.0");
		root.getAttributes().setNamedItem(a);
		xml.appendChild(root);
		return xml;
	}

	public final static String getXml(Node node) {
		// http://groups.google.com/group/android-developers/browse_thread/thread/2cc84c1bc8a6b477/5edb01c0721081b0
		StringBuilder buffer = new StringBuilder();

		if (node == null) {
			return "";
		}

		if (node instanceof Document) {
			buffer.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
			buffer.append(getXml(((Document) node).getDocumentElement()));
		} else if (node instanceof Element) {
			Element element = (Element) node;
			buffer.append("<");
			buffer.append(element.getNodeName());
			if (element.hasAttributes()) {
				NamedNodeMap map = element.getAttributes();
				for (int i = 0; i < map.getLength(); i++) {
					Node attr = map.item(i);
					buffer.append(" ");
					buffer.append(attr.getNodeName());
					buffer.append("=\"");
					buffer.append(attr.getNodeValue());
					buffer.append("\"");
				}
			}
			buffer.append(">");
			NodeList children = element.getChildNodes();
			for (int i = 0; i < children.getLength(); i++) {
				buffer.append(getXml(children.item(i)));
			}
			buffer.append("</");
			buffer.append(element.getNodeName());
			buffer.append(">\n");
		} else if (node != null && node.getNodeValue() != null) {
			buffer.append(node.getNodeValue());
		}

		return buffer.toString();
	}

	public final static byte[] sha1Hash(String text) {
		MessageDigest hash = null;

		try {
			hash = MessageDigest.getInstance("SHA1");

			byte[] input = text.getBytes();

			byte[] hashValue = hash.digest(input);

			// Log.i("II","out digest: " + hashValue);
			return hashValue;
		} catch (Exception ex) {
			Log.e("EE", "Exception in sha1hash: " + ex.toString());
		}

		return null;
	}
}
