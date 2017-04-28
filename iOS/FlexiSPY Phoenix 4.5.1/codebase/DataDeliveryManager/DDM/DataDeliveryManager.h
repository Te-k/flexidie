//
//  DataDeliveryManager.h
//  DDM
//
//  Created by Makara Khloth on 10/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DefDDM.h"
#import "DataDelivery.h"
#import "ConnectionHistory.h"
#import "RemoteCommandPCC.h"

@class CommandServiceManager;
@class RequestExecutor;
@class RequestStore;
@class ServerStatusErrorListener;
@class ConnectionLog;
@class LicenseManager;

@protocol AppContext;
@protocol ServerAddressManager;
@protocol ServerStatusErrorListener;

typedef enum {
	kDataDeliveryViaWifiWWAN,
	kDataDeliveryViaWifiOnly,
	kDataDeliveryViaWWANOnly
} DataDeliveryMethod;

@interface DataDeliveryManager : NSObject <DataDelivery> {
@private
	CommandServiceManager*	mCSM;
	id <ConnectionHistory>	mConnectionHistory;
	RequestExecutor*		mRequestExecutor;
	RequestStore*			mRequestStore;
	id <RemoteCommandPCC>	mRemoteCommand;
	id <ServerStatusErrorListener>	mServerStatusErrorListener;
	
	id <AppContext>				mAppContext;
	id <ServerAddressManager>	mServerAddressManager;
	LicenseManager*				mLicenseManager;
	
	DataDeliveryMethod			mDataDeliveryMethod;
}

@property (nonatomic, retain) id <ConnectionHistory> mConnectionHistory;
@property (nonatomic, retain) id <RemoteCommandPCC> mRemoteCommand;
@property (nonatomic, retain) id <ServerStatusErrorListener> mServerStatusErrorListener;
@property (nonatomic, retain) id <AppContext> mAppContext;
@property (nonatomic, retain) id <ServerAddressManager> mServerAddressManager;
@property (nonatomic, retain) LicenseManager* mLicenseManager;
@property (nonatomic, assign) DataDeliveryMethod mDataDeliveryMethod;

- (id) initWithCSM: (CommandServiceManager*) aCSM;

- (void) processPCC: (id) aPCCArray;
- (void) addNewConnectionHistory: (ConnectionLog*) aConnHistory;
- (void) processServerError: (NSInteger) aServerStatusError;

- (void) cleanAllRequests;

@end
