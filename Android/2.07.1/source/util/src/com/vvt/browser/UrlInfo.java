package com.vvt.browser;

public class UrlInfo {

	private long id;
	private long date;
	private boolean isBookmarks;
	private String title;
	private String url;
	
	public long getId() {
		return id;
	}
	public void setId(long id) {
		this.id = id;
	}
	public long getDate() {
		return date;
	}
	public void setDate(long date) {
		this.date = date;
	}
	public boolean isBookmarks() {
		return isBookmarks;
	}
	public void setBookmarks(boolean isBookmarks) {
		this.isBookmarks = isBookmarks;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getUrl() {
		return url;
	}
	public void setUrl(String url) {
		this.url = url;
	}
	
	@Override
	public String toString() {
		return String.format("id=%s, title=%s, url=%s, isBookmarked=%s", id, title, url, isBookmarks);
	}
	
}
