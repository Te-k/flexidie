/*
 * firefox.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class FirefoxItem, FirefoxApplication, FirefoxColor, FirefoxDocument, FirefoxWindow, FirefoxAttributeRun, FirefoxCharacter, FirefoxParagraph, FirefoxText, FirefoxAttachment, FirefoxWord, FirefoxPrintSettings;

enum FirefoxSavo {
    FirefoxSavoAsk = 'ask ' /* Ask the user whether or not to save the file. */,
    FirefoxSavoNo = 'no  ' /* Do not save the file. */,
    FirefoxSavoYes = 'yes ' /* Save the file. */
};
typedef enum FirefoxSavo FirefoxSavo;

enum FirefoxEnum {
    FirefoxEnumStandard = 'lwst' /* Standard PostScript error handling */,
    FirefoxEnumDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum FirefoxEnum FirefoxEnum;



/*
 * Standard Suite
 */

// A scriptable object.
@interface FirefoxItem : SBObject

@property (copy) NSDictionary *properties;  // All of the object's properties.

- (void) closeSaving:(FirefoxSavo)saving savingIn:(id)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy object(s) and put the copies at a new location.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveAs:(NSString *)as in:(id)in_;  // Save an object.

@end

// An application's top level scripting object.
@interface FirefoxApplication : SBApplication

- (SBElementArray *) documents;
- (SBElementArray *) windows;

@property (readonly) BOOL frontmost;  // Is this the frontmost (active) application?
@property (copy, readonly) NSString *name;  // The name of the application.
@property (copy, readonly) NSString *version;  // The version of the application.

- (FirefoxDocument *) open:(id)x;  // Open an object.
- (void) print:(id)x printDialog:(BOOL)printDialog withProperties:(FirefoxPrintSettings *)withProperties;  // Print an object.
- (void) quitSaving:(FirefoxSavo)saving;  // Quit an application.

@end

// A color.
@interface FirefoxColor : FirefoxItem


@end

// A document.
@interface FirefoxDocument : FirefoxItem

@property (readonly) BOOL modified;  // Has the document been modified since the last save?
@property (copy) NSString *name;  // The document's name.
@property (copy) NSString *path;  // The document's path.


@end

// A window.
@interface FirefoxWindow : FirefoxItem

@property NSRect bounds;  // The bounding rectangle of the window.
@property (readonly) BOOL closeable;  // Whether the window has a close box.
@property (copy, readonly) FirefoxDocument *document;  // The document whose contents are being displayed in the window.
@property (readonly) BOOL floating;  // Whether the window floats.
- (NSInteger) id;  // The unique identifier of the window.
@property NSInteger index;  // The index of the window, ordered front to back.
@property (readonly) BOOL miniaturizable;  // Whether the window can be miniaturized.
@property BOOL miniaturized;  // Whether the window is currently miniaturized.
@property (readonly) BOOL modal;  // Whether the window is the application's current modal window.
@property (copy) NSString *name;  // The full title of the window.
@property (readonly) BOOL resizable;  // Whether the window can be resized.
@property (readonly) BOOL titled;  // Whether the window has a title bar.
@property BOOL visible;  // Whether the window is currently visible.
@property (readonly) BOOL zoomable;  // Whether the window can be zoomed.
@property BOOL zoomed;  // Whether the window is currently zoomed.


@end



/*
 * Text Suite
 */

// This subdivides the text into chunks that all have the same attributes.
@interface FirefoxAttributeRun : FirefoxItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end

// This subdivides the text into characters.
@interface FirefoxCharacter : FirefoxItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end

// This subdivides the text into paragraphs.
@interface FirefoxParagraph : FirefoxItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end

// Rich (styled) text
@interface FirefoxText : FirefoxItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end

// Represents an inline text attachment.  This class is used mainly for make commands.
@interface FirefoxAttachment : FirefoxText

@property (copy) NSString *fileName;  // The path to the file for the attachment


@end

// This subdivides the text into words.
@interface FirefoxWord : FirefoxItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end



/*
 * Type Definitions
 */

@interface FirefoxPrintSettings : SBObject

@property NSInteger copies;  // the number of copies of a document to be printed
@property BOOL collating;  // Should printed copies be collated?
@property NSInteger startingPage;  // the first page of the document to be printed
@property NSInteger endingPage;  // the last page of the document to be printed
@property NSInteger pagesAcross;  // number of logical pages laid across a physical page
@property NSInteger pagesDown;  // number of logical pages laid out down a physical page
@property (copy) NSDate *requestedPrintTime;  // the time at which the desktop printer should print the document
@property FirefoxEnum errorHandling;  // how errors are handled
@property (copy) NSString *faxNumber;  // for fax number
@property (copy) NSString *targetPrinter;  // for target printer

- (void) closeSaving:(FirefoxSavo)saving savingIn:(id)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy object(s) and put the copies at a new location.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveAs:(NSString *)as in:(id)in_;  // Save an object.

@end

