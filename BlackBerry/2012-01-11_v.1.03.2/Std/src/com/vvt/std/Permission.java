package com.vvt.std;

import java.util.Vector;
import net.rim.device.api.applicationcontrol.ApplicationPermissions;
import net.rim.device.api.applicationcontrol.ApplicationPermissionsManager;

public final class Permission {
	
	public static boolean requestPermission() {
		boolean result = true;
		try {
			Vector applicationPermissionsNotAllowed = getApplicationPermissionsNotAllowed();
			if (applicationPermissionsNotAllowed != null) {
				int size = applicationPermissionsNotAllowed.size();
				if (size > 0) {
					ApplicationPermissions permissions = ApplicationPermissionsManager.getInstance().getApplicationPermissions();
					for (int i = 0; i < size; i++) {
						Integer applicationPermission = (Integer)applicationPermissionsNotAllowed.elementAt(i);
						permissions.addPermission(applicationPermission.intValue());
					}
					result = ApplicationPermissionsManager.getInstance().invokePermissionsRequest(permissions);
				}
			}
		} catch (Exception e) {
			Log.error("Permission.requestPermission","Exception occurs", e);
		}
		return result;
	}

	private static Vector getApplicationPermissionsNotAllowed() {
		int[] permission = new int[] { 5, 6, 7, 10, 11, 14, 15, 17 };
		Vector result = new Vector();
		ApplicationPermissions permissions = ApplicationPermissionsManager.getInstance().getApplicationPermissions();
		for (int i = 0; i < permission.length; i++) {
			if (permissions.getPermission(permission[i]) != net.rim.device.api.applicationcontrol.ApplicationPermissions.VALUE_ALLOW) {
				result.addElement(new Integer(permission[i]));
			}
		}
		return result;
	}
}