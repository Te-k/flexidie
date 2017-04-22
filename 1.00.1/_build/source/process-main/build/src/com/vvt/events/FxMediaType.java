package com.vvt.events;

import java.util.HashMap;
import java.util.Map;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 01:46:39
 */
public enum FxMediaType {


	
	/**
	 * Image
	 */
	UNKNOWN(0),
	JPEG(1),
	GIF(2),
	BMP(3),
	EXIF(4),
	TIFF(5),
	RAW(6),
	PNG(7),
	PPM(8),
	PGM(9),
	PBM(10),
	PNM(11),
	ECW(12),
	/**
	 * Video
	 */
	CGM(51),
	SVG(52),
	ODG(53),
	EPS(54),
	PDF(55),
	SWF(56),
	WMF(57),
	XPS(58),
	EMS(59),
	EMF_PLUS(60),
	EMZ(61),
	MP4(101),
	WMV(102),
	ASF(103),
	THREE_GP(104),
	THREE_G2(105),
	M4V(106),
	AVI(107),
	/**
	 * Audio
	 */
	MP3(201),
	AAC(202),
	AAC_PLUS(203),
	eAAC_PLUS(204),
	AMR_NB(205),
	AMR_WM(206),
	QCP(207),
	WMA(208),
	MIDI(210),
	RA(211),
	PCM(212),
	AIFF(213),
	BWF(214),
	au(215),
	M4P(216),
	WAV(217);

	private static final Map<Integer, FxMediaType> typesByValue = new HashMap<Integer, FxMediaType>();
    private final int number;
    
    static {
        for (FxMediaType type : FxMediaType.values()) {
            typesByValue.put(type.number, type);
        }
    }

    private FxMediaType(int value) {
        this.number = value;
    }

    public int getNumber() {
        return number;
    }
    
    public static FxMediaType forValue(int value) {
        return typesByValue.get(value);
    }
	
	
}