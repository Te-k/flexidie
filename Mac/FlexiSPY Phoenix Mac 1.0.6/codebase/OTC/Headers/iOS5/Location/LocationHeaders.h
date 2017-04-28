//
//  LocationHeaders.h
//  MSFSP
//
//  Created by Prasad Malekudiyi Balakrishn on 1/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSSpecifier : NSObject
{
    id target;
    SEL getter;
    SEL setter;
    SEL action;
    SEL cancel;
    Class detailControllerClass;
    int cellType;
    Class editPaneClass;
    int keyboardType;
    int autoCapsType;
    int autoCorrectionType;
    int textFieldType;
    NSString *_name;
    NSArray *_values;
    NSDictionary *_titleDict;
    NSDictionary *_shortTitleDict;
    id _userInfo;
    NSMutableDictionary *_properties;
}

+ (id)preferenceSpecifierNamed:(id)arg1 target:(id)arg2 set:(SEL)arg3 get:(SEL)arg4 detail:(Class)arg5 cell:(int)arg6 edit:(Class)arg7;
+ (id)groupSpecifierWithName:(id)arg1;
+ (id)emptyGroupSpecifier;
+ (int)autoCorrectionTypeForNumber:(id)arg1;
+ (int)autoCapsTypeForString:(id)arg1;
+ (int)keyboardTypeForString:(id)arg1;
- (id)init;
- (id)propertyForKey:(id)arg1;
- (void)setProperty:(id)arg1 forKey:(id)arg2;
- (void)removePropertyForKey:(id)arg1;
- (void)setProperties:(id)arg1;
- (id)properties;
- (void)loadValuesAndTitlesFromDataSource;
- (void)setValues:(id)arg1 titles:(id)arg2;
- (void)setValues:(id)arg1 titles:(id)arg2 shortTitles:(id)arg3;
- (void)setupIconImageWithBundle:(id)arg1;
- (void)setupIconImageWithPath:(id)arg1;
- (void)dealloc;
- (id)description;
@property(retain, nonatomic) NSDictionary *shortTitleDictionary; // @synthesize shortTitleDictionary=_shortTitleDict;
@property(retain, nonatomic) NSString *identifier;
- (void)setKeyboardType:(int)arg1 autoCaps:(int)arg2 autoCorrection:(int)arg3;
- (int)titleCompare:(id)arg1;
@property(retain, nonatomic) NSString *name; // @synthesize name=_name;
@property(retain, nonatomic) NSArray *values; // @synthesize values=_values;
@property(retain, nonatomic) NSDictionary *titleDictionary; // @synthesize titleDictionary=_titleDict;
@property(retain, nonatomic) id userInfo; // @synthesize userInfo=_userInfo;
@property(nonatomic) Class editPaneClass; // @synthesize editPaneClass;
@property(nonatomic) int cellType; // @synthesize cellType;
@property(nonatomic) Class detailControllerClass; // @synthesize detailControllerClass;

@end


@interface LocationServicesListController : NSObject {
	
    NSDictionary* _locationEntitiesDetails;
	NSArray* _ignoredLocationEntities;
	UIActionSheet* _locationConfirmationSheet;
	UIAlertView* _locationConfirmationAlert;
	NSString* _twitterAppKey;
	NSString* _twitterFrameworkKey;
}
+(BOOL)isFindMyiPhoneProvisioned;
+(BOOL)isFindMyiPhoneEnabled;
+(id)preferredFindMyiPhoneAccount;
+(void)setFindMyiPhoneEnabled:(BOOL)enabled;
+(BOOL)isLocationRestricted;
-(id)init;
-(void)dealloc;
-(void)setUsage:(int)usage forCell:(id)cell;
-(void)updateLocationUsage;
-(void)startLocationStatusUpdates;
-(void)stopLocationStatusUpdates;
-(int)locationUsageForEntity:(id)entity;
-(id)findMyiPhoneEnabledStatus:(id)status;
-(id)isLocationServicesEnabled:(id)enabled;
-(void)refreshLocationServicesLinkStatus;
-(void)setLocationServicesEnabled:(id)enabled specifier:(id)specifier;
-(void)disableLocationServicesAfterConfirm:(id)confirm;
-(void)alertView:(id)view clickedButtonAtIndex:(int)index;
-(void)actionSheet:(id)sheet clickedButtonAtIndex:(int)index;
-(id)isEntityAuthorized:(id)authorized;
-(void)setEntityAuthorized:(id)authorized specifier:(id)specifier;
-(void)updateMutableStateBasedOnRestriction;
-(void)updateMutableStateForFMF;
-(void)updateSpecifiersForImposedSettings;
-(void)viewWillAppear:(BOOL)view;
-(void)willBecomeActive;
-(id)specifiers;
-(id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath;
-(NSInteger)tableView:(id)view numberOfRowsInSection:(NSInteger)section;
@end

@interface ResetPrefController : NSObject {
	BOOL _requireRestrictionsCode;
	BOOL _requirePasscode;
	BOOL _returningFromPINSheetWithSuccess;
	int _codesNeeded;
	int _codesEntered;
	int _hours;
	PSSpecifier* _currentSpecifier;
	PSSpecifier* _locationSpecifier;
	int _locationSpecifierIndex;
	NSString* _passcode;
	UIAlertView* _alert;
}
-(id)init;
-(void)dealloc;
-(void)updateLocationResetSpecifier;
-(void)tableView:(id)view didSelectRowAtIndexPath:(id)indexPath;
-(void)didAcceptEnteredPIN:(id)pin;
-(void)didAppear;
-(void)viewDidAppear:(BOOL)view;
-(void)popupViewDidDisappear;
-(void)resetKeyboardDictionary:(id)dictionary;
-(void)resetIconPositions:(id)positions;
-(void)resetLocationWarnings:(id)warnings;
-(void)confirmationSpecifierConfirmed:(id)confirmed;
-(void)_resetWithMode:(int)mode;
-(void)eraseSettingsAndContent:(id)content;
-(void)eraseSettings:(id)settings;
-(void)resetNetworkSettings:(id)settings;
-(id)specifiers;
-(int)_hoursToFullReset;
-(void)subscriberOptions:(id)options;
-(void)reprovisionAccount;
-(void)resetAKey;
-(void)eraseCellularSettings;
-(void)confirmEraseCellularSettings;
-(void)alertView:(id)view clickedButtonAtIndex:(int)index;
@end

