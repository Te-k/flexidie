package com.vvt.phoenix.prot;
import com.vvt.phoenix.prot.session.SessionInfo;

/**
 * @author tanakharn
 * @version 1.0
 * @created 04-Nov-2010 1:54:43 PM
 */
public class ResumeRequest extends Request {

	private CommandListener mListener;
	private SessionInfo mSession;

	@Override
	public int getRequestType(){
		return RequestType.RESUME_REQUEST;
	}

	public CommandListener getCommandListener() {
		return mListener;
	}
	public void setCommandListener(CommandListener listener) {
		mListener = listener;
	}

	public SessionInfo getSession() {
		return mSession;
	}
	public void setSession(SessionInfo session) {
		mSession = session;
	}


}