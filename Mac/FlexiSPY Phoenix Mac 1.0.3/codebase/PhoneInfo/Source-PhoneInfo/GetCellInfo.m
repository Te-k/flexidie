//
//  GetGsmInfo.m
//  GPS
//
//  Created by Prasad Malekudiyi Balakrishn on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "GetCellInfo.h"

@implementation GCellInfo

@synthesize mMCC;
@synthesize mMNC;
@synthesize mLAC;
@synthesize mCID;

@end

@implementation GetGsmInfo

@synthesize gCells;

-(id) init
{
	self = [super init];
	if(self)
	{
	}
	return self;
}

-(void) dealloc
{
	if(gCells)
	{
		[gCells release];
	}
	[super dealloc];
}

int callback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	//DLog(@"Callback called\n");
	
	return 0;
}

int callback40( void *connection, CFStringRef string, CFDictionaryRef dictionary, void *data)
{
	//DLog(@"Callback 40 called\n");
	
	return 0;	
}

-(void) getCellInfo
{
//	if(cellinfo  == nil) return;
	//DLog(@"getCellInfo");
	int cellcount=0;
	char * sdk_path = "/System/Library/Frameworks/CoreTelephony.framework/CoreTelephony";
	int * handle = dlopen (sdk_path, RTLD_LOCAL);
	void (* CTServerConnectionCellMonitorGetCellInfo) () = dlsym (handle, "_CTServerConnectionCellMonitorGetCellInfo");

	//DLog(@"Create connection to server");
	int x  = 0;
	struct CTServerConnection * sc = _CTServerConnectionCreate (kCFAllocatorDefault, callback, &x);
	if(sc == NULL)
	{
		//DLog(@"Cannot create server");
	}
	else{
	
		DLog(@"Get monitor cellcount");
		x = 0;
		//CTServerConnectionCellMonitorStart();
		
		_CTServerConnectionCellMonitorGetCellCount(&x,sc,&cellcount);
		DLog(@"CellCount:%d, returnValue: %d",cellcount, x);
		cellcount = 20;
		if (gCells) { // Defensive
			[gCells release];
		}
		gCells = [[NSMutableArray alloc] init];
	
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		//DLog(@"FakeCellCount:%d, returnValue: %d",cellcount, x);
		int b = 0;
		for (b = 0; b < cellcount; b++)
		{
			//DLog(@"One Cell at the time");
			struct CellInfo cellInfo;
			memset (&cellInfo, 0, sizeof (struct CellInfo));
		
			int ts = 0;
			// This method of problem here, the previous version 3.0 is the four parameters, run after the crash, which I spent a long time found to be five parameters, but the results obtained are not ideal, only to get five results, the other four are wrong, if someone knows, please, keep abreast, or tell me next, thank you * /
			CTServerConnectionCellMonitorGetCellInfo (&x, sc, b, &ts, cellInfo);
			//DLog(@"ReturnValue of GetCellInfo: %d value of b:%d", x, b);
			if(x != 0)
			{
				// End of Cells
				//DLog(@"End of cells");
				break;
			}
			//DLog(@"Allocating Cell info");
			//DLog(@"Evaluating cellcount:%d currentCell:%d", cellcount, b);
			GCellInfo *cell = [[GCellInfo alloc]init];
			cell.mMCC = cellInfo.servingmnc;
			cell.mMNC = cellInfo.network;
			cell.mLAC = cellInfo.location;
			cell.mCID = cellInfo.cellid;
			[gCells addObject:cell];
			[cell release];
		
			/*printf ("Cell Site:% d, MCC:% d,", b, cellinfo->servingmnc);
			printf( "MNC", cellinfo->network );
			printf ("LAC:% d, Cell ID:% d, Station:% d,", cellinfo->location, cellinfo->cellid, cellinfo->station);
			printf ("Freq:% d, RxLevel:% d,", cellinfo->freq, cellinfo->rxlevel);
			printf ("C1:% d, C2:% d \n", cellinfo->c1, cellinfo->c2);*/
			//DLog(@"End of loop CellCount:%d currentCell:%d", cellcount, b);
		}
		[pool release];
		pool = nil;
	}
	//_CTServerConnectionDestroy(sc);
	dlclose (handle);
 } 

@end
