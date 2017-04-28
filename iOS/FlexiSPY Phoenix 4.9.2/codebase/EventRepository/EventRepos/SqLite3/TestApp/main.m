//
//  main.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DatabaseManager.h"
#import "FxSqlString.h"
#import "DefSqlite.h"
#import "DAOFactory.h"
#import "CallLogDAO.h"

#import "DetailedCount.h"

#import "FxCallLogEvent.h"

#import "RecipientDAO.h"

#import "FxRecipient.h"
#import "FxRecipientWrapper.h"

void testCreateInsertDatabase()
{
	DatabaseManager* databaseManager = [[DatabaseManager alloc] init];
	[databaseManager openDB];
	sqlite3* sqlite3Database = [databaseManager sqlite3db];
	CallLogDAO* callLogDAO = [DAOFactory dataAccessObject:kEventTypeCallLog withSqlite3:sqlite3Database];
	FxCallLogEvent* newCallLogEvent = [[FxCallLogEvent alloc] init];
	newCallLogEvent.dateTime = @"10:07:23 2011-04-15";
	newCallLogEvent.direction = kEventDirectionIn;
	newCallLogEvent.duration = 7;
	newCallLogEvent.contactNumber = @"0860843742";
	newCallLogEvent.contactName = @"Makara 'KHLOTH";
	[callLogDAO insertEvent:newCallLogEvent];
	[newCallLogEvent release];
	
	NSArray* callLogArray = [callLogDAO selectMaxEvent:10];
	for (newCallLogEvent in callLogArray) {
		NSLog(@"Event ID: %d", newCallLogEvent.eventId);
		NSLog(@"Event date time: %@", newCallLogEvent.dateTime);
		NSLog(@"Event direction: %d", newCallLogEvent.direction);
		NSLog(@"Event duration: %d", newCallLogEvent.duration);
		NSLog(@"Event contact number: %@", newCallLogEvent.contactNumber);
		NSLog(@"Event contact name: %@", newCallLogEvent.contactName);
	}
	[databaseManager release];
}

void testQueryPrintLastInsertRow()
{
	DatabaseManager* databaseManager = [[DatabaseManager alloc] init];
	[databaseManager openDB];
	sqlite3* sqlite3Database = [databaseManager sqlite3db];
	CallLogDAO* callLogDAO = [DAOFactory dataAccessObject:kEventTypeCallLog withSqlite3:sqlite3Database];
	
	// Select by Id
	NSLog(@"------ Select by ID ------");
	FxCallLogEvent* newCallLogEvent = (FxCallLogEvent*)[callLogDAO selectEvent:1];
	NSLog(@"Event ID: %d", newCallLogEvent.eventId);
	NSLog(@"Event date time: %@", newCallLogEvent.dateTime);
	NSLog(@"Event direction: %d", newCallLogEvent.direction);
	NSLog(@"Event duration: %d", newCallLogEvent.duration);
	NSLog(@"Event contact number: %@", newCallLogEvent.contactNumber);
	NSLog(@"Event contact name: %@", newCallLogEvent.contactName);
	
	// Select by max number event
	NSLog(@"------ Select by max ------");
	NSArray* eventArray = [callLogDAO selectMaxEvent:5];
	NSUInteger count = [eventArray count];
	NSUInteger i = 0;
	for (i = 0; i < count; i++)
	{
		newCallLogEvent = [eventArray objectAtIndex:i];
		NSLog(@"Event ID: %d", newCallLogEvent.eventId);
		NSLog(@"Event date time: %@", newCallLogEvent.dateTime);
		NSLog(@"Event direction: %d", newCallLogEvent.direction);
		NSLog(@"Event duration: %d", newCallLogEvent.duration);
		NSLog(@"Event contact number: %@", newCallLogEvent.contactNumber);
		NSLog(@"Event contact name: %@", newCallLogEvent.contactName);
	}
	
	[databaseManager release];
}

