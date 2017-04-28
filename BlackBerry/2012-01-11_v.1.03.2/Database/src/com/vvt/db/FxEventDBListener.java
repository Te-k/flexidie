package com.vvt.db;

public interface FxEventDBListener {
	public void onDeleteSuccess();
	public void onInsertSuccess();
	public void onDeleteError();
	public void onInsertError();
}
