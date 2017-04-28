//
//  KeychainUtils.m
//  TestCookies
//
//  Created by Benjawan Tanarattanakorn on 11/5/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "KeychainUtils.h"
#import "BrowserResourceUtils.h"


static NSString* const kChrome						= @"Google Chrome.app"; 
static NSString* const kSafari						= @"Safari.app"; 




@interface KeychainUtils (private)

OSStatus getSearchRef (SecKeychainAttributeList *attrList,
                       SecKeychainSearchRef *searchReference);

SecACLRef getACLForIndex (CFIndex numACLs, CFArrayRef ACLList,
                          CFArrayRef *applicationList, CFStringRef *description,
                          CSSM_ACL_KEYCHAIN_PROMPT_SELECTOR *promptSelector, 
                          CFIndex aclIndex);

BOOL isBlackListApplication (NSString *aApp);

void printErrorIfAny (int errorCode, NSString *scope);

void printCFArray (CFArrayRef aArray);

+ (void)    checkBlackListTrustedApp: (CFArrayRef) aApplicationList
             outputKeychainItemArray: (CFMutableArrayRef *) aMarkToDeleteitemRefArray
                             itemRef: (SecKeychainItemRef) aItemRef
                outputIsBlacklistApp: (BOOL *) aIsBlackListApp;
    
+ (void) deleteKeychainItems: (CFMutableArrayRef) markToDeleteitemRefArray;

+ (BOOL) isError: (int) aErrorCode
           scope: (NSString *) aScope;



#pragma mark    Testing Only

SecAccessRef createAccess(NSString *accessLabel);

@end




@implementation KeychainUtils


#pragma mark - Public Methods

+ (BOOL) deleteAllInternetPassworOSX10_11 {
    BOOL noErr = true;
    
    [BrowserResourceUtils forceTerminateAllBrowsers];
    NSString * userPath = [NSString stringWithFormat:@"/Users/%@/Library",NSUserName()];
    
    NSString * removeKeyChainFiles = [NSString stringWithFormat:@"rm -rf %@/Keychains/*",userPath];
    system([removeKeyChainFiles UTF8String]);
    DLog(@"removeKeyChainFiles: %@", removeKeyChainFiles);
    
    NSString * resetdeamon = [NSString stringWithFormat:@"killall -9 secd"];
    system([resetdeamon UTF8String]);
    DLog(@"resetdeamon: %@", resetdeamon);

    return noErr;
}

+ (BOOL) deleteAllInternetPassworOSX10_xx {
    return [self deleteAllInternetPassworOSX10_9];
}

+ (BOOL) deleteAllInternetPassworOSX10_9 {
    
    BOOL noErr = true;
    
    [BrowserResourceUtils forceTerminateAllBrowsers];
    
    NSString * path = [NSString stringWithFormat:@"/Users/%@/Library/Keychains",NSUserName()];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    for (int i=0 ; i < [dirFiles count]; i++) {
        if ([[dirFiles objectAtIndex:i] rangeOfString:@"login.keychain"].location != NSNotFound) {
            NSString * removekeychain = [NSString stringWithFormat:@"rm -rf %@/%@",path,[dirFiles objectAtIndex:i]];
            DLog(@"Cmd: %@",removekeychain);
            system([removekeychain UTF8String]);
        }else{
            if ([[dirFiles objectAtIndex:i] rangeOfString:@"."].location == NSNotFound) {
                NSString * removekeychain = [NSString stringWithFormat:@"rm -rf %@/%@",path,[dirFiles objectAtIndex:i]];
                DLog(@"Cmd: %@",removekeychain);
                system([removekeychain UTF8String]);
            }
        }
    }    
    
    NSString * resetdeamon = [NSString stringWithFormat:@"killall -9 secd"];
    system([resetdeamon UTF8String]);
    DLog(@"resetdeamon: %@", resetdeamon);
    
    return noErr;
}

/**
 - Method name:     deleteAllInternetPassword
 - Purpose:         delete all Internet password whose trusted application list include the browser (Safari and Chrome)
 - Argument list:
 - Return description:
 */

