//
//  WipeDataManager.h
//  WipeDataManager
//
//  Created by Benjawan Tanarattanakorn on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kErrorDomain	@"com.ssmp.WipeOperationDomain"

#define kWipeDataTypeKey	@"wipeDataTypeKey"
#define kWipeDataErrorKey	@"wipeDataErrorKey"

@protocol WipeDataDelegate;

typedef enum {
	kWipeContactType		= 1,			// 000001
	kWipeCallHistoryType	= 1 << 1,		// 000010
	kWipeMessageType		= 1 << 2,		// 000100
	kWipePhoneMemoryType	= 1 << 3,		// 001000
	kWipeEmailAccountType	= 1 << 4,		// 010000
    kWipeOtherAccountsType  = 1 << 5		// 100000
} WipeDataType;

typedef enum {
	kWipeOperationOK					= 0,				// for all types of operation					
	kWipeOperationCannotOpenDatabase	= 1,				// for all operations that deal with database
	kWipeOperationCannotWipePhoneMemory = 2,				// for WipePhoneMemoryOP
	kWipeOperationCannotCreateCustomFunctionForTrigger	= 3,// for WipeMessageOP
	kWipeOperationCannotWipeSmsAndSmsSportlightData		= 4,// for WipeMessageOP
    kWipeOperationCannotGetPeopleFromAddressBookAPI		= 5 // for WipeContactOP
} WipeOperationErrorCode;


@protocol WipeDataManager <NSObject>
@required
- (void) wipeAllData: (id <WipeDataDelegate>) aDelegate;
@end

@protocol WipeDataDelegate <NSObject>
@required
- (void) wipeDataProgress: (WipeDataType) aWipeDataType error: (NSError *) aError;
- (void) wipeAllDataDidFinished;
@end



