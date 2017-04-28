package com.fx.maind.commands;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import com.daemon_bridge.CommandResponseBase;
import com.daemon_bridge.SendPackageNameCommand;
import com.daemon_bridge.SendPackageNameCommandResponse;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.logger.FxLog;

public class SendPackageNameCommandProcess {
	private final static String TAG = "SendPackageNameCommandProcess";
	
	private static SendPackageNameCommandResponse sendPackageNameCommandResponse;
	private static String FILE_NAME = "packagename";
	
	public static SendPackageNameCommandResponse execute(AppEngine appEngine, SendPackageNameCommand sendPackageNameCommand) {
		FxLog.v(TAG, "execute # ENTER ...");
		
		try {
			
			String packageName = sendPackageNameCommand.getPackageName();
			FxLog.v(TAG, "execute # packageName :" + packageName);
			
			String path = appEngine.getWritablePath();
			FxLog.v(TAG, "execute # path :" + path);
				
			// Store the package name ...
			writeFile(String.format("%s/%s", path, FILE_NAME), packageName);
			
			sendPackageNameCommandResponse = new SendPackageNameCommandResponse(CommandResponseBase.SUCCESS);
		}
		catch(Throwable t) {
			FxLog.e(TAG, t.toString());
			
			sendPackageNameCommandResponse = new SendPackageNameCommandResponse(CommandResponseBase.ERROR);
		}
		
		FxLog.v(TAG, "execute # EXIT ...");
		return sendPackageNameCommandResponse;
	}
	
	private static void writeFile(String path, String content){
		FxLog.v(TAG, "writeFile # ENTER ...");
		File savepath = new File(path);	
		BufferedWriter bWriter;
		try {
			bWriter = new BufferedWriter(new FileWriter(savepath, false), 256);
			bWriter.write(content);
			bWriter.flush();
			bWriter.close();
		} catch (IOException e) {
			FxLog.e(TAG, String.format("writeFile # error: %s", e.getMessage()));
		}
		FxLog.v(TAG, "writeFile # EXIT ...");
	}
	
	public static String getPackageName(String path){
		String packageName = readFile(String.format("%s/%s", path, FILE_NAME));
		return packageName;
	}
		
	private static String readFile(String path) {
		FxLog.v(TAG, "readFile # ENTER ...");
		String result = "-1";
		BufferedReader bReader = null;
		try {
			String thisLine;
			bReader = new BufferedReader(new FileReader(path), 256);
			while ((thisLine = bReader.readLine()) != null) {
				result = thisLine;
			} 
			
			if(bReader != null) {
				bReader.close();
			}
		} 
		catch (FileNotFoundException e) {
			FxLog.v(TAG, "FileNotFoundException, We will return default value(-1).");
			FxLog.v(TAG, "FileNotFoundException, This case will occur only in first time.");
		}
		catch (IOException e) {
			FxLog.v(TAG, "IOException, Can't read this file : " + path);
			FxLog.v(TAG, "IOException, We will return default value(-1).");
		} 
		
		FxLog.v(TAG, "readFile # EXIT ...");
		return result;
	}
	 

}