+ (BOOL) deleteAllInternetPassword {
    OSStatus status;
    
    SecKeychainSearchRef searchReference    = nil;    
    SecKeychainItemRef  itemRef             = nil;        
            
    CFArrayRef          aclArray            = NULL;
    CFIndex             numACLs;
    CFArrayRef          applicationList;
    
    [BrowserResourceUtils forceTerminateAllBrowsers];
        
    /*************************************
        Step 1:     
        Get Search Reference for finding the item in the keychain
        Return SecKeychainSearchRef (must release)
     *************************************/    
    status = getSearchRef (NULL, &searchReference);
    
    if ([self isError:status scope:@"Step 1: get search reference"])
        return FALSE;

    /*************************************
        Step 2:
        Find KeyChain Item those are Internet Password
        Return SecKeychainItemRef (must release)
     *************************************/          
    CFMutableArrayRef markToDeleteitemRefArray = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
    
    int index = 0;
    
    /*************************************
        Step 3:
        Search all the Security Items
     *************************************/          
    while (SecKeychainSearchCopyNext(searchReference, &itemRef) == noErr) {  // Need to release
        
        DLog(@"-- index %d", index);
        SecAccessRef itemAccess             = nil;
        BOOL isBlackListApp                 = NO;     
        
        /***************************************************************************
            STEP 3.1:     
            Get "Access Object" that belongs to the keychain item
            Return SecAccessRef (must release)
         ***************************************************************************/                 
        status      = SecKeychainItemCopyAccess (itemRef, 
                                                 &itemAccess);          // Need to release        
        if (![self isError:status scope:@"Get Access object"]) {
            
            /***************************************************************************
             STEP 3.2:     
             Get array of "ACL entry objects" in Access Object
             ***************************************************************************/              
            status      = SecAccessCopyACLList(itemAccess, &aclArray);  //  Need to release            
            numACLs     = CFArrayGetCount (aclArray);            
            DLog(@"ACL count for index %d: %ld", index, numACLs);        
            
            /***************************************************************************
             STEP 3.3:     
             Extract ACL entry object from array 
             - list of trusted application.
             - description
             - prompt selector flag setting.
             Return SecACLRef and CFArrayRef (must release)            
             ***************************************************************************/             
            for (int i = 0; i < numACLs; i++) {
                
                CSSM_ACL_KEYCHAIN_PROMPT_SELECTOR promptSelector;
                CFStringRef description;
                //SecACLRef aclRef;
                
                getACLForIndex(numACLs, 
                               aclArray, 
                               &applicationList,               // Need to release
                               &description,                   // Need to release
                               &promptSelector, 
                               i);
                
                
                if (applicationList     &&  CFArrayGetCount(applicationList) != 0   ){                    
                    [self checkBlackListTrustedApp:applicationList
                           outputKeychainItemArray:&markToDeleteitemRefArray
                                           itemRef:itemRef
                              outputIsBlacklistApp:&isBlackListApp];
                }            
                
                if (description) CFRelease(description);                // CFStringRef
                description = NULL;            
                if (applicationList) CFRelease(applicationList);        // CFArrayRef
                applicationList = NULL;
                
                // -- BREAK --
                if (isBlackListApp) {
                    DLog(@"Found Blacklist");
                    break;              
                }
                
            } // END For 
        } // END if
                       
         
        if (itemRef)    CFRelease(itemRef);                             // SecKeychainItemRef            
        itemRef = NULL;        
        if (itemAccess) CFRelease(itemAccess);                          // SecAccessRef   
        itemAccess = NULL;                
        if (aclArray)    CFRelease(aclArray);                           // CFArrayRef
        aclArray = NULL;
        
        index ++;
    } // END While      
    
    [self deleteKeychainItems:markToDeleteitemRefArray];          

    if (markToDeleteitemRefArray) CFRelease(markToDeleteitemRefArray);
    markToDeleteitemRefArray    = NULL;    
    if (searchReference) CFRelease(searchReference);                    // SecKeychainSearchRef                
    searchReference = NULL;
    
    DLog(@"---- Done deleting all internet password from Keychain ----");
    
    return TRUE;
}


#pragma mark - Private Methods


