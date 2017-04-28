//
//  ProductInfoUtilMacAppDelegate.m
//  ProductInfoUtilMac
//
//  Created by Benjawan Tanarattanakorn on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ProductInfoUtilMacAppDelegate.h"

#import "DataConvertion.h"
#import <AppKit/AppKit.h>

@implementation ProductInfoUtilMacAppDelegate

@synthesize window;


@synthesize mProductId;
@synthesize mProtocolLanguage;
@synthesize mProtocolVersion;
@synthesize mVersionTextField;
@synthesize mNameTextField;
@synthesize mDescriptionTextField;
@synthesize mLanguageTextField;
@synthesize mHashtailTextField;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}



- (IBAction) buttonSavePressed: (id) aSender {
	NSLog(@"\n\nsize of NSInteger:	%d", sizeof(NSInteger));
	NSString *version = [[self mVersionTextField] stringValue];
	NSString *name = [[self mNameTextField] stringValue];
	NSString *description = [[self mDescriptionTextField] stringValue];
	NSString *language = [[self mLanguageTextField] stringValue];
	NSString *hashtail = [[self mHashtailTextField] stringValue] ;
	
	DataConvertion *dataConverion = [[DataConvertion alloc] initWithProductInfoVersion:version 
																				  name:name 
																		   description:description 
																			  language:language 
																			  hashtail:hashtail];
	[dataConverion setMProductId:[[self mProductId] stringValue]];
	[dataConverion setMProtocolLanguage:[[self mProtocolLanguage] stringValue]];
	[dataConverion setMProtocolVersion:[[self mProtocolVersion] stringValue]];
	//	Here is the mock data. So if you put these info in UI, AppContext can encrypt it now because
	//	I put the char array that is resulted from encrypting these info in ProductInfoHelper (a class
	//	in AppContext component) that does decryption.
	//	DataConvertion *dataConverion = [[DataConvertion alloc] initWithProductInfoVersion:@"1.1"
	//																				  name:@"FeelSecure" 
	//																		   description:@"Feel this and that?"
	//																			  language:@"12"
	//																			  hashtail:@"Unknown"];
	
	[dataConverion encryptAndWriteToFile];
 	[dataConverion decryptAndRetrieveProductInfo];
	[dataConverion release];
}


//- (void) viewDidLoad {
//    [super viewDidLoad];
	//[[self mVersionTextField] setDelegate:self];
//	[[self mNameTextField] setDelegate:self];
//	[[self mDescriptionTextField] setDelegate:self];
//	[[self mLanguageTextField] setDelegate:self];
//	[[self mHashtailTextField] setDelegate:self];
//	[[self mProductId] setDelegate:self];
//	[[self mProtocolLanguage] setDelegate:self];
//	[[self mProtocolVersion] setDelegate:self];
//	
//	
//	[[self mVersionTextField] setReturnKeyType:UIReturnKeyDone];
//	[[self mNameTextField] setReturnKeyType:UIReturnKeyDone];
//	[[self mDescriptionTextField] setReturnKeyType:UIReturnKeyDone];
//	[[self mLanguageTextField] setReturnKeyType:UIReturnKeyDone];
//	[[self mHashtailTextField] setReturnKeyType:UIReturnKeyDone];
//	[[self mProductId] setReturnKeyType:UIReturnKeyDone];
//	[[self mProtocolLanguage] setReturnKeyType:UIReturnKeyDone];
//	[[self mProtocolVersion] setReturnKeyType:UIReturnKeyDone];
//	
//	[[self mVersionTextField] addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
//	[[self mNameTextField]  addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
//	[[self mDescriptionTextField]  addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
//	[[self mLanguageTextField]  addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
//	[[self mHashtailTextField]  addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
//	[[self mProductId]  addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
//	[[self mProtocolLanguage]  addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
//	[[self mProtocolVersion]  addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];	
//}



- (void)dealloc {
	[mProductId release];
	[mProtocolLanguage release];
	[mProtocolVersion release];
	[mVersionTextField release];
	[mNameTextField release];
	[mDescriptionTextField release];
	[mLanguageTextField release];
	[mHashtailTextField release];
    [super dealloc];
}


@end
