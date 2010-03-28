//
//  PreferenceController.m
//  MelScrobbleX
//
//  Created by Tohno Minagi on 3/25/10.
//  Copyright 2010 James M.. All rights reserved. Covered under the GNU Public License V3
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
	[loginview loadlogin];
	[loginview release];
	[updatesview release];
}

- (void)showPreferences:(id)sender
{
	[[MBPreferencesController sharedController] showWindow:sender];
}

@end
