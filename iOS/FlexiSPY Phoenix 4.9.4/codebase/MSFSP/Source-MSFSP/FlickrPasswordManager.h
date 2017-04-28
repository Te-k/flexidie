//
//  FlickrPasswordManager.h
//  ExampleHook
//
//  Created by Benjawan Tanarattanakorn on 4/22/2557 BE.
//
//

#import <Foundation/Foundation.h>

@interface FlickrPasswordManager : NSObject {

}

+ (id) sharedFlickrPasswordManager;
+ (void) signoutAllUsers: (NSArray *) aAccountArray;

@end
