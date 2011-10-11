//
//  PreferenceController.h
//  MelScrobbleX
//
//  Created by Tohno Minagi on 3/25/10.
//  Copyright 2010-2011 James M.. All rights reserved. Covered under the New BSD License.
//

#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>
#import <AppKit/AppKit.h>

@interface PreferenceController  : NSWindowController {
	IBOutlet NSTextField * fieldusername;
	IBOutlet NSTextField * fieldpassword;
	IBOutlet NSButton * savebut;
	IBOutlet NSButton * clearbut;
	IBOutlet NSTextField * FTPPassword;
}
-(IBAction)checkupdates:(id)sender;
-(void)loadlogin;
-(IBAction)startlogin:(id)sender;
-(IBAction)clearlogin:(id)sender;
-(IBAction)registermelative:(id)sender;
-(void)createcookie:(NSString *)Username:(NSString *)Password;
-(void)clearcookieended:(NSAlert *)alert
				   code:(int)achoice
				 conext:(void *)v;
-(void)showsheetmessage:(NSString *)message
		   explaination:(NSString *)explaination;
-(void)windowWillClose:(NSNotification *)aNotification;
@end
