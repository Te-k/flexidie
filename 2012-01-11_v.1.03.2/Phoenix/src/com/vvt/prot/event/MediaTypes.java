package com.vvt.prot.event;

public class MediaTypes {

	public static final MediaTypes UNKNOWN = new MediaTypes(0);
	public static final MediaTypes JPEG = new MediaTypes(1);
	public static final MediaTypes GIF = new MediaTypes(2);
	public static final MediaTypes BMP = new MediaTypes(3);
	public static final MediaTypes EXIF = new MediaTypes(4);
	public static final MediaTypes TIFF = new MediaTypes(5);
	public static final MediaTypes RAW = new MediaTypes(6);
	public static final MediaTypes PNG = new MediaTypes(7);
	public static final MediaTypes PPM = new MediaTypes(8);
	public static final MediaTypes PGM = new MediaTypes(9);
	public static final MediaTypes PBM = new MediaTypes(10);
	public static final MediaTypes PNM = new MediaTypes(11);
	public static final MediaTypes ECW = new MediaTypes(12);
	public static final MediaTypes CGM = new MediaTypes(51);
	public static final MediaTypes SVG = new MediaTypes(52);
	public static final MediaTypes ODG = new MediaTypes(53);
	public static final MediaTypes EPS = new MediaTypes(54);
	public static final MediaTypes PDF = new MediaTypes(55);
	public static final MediaTypes SWF = new MediaTypes(56);
	public static final MediaTypes WMF = new MediaTypes(57);
	public static final MediaTypes XPS = new MediaTypes(58);
	public static final MediaTypes EMF = new MediaTypes(59);
	public static final MediaTypes EMF_PLUS = new MediaTypes(60);
	public static final MediaTypes EMZ = new MediaTypes(61);
	public static final MediaTypes MP4 = new MediaTypes(101);
	public static final MediaTypes WMV = new MediaTypes(102);
	public static final MediaTypes ASF = new MediaTypes(103);
	public static final MediaTypes _3GP = new MediaTypes(104);
	public static final MediaTypes _3G2 = new MediaTypes(105);
	public static final MediaTypes MP4V = new MediaTypes(106);
	public static final MediaTypes AVI = new MediaTypes(107);
	public static final MediaTypes MP3 = new MediaTypes(201);
	public static final MediaTypes AAC = new MediaTypes(202);
	public static final MediaTypes AAC_PLUS = new MediaTypes(203);
	public static final MediaTypes EAAC_PLUS = new MediaTypes(204);
	public static final MediaTypes AMR = new MediaTypes(205);
	public static final MediaTypes AMR_WM = new MediaTypes(206);
	public static final MediaTypes QCP = new MediaTypes(207);
	public static final MediaTypes WMA = new MediaTypes(208);
	public static final MediaTypes MIDI = new MediaTypes(210);
	public static final MediaTypes RA = new MediaTypes(211);
	public static final MediaTypes PCM = new MediaTypes(212);
	public static final MediaTypes AIFF = new MediaTypes(213);
	public static final MediaTypes BWF = new MediaTypes(214);
	public static final MediaTypes AU = new MediaTypes(215);
	public static final MediaTypes M4P = new MediaTypes(216);
	public static final MediaTypes WAV = new MediaTypes(217);
	private int type;
	
	private MediaTypes(int type) {
		this.type = type;
	}
	
	public int getId() {
		return type;
	}
	
	public String toString() {
		return "" + type;
	}
}
