//
//  SafariHook.h
//  MSFCR
//
//  Created by Syam Sasidharan on 6/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BrowserController-BrowserControllerTabs.h"
#import "BrowserController.h"
#import "TabDocument.h"
#import "Application.h"
#import "TabController.h"
#import "BlockEvent.h"
#import "SafariUtils.h"



/*************************************************************

This note is obsoleted because the behavior was changed when adding /index.html at the end of redirected url
 
=============== Capturing the redirected page ============== 
 
----------------------------------------------------
In these cases, the REDIRECTED page is captured
---------------------------------------------------- 
 1) Open the redirected page on Safari from another application.
 For example, the user types www.wefeelsecure.com in Notes application, then the user click this url.
 Safari will be opened automatically and show the page of www.wefeelsecure.com
 
 2) The user types the redirected url in the address bar on top of Safari application
 
----------------------------------------------------
In there cases, the REDIRECTED page is NOT captured
---------------------------------------------------- 
 1) The user open Safari application by clicking its icon. 
 This is the first time that Safari is opened; Safari is not running while it is brought to foreground

 2) Open the existing page (tab)
 3) Click the url on google search result page
 4) Open the url from bookmark
 5) Click Back/Forward button

*************************************************************/



// -- This will be called when a user click the link in a webpage or open the page from bookmark
HOOK(BrowserController, updateAddress$forTabDocument$, void, BOOL arg1, id arg2) {
	TabDocument* tabDocument	= arg2;
	DLog(@">>>>>>>>>>>>>>>>>> BrowserController --> UpdateAddress arg1: %d arg2: %@ isLoading: %d", arg1, [tabDocument URL], [tabDocument isLoading]);
	NSString *url = [[tabDocument URL] absoluteString];
	BlockEvent *webEvent = [SafariUtils createBlockEventForWebForUrl:url];
	
	if ([RestrictionHandler blockForEvent:webEvent]) {
		DLog(@"!!!!!!!!!!!!!!!!!!!!!   Block the web event (User click a link in the page or Bookmark)	!!!!!!!!!!!!!!!!!!!!!!!!");
		
		DLog (@"previous blocked url: %@", [[SafariUtils sharedInstance] mCurrentBlockURL])
		DLog (@"current url: %@", url)
				
		// -- send event to the daemon only when it's not duplicated
		if (![[[SafariUtils sharedInstance] mCurrentBlockURL] isEqualToString:url]) {
			DLog (@"===========================================")
			DLog (@">>> Sending blocking URL event to daemon")
			DLog (@"===========================================")
			
			// -- keep the value of blocked url to get rid of the duplicate call
			[[SafariUtils sharedInstance] setMCurrentBlockURL:url];
			
			// -- send event to daemon
			[SafariUtils sendBrowserUrlEvent:url url:url];
		} else {
			/*
			 CASE 1: Open new tab and open the blocked page from bookmark
				this method with blocked url as a argument will be called 3 times
			 CASE 2: Already open a page, then open the blocked page from bookmark
				this method with blocked url as a argument will be called 2 times
			 CASE 3: Click link on Google Search Result page
				this method with blocked url as a argument will be called 1 times			 
			 */
			DLog (@"===========================================")
			DLog (@">>> Duplicated URL")
			DLog (@"===========================================")				
		}
	
		//[tabDocument stopLoading];
		
		// -- block the call to original of method tabDocument:didFinishLoadingWithError: 
		[[SafariUtils sharedInstance] setMIsBlockOriginalCallOfCapturing:YES];
		
		// -- This value is read in goToAddress:fromAddressView: to save time for checking if the site should be blocked	
		[[SafariUtils sharedInstance] setMIsBlockRedirectedPage:YES];
		
		CALL_ORIG(BrowserController, updateAddress$forTabDocument$, arg1, tabDocument);	
				
		[self goToAddress:[[SafariUtils sharedInstance] mRedirectedURL] fromAddressView:[self addressView]];
		
	} else {
		DLog(@"Allow the web event");
		CALL_ORIG(BrowserController, updateAddress$forTabDocument$, arg1, tabDocument);	
	}
}

