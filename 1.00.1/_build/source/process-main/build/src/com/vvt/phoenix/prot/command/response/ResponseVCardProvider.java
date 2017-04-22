package com.vvt.phoenix.prot.command.response;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.event.FxVCard;

public class ResponseVCardProvider implements DataProvider{
	
	//Members
	private String mPath;
	private DataInputStream mDis;
	private int mReadCount;
	private int mTotalVcard;
	
	/**
	 * @param path
	 * @param offset
	 */
	public ResponseVCardProvider(String path, int offset, int vcardCount) throws IOException{
		mPath = path;
		mTotalVcard = vcardCount;
		
		FileInputStream fIn = new FileInputStream(path);
		mDis = new DataInputStream(fIn);
		mDis.skipBytes(offset);
	}

	/**
	 * @return VCard object or null if have any problems
	 */
	@Override
	public Object getObject(){
		
		FxVCard vc = new FxVCard();
		try{
			// CARD_ID_SERVER
			vc.setCardIdServer(mDis.readInt());
			// CARD_ID_CLIENT
			vc.setCardIdClient(readString(mDis.read()));
			// APPROVAL_STATUS
			vc.setApprovalStatus(mDis.read());
			
			// VCARD_SUMMARY
			// FIRST_NAME
			vc.setFirstName(readString(mDis.read()));
			// LAST_NAME
			vc.setLastName(readString(mDis.read()));
			// HOME_PHONE
			vc.setHomePhone(readString(mDis.read()));
			// MOBILE_PHONE
			vc.setMobilePhone(readString(mDis.read()));
			// WORK_PHONE
			vc.setWorkPhone(readString(mDis.read()));
			// EMAIL
			vc.setEMail(readString(mDis.read()));
			// NOTE
			vc.setNote(readString(mDis.readShort()));
			// CONTACT_PICTURE
			byte[] rawPic = new byte[mDis.readInt()];
			mDis.read(rawPic);
			vc.setContactPicture(rawPic);
			
			// VCARD_DATA
			//vc.setVCardData(readString(mDis.readInt()));
			int vCardDataLen = mDis.readInt();
			byte[] buffer = new byte[vCardDataLen];
			mDis.read(buffer);
			vc.setVCardData(buffer);
			
			mReadCount++;
			if(mReadCount == mTotalVcard){	//eof
				mDis.close();
				//delete vcard file
				deleteVCardFile();
			}
			
			return vc;
			
		}catch (IOException e){
			return null;
		}		
		
	}
	
	private String readString(int len) throws IOException{
		byte[] buf = new byte[len];
		mDis.read(buf);
		
		return new String(buf);
	}

	@Override
	public boolean hasNext() {
		if(mReadCount == mTotalVcard){
			deleteVCardFile();
			return false;
		}
		return (mReadCount < mTotalVcard);
	}
	
	private void deleteVCardFile(){
		File f = new File(mPath);
		f.delete();
	}

}
