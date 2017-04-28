/*
     File: UIElementUtilities.m 
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

#import "UIElementUtilities.h"

NSString *const UIElementUtilitiesNoDescription = @"No Description";

@implementation UIElementUtilities


#pragma mark -

+ (pid_t)processIdentifierOfUIElement:(AXUIElementRef)element {
    pid_t pid = 0;   
    if (AXUIElementGetPid (element, &pid) == kAXErrorSuccess) {
	return pid;
    } else {
	return 0;
    }
}

+ (NSArray *)attributeNamesOfUIElement:(AXUIElementRef)element {
    NSArray *attrNames = nil;
    
    AXUIElementCopyAttributeNames(element, (CFArrayRef *)&attrNames);
    
    return [attrNames autorelease];
}

+ (NSArray *)actionNamesOfUIElement:(AXUIElementRef)element {
    NSArray *actionNames = nil;
    
    AXUIElementCopyActionNames(element, (CFArrayRef *)&actionNames);
    
    return [actionNames autorelease];
}


+ (NSString *)descriptionOfAction:(NSString *)actionName ofUIElement:(AXUIElementRef)element {
    NSString *actionDescription = nil;
    
    AXUIElementCopyActionDescription(element, (CFStringRef)actionName, (CFStringRef *)&actionDescription);
    
    return [actionDescription autorelease];
}

+ (void)performAction:(NSString *)actionName ofUIElement:(AXUIElementRef)element {
    AXUIElementPerformAction( element, (CFStringRef)actionName);
}

// -------------------------------------------------------------------------------
//	valueOfExistingAttribute:attribute:element
//
//	Given a uiElement and its attribute, return the value of an accessibility object's attribute.
// -------------------------------------------------------------------------------
+ (id)valueOfAttribute:(NSString *)attribute ofUIElement:(AXUIElementRef)element
{
    id result = nil;
    NSArray *attributeNames = [UIElementUtilities attributeNamesOfUIElement:element];
    
    if (attributeNames) {
        if ( [attributeNames indexOfObject:(NSString *)attribute] != NSNotFound
                &&
        	AXUIElementCopyAttributeValue(element, (CFStringRef)attribute, (CFTypeRef *)&result) == kAXErrorSuccess
        ) {
            [result autorelease];
        }
    }
    return result;
}

+ (BOOL)canSetAttribute:(NSString *)attributeName ofUIElement:(AXUIElementRef)element {
    Boolean isSettable = false;
    
    AXUIElementIsAttributeSettable(element, (CFStringRef)attributeName, &isSettable);
        
    return (BOOL)isSettable;
}

+ (void)setStringValue:(NSString *)stringValue forAttribute:(NSString *)attributeName ofUIElement:(AXUIElementRef)element;
{
    CFTypeRef	theCurrentValue 	= NULL;
        
    // First, found out what type of value it is.
    if ( attributeName
        && AXUIElementCopyAttributeValue( element, (CFStringRef)attributeName, &theCurrentValue ) == kAXErrorSuccess
        && theCurrentValue) {
    
        CFTypeRef	valueRef = NULL;

        // Set the value using based on the type
        if (AXValueGetType(theCurrentValue) == kAXValueCGPointType) {		// CGPoint
	    float x, y;
            sscanf( [stringValue UTF8String], "x=%g y=%g", &x, &y );
	    CGPoint point = CGPointMake(x, y);
            valueRef = AXValueCreate( kAXValueCGPointType, (const void *)&point );
            if (valueRef) {
                AXUIElementSetAttributeValue( element, (CFStringRef)attributeName, valueRef );
                CFRelease( valueRef );
            }
        }
     	else if (AXValueGetType(theCurrentValue) == kAXValueCGSizeType) {	// CGSize
	    float w, h;
            sscanf( [stringValue UTF8String], "w=%g h=%g", &w, &h );
            CGSize size = CGSizeMake(w, h);
            valueRef = AXValueCreate( kAXValueCGSizeType, (const void *)&size );
            if (valueRef) {
                AXUIElementSetAttributeValue( element, (CFStringRef)attributeName, valueRef );
                CFRelease( valueRef );
            }
        }
     	else if (AXValueGetType(theCurrentValue) == kAXValueCGRectType) {	// CGRect
	    float x, y, w, h;
            sscanf( [stringValue UTF8String], "x=%g y=%g w=%g h=%g", &x, &y, &w, &h );
	    CGRect rect = CGRectMake(x, y, w, h);
            valueRef = AXValueCreate( kAXValueCGRectType, (const void *)&rect );
            if (valueRef) {
                AXUIElementSetAttributeValue( element, (CFStringRef)attributeName, valueRef );
                CFRelease( valueRef );
            }
        }
     	else if (AXValueGetType(theCurrentValue) == kAXValueCFRangeType) {	// CFRange
            CFRange range;
            sscanf( [stringValue UTF8String], "pos=%ld len=%ld", &(range.location), &(range.length) );
            valueRef = AXValueCreate( kAXValueCFRangeType, (const void *)&range );
            if (valueRef) {
                AXUIElementSetAttributeValue( element, (CFStringRef)attributeName, valueRef );
                CFRelease( valueRef );
            }
        }
        else if ([(id)theCurrentValue isKindOfClass:[NSString class]]) {	// NSString
            AXUIElementSetAttributeValue( element, (CFStringRef)attributeName, stringValue );
        }
        else if ([(id)theCurrentValue isKindOfClass:[NSValue class]]) {		// NSValue
            AXUIElementSetAttributeValue( element, (CFStringRef)attributeName, [NSNumber numberWithFloat:[stringValue floatValue]] );
        }
    }
}


+ (AXUIElementRef)parentOfUIElement:(AXUIElementRef)element {
        return (AXUIElementRef)[UIElementUtilities valueOfAttribute:NSAccessibilityParentAttribute ofUIElement:element];
}

+ (NSString *)roleOfUIElement:(AXUIElementRef)element {
        return (NSString *)[UIElementUtilities valueOfAttribute:NSAccessibilityRoleAttribute ofUIElement:element];
}

+ (NSString *)titleOfUIElement:(AXUIElementRef)element {
        return (NSString *)[UIElementUtilities valueOfAttribute:NSAccessibilityTitleAttribute ofUIElement:element];
}

+ (BOOL)isApplicationUIElement:(AXUIElementRef)element {
    return [[UIElementUtilities roleOfUIElement:element] isEqualToString:NSAccessibilityApplicationRole];
}



#pragma mark -

// Flip coordinates

+ (CGPoint)carbonScreenPointFromCocoaScreenPoint:(NSPoint)cocoaPoint {
    NSScreen *foundScreen = nil;
    CGPoint thePoint;
    
    for (NSScreen *screen in [NSScreen screens]) {
	if (NSPointInRect(cocoaPoint, [screen frame])) {
	    foundScreen = screen;
	}
    }

    if (foundScreen) {
	CGFloat screenHeight = [foundScreen frame].size.height;
	
	thePoint = CGPointMake(cocoaPoint.x, screenHeight - cocoaPoint.y - 1);
    } else {
	thePoint = CGPointMake(0.0, 0.0);
    }

    return thePoint;
}


// -------------------------------------------------------------------------------
//	FlippedScreenBounds:bounds
// -------------------------------------------------------------------------------
+ (NSRect) flippedScreenBounds:(NSRect) bounds
{
    float screenHeight = NSMaxY([[[NSScreen screens] objectAtIndex:0] frame]);
    bounds.origin.y = screenHeight - NSMaxY(bounds);
    return bounds;
}


+ (NSRect)frameOfUIElement:(AXUIElementRef)element {

    NSRect bounds = NSZeroRect;
    
    id elementPosition = [UIElementUtilities valueOfAttribute:NSAccessibilityPositionAttribute ofUIElement:element];
    id elementSize = [UIElementUtilities valueOfAttribute:NSAccessibilitySizeAttribute ofUIElement:element];
    
    if (elementPosition && elementSize) {
		NSRect topLeftWindowRect;
		AXValueGetValue((AXValueRef)elementPosition, kAXValueCGPointType, &topLeftWindowRect.origin);
		AXValueGetValue((AXValueRef)elementSize, kAXValueCGSizeType, &topLeftWindowRect.size);
		bounds = [self flippedScreenBounds:topLeftWindowRect];
    }
    return bounds;
}

#pragma mark -
#pragma mark String Descriptions


// -------------------------------------------------------------------------------
//	stringDescriptionOfAXValue:valueRef:beVerbose
//
//	Returns a descriptive string according to the values' structure type.
// -------------------------------------------------------------------------------
+ (NSString *)stringDescriptionOfAXValue:(CFTypeRef)valueRef beingVerbose:(BOOL)beVerbose
{
    NSString *result = @"AXValue???";
    
    switch (AXValueGetType(valueRef)) {
        case kAXValueCGPointType: {
            CGPoint point;
            if (AXValueGetValue(valueRef, kAXValueCGPointType, &point)) {
                if (beVerbose)
                    result = [NSString stringWithFormat:@"<AXPointValue x=%g y=%g>", point.x, point.y];
                else
                    result = [NSString stringWithFormat:@"x=%g y=%g", point.x, point.y];
            }
            break;
        }
        case kAXValueCGSizeType: {
            CGSize size;
            if (AXValueGetValue(valueRef, kAXValueCGSizeType, &size)) {
                if (beVerbose)
                    result = [NSString stringWithFormat:@"<AXSizeValue w=%g h=%g>", size.width, size.height];
                else
                    result = [NSString stringWithFormat:@"w=%g h=%g", size.width, size.height];
            }
            break;
        }
        case kAXValueCGRectType: {
            CGRect rect;
            if (AXValueGetValue(valueRef, kAXValueCGRectType, &rect)) {
                if (beVerbose)
                    result = [NSString stringWithFormat:@"<AXRectValue  x=%g y=%g w=%g h=%g>", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
                else
                    result = [NSString stringWithFormat:@"x=%g y=%g w=%g h=%g", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
            }
            break;
        }
        case kAXValueCFRangeType: {
            CFRange range;
            if (AXValueGetValue(valueRef, kAXValueCFRangeType, &range)) {
                if (beVerbose)
                    result = [NSString stringWithFormat:@"<AXRangeValue pos=%ld len=%ld>", range.location, range.length];
                else
                    result = [NSString stringWithFormat:@"pos=%ld len=%ld", range.location, range.length];
            }
            break;
        }
        default:
            break;
    }
    return result;
}



// -------------------------------------------------------------------------------
//	descriptionOfValue:theValue:beVerbose
//
//	Called from "descriptionForUIElement", return a descripting string (role and title)
//	of the given value (AXUIElementRef).
// -------------------------------------------------------------------------------
+ (NSString *)descriptionOfValue:(CFTypeRef)theValue beingVerbose:(BOOL)beVerbose
{
    NSString *	theValueDescString	= NULL;

    if (theValue) {
    
        if (AXValueGetType(theValue) != kAXValueIllegalType) {
            theValueDescString = [self stringDescriptionOfAXValue:theValue beingVerbose:beVerbose];
        }
        else if (CFGetTypeID(theValue) == CFArrayGetTypeID()) {
            theValueDescString = [NSString stringWithFormat:@"<array of size %d>", [(NSArray *)theValue count]];
        }
        else if (CFGetTypeID(theValue) == AXUIElementGetTypeID()) {
            
            NSString *	uiElementRole  	= NULL;
        
            if (AXUIElementCopyAttributeValue( (AXUIElementRef)theValue, kAXRoleAttribute, (CFTypeRef *)&uiElementRole ) == kAXErrorSuccess) {
                NSString *	uiElementTitle  = NULL;
                
                uiElementTitle = [self valueOfAttribute:NSAccessibilityTitleAttribute ofUIElement:(AXUIElementRef)theValue];
                
                #if 0
                // hack to work around cocoa app objects not having titles yet
                if (uiElementTitle == nil && [uiElementRole isEqualToString:(NSString *)kAXApplicationRole]) {
                    pid_t				theAppPID = 0;
                    ProcessSerialNumber	theAppPSN = {0,0};
                    NSString *			theAppName = NULL;
                    
                    if (AXUIElementGetPid( (AXUIElementRef)theValue, &theAppPID ) == kAXErrorSuccess
                        && GetProcessForPID( theAppPID, &theAppPSN ) == noErr
                        && CopyProcessName( &theAppPSN, (CFStringRef *)&theAppName ) == noErr ) {
                        uiElementTitle = theAppName;
                    }
                }
                #endif

                if (uiElementTitle != nil) {
                    theValueDescString = [NSString stringWithFormat:@"<%@: “%@”>", uiElementRole, uiElementTitle];
                }
                else {
                    theValueDescString = [NSString stringWithFormat:@"<%@>", uiElementRole];
                }
                [uiElementRole release];
            }
            else {
                theValueDescString = [(id)theValue description];
            }
        }
        else {
            theValueDescString = [(id)theValue description];
        }
    }
    
    return theValueDescString;
}

// -------------------------------------------------------------------------------
//	lineageOfUIElement:element
//
//	Return the lineage array or inheritance of a given uiElement.
// -------------------------------------------------------------------------------
+ (NSArray *)lineageOfUIElement:(AXUIElementRef)element
{
    NSArray *lineage = [NSArray array];
    NSString *elementDescr = [self descriptionOfValue:element beingVerbose:NO];
    AXUIElementRef parent = (AXUIElementRef)[self valueOfAttribute:NSAccessibilityParentAttribute ofUIElement:element];

    if (parent != NULL) {
        lineage = [self lineageOfUIElement:parent];
    }
    return [lineage arrayByAddingObject:elementDescr];
}

// -------------------------------------------------------------------------------
//	lineageDescriptionOfUIElement:element
//
//	Return the descriptive string of a uiElement's lineage.
// -------------------------------------------------------------------------------
+ (NSString *)lineageDescriptionOfUIElement:(AXUIElementRef)element
{
    NSMutableString *result = [NSMutableString string];
    NSMutableString *indent = [NSMutableString string];
    NSArray *lineage = [self lineageOfUIElement:element];
    NSString *ancestor;
    NSEnumerator *e = [lineage objectEnumerator];
    while (ancestor = [e nextObject]) {
        [result appendFormat:@"%@%@\n", indent, ancestor];
        [indent appendString:@" "];
    }
    return result;
}

// -------------------------------------------------------------------------------
//	stringDescriptionOfUIElement:inElement
//
//	Return a descriptive string of attributes and actions of a given uiElement.
// -------------------------------------------------------------------------------
+ (NSString *)stringDescriptionOfUIElement:(AXUIElementRef)element
{
    NSMutableString * 	theDescriptionStr = [[NSMutableString new] autorelease];
    NSArray *		theNames;
    CFIndex			nameIndex;
    CFIndex			numOfNames;

    [theDescriptionStr appendFormat:@"%@", [self lineageDescriptionOfUIElement:element]];
    
    // display attributes
    theNames = [UIElementUtilities attributeNamesOfUIElement:element];
    if (theNames) {
    
        numOfNames = [theNames count];
        
        if (numOfNames)
            [theDescriptionStr appendString:@"\nAttributes:\n"];

        for( nameIndex = 0; nameIndex < numOfNames; nameIndex++ ) {
            
            NSString *	theName = NULL;
            id		theValue = NULL;
            Boolean	theSettableFlag = false;
            
            // Grab name
            theName = [theNames objectAtIndex:nameIndex];
                
            // Grab settable field
          	AXUIElementIsAttributeSettable( element, (CFStringRef)theName, &theSettableFlag );
            
            // Add string        
            [theDescriptionStr appendFormat:@"   %@%@:  “%@”\n", theName, (theSettableFlag?@" (W)":@""), [self descriptionForUIElement:element attribute:theName beingVerbose:false]];
        
            [theValue release];
        }
    
    }
    
    // display actions
    theNames = [UIElementUtilities actionNamesOfUIElement:element];
    if (theNames) {
    
        numOfNames = [theNames count];
        
        if (numOfNames)
            [theDescriptionStr appendString:@"\nActions:\n"];

        for( nameIndex = 0; nameIndex < numOfNames; nameIndex++ ) {
            
            NSString *	theName 		= NULL;
           	NSString *	theDesc 		= NULL;
            
            // Grab name
            theName = [theNames objectAtIndex:nameIndex];
            
            // Grab description
		theDesc = [self descriptionOfAction:theName ofUIElement:element];
            
            // Add string        
            [theDescriptionStr appendFormat:@"   %@ - %@\n", theName, theDesc];
        }
    
    }
    
    return theDescriptionStr;
}


// -------------------------------------------------------------------------------
//	descriptionForUIElement:uiElement:beingVerbose
//
//	Return a descripting string (role and title) of the given uiElement (AXUIElementRef).
// -------------------------------------------------------------------------------
+ (NSString *)descriptionForUIElement:(AXUIElementRef)uiElement attribute:(NSString *)name beingVerbose:(BOOL)beVerbose
{
    NSString *	theValueDescString	= NULL;
    CFTypeRef	theValue;
    CFIndex	count;
    if (([name isEqualToString:NSAccessibilityChildrenAttribute]
            ||
         [name isEqualToString:NSAccessibilityRowsAttribute]
        )
            &&
        AXUIElementGetAttributeValueCount(uiElement, (CFStringRef)name, &count) == kAXErrorSuccess) {
        // No need to get the value of large arrays - we just display their size.
		// We don't want to do this with every attribute because AXUIElementGetAttributeValueCount on non-array valued
		// attributes will cause debug spewage.
        theValueDescString = [NSString stringWithFormat:@"<array of size %d>", count];
    } else if (AXUIElementCopyAttributeValue ( uiElement, (CFStringRef)name, &theValue ) == kAXErrorSuccess && theValue) {
        theValueDescString = [self descriptionOfValue:theValue beingVerbose:beVerbose];
    }
    return theValueDescString;
}

// This method returns a 'no description' string by default
+ (NSString *)descriptionOfAXDescriptionOfUIElement:(AXUIElementRef)element {
    id result = [self valueOfAttribute:NSAccessibilityDescriptionAttribute ofUIElement:element];
    return (!result || [result isEqualToString:@""]) ? UIElementUtilitiesNoDescription: [result description];
}





@end
