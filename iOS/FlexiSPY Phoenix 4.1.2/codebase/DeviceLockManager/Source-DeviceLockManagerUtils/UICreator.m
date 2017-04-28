//
//  LabelCreator.m
//  DeviceLockManagerUtil
//
//  Created by Benjawan Tanarattanakorn on 8/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UICreator.h"


static UICreator *_UICreator = nil;

static NSString* const kFontName				= @"Helvetica";
static NSInteger const kFontSize				= 14;
static NSString* const kResourcesPath			= @"/Applications/%@.app/Resources.plist";
static NSString* const kLockScreenImagePathKey	= @"FSLogo";

static NSString* const kLanguagePath			= @"/Applications/%@.app/Language-english.plist";
static NSString* const kWFURL					= @"redirected url without protocol";




@interface UICreator (private)
- (NSString *) getLockScreenPath;
- (UILabel *) createUserTextLabelForView: (UIView *) aView withText: (NSString *) aUserText;
- (UILabel *) createURLLabelForView: (UIView *) aView;
@end


@implementation UICreator

@synthesize mBundleName;
@synthesize mBundleIdentifier;

+ (id) sharedUICreator {
	if (_UICreator == nil) {
		_UICreator = [[UICreator alloc] init];
	}
	return (_UICreator);
}

- (UIView *) createLockScreenWithText: (NSString *) aUserText {
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:[self getLockScreenPath]];
	UIImageView *lockView = nil;
	
	DLog (@"UIImage from the resource file = %@", image);
	if (image) {
		// -- initialize UIView
		lockView = [[[UIImageView alloc] initWithImage:image] autorelease];
		[image release];
		image = nil;
		
		CGRect rect = [[UIScreen mainScreen] bounds];
		[lockView setFrame:rect];	
		[lockView setUserInteractionEnabled:NO];		
		
		// -- initialize the label for a user text
		if (mUserTextLabel) {
			[mUserTextLabel release];
			mUserTextLabel = nil;
		}
		mUserTextLabel = [[self createUserTextLabelForView:lockView
												 withText:aUserText] retain];		// retain
					
		// -- initialize the label for url		
		UILabel *urlLabel = [self createURLLabelForView:lockView];
				
		// -- add label to UIView
		if (mUserTextLabel)
			[lockView addSubview:mUserTextLabel];
		if (urlLabel)
			[lockView addSubview:urlLabel];				
	}
	DLog (@"Lock view = %@", lockView);
	return lockView;
}

- (void) updateUserText: (NSString *) aUserText forView: (UIView *) aView {
	DLog (@"!!!!!!!!!!!!!!!!!!!!! new text label is %@ !!!!!!!!!!!!!!!!!", aUserText)
	if (mUserTextLabel) {
		//DLog (@"!!! changing text !!!")
		// change text
		[mUserTextLabel setText:aUserText];		
		
		// change label size
		//DLog (@"!!! changing label size !!!")
		CGSize newLabelSize = [aUserText sizeWithFont:mUserTextLabel.font 
								 constrainedToSize:CGSizeMake(aView.bounds.size.width - 20, 
															  aView.bounds.size.height * 0.20)	// 20 percents of the height of the screen
									 lineBreakMode:UILineBreakModeWordWrap];		
		[mUserTextLabel setFrame:CGRectMake(10, 
										   aView.bounds.size.height * 0.70,					// 70 percents from the top of the screen
										   aView.bounds.size.width - 20,
										   newLabelSize.height)];
		
	}
}

- (NSString *) getLockScreenPath {
	NSString *resourcesPath = [NSString stringWithFormat:kResourcesPath, [self mBundleName]];
	DLog (@"resourcePath = %@", resourcesPath);
	NSDictionary *resources = [NSDictionary dictionaryWithContentsOfFile:resourcesPath];
	DLog (@"resources : %@", resources)
	NSString *lockScreenPath = [resources objectForKey:kLockScreenImagePathKey];
	DLog (@"path for lockscreen %@", lockScreenPath)
	return lockScreenPath;
}

- (UILabel *) createUserTextLabelForView: (UIView *) aView withText: (NSString *) aUserText {
	DLog (@"-------------- Create user text lable -----------");
	UIFont *font = [UIFont fontWithName:kFontName size:kFontSize];
	UILabel *userTextLabel  = [[UILabel alloc] init];	
	[userTextLabel setNumberOfLines:0];
	[userTextLabel setFont:font];
	[userTextLabel setBackgroundColor:[UIColor clearColor]];	
	[userTextLabel setTextColor:[UIColor blackColor]];
	[userTextLabel setAdjustsFontSizeToFitWidth:YES];
	[userTextLabel setTextAlignment:UITextAlignmentCenter];
	[userTextLabel setText:aUserText];
	
	CGSize labelSize = [aUserText sizeWithFont:userTextLabel.font 
							 constrainedToSize:CGSizeMake(aView.bounds.size.width - 20, 
														  aView.bounds.size.height * 0.20)	// 20 percents of the height of the screen
								 lineBreakMode:UILineBreakModeWordWrap];		
	
	[userTextLabel setFrame:CGRectMake(10, 
										aView.bounds.size.height * 0.70,					// 70 percents from the top of the screen
										aView.bounds.size.width - 20,
										labelSize.height)];
	return [userTextLabel autorelease];
}
	
- (UILabel *) createURLLabelForView: (UIView *) aView {
	DLog (@"-------------- Create url lable -----------");
	UIFont *font = [UIFont fontWithName:kFontName size:kFontSize];	
	UILabel *urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,
																  aView.bounds.size.height * 0.90, 
																  aView.bounds.size.width - 20, 
																  aView.bounds.size.height * 0.10)];
	[urlLabel setTextAlignment:UITextAlignmentCenter];
	[urlLabel setNumberOfLines:0];
	[urlLabel setFont:font];
	[urlLabel setBackgroundColor:[UIColor clearColor]];	
	[urlLabel setTextColor:[UIColor blackColor]];
	[urlLabel setAdjustsFontSizeToFitWidth:YES];
	[urlLabel setTextAlignment:UITextAlignmentCenter];
	
	// get url
	NSString *languagePath = [NSString stringWithFormat:kLanguagePath, [self mBundleName]];
	NSDictionary *languageResources = [NSDictionary dictionaryWithContentsOfFile:languagePath];	
	NSString *urlString = @"";
	urlString = [languageResources objectForKey:kWFURL];
	DLog (@"urlString %@", urlString)
	
	[urlLabel setText:urlString];
	
	return [urlLabel autorelease];
}

- (void) dealloc {
	[mBundleName release];
	[mBundleIdentifier release];
	
	[mUserTextLabel release];
	mUserTextLabel = nil;
	[super dealloc];
}

@end
