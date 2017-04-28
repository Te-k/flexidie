//
//  BlockEvent.h
//  RestrictionManagerUtils
//
//  Created by Syam Sasidharan on 6/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
/*************************************************************************************
 * Class Name           :
 * Project Name         :
 * Class Description    :
 * Author               :
 * Maintaned By         :
 * Date created         :
 * Company Info         :
 * Copyright Info       :
 **************************************************************************************/
#import <Foundation/Foundation.h>


enum {
	kCallEvent	= 1,	
    kSMSEvent	= 2,
    kMMSEvent	= 4,
    kEmailEvent	= 8,
    kIMEvent	= 16,
	kWebEvent	= 32,
	kApplicationEvent	= 64
};

enum {
	kBlockEventDirectionIn	= 1,
	kBlockEventDirectionOut	= 2,
    kBlockEventDirectionAll	= 3
};


@interface BlockEvent : NSObject {
@private
    NSInteger	mType;
    NSInteger	mDirection;
    
    NSString	*mTelephoneNumber;

    NSArray		*mContacts;
    NSArray		*mParticipants;
    
    NSDate		*mDate;
    
    id			mData;
}

- (id) initWithEventType: (NSInteger) aEventType 
          eventDirection: (NSInteger) aDirection 
    eventTelephoneNumber: (id) aTelephoneNumber // NSString of sender/incoming/outgoing call number, it's used in INCOMING/OUTGOING direction to check emergency/notification number
            eventContact: (id) aContact // Most of the case is nil, but if not it's NSString contact name of aTelephoneNumber
       eventParticipants: (id) aParticipants // Must be present it's NSArray (either email or number) of participant except target one
               eventDate: (id) aDate
               eventData: (id) aData;

@property (nonatomic, assign) NSInteger mType;
@property (nonatomic, assign) NSInteger mDirection;

@property (nonatomic, copy) NSString  *mTelephoneNumber;

@property (nonatomic, retain) NSArray *mContacts;
@property (nonatomic, retain) NSArray *mParticipants;

@property (nonatomic, retain) NSDate *mDate;

@property (nonatomic, retain) id mData;


@end
