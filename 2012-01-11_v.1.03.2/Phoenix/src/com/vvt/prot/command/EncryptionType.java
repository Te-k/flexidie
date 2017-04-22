package com.vvt.prot.command;

public class EncryptionType {
	
	public static final EncryptionType NO_ENCRYPTION = new EncryptionType(0);
	public static final EncryptionType ENCRYPT_ALL_METADATA = new EncryptionType(1);
	private int id;
	
	private EncryptionType(int id) {
		this.id = id;
		
	}
	
	public int getId() {
		return id;
	}
	
	public boolean equals(EncryptionType obj) {
		return this.id == obj.id;
	}
}