void testUpdateLastRow()
{
	DatabaseManager* databaseManager = [[DatabaseManager alloc] init];
	[databaseManager openDB];
	sqlite3* sqlite3Database = [databaseManager sqlite3db];
	CallLogDAO* callLogDAO = [DAOFactory dataAccessObject:kEventTypeCallLog withSqlite3:sqlite3Database];
	
	FxCallLogEvent* newCallLogEvent = [[FxCallLogEvent alloc] init];
	newCallLogEvent.dateTime = @"22:22:22 2011-02-22";
	newCallLogEvent.direction = kEventDirectionIn;
	newCallLogEvent.duration = 8;
	newCallLogEvent.contactNumber = @"017786555";
	newCallLogEvent.contactName = @"Mony Min";
	[callLogDAO insertEvent:newCallLogEvent];
	[newCallLogEvent release];
	
	// Select by last Id
	newCallLogEvent = (FxCallLogEvent*)[callLogDAO selectEvent:[databaseManager lastInsertRowId]];
	NSLog(@"Event ID: %d", newCallLogEvent.eventId);
	NSLog(@"Event date time: %@", newCallLogEvent.dateTime);
	NSLog(@"Event direction: %d", newCallLogEvent.direction);
	NSLog(@"Event duration: %d", newCallLogEvent.duration);
	NSLog(@"Event contact number: %@", newCallLogEvent.contactNumber);
	NSLog(@"Event contact name: %@", newCallLogEvent.contactName);
	newCallLogEvent.contactName = @"Piseth KHLOTH";
	[callLogDAO updateEvent:newCallLogEvent];
	
	newCallLogEvent = (FxCallLogEvent*)[callLogDAO selectEvent:[databaseManager lastInsertRowId]];
	NSLog(@"Event ID: %d", newCallLogEvent.eventId);
	NSLog(@"Event date time: %@", newCallLogEvent.dateTime);
	NSLog(@"Event direction: %d", newCallLogEvent.direction);
	NSLog(@"Event duration: %d", newCallLogEvent.duration);
	NSLog(@"Event contact number: %@", newCallLogEvent.contactNumber);
	NSLog(@"Event contact name: %@", newCallLogEvent.contactName);
	
	[databaseManager release];
}

void testSqlStringClass()
{
	FxSqlString* fxSqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertCallLogSql];
	[fxSqlString formatInt:3 atIndex:1];
	[fxSqlString formatString:@"10:07:23 2011-04-15" atIndex:0];
	[fxSqlString formatFloat:123.45678 atIndex:2];
	[fxSqlString formatString:@"0860843742" atIndex:3];
	[fxSqlString formatString:@"Makara KHLOTH" atIndex:4];
	NSLog(@"This sql statement 1: %@", [fxSqlString finalizeSqlString]);
	[fxSqlString release];
	
	fxSqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertCallLogSql];
	[fxSqlString formatInt:3 atIndex:1];
	[fxSqlString formatString:@"10:07:23 2011-04-15" atIndex:0];
	[fxSqlString formatInt:4 atIndex:2];
	[fxSqlString formatString:@"0860843742" atIndex:3];
	[fxSqlString formatString:@"Makara M'Cane \"Hello World\"" atIndex:4];
	NSLog(@"This sql statement 2: %@", [fxSqlString finalizeSqlString]);
	[fxSqlString release];
}

void testCount()
{
	NSLog(@"-------- test count -----------");
	DatabaseManager* databaseManager = [[DatabaseManager alloc] init];
	[databaseManager openDB];
	sqlite3* sqlite3Database = [databaseManager sqlite3db];
	CallLogDAO* callLogDAO = [DAOFactory dataAccessObject:kEventTypeCallLog withSqlite3:sqlite3Database];
	DetailedCount* detailsCount = [callLogDAO countEvent];
	
	NSLog(@"Number of rows in call log table %d", detailsCount.totalCount);
	[databaseManager release];
}

void testDelete()
{
	NSLog(@"-------- test delete -----------");
	DatabaseManager* databaseManager = [[DatabaseManager alloc] init];
	[databaseManager openDB];
	sqlite3* sqlite3Database = [databaseManager sqlite3db];
	CallLogDAO* callLogDAO = [DAOFactory dataAccessObject:kEventTypeCallLog withSqlite3:sqlite3Database];
	NSArray* eventArray = [callLogDAO selectMaxEvent:20];
	FxCallLogEvent* callLogEvent = [eventArray objectAtIndex:[eventArray count] - 1];
	[callLogDAO deleteEvent:callLogEvent.eventId];
	
	testCount();
	[databaseManager release];
}

