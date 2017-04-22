package com.vvt.memory;

import android.app.ActivityManager;
import android.app.ActivityManager.MemoryInfo;
import android.content.Context;

public class MemoryUtil {
	public static long getAvailableMemory(Context context) {
		
		ActivityManager activityManage = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
		
		 MemoryInfo memoryInfo = new MemoryInfo();
         activityManage.getMemoryInfo(memoryInfo);

         long availMem = memoryInfo.availMem;

         if(availMem > 1024)
             availMem = availMem  / 1024;
         else
             availMem = 1;
         
		return availMem;
	}
}
