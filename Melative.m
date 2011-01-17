//
//  Melative.m
//  MelScrobbleX
//
//  Created by Tohno Minagi on 3/14/10.
//  Copyright 2010 James M.. All rights reserved. Covered under the GNU Public License V3
//

#import "Melative.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "iTunes.h"
#import "Melative_ExampleAppDelegate.h"

@implementation Melative
@synthesize fieldusername;
@synthesize apikey;

- (void) awakeFromNib {
	// Set Default Font Values for fieldmessage
	[fieldmessage setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
	[fieldmessage setTextColor:[NSColor whiteColor]];
}

-(IBAction)postmessage:(id)sender {
// Set Status
[scrobblestatus setObjectValue:@"Posting..."];
//Post the update
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (apikey == nil || apikey !=[defaults objectForKey:@"APIKey"]) {
		//Load Login
		NSLog(@"Loading Login");
		apikey = [defaults objectForKey:@"APIKey"];
	}
		if ( apikey.length == 0 ) {
			//No account information. Show error message.
			[self showsheetmessage:@"MelScrobbleX was unable to post an update since you didn't set any account information." explaination:@"Set your account information in Preferences and try again."];
			[scrobblestatus setObjectValue:@"No Account Info..."];
		}
		else {

			if ( [[fieldmessage string] length] == 0 && [[mediatitle stringValue]length] == 0 ) {
			//No message, show error
				[self showsheetmessage:@"MelScrobbleX was unable to post an update since you didn't enter a message." explaination:@"Enter a message and try posting again"];
			[scrobblestatus setObjectValue:@"No Message Entered.."];
			}
			else {
				int httperror = [self postupdate];
				switch (httperror) {
					case 200: // 200 - OK
						[scrobblestatus setObjectValue:@"Post Successful..."];
						//Clear Message
						[fieldmessage setString:@""];
						//Unset "Complete" and "Send to Twitter" checkboxes
						[completecheckbox setState:0];
						[sendtotwitter setState:0];
						break;
						
					case 401: // 401 - Unauthorized
						//Login Failed, show error message
						[self showsheetmessage:@"MelScrobbleX was unable to post an update since you don't have the correct username and/or password" explaination:@"Check your username and password and try posting again. If you recently changed your password, enter you new password and try again."];
						[scrobblestatus setObjectValue:@"Unable to Post..."];
						break;

					default:
						//Some other error...
						[self showsheetmessage:@"MelScrobbleX was unable to post an update because of an unknown error." explaination:[NSString stringWithFormat:@"Error %i", httperror]];
						[scrobblestatus setObjectValue:@"Unable to Post..."];
						break;
				}
				//Reset Progress
				[APIProgress setDoubleValue:0];
			}
	}
}
-(IBAction)getnowplaying:(id)sender {
	switch ([mediatypemenu indexOfSelectedItem]) {
		case 0:
			// Init Anime Detection
			[self animedetect];
			break;
		case 1:
			// Init Music Detection
			[self musicdetect];
			break;
		case 2:
			// Init Adrama Detection
			[self animedetect];
			break;
	}
}
-(void)musicdetect {
	// Init iTunes Scripting 
	iTunesApplication *iTunes = [[SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"]autorelease];
	if (iTunes.currentTrack == nil) {
		//Show Error Message
		[scrobblestatus setObjectValue:@"Detect Failed: Nothing is playing..."];
	}
	else {
		//Obtain the Album, Artist and Track Name and place them in the Media Title and Segment Fields
		[mediatitle setObjectValue:iTunes.currentTrack.album];
		[segment setObjectValue:iTunes.currentTrack.name];
		[artist setObjectValue:iTunes.currentTrack.artist];
		[scrobblestatus setObjectValue:@"Detected current iTunes track..."];
	}
}
-(void)animedetect {
	// LSOF mplayer to get the media title and segment
	NSTask *task;
	task = [[NSTask alloc] init];
	[task setLaunchPath: @"/usr/sbin/lsof"];
	NSString * player;
	//Load Selected Player from Preferences
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	// Player Selection
	switch ([defaults integerForKey:@"PlayerSel"]) {
		case 0:
			player = @"mplayer";
			break;
		case 1:
			player = @"QTKitServer";
			break;
		case 2:
			player = @"VLC";
			break;
		case 3:
			player = @"QuickTime Player";
			break;
		default:
			break;
	}
	//lsof -c '<player name>' -Fn		
	[task setArguments: [NSArray arrayWithObjects:@"-c", player, @"-F", @"n", nil]];
	
	[player release];
	
	NSPipe *pipe;
	pipe = [NSPipe pipe];
	[task setStandardOutput: pipe];
	
	NSFileHandle *file;
	file = [pipe fileHandleForReading];
	
	[task launch];
	
	NSData *data;
	data = [file readDataToEndOfFile];
	
	//Release task
	[task autorelease];
	
	NSString *string;
	string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]autorelease];
	if (string.length > 0) {
		//Regex time
		//Setup OgreKit
		OGRegularExpressionMatch    *match;
		OGRegularExpression    *regex;
		//Get the filename first
		regex = [OGRegularExpression regularExpressionWithString:@"^.+(avi|mkv|mp4|ogm)$"];
		NSEnumerator    *enumerator;
		enumerator = [regex matchEnumeratorInString:string];		
		while ((match = [enumerator nextObject]) != nil) {
			string = [match matchedString];
		}
		//Cleanup
		regex = [OGRegularExpression regularExpressionWithString:@"^.+/"];
		string = [regex replaceAllMatchesInString:string
									   withString:@""];
		regex = [OGRegularExpression regularExpressionWithString:@"\\.\\w+$"];
		string = [regex replaceAllMatchesInString:string
									   withString:@""];
		regex = [OGRegularExpression regularExpressionWithString:@"[\\s_]*\\[[^\\]]+\\]\\s*"];
		string = [regex replaceAllMatchesInString:string
									   withString:@""];
		regex = [OGRegularExpression regularExpressionWithString:@"[\\s_]*\\([^\\)]+\\)$"];
		string = [regex replaceAllMatchesInString:string
									   withString:@""];
		regex = [OGRegularExpression regularExpressionWithString:@"_"];
		string = [regex replaceAllMatchesInString:string
									   withString:@" "];
		// Set Title Info
		regex = [OGRegularExpression regularExpressionWithString:@"( \\-)? (episode |ep |ep|e)?(\\d+)([\\w\\-! ]*)$"];
		[mediatitle setObjectValue:[regex replaceAllMatchesInString:string
														 withString:@""]];
		// Set Segment Info
		regex = [OGRegularExpression regularExpressionWithString:@" - "];
		string = [regex replaceAllMatchesInString:string
									   withString:@""];
		regex = [OGRegularExpression regularExpressionWithString: [mediatitle stringValue]];
		string = [regex replaceAllMatchesInString:string
									   withString:@""];
		regex = [OGRegularExpression regularExpressionWithString:@"v[\\d]"];
		[segment setObjectValue:[regex replaceAllMatchesInString:string
													  withString:@""]];
		// Trim Whitespace
		[mediatitle setObjectValue:[[mediatitle stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
		//release
		regex = nil;
		enumerator = nil;
		// Set Status
		[scrobblestatus setObjectValue:@"Detected currently playing video..."];
	}
	else {
		// Show error
		[scrobblestatus setObjectValue:@"Detect Failed: Nothing is playing..."];
	}
	string = nil;

}
-(IBAction)scrobble:(id)sender {
	if ([[segment stringValue] length] == 0 || [[mediatitle stringValue]length] == 0 ) {
		switch ([mediatypemenu indexOfSelectedItem]) {
			case 0:
			case 2:
				if ([[mediatitle stringValue] length] != 0) {
					// Set Up Prompt Message Window
					NSAlert * alert = [[[NSAlert alloc] init] autorelease];
					[alert addButtonWithTitle:@"Yes"];
					[alert addButtonWithTitle:@"No"];
					[alert setMessageText:@"Do you really want to perform a scrobble commend with the current information?"];
					[alert setInformativeText:@"No segment has been entered. It will default to 1 if you continue."];
					// Set Message type to Warning
					[alert setAlertStyle:NSWarningAlertStyle];
						Melative_ExampleAppDelegate* appDelegate=[NSApp delegate];	
					// Show as Sheet on historywindow
					[alert beginSheetModalForWindow:[appDelegate window]
									  modalDelegate:self
									 didEndSelector:@selector(scrobblebypass:code:conext:)
										contextInfo:NULL];
					break;
				}
			default:
				// No segment or title	
				[self showsheetmessage:@"MelScrobbleX was unable to scrobble since you didn't enter a title or segment info." explaination:@"Enter a media title or segment and try the scrobble command again."];
				[scrobblestatus setObjectValue:@"Title/Segment Missing..."];
				break;
		}
	}
	else {
		int httperror = [self scrobble];
		switch (httperror) {
			case 200:
				[scrobblestatus setObjectValue:@"Scrobble Successful..."];
				//Set up Delegate
				Melative_ExampleAppDelegate* appDelegate=[NSApp delegate];
				[appDelegate addrecord:[mediatitle stringValue] mediasegment:[segment stringValue] Date:[NSDate date] type:[mediatypemenu indexOfSelectedItem]];
				break;
			case 401:
				//Login Failed, show error message
				[self showsheetmessage:@"MelScrobbleX was unable to scrobble since you don't have the correct username and/or password" explaination:@"Check your username and password and try the scrobble command again. If you recently changed your password, enter your new password and try again."];
				// Set Status
				[scrobblestatus setObjectValue:@"Unable to Scrobble..."];
				break;
			default:
				//Login Failed, show error message
				[self showsheetmessage:@"MelScrobbleX was unable to scrobble because of an unknown error." explaination:[NSString stringWithFormat:@"Error %i", httperror]];
				// Set Status
				[scrobblestatus setObjectValue:@"Unable to Scrobble..."];
				break;
		}
	}
}
-(void)scrobblebypass:(NSAlert *)alert
				   code:(int)achoice
				 conext:(void *)v {
	if (achoice == 1000) {
		[segment setObjectValue:@"1"];
		int httperror = [self scrobble];
		switch (httperror) {
			case 200:
				[scrobblestatus setObjectValue:@"Scrobble Successful..."];
				//Set up Delegate
				Melative_ExampleAppDelegate* appDelegate=[NSApp delegate];
				[appDelegate addrecord:[mediatitle stringValue] mediasegment:[segment stringValue] Date:[NSDate date] type:[mediatypemenu indexOfSelectedItem]];
				break;
			case 401:
				//Login Failed, show error message
				[self showsheetmessage:@"MelScrobbleX was unable to scrobble since you don't have the correct username and/or password" explaination:@"Check your username and password and try the scrobble command again. If you recently changed your password, enter your new password and try again."];
				// Set Status
				[scrobblestatus setObjectValue:@"Unable to Scrobble..."];
				break;
			default:
				//Login Failed, show error message
				[self showsheetmessage:@"MelScrobbleX was unable to scrobble because of an unknown error." explaination:[NSString stringWithFormat:@"Error %i", httperror]];
				// Set Status
				[scrobblestatus setObjectValue:@"Unable to Scrobble..."];
				break;
		}
	}
	else {
				[scrobblestatus setObjectValue:@"Title/Segment Missing..."];
	}

}
-(BOOL)reportoutput {
// Load Settings
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:@"SuccessDebug"];
	[defaults release];
}

- (IBAction)toggletimer:(id)sender {
	if (timer == nil) {
	//Create Timer
		timer = [[NSTimer scheduledTimerWithTimeInterval:180
												  target:self
												selector:@selector(firetimer:)
												userInfo:nil
												 repeats:YES] retain];
		[togglescrobbler setTitle:@"Stop Auto Scrobbling"];
		[GrowlApplicationBridge notifyWithTitle:@"MelScrobbleX"
									description:@"Auto Scrobble is now turned on."
							   notificationName:@"Message"
									   iconData:nil
									   priority:0
									   isSticky:NO
								   clickContext:[NSDate date]];
	}
	else {
		//Stop Timer
		// Remove Timer
		[timer invalidate];
		[timer release];
		timer = nil;
		[togglescrobbler setTitle:@"Start Auto Scrobbling"];
		[GrowlApplicationBridge notifyWithTitle:@"MelScrobbleX"
									description:@"Auto Scrobble is now turned off."
							   notificationName:@"Message"
									   iconData:nil
									   priority:0
									   isSticky:NO
								   clickContext:[NSDate date]];
	}

}
- (void)firetimer:(NSTimer *)aTimer {
	switch ([mediatypemenu indexOfSelectedItem]) {
		case 0:
			// Init Anime Detection
			[self animedetect];
			break;
		case 1:
			// Init Music Detection
			[self musicdetect];
			break;
	}
	if ([[segment stringValue] length] == 0 || [[mediatitle stringValue]length] == 0 ) {
		// Do Nothing
	}
	else if ([[mediatitle stringValue] isEqualToString:ScrobbledMediaTitle] && [[segment stringValue] isEqualToString: ScrobbledMediaSegment] && scrobblesuccess == 1) {
		// Do Nothing
		NSLog(@"Already Scrobbled");
		}
	else {
		//Execute Scrobble Command and retrieve HTTPCode
		int httperror = [self scrobble];
		switch (httperror) {
			case 200:
				[scrobblestatus setObjectValue:@"Scrobble Successful..."];
				[GrowlApplicationBridge notifyWithTitle:@"Scrobble Successful"
											description:[NSString stringWithFormat:@"%@ - %@", [mediatitle stringValue], [segment stringValue]] 
									   notificationName:@"Message"
											   iconData:nil
											   priority:0
											   isSticky:NO
										   clickContext:[NSDate date]];
				ScrobbledMediaTitle = [mediatitle stringValue];
				ScrobbledMediaSegment = [segment stringValue];
				scrobblesuccess = YES;
				//Set up Delegate
				Melative_ExampleAppDelegate* appDelegate=[NSApp delegate];
				//Set last successful scrobble to statusItem Tooltip
				[appDelegate setStatusToolTip:[NSString stringWithFormat:@"MelScrobbleX - Last Scrobble: %@ - %@", [mediatitle stringValue], [segment stringValue]]];						
				//Add to History
				[appDelegate addrecord:ScrobbledMediaTitle mediasegment:ScrobbledMediaSegment Date:[NSDate date] type:[mediatypemenu indexOfSelectedItem]];
				//Retain values for later use
				[ScrobbledMediaTitle retain];
				[ScrobbledMediaSegment retain];
				[scrobblestatus retain];
				break;
			case 401:
				// Set Status
				[scrobblestatus setObjectValue:@"Unable to Scrobble..."];
				[GrowlApplicationBridge notifyWithTitle:@"Scrobble Unsuccessful"
											description:@"Check your login information and try scrobbling again." 
									   notificationName:@"Message"
											   iconData:nil
											   priority:0
											   isSticky:NO
										   clickContext:[NSDate date]];
				scrobblesuccess = NO;
				break;
			default: // Any error codes thats not 200 or 401
				// Set Status
				[scrobblestatus setObjectValue:@"Unable to Scrobble..."];
				[GrowlApplicationBridge notifyWithTitle:@"Scrobble Unsuccessful"
											description:[NSString stringWithFormat:@"Unknown Error. Error %i", httperror]
									   notificationName:@"Message"
											   iconData:nil
											   priority:0
											   isSticky:NO
										   clickContext:[NSDate date]];
				scrobblesuccess = NO;
				break;				
		}
	
}
}

-(int)scrobble {
	// Scrobble Command 
	// Usage: <integer> = [self scrobble];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (apikey == nil || apikey !=[defaults objectForKey:@"APIKey"]) {
		//Load Login
		NSLog(@"Loading Login");
		apikey = [defaults objectForKey:@"APIKey"];
	}
	if ( apikey.length < 0 ) {
		return 401;
	}
	else {
		//Set library/scrobble API
		NSURL *url = [NSURL URLWithString:@"http://melative.com/api/library/scrobble.json"];
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
		//Ignore Cookies
		[request setUseCookiePersistence:NO];
		//Set API Key
		[request addRequestHeader:@"Cookie" value:apikey];
		[request setDownloadProgressDelegate:APIProgress];
		switch ([mediatypemenu indexOfSelectedItem]) {
			case 0:
				[request setPostValue:[mediatitle stringValue] forKey:@"anime"];
				[request setPostValue:@"episode" forKey:@"attribute_type"];
				[request setPostValue:[segment stringValue] forKey:@"attribute_name"];	
				break;
			case 1:
				[request setPostValue:[mediatitle stringValue] forKey:@"music"];
				[request setPostValue:@"track" forKey:@"attribute_type"];
				[request setPostValue:[segment stringValue] forKey:@"attribute_name"];
				break;
			case 2:
				[request setPostValue:[mediatitle stringValue] forKey:@"adrama"];
				[request setPostValue:@"episode" forKey:@"attribute_type"];
				[request setPostValue:[segment stringValue] forKey:@"attribute_name"];	
				break;
				break;

		}
		[request startSynchronous];
		// Get Status Code
		if ([self reportoutput] == 1) {
			//Post suggessful... or is it?
		    NSString *response = [request responseString];
			choice = NSRunAlertPanel(@"API Response", response, @"OK", nil, nil, 8);
		}
		//Reset Progress
		[APIProgress setDoubleValue:0];
		return [request responseStatusCode];
	}
}
-(int)postupdate {
	//Update command
	//Set micro/update API
	NSURL *url = [NSURL URLWithString:@"http://melative.com/api/micro/update.json"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	//Ignore Cookies
	[request setUseCookiePersistence:NO];
	//Set API Key
	[request addRequestHeader:@"Cookie" value:apikey];
	//Set Progress
	[request setDownloadProgressDelegate:APIProgress];
	//Twitter Bridge
	if ([sendtotwitter state] == 1) {
		[fieldmessage setString:[NSString stringWithFormat:@"%@ @tw", [fieldmessage string]]];
	}
	if ([[mediatitle stringValue]length] > 0) {
		
		//Generate the mediamessage in /<action> /<mediatype>/<mediatitle>/<segment>: <message> format
		NSString * mediamessage = @"/";
		switch ([mediatypemenu indexOfSelectedItem]) {
			case 0:
				// Check if the media title is complete or not
				if ([completecheckbox state] == 1) {
					mediamessage = @"watched /anime/";
				}
				else {
					mediamessage = @"watching /anime/";
				}
				
				// Set Player Source
				[request setPostValue:[self reportplayer] forKey:@"source"];
				break;
			case 1:
				// Check if the media title is complete or not
				if ([completecheckbox state] == 1) {
					mediamessage = @"listened /mu/";
				}
				else {
					mediamessage = @"listening /mu/";
				}
				// Music Playing, must be from iTunes
				[request setPostValue:@"iTunes" forKey:@"source"];
				break;
			case 2:
				// Check if the media title is complete or not
				if ([completecheckbox state] == 1) {
					mediamessage = @"watched /adrama/";
				}
				else {
					mediamessage = @"watching /adrama/";
				}
				
				// Set Player Source
				[request setPostValue:[self reportplayer] forKey:@"source"];
		}
		if ([[segment stringValue]length] >0) {
			switch ([mediatypemenu indexOfSelectedItem]) {
				case 0:
					mediamessage = [mediamessage stringByAppendingFormat:@"%@/episode %@: %@",[mediatitle stringValue], [segment stringValue], [fieldmessage string]];
					break;
				case 1:
					mediamessage = [mediamessage stringByAppendingFormat:@"%@/%@: %@",[mediatitle stringValue], [segment stringValue], [fieldmessage string]];
					break;
				case 2:
					mediamessage = [mediamessage stringByAppendingFormat:@"%@/episode %@: %@",[mediatitle stringValue], [segment stringValue], [fieldmessage string]];
					break;

			}
		}
		else {
			mediamessage = [mediamessage stringByAppendingFormat:@"%@/: %@",[mediatitle stringValue], [fieldmessage string]];
		}
		[request setPostValue:mediamessage forKey:@"message"];
		// Get rid of Mediamessage. Not needed
		mediamessage = nil;
	}
	else {
		//Send message only
		[request setPostValue:[fieldmessage string] forKey:@"message"];
		[request setPostValue:@"MelScrobbleX" forKey:@"source"];
	}
	[request startSynchronous];
	// Show API Output
	if ([self reportoutput] == 1) {
		NSString *response = [request responseString];
		//Post suggessful... or is it?
		choice = NSRunAlertPanel(@"API Response", response, @"OK", nil, nil, 8);
		//release
		response = nil;
	}
	if ([request responseStatusCode] == 200 && [completecheckbox state] == 1 ) {
		//Record Completed Title to History
		Melative_ExampleAppDelegate* appDelegate=[NSApp delegate];					
		//Add to History
		[appDelegate addrecord:[mediatitle stringValue] mediasegment:[segment stringValue] Date:[NSDate date] type:[mediatypemenu indexOfSelectedItem]];
	}
	// Get Status Code
	return [request responseStatusCode];
}
-(NSString*) reportplayer {
	//Reports back Player Name set in Settings
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	switch ([defaults integerForKey:@"PlayerSel"]) {
		case 0:
			return @"mplayer";
			break;
		case 1:
			return @"Quicktime";
			break;
		case 2:
			return @"vlc";
			break;
		case 3:
			return @"Quicktime";
			break;
		default:
			return @"MelScrobbleX";
			break;
	}
}
-(IBAction)resetfields:(id)sender
{
	// Clear All Fields
	[fieldmessage setString:@""];
	[mediatitle setObjectValue:@""];
	[segment setObjectValue:@""];
	[artist setObjectValue:@""];
	[scrobblestatus setObjectValue:@"All fields cleared..."];
}
-(void)showsheetmessage:(NSString *)message
		   explaination:(NSString *)explaination
{
	// Set Up Prompt Message Window
	NSAlert * alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:message];
	[alert setInformativeText:explaination];
	// Set Message type to Warning
	[alert setAlertStyle:1];
	Melative_ExampleAppDelegate* appDelegate=[NSApp delegate];	
	// Show as Sheet on Preference Window
	[alert beginSheetModalForWindow:[appDelegate window]
					  modalDelegate:self
					 didEndSelector:nil
						contextInfo:NULL];
}
- (void)dealloc {
    [fieldusername release];
	[apikey release];
    [super dealloc];
}
@end