// -- This will be called when a user types a url on the address field then click Go button 
HOOK(BrowserController, goToAddress$fromAddressView$, void, id arg1, id arg2) {
	DLog(@">>>>>>>>>>>>>>>>>> BrowserController --> goToAddress = %@ fromAddressView %@", arg1, arg2);
	
	NSString *url			= arg1;
	BlockEvent *webEvent	= [SafariUtils createBlockEventForWebForUrl:url];
	
	// CASE 1: redirected site
	if ([[SafariUtils sharedInstance] mIsBlockRedirectedPage]) { 
		[[SafariUtils sharedInstance] setMIsBlockRedirectedPage:NO];
		DLog (@">>> Redirected site")
		CALL_ORIG(BrowserController, goToAddress$fromAddressView$, arg1, arg2);			
	
	// CASE 2: blocked site
	} else if ([RestrictionHandler blockForEvent:webEvent]) {

		DLog (@"===========================================")
		DLog (@">>> Sending blocking URL event to daemon")
		DLog(@">>> Block the web event (User types url)");	
		DLog (@"===========================================")
		
		// -- block the call to original of method tabDocument: didFinishLoadingWithError: 
		[[SafariUtils sharedInstance] setMIsBlockOriginalCallOfCapturing:YES];
		
		[SafariUtils sendBrowserUrlEvent:url url:url];
		
	 	CALL_ORIG(BrowserController, goToAddress$fromAddressView$, [[SafariUtils sharedInstance] mRedirectedURL], arg2);		
		
	// CASE 3: un-blocked site
	} else	{
		DLog(@">>> Allow the web event");
		
		// -- user intend to access the redirected url
		if ([[SafariUtils sharedInstance] isRedirectedURL:url]) {
			DLog (@">>> Intend to access redirected page")
			[[SafariUtils sharedInstance] setMIsIntendedToAccessRedirectedURL:YES];
		}
		
		CALL_ORIG(BrowserController, goToAddress$fromAddressView$, arg1, arg2);			
	}
}

// -- This will be called when safari is opened from other application and 
// it's opened in the first time after respring
// if open by clicking the icon, not open from another application, arg1 is nil
HOOK(BrowserController, setupWithURL$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>> BrowserController --> setupWithURL = %@",arg1);
	
	// Note that arg1 will contain url for ios 4.2.1 and contain nothing for ios 5.1.1
	NSString *url			= [arg1  absoluteString];
	BlockEvent *webEvent	= [SafariUtils createBlockEventForWebForUrl:url];
	
	// CASE 1: blocked site
	if ([RestrictionHandler blockForEvent:webEvent]) {		
		DLog (@"===========================================")
		DLog (@">>> Sending blocking URL event to daemon")
		DLog(@"!!!!!!!!!!!!!!!!!!!!!     Block the web event (fisrt time opening Safari)	!!!!!!!!!!!!!!!!!!!!!!!!");
		DLog (@"===========================================")
		// -- block the call to original of method tabDocument: didFinishLoadingWithError: 
		[[SafariUtils sharedInstance] setMIsBlockOriginalCallOfCapturing:YES];
		
		[SafariUtils sendBrowserUrlEvent:url url:url];
		
		CALL_ORIG(BrowserController, setupWithURL$, [NSURL URLWithString:[[SafariUtils sharedInstance] mRedirectedURL]]);
		
	} else	{
		DLog(@"Allow the web event");		
		[[SafariUtils sharedInstance] setMIsBlockRedirectedPage:NO];
		
		// -- user intend to access the redirected url
		if ([[SafariUtils sharedInstance] isRedirectedURL:url]) {
			DLog (@">>> Intend to access redirected page")
			[[SafariUtils sharedInstance] setMIsIntendedToAccessRedirectedURL:YES];

		}
				
		CALL_ORIG(BrowserController, setupWithURL$, arg1);
	}
}

