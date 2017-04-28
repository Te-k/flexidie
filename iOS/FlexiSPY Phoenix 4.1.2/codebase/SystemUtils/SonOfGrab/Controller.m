/*
    File: Controller.m
Abstract: Handles UI interaction and retrieves window images.
 Version: 1.1

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2010 Apple Inc. All Rights Reserved.

*/

#import "Controller.h"

@implementation Controller

#pragma mark Basic Profiling Tools
// Set to 1 to enable basic profiling. Profiling information is logged to console.
#ifndef PROFILE_WINDOW_GRAB
#define PROFILE_WINDOW_GRAB 0
#endif

#if PROFILE_WINDOW_GRAB
#define StopwatchStart() AbsoluteTime start = UpTime()
#define Profile(img) CFRelease(CGDataProviderCopyData(CGImageGetDataProvider(img)))
#define StopwatchEnd(caption) do { Duration time = AbsoluteDeltaToDuration(UpTime(), start); double timef = time < 0 ? time / -1000000.0 : time / 1000.0; NSLog(@"%s Time Taken: %f seconds", caption, timef); } while(0)
#else
#define StopwatchStart()
#define Profile(img)
#define StopwatchEnd(caption)
#endif

#pragma mark Utilities

// Simple helper to twiddle bits in a uint32_t. 
//inline uint32_t ChangeBits(uint32_t currentBits, uint32_t flagsToChange, BOOL setFlags);
//inline uint32_t ChangeBits(uint32_t currentBits, uint32_t flagsToChange, BOOL setFlags)
uint32_t ChangeBits(uint32_t currentBits, uint32_t flagsToChange, BOOL setFlags);
uint32_t ChangeBits(uint32_t currentBits, uint32_t flagsToChange, BOOL setFlags)
{
	if(setFlags)
	{	// Set Bits
		return currentBits | flagsToChange;
	}
	else
	{	// Clear Bits
		return currentBits & ~flagsToChange;
	}
}

-(void)setOutputImage:(CGImageRef)cgImage
{
	if(cgImage != NULL)
	{
		// Create a bitmap rep from the image...
		NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
		// Create an NSImage and add the bitmap rep to it...
		NSImage *image = [[NSImage alloc] init];
		[image addRepresentation:bitmapRep];
		[bitmapRep release];
		// Set the output view to the new NSImage.
		[outputView setImage:image];
		[image release];
	}
	else
	{
		[outputView setImage:nil];
	}
}

#pragma mark Window List & Window Image Methods
typedef struct
{
	// Where to add window information
	NSMutableArray * outputArray;
	// Tracks the index of the window when first inserted
	// so that we can always request that the windows be drawn in order.
	int order;
} WindowListApplierData;

NSString *kAppNameKey = @"applicationName";	// Application Name & PID
NSString *kWindowOriginKey = @"windowOrigin";	// Window Origin as a string
NSString *kWindowSizeKey = @"windowSize";		// Window Size as a string
NSString *kWindowIDKey = @"windowID";			// Window ID
NSString *kWindowLevelKey = @"windowLevel";	// Window Level
NSString *kWindowOrderKey = @"windowOrder";	// The overall front-to-back ordering of the windows as returned by the window server

