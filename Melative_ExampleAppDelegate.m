//
//  Melative_ExampleAppDelegate.m
//  Melative Example
//
//  Created by Tohno Minagi on 3/14/10.
//  Copyright 2010 James M.. All rights reserved. Covered under the GNU Public License V3
//

#import "Melative_ExampleAppDelegate.h"
#import "PreferenceController.h"
#import "PFMoveApplication.h"

@implementation Melative_ExampleAppDelegate

@synthesize window;
+ (void)initialize
{
	//Create a Dictionary
	NSMutableDictionary * defaultValues = [NSMutableDictionary dictionary];
	
	// Defaults
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:@"ShowAtStartup"];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:@"SuccessDebug"];
	[defaultValues setObject:@"" forKey:@"APIKey"];
	//Register Dictionary
	[[NSUserDefaults standardUserDefaults]
	 registerDefaults:defaultValues];

}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	//Check if Application is in the /Applications Folder
	PFMoveToApplicationsFolderIfNecessary();
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
	//Register Growl
	NSBundle *myBundle = [NSBundle bundleForClass:[Melative_ExampleAppDelegate class]];
	NSString *growlPath = [[myBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl.framework"];
	NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];
	if (growlBundle && [growlBundle load]) {
		// Register ourselves as a Growl delegate
		[GrowlApplicationBridge setGrowlDelegate:self];
	}
	else {
		NSLog(@"ERROR: Could not load Growl.framework");
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
