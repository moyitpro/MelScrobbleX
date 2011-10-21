//
//  Melative_ExampleAppDelegate.h
//  Melative Example
//
//  Created by Tohno Minagi on 3/14/10.
//  Copyright 2010 James M.. All rights reserved. Covered under the GNU Public License V3
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import <CMCrashReporter/CMCrashReporter.h>
#import "Melative.h"
@class PreferenceController;
@interface Melative_ExampleAppDelegate : NSObject <GrowlApplicationBridgeDelegate> {
	/* User Interface */
    IBOutlet NSWindow *window;
	IBOutlet NSWindow *historywindow;
	IBOutlet NSMenu *statusMenu;
	IBOutlet NSTextView * fieldmessage;
	IBOutlet NSTextField * mediatitle;
	IBOutlet NSTextField * segment;
	IBOutlet NSToolbarItem * postbutton;
	IBOutlet NSButton * completecheckbox;
	IBOutlet NSButton * sendtotwitter;
	IBOutlet NSPopUpButton * mediatypemenu;
	IBOutlet NSTableView * historytable;
	IBOutlet NSTextField * artist;
	IBOutlet NSTextField * scrobblestatus;
	IBOutlet NSMenuItem * togglescrobbler;
    NSStatusItem                *statusItem;
    NSImage                        *statusImage;
    NSImage                        *statusHighlightImage;
	/* Controllers and stuff */
	PreferenceController * preferenceController;
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	Melative * melativeEngine;
	NSTimer * timer;
}
-(IBAction)togglescrobblewindow:(id)sender;
-(void)showPreferences:(id)sender;
-(void)setStatusToolTip:(NSString*)toolTip;
-(void)addrecord:(NSString *)rectitle
	mediasegment:(NSString *)recsegment
			Date:(NSDate *)date
			type:(int)mediatype;
-(IBAction)clearhistory:(id)sender;
-(IBAction)showhistory:(id)sender;
-(void)clearhistoryended:(NSAlert *)alert
					code:(int)choice
				  conext:(void *)v;
-(IBAction)postmessage:(id)sender;
-(IBAction)getnowplaying:(id)sender;
-(IBAction)scrobble:(id)sender;
-(IBAction)resetfields:(id)sender;
-(IBAction)toggletimer:(id)sender;
-(void)firetimer:(NSTimer *)aTimer;
-(void)clearEverything;
-(void)scrobblebypass:(NSAlert *)alert
				 code:(int)achoice
			   conext:(void *)v;
-(void)showsheetmessage:(NSString *)message
		   explaination:(NSString *)explaination;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *historywindow;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;


@end