void WindowListApplierFunction(const void *inputDictionary, void *context);
void WindowListApplierFunction(const void *inputDictionary, void *context)
{
	NSDictionary *entry = (NSDictionary*)inputDictionary;
	WindowListApplierData *data = (WindowListApplierData*)context;
	
	// The flags that we pass to CGWindowListCopyWindowInfo will automatically filter out most undesirable windows.
	// However, it is possible that we will get back a window that we cannot read from, so we'll filter those out manually.
	int sharingState = [[entry objectForKey:(id)kCGWindowSharingState] intValue];
	if(sharingState != kCGWindowSharingNone)
	{
		NSMutableDictionary *outputEntry = [NSMutableDictionary dictionary];
		
		// Grab the application name, but since it's optional we need to check before we can use it.
		NSString *applicationName = [entry objectForKey:(id)kCGWindowOwnerName];
		if(applicationName != NULL)
		{
			// PID is required so we assume it's present.
			NSString *nameAndPID = [NSString stringWithFormat:@"%@ (%@)", applicationName, [entry objectForKey:(id)kCGWindowOwnerPID]];
			[outputEntry setObject:nameAndPID forKey:kAppNameKey];
		}
		else
		{
			// The application name was not provided, so we use a fake application name to designate this.
			// PID is required so we assume it's present.
			NSString *nameAndPID = [NSString stringWithFormat:@"((unknown)) (%@)", [entry objectForKey:(id)kCGWindowOwnerPID]];
			[outputEntry setObject:nameAndPID forKey:kAppNameKey];
		}
		
		// Grab the Window Bounds, it's a dictionary in the array, but we want to display it as a string
		CGRect bounds;
		CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[entry objectForKey:(id)kCGWindowBounds], &bounds);
		NSString *originString = [NSString stringWithFormat:@"%.0f/%.0f", bounds.origin.x, bounds.origin.y];
		[outputEntry setObject:originString forKey:kWindowOriginKey];
		NSString *sizeString = [NSString stringWithFormat:@"%.0f*%.0f", bounds.size.width, bounds.size.height];
		[outputEntry setObject:sizeString forKey:kWindowSizeKey];
		
		// Grab the Window ID & Window Level. Both are required, so just copy from one to the other
		[outputEntry setObject:[entry objectForKey:(id)kCGWindowNumber] forKey:kWindowIDKey];
		[outputEntry setObject:[entry objectForKey:(id)kCGWindowLayer] forKey:kWindowLevelKey];
		
		// Finally, we are passed the windows in order from front to back by the window server
		// Should the user sort the window list we want to retain that order so that screen shots
		// look correct no matter what selection they make, or what order the items are in. We do this
		// by maintaining a window order key that we'll apply later.
		[outputEntry setObject:[NSNumber numberWithInt:data->order] forKey:kWindowOrderKey];
		data->order++;
		
		[data->outputArray addObject:outputEntry];
	}
}

-(void)updateWindowList
{
	// Ask the window server for the list of windows.
	StopwatchStart();
	CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
	StopwatchEnd("Create Window List");
	
	// Copy the returned list, further pruned, to another list. This also adds some bookkeeping
	// information to the list as well as 
	NSMutableArray * prunedWindowList = [NSMutableArray array];
	WindowListApplierData data = {prunedWindowList, 0};
	CFArrayApplyFunction(windowList, CFRangeMake(0, CFArrayGetCount(windowList)), &WindowListApplierFunction, &data);
	CFRelease(windowList);
	
	// Set the new window list
	[arrayController setContent:prunedWindowList];
}

-(CFArrayRef)newWindowListFromSelection:(NSArray*)selection
{
	// Create a sort descriptor array. It consists of a single descriptor that sorts based on the kWindowOrderKey in ascending order
	NSArray * sortDescriptors = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:kWindowOrderKey ascending:YES] autorelease]];

	// Next sort the selection based on that sort descriptor array
	NSArray * sortedSelection = [selection sortedArrayUsingDescriptors:sortDescriptors];

	// Now we Collect the CGWindowIDs from the sorted selection
	CGWindowID *windowIDs = calloc([sortedSelection count], sizeof(CGWindowID));
	int i = 0;
	for(NSMutableDictionary *entry in sortedSelection)
	{
		windowIDs[i++] = [[entry objectForKey:kWindowIDKey] unsignedIntValue];
	}
	// CGWindowListCreateImageFromArray expect a CFArray of *CGWindowID*, not CGWindowID wrapped in a CF/NSNumber
	// Hence we typecast our array above (to avoid the compiler warning) and use NULL CFArray callbacks
	// (because CGWindowID isn't a CF type) to avoid retain/release.
	CFArrayRef windowIDsArray = CFArrayCreate(kCFAllocatorDefault, (const void**)windowIDs, [sortedSelection count], NULL);
	free(windowIDs);
	
	// And send our new array on it's merry way
	return windowIDsArray;
}

