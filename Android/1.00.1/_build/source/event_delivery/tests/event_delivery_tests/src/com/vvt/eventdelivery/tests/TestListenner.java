package com.vvt.eventdelivery.tests;

import com.vvt.datadeliverymanager.enums.DataProviderType;

public interface TestListenner {
	public void onFinish(DataProviderType dataProviderType);
}
