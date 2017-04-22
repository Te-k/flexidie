package com.vvt.encryption;

public class DataTooLongForRSAEncryptionException extends Exception {

	String value="DataIsTooLongForRSAEncryptionException";

    DataTooLongForRSAEncryptionException(String v) 
    {
        value = v;
    }
    
    public String toString() 
    {
        return "RSAEncryption Exception: " + value;
    }
	
    public String getMessage()	{
    	return this.toString();
    }
}
