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
	NSString * apikey;
	IBOutlet NSTextView * fieldmessage;
	IBOutlet NSTextField * mediatitle;
	IBOutlet NSTextField * segment;
	IBOutlet NSButton * postbutton;
	IBOutlet NSButton * completecheckbox;
	IBOutlet NSButton * sendtotwitter;
	IBOutlet NSPopUpButton * mediatypemenu;
	int choice;
	IBOutlet NSTextField * artist;
	IBOutlet NSTextField * scrobblestatus;
	IBOutlet NSMenuItem * togglescrobbler;
	IBOutlet NSProgressIndicator * APIProgress;
    BOOL scrobblesuccess;
	NSString * ScrobbledMediaTitle;
	NSString * ScrobbledMediaSegment;
	NSTimer * timer;
}
@property(copy, readwrite) NSString *apikey;
@property(copy, readwrite) NSString *fieldusername;

-(IBAction)postmessage:(id)sender;
-(IBAction)getnowplaying:(id)sender;
-(IBAction)scrobble:(id)sender;
-(void)musicdetect;
-(void)animedetect;
-(int)scrobble;
-(int)postupdate;
-(BOOL)reportoutput;
-(IBAction)toggletimer:(id)sender;
-(void)firetimer:(NSTimer *)aTimer;
-(void)showsheetmessage:(NSString *)message
		   explaination:(NSString *)explaination;
-(NSString*) reportplayer;;
-(IBAction)uploadimage:(id)sender;
-(void)openPanelDidEnd:(NSOpenPanel *)openPanel
			returnCode:(int)returnCode
		   contextInfo:(void *)x;
@end
