//
//  Melative_ExampleAppDelegate.h
//  Melative Example
//
//  Created by Tohno Minagi on 3/14/10.
//  Copyright 2010 James M.. All rights reserved. Covered under the GNU Public License V3
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

@class PreferenceController;
@interface Melative_ExampleAppDelegate : NSObject <GrowlApplicationBridgeDelegate> {
    IBOutlet NSWindow *window;
	IBOutlet NSMenu *statusMenu;
    NSStatusItem                *statusItem;
    NSImage                        *statusImage;
    NSImage                        *statusHighlightImage;
	PreferenceController * preferenceController;
}
-(IBAction)togglescrobblewindow:(id)sender;
-(void)showPreferences:(id)sender;
@property (assign) IBOutlet NSWindow *window;

@end
