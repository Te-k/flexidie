//
//  ResponseFileExecutor.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/6/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Working with the response file from getAddressBook command
 @note Working the same as ResponseFileExecutor class but just want to try using static method
 */

@interface ResponseFileExecutor : NSObject {

}

/**
 Doing the job
 @returns GetAddressBookResponse object (only use to execute address book response)
 @param path response file path
 @param key key of aes crypto
 */
+ (id)executeFile:(NSString *)path withKey:(NSString *)key;

/**
 Doing the job
 @returns any file response objects (commands) except address book
 @param path response file path
 @param key key of aes crypto
 */
+ (id) parseResponse: (NSString *) aFilePath withAESKey: (NSString *) aAESKey;

@end
