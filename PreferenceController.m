//
//  PreferenceController.m
//  MelScrobbleX
//
//  Created by Tohno Minagi on 3/25/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "PreferenceController.h"
#import "Login.h"
#import "Updates.h"
#import "MBPreferencesController.h"


@implementation PreferenceController
- (void)awakeFromNib
{
	Login *loginview = [[Login alloc] initWithNibName:@"Login" bundle:nil];
	Updates *updatesview = [[Updates alloc] initWithNibName:@"Updates" bundle:nil];
	[[MBPreferencesController sharedController] setModules:[NSArray arrayWithObjects:loginview, updatesview, nil]];
	[loginview release];
	[updatesview release];
}

- (void)showPreferences:(id)sender
{
	[[MBPreferencesController sharedController] showWindow:sender];
}

@end
