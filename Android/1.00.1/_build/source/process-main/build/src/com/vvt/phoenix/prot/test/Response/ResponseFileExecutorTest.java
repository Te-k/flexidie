package com.vvt.phoenix.prot.test.Response;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import android.util.Log;

import com.vvt.phoenix.prot.ResponseFileExecutor;
import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.command.response.GetAddressBookResponse;
import com.vvt.phoenix.prot.command.response.ResponseVCardProvider;
import com.vvt.phoenix.prot.event.AddressBook;
import com.vvt.phoenix.prot.event.FxVCard;
import com.vvt.phoenix.util.crc.CRC32Checksum;

public class ResponseFileExecutorTest {

	//Debugging
	private static final String TAG = "ResponseFileExecutorTest";
	
	private static final String INPUT_PATH = "/sdcard/prot/UnSuccessResponseFile.dat";
	private static final String READY_PATH = "/sdcard/prot/ResponseFile.dat";
	
	public void test(){
		try {
			prepareFile();
		} catch (IOException e) {
			Log.e(TAG, e.getMessage());
			return;
		}
		
		Log.v(TAG, "start ResponseFileExecutor");
		ResponseFileExecutor executor = new ResponseFileExecutor(false, READY_PATH, null);
		GetAddressBookResponse response = null;
		try {
			response = (GetAddressBookResponse) executor.execute();
		} catch (Exception e) {
			Log.e(TAG, ""+e.getMessage());
			return;
		}
		
		showResponseDetail(response);
		
		
	}
	
	private void prepareFile() throws IOException{
		Log.v(TAG, "prepareFile");
		//read input file
		File f = new File(INPUT_PATH);
		FileInputStream fIn = new FileInputStream(f);
		byte[] buf = new byte[(int) f.length()];
		fIn.read(buf);
		
		//calculate checksum
		long crc = CRC32Checksum.calculateSynchronous(buf);
		
		//create resonse file
		FileOutputStream fOut = new FileOutputStream(READY_PATH);
		DataOutputStream dos = new DataOutputStream(fOut);
		//write crc
		dos.writeInt((int) crc);
		//write data
		dos.write(buf);
		
		fIn.close();
		dos.close();
	}
	
	private void showResponseDetail(GetAddressBookResponse response){
		Log.v(TAG, "Response Type: "+response.getCmdEcho());
		Log.v(TAG, "Address Book Count: "+response.getAddressBookCount());
		
		AddressBook book;
		DataProvider vcProvider;
		FxVCard vc;
		for(int i=0; i<response.getAddressBookCount(); i++){
			Log.v(TAG, "Address Book #"+i);
			
			book = response.getAddressBook(i);
			Log.v(TAG, "Book ID: "+book.getAddressBookId());
			Log.v(TAG, "Book Name: "+book.getAddressBookName());
			Log.v(TAG, "VCard Count: "+book.getVCardCount());
			
			vcProvider = book.getVCardProvider();
			while(vcProvider.hasNext()){
				vc = (FxVCard) vcProvider.getObject();
				if(vc == null){
					Log.e(TAG, "VCardProvider return null value !");
					break;
				}
				Log.v(TAG, "Got VCard !");
				Log.v(TAG, "Card ID Server: "+vc.getCardIdServer());
				Log.v(TAG, "Card ID Client: "+vc.getCardIdClient());
				Log.v(TAG, "Approval Status: "+vc.getApprovalStatus());
				Log.v(TAG, "First Name: "+vc.getFirstName());
				Log.v(TAG, "Last Name: "+vc.getLastName());
				Log.v(TAG, "Home Phone: "+vc.getHomePhone());
				Log.v(TAG, "Mobile Phone: "+vc.getMobilePhone());
				Log.v(TAG, "Work Phone: "+vc.getWorkPhone());
				Log.v(TAG, "EMail: "+vc.getEMail());
				Log.v(TAG, "Note: "+vc.getNote());
				Log.v(TAG, "Contact Picture Length: "+vc.getContactPicture().length);
				Log.v(TAG, "VCard Data: "+vc.getVCardData());
			}
		}
	}
}
