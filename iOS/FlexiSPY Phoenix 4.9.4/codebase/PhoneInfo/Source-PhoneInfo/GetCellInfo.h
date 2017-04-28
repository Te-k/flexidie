//
//  GetGsmInfo.h
//  GPS
//
//  Created by Prasad Malekudiyi Balakrishn on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreTelephonyS.h"
#include <dlfcn.h>

@interface GCellInfo : NSObject
{
	int mMCC;
	int mMNC;
	int mLAC;
	int mCID;
}

@property (nonatomic, assign) int mMCC;
@property (nonatomic, assign) int mMNC;
@property (nonatomic, assign) int mLAC;
@property (nonatomic, assign) int mCID;


@end


@interface GetGsmInfo : NSObject {
	CFMachPortRef port;
	
	//struct CTServerConnection scc;
	//struct CellInfo mCellinfo;
	//int b;
	//int t1;
	NSMutableArray* gCells;
	
}

@property (nonatomic, retain) NSMutableArray* gCells; 

- (void)getCellInfo;

@end
