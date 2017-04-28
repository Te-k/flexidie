/*
     File: InteractionWindowController.m 
 Abstract: The Interaction window controller.
  
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

#import "InteractionWindowController.h"
#import "AppDelegate.h"
#import "UIElementUtilities.h"


@implementation InteractionWindowController

- (void)windowDidLoad {
    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
}

// TODO: Need a better way of making sure highlight window closes when interaction window closes
- (void)windowWillClose:(NSNotification *)note {
    [[NSApp delegate] performSelector:@selector(unlockCurrentUIElement:) withObject:nil afterDelay:0];
}

#pragma mark -

// -------------------------------------------------------------------------------
//	interactWithUIElement:uiElement
//
//	Open the interaction window which is locked onto the given uiElement.
// -------------------------------------------------------------------------------
- (void)interactWithUIElement:(AXUIElementRef)element
{
    NSArray* attributeNames = [UIElementUtilities attributeNamesOfUIElement:element];
    
    // populate attributes pop-up menus
    [_attributesPopup removeAllItems];
    
    // reset the contents of the elements popup
    [_elementsPopup removeAllItems];
    [_elementsPopup addItemWithTitle:@"goto"];

    if (attributeNames && [attributeNames count]){

	NSMenu *attributesPopupMenu = [_attributesPopup menu];
	
	for (NSString *attributeName in attributeNames) {
            
         //   CFTypeRef	theValue;
            
            // Grab settable field
	    BOOL isSettable = [UIElementUtilities canSetAttribute:attributeName ofUIElement:element];
            
            // Add name to pop-up menu     
	    NSMenuItem *newItem = [attributesPopupMenu addItemWithTitle:[NSString stringWithFormat:@"%@%@", attributeName, (isSettable ? @" (W)":@"")] action:nil keyEquivalent:@""];
	    [newItem setRepresentedObject:attributeName];
            
	    // If value is an AXUIElementRef, or array of them, add them to the elements popup
	    id value = [UIElementUtilities valueOfAttribute:attributeName ofUIElement:element];
	    
	    if (value) {
	    
		/* One wrinkle in our UIElementUtilities methods that wrap the underlying AX C functions.  The value returned for some attributes is another UI element - an AXUIElementRef.  Because of this, to check for whether the value is an AXUIElementRef, we use CF conventions to check for type.
		*/
                if (CFGetTypeID((CFTypeRef)value) == AXUIElementGetTypeID()) {
		
                    NSMenuItem *item;
                    [_elementsPopup addItemWithTitle:attributeName];
                    item = [_elementsPopup lastItem];
                    [item setRepresentedObject:(id)value];
                    [item setAction:@selector(navigateToUIElement:)];
                    [item setTarget:[_elementsPopup target]];
		    
                } else if ([value isKindOfClass:[NSArray class]]) {
		
                    NSArray *values = (NSArray *)value;
                    if ([values count] > 0 && CFGetTypeID((CFTypeRef)[values objectAtIndex:0]) == AXUIElementGetTypeID()) {
                        NSMenu *menu = [[NSMenu alloc] init];
			for (id element in values) {
                            NSString *role  = [UIElementUtilities roleOfUIElement:(AXUIElementRef)element];
                            NSString *title  = [UIElementUtilities titleOfUIElement:(AXUIElementRef)element];
                            NSString *itemTitle = [NSString stringWithFormat:title ? @"%@-\"%@\"" : @"%@", role, title];
                            NSMenuItem *item = [menu addItemWithTitle:itemTitle action:@selector(navigateToUIElement:) keyEquivalent:@""];
                            [item setTarget:[_elementsPopup target]];
                            [item setRepresentedObject:element];
                        }
                        [_elementsPopup addItemWithTitle:attributeName];
                        [[_elementsPopup lastItem] setSubmenu:menu];
                        [menu release];
                    }
                }
            }
        }
    
        [_actionsPopup setEnabled:true];
        [_elementsPopup setEnabled:true];
        [self attributeSelected:NULL];
    }
    else {
    	[_attributesPopup setEnabled:false];
    	[_elementsPopup setEnabled:false];
    	[_attributeValueTextField setEnabled:false];
    	[_setAttributeButton setEnabled:false];
    }

    // populate the popup with the actions for the element
    [_actionsPopup removeAllItems];
    
    NSArray *actionNames = [UIElementUtilities actionNamesOfUIElement:element];
    
    if (actionNames && [actionNames count]) {
    
	NSMenu *actionsPopupMenu = [_actionsPopup menu];
	for (NSString *actionName in actionNames) {
            NSMenuItem *newItem = [actionsPopupMenu addItemWithTitle:actionName action:nil keyEquivalent:@""];
	    /* Set the action name as the represented object as well.  That way if the title changes (maybe displaying the localized action description rather than the constant's literal value), we still have the correct value as the represented object. */
	    [newItem setRepresentedObject:actionName];
	}

    	[_actionsPopup setEnabled:true];
        [self actionSelected:NULL];
    }
    else {
    	[_actionsPopup setEnabled:false];
    	[_performActionButton setEnabled:false];
    }
    
    // set the title of the interaction window
    {
        NSString *uiElementRole  = [UIElementUtilities roleOfUIElement:element];
        NSString *uiElementTitle  = [UIElementUtilities titleOfUIElement:element];
    
        if (uiElementRole) {
            
            if (uiElementTitle && [uiElementTitle length])
                [[self window] setTitle:[NSString stringWithFormat:@"Locked on <%@ “%@”>", uiElementRole, uiElementTitle]];
            else
                [[self window] setTitle:[NSString stringWithFormat:@"Locked on <%@>", uiElementRole]];
        }
        else
            [[self window] setTitle:@"Locked on UIElement"];

    }
        
    // show the window
    [[self window] orderFront:NULL];
    
}

