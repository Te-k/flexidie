package com.vvt.daemon_addressbook_manager;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import a_vcard.android.syncml.pim.PropertyNode;
import a_vcard.android.syncml.pim.VDataBuilder;
import a_vcard.android.syncml.pim.VNode;
import a_vcard.android.syncml.pim.vcard.VCardException;
import a_vcard.android.syncml.pim.vcard.VCardParser;
import android.content.Context;
import android.database.Cursor;
import android.provider.ContactsContract;
import android.provider.ContactsContract.CommonDataKinds.Email;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.provider.ContactsContract.Data;

import com.vvt.daemon_addressbook_manager.contacts.sync.Contact;
import com.vvt.daemon_addressbook_manager.contacts.sync.ContactDBHelper;
import com.vvt.daemon_addressbook_manager.contacts.sync.EmailContact;
import com.vvt.daemon_addressbook_manager.contacts.sync.PhoneContact;
import com.vvt.ioutil.Path;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.event.FxVCard;
import com.vvt.processaddressbookmanager.repository.AddressbookRepository;
import com.vvt.stringutil.FxStringUtils;


public class ProcessServerVCard {
	private static final String TAG = "ProcessServerVCard";
	@SuppressWarnings("unused")
	private static final boolean LOGV = Customization.VERBOSE;
	@SuppressWarnings("unused")
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private AddressbookRepository mAddressbookRepository;
	
	private static final int NAME_ORDER_TYPE_ENGLISH = 0;
	private static final int NAME_ORDER_TYPE_JAPANESE = 1;
	private Context mContext;
	
	public void setAddressbookRepository(AddressbookRepository addressbookRepository, Context context) {
		mAddressbookRepository = addressbookRepository;
		mContext = context;
	}
	
	public void parseAndProcess(DataProvider vcProvider) {
		while (vcProvider.hasNext()) {
			FxVCard vc = (FxVCard) vcProvider.getObject();
			VCardParser parser = null;
			VDataBuilder builder = null;
			
			if (vc != null) {
				String vCardFilePath = null;
				
				try {
					long serverId = vc.getCardIdServer();
					String serverClientId = vc.getCardIdClient();
					long clientId = Long.parseLong(serverClientId);
					boolean isConactExist = false;
					
					if (clientId > 0) {
						Container c = new Container();
						c.id = serverClientId;
						
						isConactExist = isContactIdExist(c);
						
						if(isConactExist) {
							long newClientId = Long.parseLong(c.id);
							
							if(newClientId != clientId)
								clientId = newClientId;
						}
					}

					if (serverId > 0) {
						isConactExist = isContactServerIdExist(serverId);

						if (isConactExist)
							clientId = getContactIdUsingServerId(serverId);
						else
							clientId = -1;
					}
					
					vCardFilePath = saveVCardDataOnFile(vc.getVCardData());
			        parser = new VCardParser();
			        builder = new VDataBuilder();
			     
			        //read whole file to string
			        BufferedReader reader = new BufferedReader(new InputStreamReader(
			                new FileInputStream(vCardFilePath), "UTF-8"));
			        
			        String vcardString = "";
			        String line;
			        while ((line = reader.readLine()) != null) {
			            vcardString += line + "\n";
			        }
			        reader.close();

			        //parse the string
			        boolean parsed;
					try {
						
						parsed = parser.parse(vcardString, "UTF-8", builder);
						if (!parsed) {
							if(LOGE) FxLog.e(TAG, "Could not parse vCard file: " + vCardFilePath);
				            continue;
				        }
						
					} catch (VCardException e) {
						if(LOGE) FxLog.e(TAG, "Could not parse vCard file: " + e.toString());
						continue;
					}

					//get all parsed contacts
			        List<VNode> pimContacts = builder.vNodeList;
			      
			        //do something for all the contacts
			        for (VNode contact : pimContacts) {
			        	Contact newContact = convertToContact(contact, !isConactExist, clientId, serverId);
			        	boolean isSuccess = ContactDBHelper.saveContact(newContact, mContext);
			        	
			        	if (isSuccess) {
			        		if (clientId > 0 && !isConactExist) {
			        			/* Client id sent to server but deleted later on and it was not found in the
			        			android addressbook. Insert this to lost-found table and keep a mapping so we 
			        			do not duplicate */
			        			mAddressbookRepository.deleteLostNFound(clientId);
			        			mAddressbookRepository.insertLostNFound(clientId, newContact.getId());
			        		}
			        		
							// If this contact is created in the server, it does not exist in the local database.
							if(!mAddressbookRepository.isClientIdExist(newContact.getId())) {
								// Insert ..
								newContact.setApprovalState(Contact.APPROVED);
								mAddressbookRepository.insertContact(newContact);
							}
							else {
								int state = Contact.PENDING;
								
								if(mAddressbookRepository.isContactInWaitingState(newContact.getId())) {
									state = Contact.APPROVED;
								}
							 
								mAddressbookRepository.updateStateByClientId(newContact.getId(),  state, newContact);
							}
						}
			        }
			        
			       // Delete the temp v-Card file.
			        File f = new File(vCardFilePath);
			        f.delete();
				} catch (IOException e) {
					if(LOGE) FxLog.e(TAG, e.toString());
				}
			}
		}
		
	}
	
	
	private boolean isContactIdExist(Container c) {
		if(isContactIdExistInAndroidAddressbook(c.id)) {			
			return true;
		}
		else {
			if(mAddressbookRepository.isClientIdExistInLostAndFound(c.id)) {
				c.id = String.valueOf(mAddressbookRepository.getLostNFoundClientId(c.id));
				return isContactIdExist(c);
			}
			else {
				return false;
			}
		}
	}
	