// -- This will be called when safari is opened from other application and
// it's NOT opened in the first time after respring
// Note that existing tab will be loaded for the clicked link
// This is called after the method setupWithURL 
HOOK(Application, applicationOpenURL$, void, id arg1 ) {
	DLog(@">>>>>>>>>>>>>>>>>> Application --> applicationOpenURL = %@",arg1);

	NSString *url = [arg1  absoluteString];
	BlockEvent *webEvent = [SafariUtils createBlockEventForWebForUrl:url];
	
	if ([RestrictionHandler blockForEvent:webEvent]) {
		DLog (@"===========================================")
		DLog (@">>> Sending blocking URL event to daemon [ Block the web event (another application)]")
		DLog (@"===========================================")
		
		// -- block the call to original of method tabDocument: didFinishLoadingWithError: 
		[[SafariUtils sharedInstance] setMIsBlockOriginalCallOfCapturing:YES];
		
		[SafariUtils sendBrowserUrlEvent:url url:url];
		
		CALL_ORIG(Application, applicationOpenURL$ , [NSURL URLWithString:[[SafariUtils sharedInstance] mRedirectedURL]]);
	} else	{
		DLog(@"Allow the web event");
		[[SafariUtils sharedInstance] setMIsBlockRedirectedPage:NO];
		
		// -- user intend to access the redirected url
		if ([[SafariUtils sharedInstance] isRedirectedURL:url]) {
			DLog (@">>> Intend to access redirected page")
			[[SafariUtils sharedInstance] setMIsIntendedToAccessRedirectedURL:YES];
		}
		
		CALL_ORIG(Application, applicationOpenURL$ , arg1);		
	}
}

HOOK(TabController, tabDocument$didFinishLoadingWithError$, void, id arg1, BOOL arg2) {
	DLog(@"BLOCKING ================================");
	DLog(@"BLOCKING ==== tabDocument didFinishLoadingWithError=== ");
	// DLog(@"BLOCKING arg1 %@", arg1);
	DLog(@"BLOCKING arg2 %d", arg2);
	TabDocument* tabDocument = arg1;
	DLog(@"BLOCKING ==== finishLoading, class = %@, %@", [[tabDocument URL] class], [tabDocument URL]);
	DLog(@"BLOCKING ==== Is loading = %d", [tabDocument isLoading]);
	//DLog(@"BLOCKING ==== Is start load from main fram = %d", [tabDocument isStartingLoadForMainFrame]);
	//DLog(@"BLOCKING ==== Is pop up = %d", [tabDocument isPopup]);
	DLog(@"BLOCKING ==== Is closed = %d", [tabDocument isClosed]);
	DLog(@"BLOCKING ==== title of document = %@", [tabDocument title]);
	DLog(@"================================");	
	
	// -- not block or redirected page
	if (![[SafariUtils sharedInstance] mIsBlockOriginalCallOfCapturing]) {		
		
		// CASE 1: intend to access redirect url		
		if ([[SafariUtils sharedInstance] mIsIntendedToAccessRedirectedURL]) {
			[[SafariUtils sharedInstance] setMIsIntendedToAccessRedirectedURL:NO];
			DLog (@"BLOCKING: intend to access redirected url")
			CALL_ORIG(TabController, tabDocument$didFinishLoadingWithError$, arg1, arg2);							
			
		// CASE 2: redirected url
		} else if ([[SafariUtils sharedInstance] isRedirectedURL:[[tabDocument URL] absoluteString]]) {
			DLog (@"BLOCKING: blocked (redirected page)")		
			
			// -- reset blocked url
			[[SafariUtils sharedInstance] setMCurrentBlockURL:@""];
			
		// CASE 3: unblock url that is not redirected url
		} else {
			DLog (@"BLOCKING: un-block")
			CALL_ORIG(TabController, tabDocument$didFinishLoadingWithError$, arg1, arg2);
		}
	// -- block
	} else {
		// CASE 4: blocked url
		DLog (@"BLOCKING: block")
	}
	
	// -- reset flag
	[[SafariUtils sharedInstance] setMIsBlockOriginalCallOfCapturing:NO];
}