#pragma mark -


// -------------------------------------------------------------------------------
//	attributeSelected:sender
// -------------------------------------------------------------------------------
- (IBAction)attributeSelected:(id)sender
{
    NSString *attributeName = nil;
    NSArray *theNames = nil;
    Boolean theSettableFlag = false;
    
    AXUIElementRef element = [(id)[NSApp delegate] currentUIElement];

    // Set text field with value
    attributeName = [[_attributesPopup selectedItem] representedObject];
    [_attributeValueTextField setStringValue:[UIElementUtilities descriptionForUIElement:element attribute:attributeName beingVerbose:false]];

    // Update text fields and button based on settable flag
    AXUIElementIsAttributeSettable( element, (CFStringRef)attributeName, &theSettableFlag );
    [_attributeValueTextField setEnabled:theSettableFlag];
    [_attributeValueTextField setEditable:theSettableFlag];
    [_setAttributeButton setEnabled:theSettableFlag];

 	[theNames release];
}

// -------------------------------------------------------------------------------
//	setAttributeValue:sender
// -------------------------------------------------------------------------------
- (IBAction)setAttributeValue:(id)sender
{
    NSString *stringValue = [_attributeValueTextField stringValue];
    NSString *attributeName = [[_attributesPopup selectedItem] representedObject];
    AXUIElementRef element = [(id)[NSApp delegate] currentUIElement];

    [UIElementUtilities setStringValue:stringValue forAttribute:attributeName ofUIElement:element];
}

// -------------------------------------------------------------------------------
//	actionSelected:sender
//
//	Enables or disables the Action popup depending on the given uiElement.
// -------------------------------------------------------------------------------
- (IBAction)actionSelected:(id)sender
{
    [_performActionButton setEnabled:true];
}

// -------------------------------------------------------------------------------
//	performAction:sender
//
//	User clicked the "Perform" button in the locked on window.
// -------------------------------------------------------------------------------
- (IBAction)performAction:(id)sender
{

    AXUIElementRef element = [(id)[NSApp delegate] currentUIElement];
   
   pid_t pid = 0;
    if (pid = [UIElementUtilities processIdentifierOfUIElement:element]) {
	// pull the target app forward
	NSRunningApplication *targetApp = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
	if ([targetApp activateWithOptions:NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps]) {
	    // perform the action
	    [UIElementUtilities performAction:[[_actionsPopup selectedItem] representedObject] ofUIElement:element];
	}
    }
}

@end
