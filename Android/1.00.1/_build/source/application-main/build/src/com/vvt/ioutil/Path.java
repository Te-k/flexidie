package com.vvt.ioutil;

import java.io.File;

public class Path {
	public static String combine(String path1, String path2) {
		File parent = new File(path1);
		File child = new File(parent, path2);
		return child.getPath();
	}
}
