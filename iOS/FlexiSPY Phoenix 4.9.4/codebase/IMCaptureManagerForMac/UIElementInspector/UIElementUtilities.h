/*
     File: UIElementUtilities.h 
 Abstract: Utility methods to manage AXUIElementRef instances.
  
  Version: 1.4 
  
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

#import <Cocoa/Cocoa.h>

extern NSString *const UIElementUtilitiesNoDescription;

@interface UIElementUtilities : NSObject {}

#pragma mark -
#pragma mark AXUIElementRef cover methods
/* These methods cover the bulk of the AXUIElementRef API found in <HIServices/AXUIElement.h> */

// Attribute values
+ (NSArray *)attributeNamesOfUIElement:(AXUIElementRef)element;
+ (id)valueOfAttribute:(NSString *)attribute ofUIElement:(AXUIElementRef)element;
+ (BOOL)canSetAttribute:(NSString *)attributeName ofUIElement:(AXUIElementRef)element;

// Takes a string value, converts the string to numbers, ranges, points, sizes, rects, if required
+ (void)setStringValue:(NSString *)stringValue forAttribute:(NSString *)attribute ofUIElement:(AXUIElementRef)element;

// Actions
+ (NSArray *)actionNamesOfUIElement:(AXUIElementRef)element;
+ (NSString *)descriptionOfAction:(NSString *)actionName ofUIElement:(AXUIElementRef)element;
+ (void)performAction:(NSString *)actionName ofUIElement:(AXUIElementRef)element;

// Returns 0 if process identifier could not be retrieved.  Process 0 never has valid UI elements
+ (pid_t)processIdentifierOfUIElement:(AXUIElementRef)element;


#pragma mark -
#pragma mark Convenience Methods
/* Convenience methods to return commonly requested attributes of a UI element */

// Returns the frame of the UI element in Cocoa screen coordinates
+ (NSRect)frameOfUIElement:(AXUIElementRef)element;

+ (AXUIElementRef)parentOfUIElement:(AXUIElementRef)element;
+ (NSString *)roleOfUIElement:(AXUIElementRef)element;
+ (NSString *)titleOfUIElement:(AXUIElementRef)element;

+ (BOOL)isApplicationUIElement:(AXUIElementRef)element;

#pragma mark -
// Screen geometry conversions
+ (CGPoint)carbonScreenPointFromCocoaScreenPoint:(NSPoint)cocoaPoint;

#pragma mark -
#pragma mark String Descriptions
/* Methods to return the various strings displayed in the interface */
+ (NSString *)stringDescriptionOfUIElement:(AXUIElementRef)inElement; // Note this is NOT nec. the AXDescription of the UIElement
+ (NSString *)descriptionForUIElement:(AXUIElementRef)uiElement attribute:(NSString *)name beingVerbose:(BOOL)beVerbose;


+ (NSString *)descriptionOfAXDescriptionOfUIElement:(AXUIElementRef)element;

@end