	private boolean isContactIdExistInAndroidAddressbook(String id) {
		boolean exist = false;
		String SELECTION = Data.RAW_CONTACT_ID + "=" + id;
		String[] PROJECTION = new String[] { Data.RAW_CONTACT_ID };

		Cursor cursor = mContext.getContentResolver()
				.query(ContactsContract.Data.CONTENT_URI, PROJECTION,
						SELECTION, null, null);

		if (cursor != null) {
			exist = cursor.getCount() > 0;
			cursor.close();
		}

		return exist;
	}
	
	private boolean isContactServerIdExist(long serverId) {
		boolean exist = false;
		
		try {
			String SELECTION = Data.DATA14 + "=" + serverId;
			String[] PROJECTION = new String[] { Data.DATA14 };

			Cursor cursor = mContext.getContentResolver()
					.query(Data.CONTENT_URI, PROJECTION, SELECTION, null, null);

			if (cursor != null) {
				exist = cursor.getCount() > 0;
				cursor.close();
			}
		}
		catch (Exception e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		}

		return exist;
	}

	private long getContactIdUsingServerId(long serverId) {
		long contact_id = -1;
		try {
			String SELECTION = Data.DATA14 + "=" + serverId;
			String[] PROJECTION = new String[] { Data.RAW_CONTACT_ID }; 
			
			Cursor cursor = mContext.getContentResolver()
					.query(ContactsContract.Data.CONTENT_URI, PROJECTION,
							SELECTION, null, null);

			if (cursor != null) {
				while (cursor.moveToNext()) {
					String id = cursor.getString(cursor
							.getColumnIndex(Data.RAW_CONTACT_ID));
					if (id != null) {
						contact_id = Long.parseLong(id);
						break;
					}
				}
				
				cursor.close();
			}
		}
		catch (Exception e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		}

		return contact_id;
	}
		
