//
//  Login.h
//  MelScrobbleX
//
//  Created by Tohno Minagi on 3/25/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Login  : NSViewController {
	IBOutlet NSTextField * fieldusername;
	IBOutlet NSTextField * fieldpassword;
	IBOutlet NSButton * savebut;
	IBOutlet NSButton * clearbut;
	int choice;
}
-(IBAction)startlogin:(id)sender;
-(IBAction)clearlogin:(id)sender;
@end
