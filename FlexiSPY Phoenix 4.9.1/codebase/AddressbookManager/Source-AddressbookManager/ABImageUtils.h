//
//  ABImageUtils.h
//  AddressbookManager
//
//  Created by Makara Khloth on 10/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ContactPhoto;

@interface ABImageUtils : NSObject {

}

+ (ContactPhoto *) contactPhotoFillLargePhoto: (NSInteger) aContactID;
+ (void) saveContactLargePhotoIfNotExist: (ContactPhoto *) aPhoto contactID: (NSInteger) aContactID;

@end
