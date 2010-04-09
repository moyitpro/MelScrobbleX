//
//  Melative.h
//  Melative Example
//
//  Created by Tohno Minagi on 3/14/10.
//  Copyright 2009-2010 James M.. All rights reserved. Licensed under the GPL v3
//

#import <Cocoa/Cocoa.h>
#import <OgreKit/OgreKit.h>

@interface Melative : NSObject {
	NSString * fieldusername;
	NSString * fieldpassword;
	IBOutlet NSTextField * fieldmessage;
	IBOutlet NSTextField * mediatitle;
	IBOutlet NSTextField * segment;
	IBOutlet NSButton * postbutton;
	IBOutlet NSButton * completecheckbox;
	IBOutlet NSPopUpButton * mediatypemenu;
	int choice;
	IBOutlet NSTextField * artist;
	IBOutlet NSTextField * scrobblestatus;
	IBOutlet NSProgressIndicator * APIProgress;
}
@property(copy, readwrite) NSString *fieldpassword;
@property(copy, readwrite) NSString *fieldusername;

-(IBAction)postmessage:(id)sender;
-(IBAction)getnowplaying:(id)sender;
-(IBAction)scrobble:(id)sender;
-(void)loadlogin; 
-(void)musicdetect;
-(void)animedetect;
-(BOOL)reportoutput;
@end
