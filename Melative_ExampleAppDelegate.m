//
//  Melative_ExampleAppDelegate.m
//  Melative Example
//
//  Created by Tohno Minagi on 3/14/10.
//  Copyright 2010 James M.. All rights reserved. Covered under the GNU Public License V3
//

#import "Melative_ExampleAppDelegate.h"
#import "PreferenceController.h"
@implementation Melative_ExampleAppDelegate

@synthesize window;
+ (void)initialize
{
	//Create a Dictionary
	NSMutableDictionary * defaultValues = [NSMutableDictionary dictionary];
	
	// Defaults
	[defaultValues setObject:@"YES" forKey:@"ShowAtStartup"];
	//Register Dictionary
	[[NSUserDefaults standardUserDefaults]
	 registerDefaults:defaultValues];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	//Show Scrobble Window at Launch?
	NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults]autorelease];;
	if ([defaults boolForKey:@"ShowAtStartup"] == 0) {
		// Hide Window
		[window orderOut:self];
	}
	else {
		// Show the Window
		[window makeKeyAndOrderFront:nil];
	}
	
}

- (void) awakeFromNib{
    
    //Create the NSStatusBar and set its length
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
    
    //Used to detect where our files are
    NSBundle *bundle = [NSBundle mainBundle];
    
    //Allocates and loads the images into the application which will be used for our NSStatusItem
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"melativeicon" ofType:@"tiff"]];
    statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"melativeicon" ofType:@"tiff"]];
    
    //Sets the images in our NSStatusItem
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];
    
    //Tells the NSStatusItem what menu to load
    [statusItem setMenu:statusMenu];
    //Sets the tooptip for our item
    [statusItem setToolTip:@"MelScrobbleX"];
    //Enables highlighting
    [statusItem setHighlightMode:YES];
}
- (void) dealloc {
    //Releases the 2 images we loaded into memory
    [statusImage release];
    [statusHighlightImage release];
	[window release];
    [super dealloc];
}
-(IBAction)togglescrobblewindow:(id)sender
{
	if ([window isVisible]) { 
		[window orderOut:self]; 
	} else { 
		[window makeKeyAndOrderFront:self]; 
	} 
}
-(void)showPreferences:(id)sender
{
	//Is preferenceController nil?
	if (!preferenceController) {
		preferenceController = [[PreferenceController alloc] init];
	}
		[preferenceController showWindow:self];
}
@end
