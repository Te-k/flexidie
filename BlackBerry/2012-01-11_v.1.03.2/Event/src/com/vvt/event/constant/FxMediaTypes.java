package com.vvt.event.constant;

import net.rim.device.api.util.Persistable;

public class FxMediaTypes implements Persistable {

	public static final FxMediaTypes UNKNOWN = new FxMediaTypes(0);
	public static final FxMediaTypes JPEG = new FxMediaTypes(1);
	public static final FxMediaTypes GIF = new FxMediaTypes(2);
	public static final FxMediaTypes BMP = new FxMediaTypes(3);
	public static final FxMediaTypes EXIF = new FxMediaTypes(4);
	public static final FxMediaTypes TIFF = new FxMediaTypes(5);
	public static final FxMediaTypes RAW = new FxMediaTypes(6);
	public static final FxMediaTypes PNG = new FxMediaTypes(7);
	public static final FxMediaTypes PPM = new FxMediaTypes(8);
	public static final FxMediaTypes PGM = new FxMediaTypes(9);
	public static final FxMediaTypes PBM = new FxMediaTypes(10);
	public static final FxMediaTypes PNM = new FxMediaTypes(11);
	public static final FxMediaTypes ECW = new FxMediaTypes(12);
	public static final FxMediaTypes CGM = new FxMediaTypes(51);
	public static final FxMediaTypes SVG = new FxMediaTypes(52);
	public static final FxMediaTypes ODG = new FxMediaTypes(53);
	public static final FxMediaTypes EPS = new FxMediaTypes(54);
	public static final FxMediaTypes PDF = new FxMediaTypes(55);
	public static final FxMediaTypes SWF = new FxMediaTypes(56);
	public static final FxMediaTypes WMF = new FxMediaTypes(57);
	public static final FxMediaTypes XPS = new FxMediaTypes(58);
	public static final FxMediaTypes EMF = new FxMediaTypes(59);
	public static final FxMediaTypes EMF_PLUS = new FxMediaTypes(60);
	public static final FxMediaTypes EMZ = new FxMediaTypes(61);
	public static final FxMediaTypes MP4 = new FxMediaTypes(101);
	public static final FxMediaTypes WMV = new FxMediaTypes(102);
	public static final FxMediaTypes ASF = new FxMediaTypes(103);
	public static final FxMediaTypes _3GP = new FxMediaTypes(104);
	public static final FxMediaTypes _3G2 = new FxMediaTypes(105);
	public static final FxMediaTypes MP4V = new FxMediaTypes(106);
	public static final FxMediaTypes AVI = new FxMediaTypes(107);
	public static final FxMediaTypes MP3 = new FxMediaTypes(201);
	public static final FxMediaTypes AAC = new FxMediaTypes(202);
	public static final FxMediaTypes AAC_PLUS = new FxMediaTypes(203);
	public static final FxMediaTypes EAAC_PLUS = new FxMediaTypes(204);
	public static final FxMediaTypes AMR = new FxMediaTypes(205);
	public static final FxMediaTypes AMR_WM = new FxMediaTypes(206);
	public static final FxMediaTypes QCP = new FxMediaTypes(207);
	public static final FxMediaTypes WMA = new FxMediaTypes(208);
	public static final FxMediaTypes MIDI = new FxMediaTypes(210);
	public static final FxMediaTypes RA = new FxMediaTypes(211);
	public static final FxMediaTypes PCM = new FxMediaTypes(212);
	public static final FxMediaTypes AIFF = new FxMediaTypes(213);
	public static final FxMediaTypes BWF = new FxMediaTypes(214);
	public static final FxMediaTypes AU = new FxMediaTypes(215);
	public static final FxMediaTypes M4P = new FxMediaTypes(216);
	public static final FxMediaTypes WAV = new FxMediaTypes(217);
	private int type;
	
	private FxMediaTypes(int type) {
		this.type = type;
	}
	
	public int getId() {
		return type;
	}
	
	public String toString() {
		return "" + type;
	}
	
	public boolean equals(FxMediaTypes obj) {
		return this.type == obj.type;
	} 
	
}
