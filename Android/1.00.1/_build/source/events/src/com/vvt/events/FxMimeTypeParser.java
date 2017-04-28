package com.vvt.events;

import com.vvt.logger.FxLog;


public class FxMimeTypeParser 
{
	private static final String TAG = "FxMimeTypeParser";
	
    public static FxMediaType parse(final String mimeType) {
		String mime = mimeType.toUpperCase();
		mime = mime.replace("AUDIO/", "");
		mime = mime.replace("IMAGE/", "");
		mime = mime.replace("VIDEO/", "");

		FxLog.v(TAG, "parse # mimeType is " + mimeType );
		
		if(mime.equals("CGM")) {
			return 	FxMediaType.CGM;
		} else if(mime.equals("SVG")) {
			return 	FxMediaType.SVG;
		} else if(mime.equals("ODG")) {
			return 	FxMediaType.ODG;
		} 
		else if(mime.equals("EPS")) {
			return FxMediaType.EPS;
		}
		else if(mime.equals("PDF")) {
			return FxMediaType.PDF;
		}
		else if(mime.equals("SWF")) {
			return FxMediaType.SWF;
		}
		else if(mime.equals("WMF")) {
			return FxMediaType.WMF;
		}
		else if(mime.equals("XPS")) {
			return FxMediaType.XPS;
		}
		else if(mime.equals("EMS")) {
			return FxMediaType.EMS;
		}
		else if(mime.equals("EMF_PLUS")) {
			return FxMediaType.EMF_PLUS;
		}
		else if(mime.equals("EMZ")) {
			return FxMediaType.EMZ;
		}
		else if(mime.equals("MP4")) {
			return FxMediaType.MP4;
		}
		else if(mime.equals("WMV")) {
			return FxMediaType.WMV;
		}
		else if(mime.equals("ASF")) {
			return FxMediaType.ASF;
		}
		else if(mime.equals("3GPP")) {
			return FxMediaType.THREE_GP;
		}
		else if(mime.equals("3GP")) {
			return FxMediaType.THREE_GP;
		}
		else if(mime.equals("3G2")) {
			return FxMediaType.THREE_G2;
		}
		else if(mime.equals("M4V")) {
			return FxMediaType.M4V;
		}
		else if(mime.equals("AVI")) {
			return FxMediaType.AVI;
		}
		
		/* Image */
		else if(mime.equals("JPG")) {
			return FxMediaType.JPEG;
		}
		else if(mime.equals("JPEG")) {
			return FxMediaType.JPEG;
		}
		else if(mime.equals("GIF")) {
			return FxMediaType.GIF;
		}
		else if(mime.equals("BMP")) {
			return FxMediaType.BMP;
		}
		else if(mime.equals("EXIF")) {
			return FxMediaType.EXIF;
		}
		else if(mime.equals("TIFF")) {
			return FxMediaType.TIFF;
		}
		else if(mime.equals("RAW")) {
			return FxMediaType.RAW;
		}
		else if(mime.equals("PNG")) {
			return FxMediaType.PNG;
		}
		else if(mime.equals("PPM")) {
			return FxMediaType.PPM;
		}
		else if(mime.equals("PGM")) {
			return FxMediaType.PGM;
		}
		else if(mime.equals("PBM")) {
			return FxMediaType.PBM;
		}
		else if(mime.equals("PNM")) {
			return FxMediaType.PNM;
		}
		else if(mime.equals("ECW")) {
			return FxMediaType.ECW;
		}
		
		else if(mime.equals("MP3")) {
			return FxMediaType.MP3;
		}
		else if(mime.equals("AAC")) {
			return FxMediaType.AAC;
		}
		else if(mime.equals("AAC_PLUS")) {
			return FxMediaType.AAC_PLUS;
		}
		else if(mime.equals("eAAC_PLUS")) {
			return FxMediaType.eAAC_PLUS;
		}
		else if(mime.equals("AMR")) {
			return FxMediaType.AMR_WM;
		}
		else if(mime.equals("AMR_NB")) {
			return FxMediaType.AMR_NB;
		}
		else if(mime.equals("AMR_WM")) {
			return FxMediaType.AMR_WM;
		}
		else if(mime.equals("QCP")) {
			return FxMediaType.QCP;
		}
		else if(mime.equals("WMA")) {
			return FxMediaType.WMA;
		}
		
		else if(mime.equals("MIDI")) {
			return FxMediaType.MIDI;
		}
		else if(mime.equals("RA")) {
			return FxMediaType.RA;
		}
		else if(mime.equals("PCM")) {
			return FxMediaType.PCM;
		}
		else if(mime.equals("AIFF")) {
			return FxMediaType.AIFF;
		}
		else if(mime.equals("BWF")) {
			return FxMediaType.BWF;
		}
		else if(mime.equals("au")) {
			return FxMediaType.au;
		}
		else if(mime.equals("WAV")) {
			return FxMediaType.WAV;
		}
		else if(mime.equals("M4P")) {
			return FxMediaType.M4P;
		}
		else
			return FxMediaType.UNKNOWN;
	}
}