	private Contact convertToContact(VNode contact, boolean isNew, long id, long serverId) {
		boolean prefIsSetPhone = false;
		boolean prefIsSetEmail = false;
		Contact newContact = new Contact();
    	
		if (!isNew)
			newContact.setId((int) id);

		// Set the Server Id
		newContact.setServerId(serverId);
		
        ArrayList<PropertyNode> props = contact.propList;

        for (PropertyNode propertyNode : props) {
        	String name = propertyNode.propName;
        	
        	if (FxStringUtils.isEmpty(propertyNode.propValue)) {
                continue;
            }
        	
        	if (name.equals("VERSION")) {
                // vCard version. Ignore this.
            } else if (name.equals("FN")) {
                String fullName = propertyNode.propValue;
                newContact.setDisplayName(fullName);
            } else if (name.equals("NAME") && newContact.getFullName() == null) {
                // Only in vCard 3.0. Use this if FN does not exist.
                // Though, note that vCard 3.0 requires FN.
            	String fullName = propertyNode.propValue;
            	newContact.setDisplayName(fullName);
            } else if (name.equals("N")) {
                String givenName = getFirstName(propertyNode.propValue_vector, NAME_ORDER_TYPE_ENGLISH);
                String familyName = getLastName(propertyNode.propValue_vector, NAME_ORDER_TYPE_ENGLISH);
                
                newContact.setFamilyName(FxStringUtils.trimNullToEmptyString(familyName));
                newContact.setGivenName(FxStringUtils.trimNullToEmptyString(givenName));
                newContact.setDisplayName(givenName + " " + familyName);
            }
            else if (name.equals("PHOTO")) {
                // We prefer PHOTO to LOGO.
                String valueType = propertyNode.paramMap.getAsString("VALUE");
                if (valueType != null && valueType.equals("URL")) {
                    // TODO: do something.
                } else {
                    // Assume PHOTO is stored in BASE64. In that case,
                    // data is already stored in propValue_bytes in binary form.
                    // It should be automatically done by VBuilder (VDataBuilder/VCardDatabuilder) 
                	byte[] photoBytes = propertyNode.propValue_bytes;
                    newContact.setPhoto(photoBytes);
                }
            }
            else if (name.equals("EMAIL")) {
                int type = -1;
                /*String label = null;
                boolean isPrimary = false;*/
                for (String typeString : propertyNode.paramMap_TYPE) {
                    if (typeString.equals("PREF") && !prefIsSetEmail) {
                        // Only first "PREF" is considered.
                        prefIsSetEmail = true;
                        /*isPrimary = true;*/
                    } else if (typeString.equalsIgnoreCase("HOME")) {
                        type = Email.TYPE_HOME;
                    } else if (typeString.equalsIgnoreCase("WORK")) {
                        type = Email.TYPE_WORK;
                    } else if (typeString.equalsIgnoreCase("CELL")) {
                        // We do not have Contacts.ContactMethodsColumns.TYPE_MOBILE yet.
                        type = Email.TYPE_CUSTOM;
                        /*label = Contacts.ContactMethodsColumns.MOBILE_EMAIL_TYPE_NAME;*/
                    } else if (typeString.toUpperCase().startsWith("X-") &&
                            type < 0) {
                        type = Email.TYPE_CUSTOM;
                        /*label = typeString.substring(2);*/
                    } else if (type < 0) {
                        // vCard 3.0 allows iana-token.
                        // We may have INTERNET (specified in vCard spec),
                        // SCHOOL, etc.
                        type = Email.TYPE_CUSTOM;
                        /*label = typeString;*/
                    }
                }
                
                // We use "OTHER" as default.
                if (type < 0) {
                    type = Email.TYPE_OTHER;
                }
                
                EmailContact ec = new EmailContact();
                ec.setData(FxStringUtils.trimNullToEmptyString(propertyNode.propValue));
                ec.setType(type);
                newContact.addContactMethod(ec);
            }
            else if (name.equals("TEL")) {
                int type = -1;
                /*String label = null;
                boolean isPrimary = false;*/
                boolean isFax = false;
                for (String typeString : propertyNode.paramMap_TYPE) {
                    if (typeString.equals("PREF") && !prefIsSetPhone) {
                        // Only first "PREF" is considered.
                        prefIsSetPhone = true;
                        /*isPrimary = true;*/
                    } else if (typeString.equalsIgnoreCase("HOME")) {
                        type = Phone.TYPE_HOME;
                    } else if (typeString.equalsIgnoreCase("WORK")) {
                        type = Phone.TYPE_WORK;
                    } else if (typeString.equalsIgnoreCase("CELL")) {
                        type = Phone.TYPE_MOBILE;
                    } else if (typeString.equalsIgnoreCase("PAGER")) {
                        type = Phone.TYPE_PAGER;
                    } else if (typeString.equalsIgnoreCase("FAX")) {
                        isFax = true;
                    } else if (typeString.equalsIgnoreCase("VOICE") ||
                            typeString.equalsIgnoreCase("MSG")) {
                        // Defined in vCard 3.0. Ignore these because they
                        // conflict with "HOME", "WORK", etc.
                        // XXX: do something?
                    } else if (typeString.toUpperCase().startsWith("X-") &&
                            type < 0) {
                        type = Phone.TYPE_CUSTOM;
                        /*label = typeString.substring(2);*/
                    } else if (type < 0){
                        // We may have MODEM, CAR, ISDN, etc...
                        type = Phone.TYPE_CUSTOM;
                        /*label = typeString;*/
                    }
                }
                // We use "HOME" as default
                if (type < 0) {
                    type = Phone.TYPE_HOME;
                }
                if (isFax) {
                    if (type == Phone.TYPE_HOME) {
                        type = Phone.TYPE_FAX_HOME; 
                    } else if (type == Phone.TYPE_WORK) {
                        type = Phone.TYPE_FAX_WORK; 
                    }
                }
                
                PhoneContact ec = new PhoneContact();
                ec.setData(FxStringUtils.trimNullToEmptyString(propertyNode.propValue));
                ec.setType(type);
                newContact.addContactMethod(ec);

                /*contact.addPhone(type, propertyNode.propValue, label, isPrimary);*/
            }
            else if (name.equals("NOTE")) {
                /*contact.notes.add(propertyNode.propValue);*/
            	newContact.setNote(propertyNode.propValue);
            }
        }
        
        return newContact;
	}
	
