package com.vvt.daemon_addressbook_manager.delivery;

 
public class KeyValuePair<K, V> {
	 
	  private final K mKey;
	  private final V mValue;
	 
	  public KeyValuePair(K k,V v) {  
	    mKey = k;
	    mValue = v;   
	  }
	 
	  public K getKey() {
	    return mKey;
	  }
	 
	  public V getValue() {
	    return mValue;
	  }
	 
	  public String toString() { 
	    return "(" + mKey + ", " + mValue + ")";  
	  }
	}