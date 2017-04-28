//
//  ConfigDecryptor.h
//  ConfigurationManager
//
//  Created by Dominique  Mayrand on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSXMLParser.h>

@interface ConfigDecryptor : NSObject <NSXMLParserDelegate> {
@private
	NSMutableArray			*mFeatures;
	NSMutableArray			*mRemoteCommands;
	NSMutableDictionary		*mSettingIDs;
	NSString				*mLastRemoteCommand;	
	
    BOOL		inCfg;
    NSString*	mConfigurationID;
    NSInteger	mParseMode;        
}

 
- (id) initWithConfigurationID:(NSString*) aForConfiguration;
- (NSArray*) getFeatures;
- (NSArray*) getRemoteCommands;
- (NSDictionary*) getSettingIDs;
- (void) dealloc;

@end
