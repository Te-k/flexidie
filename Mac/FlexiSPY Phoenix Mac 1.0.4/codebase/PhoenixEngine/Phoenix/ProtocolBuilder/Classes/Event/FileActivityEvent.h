//
//  FileActivityEvent.h
//  ProtocolBuilder
//
//  Created by ophat on 9/29/15.
//
//

#import <Foundation/Foundation.h>

#import "Event.h"


@interface FileActivityEvent : Event {
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    int         mActivityType;
    int         mActivityFileType;
    NSString    *mActivityOwner;
    NSString    *mDateCreated;
    NSString    *mDateModified;
    NSString    *mDateAccessed;
    id          mOriginalFile;
    id          mModifiedFile;
}
@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, assign) int mActivityType;
@property (nonatomic, assign) int mActivityFileType;
@property (nonatomic, copy) NSString *mActivityOwner;
@property (nonatomic, copy) NSString *mDateCreated;
@property (nonatomic, copy) NSString *mDateModified;
@property (nonatomic, copy) NSString *mDateAccessed;
@property (nonatomic, retain) id mOriginalFile;
@property (nonatomic, retain) id mModifiedFile;

@end