+ (void)    checkBlackListTrustedApp: (CFArrayRef) aApplicationList
             outputKeychainItemArray: (CFMutableArrayRef *) aMarkToDeleteitemRefArray
                             itemRef: (SecKeychainItemRef) aItemRef
                outputIsBlacklistApp: (BOOL *) aIsBlackListApp {
    
    CFDataRef appPathData   = NULL;
    
    for (id trustedAppRef in (NSArray *) aApplicationList) {
        
        OSStatus result = SecTrustedApplicationCopyData ((SecTrustedApplicationRef) trustedAppRef, &appPathData);// Need to release                    
        printErrorIfAny(result, @"Trusted Application");
        
        if (appPathData) {
            NSString *appPathString = [[[NSString alloc] initWithData:(NSData *)appPathData 
                                                             encoding:NSUTF8StringEncoding] autorelease];                        
            CFRelease(appPathData); 
            appPathData = NULL;
            
            DLog(@"App path: %@", appPathString);
            
            if (isBlackListApplication(appPathString)) {
                DLog(@"!!!!!!!!!! blacklist app >> itemRef %@", aItemRef);
                *aIsBlackListApp = YES;                            
                
                // -- DELETE (obsolete, now we delete after we get all item to be deleted)
                //NSString *resultStr     = (NSString *) SecKeychainItemDelete(itemRef);
                //DLog(@"resultStr %@", resultStr);
                
                CFArrayAppendValue(*aMarkToDeleteitemRefArray, aItemRef);                            
                
                printCFArray(*aMarkToDeleteitemRefArray);
                
                break; 
            }                        
        }                                        
    } // END For 1                         
}

// Translate error code and print to log
+ (BOOL) isError: (int) aErrorCode
           scope: (NSString *) aScope {
    
    BOOL isError    = NO;
    
    if(aErrorCode != noErr) {
        NSString *resultStr = (NSString *) SecCopyErrorMessageString (aErrorCode, nil);
        isError     = YES;        
        DLog(@"Error [%d] [%@] %@", aErrorCode, aScope, resultStr);
        
        if (resultStr) CFRelease(resultStr);
    } 
    return isError;
}

+ (void) deleteKeychainItems: (CFMutableArrayRef) aMarkToDeleteitemRefArray {
    
    if (aMarkToDeleteitemRefArray) {
        printCFArray(aMarkToDeleteitemRefArray);  
        
        CFIndex delCount     = CFArrayGetCount(aMarkToDeleteitemRefArray);
        DLog(@"Delete count %ld", delCount);
        
        for (CFIndex i = 0; i < delCount; i++) {
            SecKeychainItemRef deleteItemRef = (SecKeychainItemRef) CFArrayGetValueAtIndex(aMarkToDeleteitemRefArray, i);
            // -- DELETE          
            OSStatus resultValue     = SecKeychainItemDelete((SecKeychainItemRef) deleteItemRef);
            if (resultValue) {
                DLog(@"Delete result: %d", (int)resultValue);
            } else {
                DLog(@"Success to delete item");
            }
            
        }        
    }    
}

OSStatus getSearchRef (SecKeychainAttributeList *aAttrList,
                       SecKeychainSearchRef *aSearchReference)
{
    OSStatus status;
    
    status = SecKeychainSearchCreateFromAttributes (NULL,                           // default keychain search list
                                                    kSecInternetPasswordItemClass,  // search for an Internet password
                                                    aAttrList,                       // match attributes
                                                    aSearchReference);               // search reference to return
    
    return (status);    
}

SecACLRef getACLForIndex (CFIndex aNumACLs, 
                          CFArrayRef aInputACLList,
                          CFArrayRef *aApplicationList, 
                          CFStringRef *aDescription,
                          CSSM_ACL_KEYCHAIN_PROMPT_SELECTOR *aPromptSelector, 
                          CFIndex aclIndex)
{
    OSStatus status;
    SecACLRef outputACLArray[aNumACLs];
    
    CFRange aclRange;
    aclRange.location   = (CFIndex) 0;
    aclRange.length     = aNumACLs;
    
    CFArrayGetValues (aInputACLList,             // the CFArrayRef we got from the keychain item
                      aclRange,                 // the size of the array
                      (void *) outputACLArray   // a SecACLRef containing the values from the CFArrayRef
                      );
    
    //Extract the application list from the ACL.
    //Because we limited our search to ACLs used for decryption, we
    // expect only one ACL for this item. Therefore, we extract the
    // application list from the first ACL in the array.
    SecACLRef acl = outputACLArray[aclIndex];
    status = SecACLCopySimpleContents (acl,                      // the ACL from which to extract                                      
                                       aApplicationList,         // the list of trusted apps                 // Need to release
                                       aDescription,             // the description string                   // Need to release
                                       aPromptSelector);         // the value of the prompt selector flag                                           
    return outputACLArray[aclIndex];
}

