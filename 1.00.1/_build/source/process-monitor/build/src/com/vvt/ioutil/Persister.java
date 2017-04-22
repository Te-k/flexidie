package com.vvt.ioutil;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
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
	
	public static void persistObject(List<String> obj, String pathOutput) {
		try {
			// use buffering
			OutputStream file = new FileOutputStream(pathOutput);
			OutputStream buffer = new BufferedOutputStream(file);
			ObjectOutput output = new ObjectOutputStream(buffer);
			try {
				output.writeObject(obj);
			} finally {
				if (output != null) output.close();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public static boolean serializeObject(Serializable obj, String pathOutput) {
		boolean isSuccess = false;
		File f = new File(pathOutput);
		ObjectOutputStream out = null;
		try {
			f.createNewFile();
			out = new ObjectOutputStream(new FileOutputStream(f));
			out.writeObject(obj);
			out.flush();
		}
		catch (Exception e) { /* ignore */ }
		finally { 
			if (out != null) {
				try { out.close(); }
				catch (Exception e) { /* ignore */ }
			}
		}
			
		isSuccess = true;
		return isSuccess;
	}

	@SuppressWarnings("unchecked")
	public static List<String> deserializeObject(String path) {
		List<String> list = null;

		try {
			// use buffering
			InputStream file = new FileInputStream(path);
			InputStream buffer = new BufferedInputStream(file);
			ObjectInput input = new ObjectInputStream(buffer);

			try {
				list = (List<String>) input.readObject();
			} finally {
				input.close();
			}
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		return list;
	}
	
	public static Object deserializeToObject(String path) {
		Object obj = null;
		
		try {
			ObjectInputStream in = new ObjectInputStream(new FileInputStream(new File(path)));
			obj = in.readObject();
			in.close();
		} 
		catch (Exception e) {
			FxLog.e(TAG, "deserializeToObject # Error!!", e);
		}
		
		return obj;
	}
	
	public static boolean persistObject(Serializable obj, String pathOutput) {
		
		boolean isSuccess = false;
		try {
			File f = new File(pathOutput);
			f.createNewFile();
			ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream(f));
			out.writeObject(obj);
			out.flush();
			out.close();
			isSuccess = true;
		}
		catch (IOException e) {
			FxLog.e(TAG, "persistObject # Persisting FAILED!!",e);
		}
		return isSuccess;
	}
}
