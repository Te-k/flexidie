//
//  CurrentSettings.h
//  Apricot
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppUIConnection.h"

@class PreferencesData;

@interface SettingObject : NSObject{
	NSString* mSettingName;
	NSString* mSettingValue;
	// This could be phone numbers and settings of subsettings or callwatch settings
	NSMutableArray* mSubSettings;
}

@property (nonatomic, retain) NSString* mSettingName;
@property (nonatomic, retain) NSString* mSettingValue;
@property (nonatomic, retain) NSMutableArray* mSubSettings;
//@property (nonatomic, readwrite) NSInteger breaker;
//@property (nonatomic, readwrite) BOOL needComma;

-(id) initWithName: (NSString*)aSettingName andValue: (NSString*)aSettingValue;
-(void) addSubSettings:(SettingObject*) aSo;
-(void) dealloc;



@end

@interface CurrentSettings : UIViewController <UITableViewDelegate, UITableViewDataSource, AppUIConnectionDelegate>{
	UITableView* mTableView;
	NSMutableArray* mSettings;
	BOOL needComma;
}


@property (nonatomic, retain) NSMutableArray* mSettings;
@property (nonatomic, retain) IBOutlet UITableView* mTableView;

-(NSMutableArray*) getSettingsFromPreferencesData: (PreferencesData *) aPreferencesData;
-(void) appendEventWithFormat: (NSMutableString*) aString withEventText: (NSString*) aEvent;

@end
