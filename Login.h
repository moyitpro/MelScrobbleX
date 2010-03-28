//
//  Login.h
//  MelScrobbleX
//
//  Created by Tohno Minagi on 3/25/10.
//  Copyright 2010 James M.. All rights reserved. Covered under the GNU Public License V3
//

#import <Cocoa/Cocoa.h>


@interface Login  : NSViewController {
	IBOutlet NSTextField * fieldusername;
	IBOutlet NSTextField * fieldpassword;
	IBOutlet NSButton * savebut;
	IBOutlet NSButton * clearbut;
	int choice;
}
-(void)loadlogin;
-(IBAction)startlogin:(id)sender;
-(IBAction)clearlogin:(id)sender;

@end