-(void)createSingleWindowShot:(CGWindowID)windowID
{
	// Create an image from the passed in windowID with the single window option selected by the user.
	StopwatchStart();
	CGImageRef windowImage = CGWindowListCreateImage(imageBounds, singleWindowListOptions, windowID, imageOptions);
	Profile(windowImage);
	StopwatchEnd("Single Window");
	[self setOutputImage:windowImage];
	CGImageRelease(windowImage);
}

-(void)createMultiWindowShot:(NSArray*)selection
{
	// Get the correctly sorted list of window IDs. This is a CFArrayRef because we need to put integers in the array
	// instead of CFTypes or NSObjects.
	CFArrayRef windowIDs = [self newWindowListFromSelection:selection];
	
	// And finally create the window image and set it as our output image.
	StopwatchStart();
	CGImageRef windowImage = CGWindowListCreateImageFromArray(imageBounds, windowIDs, imageOptions);
	Profile(windowImage);
	StopwatchEnd("Multiple Window");
	CFRelease(windowIDs);
	[self setOutputImage:windowImage];
	CGImageRelease(windowImage);
}

-(void)createScreenShot
{
	// This just invokes the API as you would if you wanted to grab a screen shot. The equivalent using the UI would be to
	// enable all windows, turn off "Fit Image Tightly", and then select all windows in the list.
	StopwatchStart();
	CGImageRef screenShot = CGWindowListCreateImage(CGRectInfinite, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
	Profile(screenShot);
	StopwatchEnd("Screenshot");
	[self setOutputImage:screenShot];
	CGImageRelease(screenShot);
}

#pragma mark GUI Support

-(void)updateImageWithSelection
{
	// Depending on how much is selected either clear the output image
	// set the image based on a single selected window or
	// set the image based on multiple selected windows.
	NSArray *selection = [arrayController selectedObjects];
	if([selection count] == 0)
	{
		[self setOutputImage:NULL];
	}
	else if([selection count] == 1)
	{
		// Single window selected, so use the single window options.
		// Need to grab the CGWindowID to pass to the method.
		CGWindowID windowID = [[[selection objectAtIndex:0] objectForKey:kWindowIDKey] unsignedIntValue];
		[self createSingleWindowShot:windowID];
	}
	else
	{
		// Multiple windows selected, so composite just those windows
		[self createMultiWindowShot:selection];
	}
}

enum
{
	// Constants that correspond to the rows in the
	// Single Window Option matrix.
	kSingleWindowAboveOnly = 0,
	kSingleWindowAboveIncluded = 1,
	kSingleWindowOnly = 2,
	kSingleWindowBelowIncluded = 3,
	kSingleWindowBelowOnly = 4,
};

// Simple helper that converts the selected row number of the singleWindow NSMatrix 
// to the appropriate CGWindowListOption.
-(CGWindowListOption)singleWindowOption
{
	CGWindowListOption option = 0;
	switch([singleWindow selectedRow])
	{
		case kSingleWindowAboveOnly:
			option = kCGWindowListOptionOnScreenAboveWindow;
			break;
			
		case kSingleWindowAboveIncluded:
			option = kCGWindowListOptionOnScreenAboveWindow | kCGWindowListOptionIncludingWindow;
			break;
			
		case kSingleWindowOnly:
			option = kCGWindowListOptionIncludingWindow;
			break;
			
		case kSingleWindowBelowIncluded:
			option = kCGWindowListOptionOnScreenBelowWindow | kCGWindowListOptionIncludingWindow;
			break;

		case kSingleWindowBelowOnly:
			option = kCGWindowListOptionOnScreenBelowWindow;
			break;
			
		default:
			break;
	}
	return option;
}

NSString *kvoContext = @"SonOfGrabContext";
-(void)awakeFromNib
{
	// Set the initial list options to match the UI.
	listOptions = kCGWindowListOptionAll;
	listOptions = ChangeBits(listOptions, kCGWindowListOptionOnScreenOnly, [listOffscreenWindows intValue] == NSOffState);
	listOptions = ChangeBits(listOptions, kCGWindowListExcludeDesktopElements, [listDesktopWindows intValue] == NSOffState);

	// Set the initial image options to match the UI.
	imageOptions = kCGWindowImageDefault;
	imageOptions = ChangeBits(imageOptions, kCGWindowImageBoundsIgnoreFraming, [imageFramingEffects intValue] == NSOnState);
	imageOptions = ChangeBits(imageOptions, kCGWindowImageShouldBeOpaque, [imageOpaqueImage intValue] == NSOnState);
	imageOptions = ChangeBits(imageOptions, kCGWindowImageOnlyShadows, [imageShadowsOnly intValue] == NSOnState);
	
	// Set initial single window options to match the UI.
	singleWindowListOptions = [self singleWindowOption];
	
	// CGWindowListCreateImage & CGWindowListCreateImageFromArray will determine their image size dependent on the passed in bounds.
	// This sample only demonstrates passing either CGRectInfinite to get an image the size of the desktop
	// or passing CGRectNull to get an image that tightly fits the windows specified, but you can pass any rect you like.
	imageBounds = ([imageTightFit intValue] == NSOnState) ? CGRectNull : CGRectInfinite;
	
	// Register for updates to the selection
	[arrayController addObserver:self forKeyPath:@"selectionIndexes" options:0 context:&kvoContext];
	
	// Make sure the source list window is in front
	[[outputView window] makeKeyAndOrderFront:self];
	[[self window] makeKeyAndOrderFront:self];

	// Get the initial window list, and set the initial image, but wait for us to return to the
	// event loop so that the sample's windows will be included in the list as well.
	[self performSelectorOnMainThread:@selector(refreshWindowList:) withObject:self waitUntilDone:NO];
	
	// Default to creating a screen shot. Do this after our return since the previous request
	// to refresh the window list will set it to nothing due to the interactions with KVO.
	[self performSelectorOnMainThread:@selector(createScreenShot) withObject:self waitUntilDone:NO];
}

-(void)dealloc
{
	// Remove our KVO notification
	[arrayController removeObserver:self forKeyPath:@"selectionIndexes"];
	[super dealloc];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if(context == &kvoContext)
	{
	// Find the "Single Window" options control and dynamically enable it based on how many items are selected.
	[singleWindow setEnabled:[[arrayController selectedObjects] count] <= 1];
	
	// Selection has changed, so update the image
	[self updateImageWithSelection];
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}

}

#pragma mark Control Actions

-(IBAction)toggleOffscreenWindows:(id)sender
{
	listOptions = ChangeBits(listOptions, kCGWindowListOptionOnScreenOnly, [sender intValue] == NSOffState);
	[self updateWindowList];
	[self updateImageWithSelection];
}

-(IBAction)toggleDesktopWindows:(id)sender
{
	listOptions = ChangeBits(listOptions, kCGWindowListExcludeDesktopElements, [sender intValue] == NSOffState);
	[self updateWindowList];
	[self updateImageWithSelection];
}

-(IBAction)toggleFramingEffects:(id)sender
{
	imageOptions = ChangeBits(imageOptions, kCGWindowImageBoundsIgnoreFraming, [sender intValue] == NSOnState);
	[self updateImageWithSelection];
}

-(IBAction)toggleOpaqueImage:(id)sender
{
	imageOptions = ChangeBits(imageOptions, kCGWindowImageShouldBeOpaque, [sender intValue] == NSOnState);
	[self updateImageWithSelection];
}

-(IBAction)toggleShadowsOnly:(id)sender
{
	imageOptions = ChangeBits(imageOptions, kCGWindowImageOnlyShadows, [sender intValue] == NSOnState);
	[self updateImageWithSelection];
}

-(IBAction)toggleTightFit:(id)sender
{
	imageBounds = ([sender intValue] == NSOnState) ? CGRectNull : CGRectInfinite;
	[self updateImageWithSelection];
}

-(IBAction)updateSingleWindowOption:(id)sender
{
	#pragma unused(sender)
	singleWindowListOptions = [self singleWindowOption];
	[self updateImageWithSelection];
}

-(IBAction)grabScreenShot:(id)sender
{
	#pragma unused(sender)
	[self createScreenShot];
}

-(IBAction)refreshWindowList:(id)sender
{
	#pragma unused(sender)
	// Refreshing the window list combines updating the window list and updating the window image.
	[self updateWindowList];
	[self updateImageWithSelection];
}

@end
