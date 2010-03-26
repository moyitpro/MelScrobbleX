//
//  Melative_ExampleAppDelegate.m
//  Melative Example
//
//  Created by Tohno Minagi on 3/14/10.
//  Copyright 2010 James M.. All rights reserved. Covered under the GNU Public License V3
//

#import "Melative_ExampleAppDelegate.h"

@implementation Melative_ExampleAppDelegate

@synthesize window;
+ 
(void)initialize
{
	//Create a Dictionary
	NSMutableDictionary * defaultValues = [NSMutableDictionary dictionary];
	
	// Defaults
	
	//Register Dictionary
	[[NSUserDefaults standardUserDefaults]
	 registerDefaults:defaultValues];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	[window makeKeyAndOrderFront:nil];
}

@end
