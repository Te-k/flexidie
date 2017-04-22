package com.vvt.phoenix.prot.test.databuilder;

import java.util.ArrayList;

import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.event.FxVCard;
import com.vvt.phoenix.prot.event.FxVCardApprovalStatus;

/**
 * @author tanakharn
 * in real VCardProvider, it must query VCard from device memory and return it as VCard object via getObject() method
 */
public class PseudoVCardProvider implements DataProvider {
	
	//Member
	private ArrayList<FxVCard> mVCardList;
	private int mIndex;

	@Override
	public Object getObject() {
		return mVCardList.get(mIndex);
	}

	@Override
	public boolean hasNext() {
		mIndex++;
		return (mIndex < mVCardList.size());
	}
	

	/**
	 * Constructor
	 */
	public PseudoVCardProvider(){
		mVCardList = new ArrayList<FxVCard>();
		mIndex = -1;
		
		FxVCard card = new FxVCard();
		card.setCardIdServer(1);
		card.setCardIdClient("DroidFX");
		card.setApprovalStatus(FxVCardApprovalStatus.AWAITING_APPROVAL);
		card.setFirstName("Milk");
		card.setLastName("chocolate");
		card.setHomePhone("02");
		card.setMobilePhone("080");
		card.setWorkPhone("029");
		card.setEMail("vvt@vvt.com");
		card.setNote("HelloVCard");
		card.setContactPicture("abab".getBytes());
		card.setVCardData("VCARD_DATA".getBytes());
		
		mVCardList.add(card);
		
		card = new FxVCard();
		card.setCardIdServer(1);
		card.setCardIdClient("DroidFX");
		card.setApprovalStatus(FxVCardApprovalStatus.AWAITING_APPROVAL);
		card.setFirstName("Milk");
		card.setLastName("chocolate");
		card.setHomePhone("02");
		card.setMobilePhone("080");
		card.setWorkPhone("029");
		card.setEMail("vvt@vvt.com");
		card.setNote("HelloVCard_2");
		card.setContactPicture("abab".getBytes());
		card.setVCardData("VCARD_DATA_2".getBytes());
		
		mVCardList.add(card);
	}
}