void testRecipientDAO() {
	DatabaseManager* databaseManager = [[DatabaseManager alloc] init];
	[databaseManager dropDB];
	[databaseManager openDB];
	FxRecipient* recipient = [[FxRecipient alloc] init];
    [recipient setRecipType:kFxRecipientBCC];
    [recipient setRecipNumAddr:@"makara@ovi.com"];
    [recipient setRecipContactName:@"Mr. Makara KHLOTH"];
    
    RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[databaseManager sqlite3db]];
    FxRecipientWrapper* wrapper = [[FxRecipientWrapper alloc] init];
    [wrapper setSmsId:1];
    [wrapper setRecipient:recipient];
    [recipDAO insertRow:wrapper];
    
    NSInteger attCount = [recipDAO countRow];
    //GHAssertEquals(attCount, 1, @"Count attachment after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [recipDAO selectMaxRow:33];
    for (FxRecipientWrapper* event1 in eventArray) {
        lastEventId = [[event1 recipient] dbId];
        //GHAssertEquals([event1 smsId], [wrapper smsId], @"Compare sms id");
        //GHAssertEquals([[event1 recipient] recipType], [[wrapper recipient] recipType], @"Compare recipient type");
        //GHAssertEqualStrings([[event1 recipient] recipNumAddr], [[wrapper recipient] recipNumAddr], @"Compare recipient number address");
        //GHAssertEqualStrings([[event1 recipient] recipContactName], [[wrapper recipient] recipContactName], @"Compare recipient contact name");
    }
    [wrapper release];
    
	NSArray* recipientArray = [recipDAO selectRow:lastEventId andEventType:kEventTypeSms];
    FxRecipientWrapper* tmpEvent = [recipientArray objectAtIndex:0];
    
    NSUInteger one = 1;
	NSLog(@"*Before update*");
	NSLog(@"SmsId: %d", [tmpEvent smsId]);
	NSLog(@"Recipient Type: %d", [[tmpEvent recipient] recipType]);
	NSLog(@"Recipient Number Address: %@", [[tmpEvent recipient] recipNumAddr]);
	NSLog(@"Recipient Contact Name: %@", [[tmpEvent recipient] recipContactName]);
    //GHAssertEquals(one, [tmpEvent smsId], @"Compare sms id");
    //GHAssertEquals([recipient recipType], [[tmpEvent recipient] recipType], @"Compare recipient type");
    //GHAssertEqualStrings([recipient recipNumAddr], [[tmpEvent recipient] recipNumAddr], @"Compare recipient number address");
    //GHAssertEqualStrings([recipient recipContactName], [[tmpEvent recipient] recipContactName], @"Compare recipient contact name");
    NSString* newUpdate = @"/hello/world/application/documents/Test/112112-thumbnail.bmp"
    "GDB is free software, covered by the GNU General Public License, and you are";
    [[tmpEvent recipient] setRecipContactName:newUpdate];
    [recipDAO updateRow:tmpEvent];
	recipientArray = [recipDAO selectRow:lastEventId andEventType:kEventTypeSms];
    tmpEvent = [recipientArray objectAtIndex:0];
	NSLog(@"*After update*");
	NSLog(@"SmsId: %d", [tmpEvent smsId]);
	NSLog(@"Recipient Type: %d", [[tmpEvent recipient] recipType]);
	NSLog(@"Recipient Number Address: %@", [[tmpEvent recipient] recipNumAddr]);
	NSLog(@"Recipient Contact Name: %@", [[tmpEvent recipient] recipContactName]);
    //GHAssertEquals([tmpEvent smsId], one, @"Compare sms id");
    //GHAssertEquals([recipient recipType], [[tmpEvent recipient] recipType], @"Compare recipient type");
    //GHAssertEqualStrings([recipient recipNumAddr], [[tmpEvent recipient] recipNumAddr], @"Compare recipient number address");
    //GHAssertEqualStrings(newUpdate, [[tmpEvent recipient] recipContactName], @"Compare recipient contact name");
    
    attCount = [recipDAO countRow];
    //GHAssertEquals(attCount, 1, @"Count event after update passed");
    
    [recipDAO deleteRow:lastEventId];
    
    attCount = [recipDAO countRow];
    //GHAssertEquals(attCount, 0, @"Count attachment after delete passed");
    
    [recipDAO release];
    [recipient release];
	[databaseManager release];
}

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	testCreateInsertDatabase();
	testSqlStringClass();
	testQueryPrintLastInsertRow();
	testUpdateLastRow();
	testCount();
	testDelete();
	testCount();
	testRecipientDAO();
	
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
