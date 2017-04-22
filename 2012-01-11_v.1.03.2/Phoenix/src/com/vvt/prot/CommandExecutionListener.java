package com.vvt.prot;

import com.vvt.http.response.FxHttpResponse;
import com.vvt.http.response.SentProgress;

public interface CommandExecutionListener {
	public void onCommandManagerError(String err);
	public void onCommandManagerSuccess(FxHttpResponse result);
	public void onCommandManagerSentProgress(SentProgress progress);
	public void onCommandManagerResponse(FxHttpResponse response); 
}
