//
//  Melative.h
//  Melative Example
//
//  Created by Tohno Minagi on 3/14/10.
//  Copyright 2009-2010 James M.. All rights reserved. Licensed under the GPL v3
//

#import <Cocoa/Cocoa.h>


@interface Melative : NSObject {
	IBOutlet NSTextField * fieldusername;
	IBOutlet NSTextField * fieldpassword;
	IBOutlet NSTextField * fieldmessage;
	IBOutlet NSTextField * mediatitle;
	IBOutlet NSTextField * segment;
	IBOutlet NSButton * postbutton;
		IBOutlet NSPopUpButton * mediatypemenu;
	int choice;
}
-(IBAction)postmessage:(id)sender;
-(IBAction)getnowplaying:(id)sender;
@end
