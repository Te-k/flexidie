package com.vvt.ioutil;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.ObjectInput;
import java.io.ObjectInputStream;
import java.io.ObjectOutput;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.io.Serializable;
import java.util.List;

import com.vvt.logger.FxLog;

public class Persister {
	
	private static final String TAG = "Persister";
	private static final boolean LOGD = Customization.DEBUG;
	
	public static void persistObject(List<String> obj, String pathOutput) {
		ObjectOutput output = null;
		try {
			// use buffering
			OutputStream file = new FileOutputStream(pathOutput);
			OutputStream buffer = new BufferedOutputStream(file);
			output = new ObjectOutputStream(buffer);
			output.writeObject(obj);
		}
		catch (Exception e) {
			if (LOGD) FxLog.d(TAG, String.format("persistObject # Error: %s",e));
		}
		finally {
			try { if (output != null) output.close(); }
			catch (Exception e) { /* ignore */ }
		}
	}
	
	public static boolean persistObject(Serializable obj, String pathOutput) {
		boolean isSuccess = false;
		ObjectOutputStream out = null;
		
		try {
			File f = new File(pathOutput);
			f.createNewFile();
			out = new ObjectOutputStream(new FileOutputStream(f));
			out.writeObject(obj);
			out.flush();
			isSuccess = true;
		}
		catch (Exception e) {
			if (LOGD) FxLog.d(TAG, String.format("persistObject # Error: %s",e));
		}
		finally {
			try { if (out != null) out.close(); }
			catch (Exception e) { /* ignore */ }
		}
		return isSuccess;
	}

	@SuppressWarnings("unchecked")
	public static List<String> deserializeObject(String path) {
		List<String> list = null;

		ObjectInput input = null;
		try {
			// use buffering
			InputStream file = new FileInputStream(path);
			InputStream buffer = new BufferedInputStream(file);
			input = new ObjectInputStream(buffer);

			list = (List<String>) input.readObject();
		}
		catch (Exception e) {
			if (LOGD) FxLog.d(TAG, String.format("deserializeObject # Error: %s",e));
		}
		finally {
			try { if (input != null) input.close(); }
			catch (Exception e) { /* ignore */ }
		}

		return list;
	}
	
	public static Object deserializeToObject(String path) {
		Object obj = null;
		
		ObjectInputStream in = null;
		try {
			in = new ObjectInputStream(new FileInputStream(new File(path)));
			obj = in.readObject();
		} 
		catch (Exception e) {
			if (LOGD) FxLog.d(TAG, String.format("deserializeToObject # Error: %s",e));
		}
		finally {
			try { if (in != null) in.close(); }
			catch (Exception e) { /* ignore */ }
		}
		
		return obj;
	}
	
}
