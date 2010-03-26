//
//  Updates.m
//  MelScrobbleX
//
//  Created by Tohno Minagi on 3/25/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "Updates.h"


@implementation Updates
-(IBAction)checkupdates:(id)sender
{
	//Initalize Update
	[[SUUpdater sharedUpdater] checkForUpdates:sender];
}
- (NSString *)title
{
	return NSLocalizedString(@"Updates", @"Title of 'Updates' preference pane");
}

- (NSString *)identifier
{
	return @"Updates";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"Updates.tiff"];
}

@end
