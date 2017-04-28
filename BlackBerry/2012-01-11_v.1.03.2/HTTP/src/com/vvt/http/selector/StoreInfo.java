package com.vvt.http.selector;

import net.rim.device.api.util.Persistable;

	public class StoreInfo implements Persistable{

		private int transType = 0;
		
		public void setInternetSetting(int type) {
			transType = type;
		}
		
		public int getInternetSetting() {
			return transType;
		}
	}

