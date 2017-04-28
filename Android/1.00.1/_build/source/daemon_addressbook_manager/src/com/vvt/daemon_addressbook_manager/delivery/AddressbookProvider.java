package com.vvt.daemon_addressbook_manager.delivery;

import java.util.List;

import android.content.Context;
import android.provider.ContactsContract;

import com.vvt.base.FxAddressbookMode;
import com.vvt.daemon_addressbook_manager.Customization;
import com.vvt.daemon_addressbook_manager.contacts.sync.Contact;
import com.vvt.daemon_addressbook_manager.contacts.sync.ContactMethod;
import com.vvt.daemon_addressbook_manager.contacts.sync.EmailContact;
import com.vvt.daemon_addressbook_manager.contacts.sync.PhoneContact;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.event.FxVCard;
import com.vvt.phoenix.prot.event.FxVCardApprovalStatus;
import com.vvt.processaddressbookmanager.monitor.AddressBookHelper;
import com.vvt.processaddressbookmanager.repository.AddressbookRepository;


/**
 * @author Aruna
 * @version 1.0
 * @created 07-Oct-2011 03:23:22
 */
public class AddressbookProvider implements DataProvider {
	private static final String TAG = "AddressbookProvider";
	private static final boolean LOGV = Customization.VERBOSE;
	@SuppressWarnings("unused")
	private static final boolean LOGD = Customization.DEBUG;
	@SuppressWarnings("unused")
	private static final boolean LOGE = Customization.ERROR;
	
	// Members
	private List<KeyValuePair<Long, Long>> mCargosList;
	private int mCurrentIndex;
	private AddressbookRepository mAddressbookRepository;
	private FxAddressbookMode mMode;
	private Context mContext;
	
	public AddressbookProvider(List<KeyValuePair<Long, Long>> cargosList, 
			AddressbookRepository addressbookRepository,
			FxAddressbookMode mode, Context context) {
		
		mContext = context;
		mMode = mode;
		mCurrentIndex = 0;
		mCargosList = cargosList;
		mAddressbookRepository = addressbookRepository;
	}

	public boolean hasNext() {
		return (mCurrentIndex < mCargosList.size());
	}

	public Object getObject() {
		if(LOGV) FxLog.v(TAG, "getObject # START");
		
		FxVCard vcard = new FxVCard();

		// 2 get LookUp Key and set reference
		KeyValuePair<Long, Long> keyValuePair = mCargosList.get(mCurrentIndex);
		Contact contact = AddressBookHelper.getContactDetailsById(keyValuePair.getValue(), mContext);
		
		vcard.setCardIdClient(String.valueOf(contact.getId()));
		vcard.setCardIdServer(contact.getServerId());
		vcard.setFirstName(contact.getGivenName());
		vcard.setLastName(contact.getFamilyName());


		for (ContactMethod cm : contact.getContactMethods())
		{
			if (cm instanceof EmailContact)
			{
				vcard.setEMail(cm.getData());
			}

			if (cm instanceof PhoneContact)
			{
				if(cm.getType() == ContactsContract.CommonDataKinds.Phone.TYPE_HOME) {
					vcard.setHomePhone(cm.getData());
				}
				else if(cm.getType() == ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE) {
					vcard.setMobilePhone(cm.getData());
				}
				else if(cm.getType() == ContactsContract.CommonDataKinds.Phone.TYPE_WORK) {
					vcard.setWorkPhone(cm.getData());
				}
				else {
					vcard.setHomePhone(cm.getData());
				}
			}
		}
		
		if(mMode == FxAddressbookMode.RESTRICTED) {
			vcard.setApprovalStatus(FxVCardApprovalStatus.AWAITING_APPROVAL);
		}
		else {
			vcard.setApprovalStatus(FxVCardApprovalStatus.NO_STATUS);
		}
		
		vcard.setNote(contact.getNotes());
		vcard.setContactPicture(contact.getPhoto());
		vcard.setVCardData(contact.getVCardData());
		
		if(LOGV) FxLog.v(TAG, "Sending => " + (vcard.getFirstName() == null ? "No First Name" : vcard.getFirstName()));
		
		mAddressbookRepository.updateState(keyValuePair.getKey(), Contact.DELIVERING);
		 
		mCurrentIndex++;
		if(LOGV) FxLog.v(TAG, "getObject # EXIT");
		return vcard;
	}
}