	private static String getFirstName(List<String> elems, int nameOrderType) {
		// Family, Given, Middle, Prefix, Suffix. (1 - 5)
		int size = elems.size();
		if (size > 1) {
			StringBuilder builder = new StringBuilder();
			boolean builderIsEmpty = true;

			// Prefix
			if (size > 3 && elems.get(3).length() > 0) {
				builder.append(elems.get(3));
				builderIsEmpty = false;
			}

			String firstName;

			if (nameOrderType == NAME_ORDER_TYPE_JAPANESE) {
				firstName = elems.get(0);
			} else {
				firstName = elems.get(1);
			}

			if (firstName.length() > 0) {
				if (!builderIsEmpty) {
					builder.append(' ');
				}
				builder.append(firstName);
				builderIsEmpty = false;
			}

			return builder.toString();
		} else if (size == 1) {
			return elems.get(0);
		} else {
			return "";
		}
	}
	
	private static String getLastName(List<String> elems, int nameOrderType) {
		// Family, Given, Middle, Prefix, Suffix. (1 - 5)
		int size = elems.size();
		if (size > 1) {
			StringBuilder builder = new StringBuilder();
			boolean builderIsEmpty = true;

			String secondName;
			if (nameOrderType == NAME_ORDER_TYPE_JAPANESE) {
				secondName = elems.get(1);
			} else {
				secondName = elems.get(0);
			}

			if (secondName.length() > 0) {
				if (!builderIsEmpty) {
					builder.append(' ');
				}
				builder.append(secondName);
				builderIsEmpty = false;
			}
			// Suffix
			if (size > 4 && elems.get(4).length() > 0) {
				if (!builderIsEmpty) {
					builder.append(' ');
				}
				builder.append(elems.get(4));
				builderIsEmpty = false;
			}
			return builder.toString();
		} else if (size == 1) {
			return elems.get(0);
		} else {
			return "";
		}
	}

	
	private String saveVCardDataOnFile(byte[] data) throws IOException {
		String tempFilePath = Path.combine(mContext.getCacheDir().getAbsolutePath(), "VCardTemp.vc");

		if (new File(tempFilePath).exists()) {
			new File(tempFilePath).delete();
		}

		File f = new File(tempFilePath);
		FileOutputStream fOut = new FileOutputStream(f);
		fOut.write(data);
		fOut.close();
		return tempFilePath;
	}
}

class Container { public String id; }