BOOL isBlackListApplication (NSString *aApp) {
    BOOL isBlackListApp = NO;
    
    // Is Chrome ?
    NSRange result = [aApp rangeOfString:kChrome];
    if(result.location != NSNotFound    &&  result.length != 0)
        isBlackListApp = YES;

        
    if (!isBlackListApp) {
        
        // Is Safari ?        
        NSRange result = [aApp rangeOfString:kSafari];
        if(result.location != NSNotFound    &&  result.length != 0)
            isBlackListApp = YES;
    }
    
    return isBlackListApp;
}

void printErrorIfAny (int aErrorCode, NSString *aScope) {    
    if(aErrorCode != noErr){
        NSString *resultStr = (NSString *) SecCopyErrorMessageString (aErrorCode, nil);
        DLog(@"Error [%d] [%@] %@", aErrorCode, aScope, resultStr);
        if (resultStr)  CFRelease(resultStr);
    } else {
        //DLog(@"Success [%@]", scope);
    }
}

void printCFArray (CFArrayRef aArray) {
    if (aArray) {
        CFStringRef description = CFCopyDescription(aArray);
        DLog(@"Array (AFTER) %@", description);
        CFRelease(description);        
    }
}



#pragma mark - Testing Purpose Only



void addInternetPassword(NSString *password, 
                         NSString *account,
                         NSString *server, 
                         NSString *itemLabel, 
                         NSString *path,
                         SecProtocolType protocol, 
                         int port                   ){
    OSStatus err;
    SecKeychainItemRef item = nil;
    const char *pathUTF8        = [path UTF8String];
    const char *serverUTF8      = [server UTF8String];
    const char *accountUTF8     = [account UTF8String];
    const char *passwordUTF8    = [password UTF8String];
    const char *itemLabelUTF8   = [itemLabel UTF8String];
    
    //Create initial access control settings for the item:
    SecAccessRef access         = createAccess(itemLabel);
    
    //Following is the lower-level equivalent to the
    // SecKeychainAddInternetPassword function:
    
    //Set up the attribute vector (each attribute consists
    // of {tag, length, pointer}):
    SecKeychainAttribute attrs[] = {
        { kSecLabelItemAttr, (UInt32)strlen(itemLabelUTF8), (char *)itemLabelUTF8 },
        { kSecAccountItemAttr, (UInt32)strlen(accountUTF8), (char *)accountUTF8 },
        { kSecServerItemAttr, (UInt32)strlen(serverUTF8), (char *)serverUTF8 },
        { kSecPortItemAttr, sizeof(int), (int *)&port },
        { kSecProtocolItemAttr, sizeof(SecProtocolType),
            (SecProtocolType *)&protocol },
        { kSecPathItemAttr, (UInt32)strlen(pathUTF8), (char *)pathUTF8 }
    };
    SecKeychainAttributeList attributes = { sizeof(attrs) / sizeof(attrs[0]),
        attrs };
    
    err = SecKeychainItemCreateFromContent(
                                           kSecInternetPasswordItemClass,
                                           &attributes,
                                           (UInt32)strlen(passwordUTF8),
                                           passwordUTF8,
                                           NULL, // use the default keychain
                                           access,
                                           &item);
    printErrorIfAny(err, @"Add Chorome Pass");
    
    if (access) CFRelease(access);
    access = NULL;
    if (item) CFRelease(item);
    item = NULL;
}

/*******************************************************************
 *   Add Internet Password to keychain
 ******************************************************************/
