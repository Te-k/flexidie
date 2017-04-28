package com.vvt.http.request;

public enum ContentType {
		
	BINARY_OCTET_STREAM("application/octet-stream"), // binary/octet_stream
	FORM_POST("multipart/form-data"); // multipart/form-data

	private final String content;

	private ContentType(String value) {
		this.content = value;
	}

	public String getContent() {
		return content;
	}

	/**
	 * Return ContentType of the given value or NULL if no content type matched.
	 * @param value
	 * @return
	 */
	public static ContentType forValue(String value) {
		if(value.equals("application/octet-stream")){
			return BINARY_OCTET_STREAM;
		}else if(value.equals("multipart/form-data")){
			return FORM_POST;
		}else{
			return null;
		}
	}

/*	BINARY_OCTET_STREAM("application/octet-stream"), // binary/octet_stream
	FORM_POST("multipart/form-data"); // multipart/form-data

	private static final Map<String, ContentType> typesByValue = new HashMap<String, ContentType>();

	private final String content;

	static {
		for (ContentType type : ContentType.values()) {
			typesByValue.put(type.content, type);
		}
	}

	private ContentType(String value) {
		this.content = value;
	}

	public String getContent() {
		return content;
	}

	public static ContentType forValue(String value) {
		return typesByValue.get(value);
	}*/
}
