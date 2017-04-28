package com.vvt.remotecommandmanager.processor.media;

import com.vvt.appcontext.AppContext;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.license.LicenseInfo;
import com.vvt.remotecommandmanager.ProcessingType;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;

/*This command is not currently use by any of our products.*/
public class OnDemandRecordProcessor  extends RemoteCommandProcessor {

	public OnDemandRecordProcessor(AppContext appContext, FxEventRepository eventRepository,
			LicenseInfo licenseInfo) {
		super(appContext, eventRepository);
	}

	

	@Override
	public ProcessingType getProcessingType() {
		return null;
	}

	@Override
	protected void doProcessCommand(RemoteCommandData commandData)
			throws RemoteCommandException {
	}

	@Override
	protected String getRecipientNumber() {
		return null;
	}

	@Override
	protected ProcessingResult getReplyMessage() {
		return null;
	}

}