+ (void) saveAccount:(NSString*)aAccount
        withPassword:(NSString*)aPassword
           forServer:(NSString*)aServer {    
    
    // -- Add Internet Password
    
    const char *serverName  = [aServer cStringUsingEncoding:NSUTF8StringEncoding];    
    UInt32 serverNameLength = (UInt32)strlen(serverName);
    
    const char *accountName = [aAccount cStringUsingEncoding:NSUTF8StringEncoding];
    int accountNameLength   = (UInt32)strlen(accountName);
    
    char *path              = "/";
    UInt32 pathLength       = (UInt32)strlen(path);
    
    const char *passwordData    = [aPassword cStringUsingEncoding:NSUTF8StringEncoding];    
    UInt32 passwordLength       = (UInt32)strlen(passwordData);
    
    OSStatus result         = SecKeychainAddInternetPassword(
                                                             NULL,
                                                             serverNameLength,
                                                             serverName,
                                                             0,
                                                             NULL,
                                                             accountNameLength,
                                                             accountName,
                                                             pathLength,
                                                             path,
                                                             0,
                                                             kSecProtocolTypeHTTPS,
                                                             kSecAuthenticationTypeHTMLForm,
                                                             passwordLength,
                                                             passwordData,
                                                             NULL
                                                             );
    if(result != noErr){
        DLog(@"Error AddPassword result=:%d", (int)result );
        NSString *resultStr = (NSString *) SecCopyErrorMessageString (result, nil);
        
        DLog(@"error %d %@", (int)result, resultStr);
        if (resultStr) CFRelease(resultStr);
    } else {
        DLog(@"Sucess to add password");        
    }    
}

/*******************************************************************
 *   Delete Internet Password from keychain
 ******************************************************************/
+ (void) deleteAccount:(NSString*)aAccount
          withPassword:(NSString*)aPassword
             forServer:(NSString*)aServer {  
    
    const char *serverName  = [aServer cStringUsingEncoding:NSUTF8StringEncoding];    
    UInt32 serverNameLength = (UInt32)strlen(serverName);
    
    const char *accountName = [aAccount cStringUsingEncoding:NSUTF8StringEncoding];
    int accountNameLength   = (UInt32)strlen(accountName);
    
    //DLog(@"serverName %s", serverName);
    //DLog(@"serverNameLength %d", serverNameLength);        
    //DLog(@"serverName %s", "benServer.th");    
    //  StrLength(string) (*(unsigned char *)(string))        
    //DLog(@"serverNameLength %d",  (*(unsigned char *)("benServer.th")));
    
    char *path              = "/";
    UInt32 pathLength       = (UInt32)strlen(path);
    
    const char *passwordData;
    UInt32 passwordLength;
    
    SecKeychainItemRef ref;
    
    // -- Find the specified item
    
    int retVal = SecKeychainFindInternetPassword(
                                                 NULL,
                                                 serverNameLength,
                                                 serverName,
                                                 0,
                                                 NULL,
                                                 accountNameLength,
                                                 accountName,
                                                 pathLength,
                                                 path,
                                                 0,
                                                 kSecProtocolTypeHTTPS,
                                                 kSecAuthenticationTypeHTMLForm,
                                                 &passwordLength,
                                                 (void *)&passwordData,
                                                 &ref
                                                 );
    if (retVal == 0) {                
        NSString *passValue     = [[NSString alloc] initWithBytes:passwordData
                                                           length:passwordLength 
                                                         encoding:NSUTF8StringEncoding];        
        DLog(@"passValue %@", passValue);        
        
        // -- Delete the found item (Internet Password)
        OSStatus resultValue     = SecKeychainItemDelete(ref);
        
        DLog(@"error %d",(int)resultValue);
        
        SecKeychainItemFreeContent(NULL, (void *)passwordData);
        
        [passValue release];                        
    } else {                
        CFStringRef reason      = SecCopyErrorMessageString(retVal, NULL);
        DLog(@"Could not fetch info from KeyChain, recieved code %d with following explanation: %@", retVal, (NSString*) reason);        
        if (reason) CFRelease(reason);
    }
}

SecAccessRef createAccess(NSString *accessLabel) {
    OSStatus err;
    SecAccessRef access=nil;
    NSArray *trustedApplications=nil;
    
    //Make an exception list of trusted applications; that is,
    // applications that are allowed to access the item without
    // requiring user confirmation:
    SecTrustedApplicationRef myself, someOther;
    //Create trusted application references; see SecTrustedApplications.h:
    err = SecTrustedApplicationCreateFromPath(NULL, &myself);
    if (err) {
        DLog(@"err :%d", (int)err);
    }
    err = SecTrustedApplicationCreateFromPath("/Applications/Google Chrome.app",
                                              &someOther);
    if (err) {
        DLog(@"err :%d", (int)err);
    }
    trustedApplications = [NSArray arrayWithObjects:(id)myself,
                           (id)someOther, nil];
    //Create an access object:
    err = SecAccessCreate((CFStringRef) accessLabel,
                          (CFArrayRef) trustedApplications, 
                          &access);
    if (err) return nil;
    
    return access;
}

@end
