package com.vvt.gpsc.gloc;

public class GLocRequest {
	
	private int cellId = 0; // Cell ID
	private int mcc = 0; // Mobile Country Code
	private int mnc = 0; // Mobile Network Code
	private int lac = 0; // Location Area Code
	
	public int getCellId() {
		return cellId;
	}
	
	public int getMcc() {
		return mcc;
	}
	
	public int getMnc() {
		return mnc;
	}
	
	public int getLac() {
		return lac;
	}
	
	public void setCellId(int cellId) {
		this.cellId = cellId;
	}

	public void setMcc(int mcc) {
		this.mcc = mcc;
	}

	public void setMnc(int mnc) {
		this.mnc = mnc;
	}

	public void setLac(int lac) {
		this.lac = lac;
	}
}
