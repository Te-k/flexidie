//
//  AlertLocationEventProvider.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/14/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "AlertLocationEventProvider.h"
#import "LocationEvent.h"
#import "CellInfo.h"

@implementation AlertLocationEventProvider

@synthesize total;

-(id)init {
	if (self = [super init]) {
		total = 1;
		count = 0;
	}
	return self;
}

-(BOOL)hasNext {
	return (count < total);
}

-(id)getObject {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSString *dateString = [dateFormatter stringFromDate:[NSDate date]]; 
	[dateFormatter release];
	
	LocationEvent *event = [[LocationEvent alloc] init];
	[event setEventId:count];
	[event setTime:dateString];
	
	[event setCallingModule:3];
	
	[event setGpsMethod:3];
	[event setGpsProvider:1];
	
	[event setLat:13.669006];
	[event setLon:100.550823];
	[event setAltitude:10];
	[event setSpeed:2.99];
	[event setHeading:9.33];
	[event setHorizontalAccuracy:7.33];
	[event setVerticalAccuracy:9.22];
	
	CellInfo *cellInfo = [[CellInfo alloc] init];
	[cellInfo setNetworkName:@"cellinfoNName"];
	[cellInfo setNetworkID:@"NID"];
	[cellInfo setCellName:@"cName"];
	[cellInfo setCellID:7];
	[cellInfo setMCC:@"MCC"];
	[cellInfo setAreaCode:9];
	
	[event setCellInfo:cellInfo];
	[cellInfo release];
	
	count ++;
	DLog(@"getObject %@", event);
	return [event autorelease];
}


@end
