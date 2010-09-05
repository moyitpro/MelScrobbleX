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

@class PreferenceController;
@interface Melative_ExampleAppDelegate : NSObject <GrowlApplicationBridgeDelegate> {
    IBOutlet NSWindow *window;
	IBOutlet NSWindow *historywindow;
	IBOutlet NSMenu *statusMenu;
	IBOutlet NSTableView * historytable;
    NSStatusItem                *statusItem;
    NSImage                        *statusImage;
    NSImage                        *statusHighlightImage;
	PreferenceController * preferenceController;
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
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

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *historywindow;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;


@end
