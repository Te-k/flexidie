package com.vvt.prot.command;

import net.rim.device.api.util.Persistable;

public class Languages implements Persistable {
	
	public static final Languages UNKNOWN = new Languages(0);
	public static final Languages ENGLISH = new Languages(1);
	public static final Languages SPANISH = new Languages(2);
	public static final Languages PORTUGUESE = new Languages(3);
	public static final Languages RUSSIAN = new Languages(4);
	public static final Languages GERMAN = new Languages(5);
	public static final Languages FRENCH = new Languages(6);
	public static final Languages ITALIAN = new Languages(7);
	public static final Languages ARABIC = new Languages(8);
	public static final Languages HINDI = new Languages(9);
	public static final Languages CHINESE = new Languages(10);
	public static final Languages BENGALI = new Languages(11);
	public static final Languages JAPANESE = new Languages(12);
	public static final Languages VIETNAMESE = new Languages(13);
	public static final Languages KOREAN = new Languages(14);
	public static final Languages THAI = new Languages(15);
	private int languageId;
	
	private Languages(int languageId) {
		this.languageId = languageId;
	}
	
	public int getId() {
		return languageId;
	}
	
	public String toString() {
		return "" + languageId;
	}
}