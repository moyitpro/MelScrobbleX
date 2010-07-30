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
			choice = NSRunCriticalAlertPanel(@"MelScrobbleX was unable to post an update since you didn't set any account information", @"Set your account information in Preferences and try again.", @"OK", nil, nil, 8);
			[scrobblestatus setObjectValue:@"No Account Info..."];
		}
		else {

			if ( [[fieldmessage stringValue] length] == 0 && [[mediatitle stringValue]length] == 0 ) {
				//No message, show error
			choice = NSRunCriticalAlertPanel(@"MelScrobbleX was unable to post an update since you didn't enter a message", @"Enter a message and try posting again", @"OK", nil, nil, 8);
			[scrobblestatus setObjectValue:@"No Message Entered.."];
			}
			else {
				//Set micro/update API
				NSURL *url = [NSURL URLWithString:@"http://melative.com/api/micro/update.json"];
				ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
				//Ignore Cookies
				[request setUseCookiePersistence:NO];
				//Set API Key
				[request addRequestHeader:@"Cookie" value:apikey];
				//Set Progress
				[request setDownloadProgressDelegate:APIProgress];
				if ([[mediatitle stringValue]length] > 0) {
					
					//Generate the mediamessage in /<action> /<mediatype>/<mediatitle>/<segment>: <message> format
					NSString * mediamessage = @"/";
					if ( [mediatypemenu indexOfSelectedItem] == 0) {
						// Check if the media title is complete or not
						if ([completecheckbox state] == 1) {
							mediamessage = @"watched /anime/";
						}
						else {
							mediamessage = @"watching /anime/";
						}

						// From Mplayer?
						[request setPostValue:@"mplayer" forKey:@"source"];
					}
					else if ([mediatypemenu indexOfSelectedItem] == 1) {
						// Check if the media title is complete or not
						if ([completecheckbox state] == 1) {
							mediamessage = @"listened /mu/";
						}
						else {
							mediamessage = @"listening /mu/";
						}
						// Music Playing, must be from iTunes
						[request setPostValue:@"iTunes" forKey:@"source"];
					}
					if ([[segment stringValue]length] >0) {
						if ([mediatypemenu indexOfSelectedItem] == 0) {
						mediamessage = [mediamessage stringByAppendingFormat:@"%@/episode %@: %@",[mediatitle stringValue], [segment stringValue], [fieldmessage stringValue]];
						}
						else if ([mediatypemenu indexOfSelectedItem] == 1) {
						mediamessage = [mediamessage stringByAppendingFormat:@"%@/%@: %@",[mediatitle stringValue], [segment stringValue], [fieldmessage stringValue]];
						}
					}
					else{
						mediamessage = [mediamessage stringByAppendingFormat:@"%@/: %@",[mediatitle stringValue], [fieldmessage stringValue]];
					}
					[request setPostValue:mediamessage forKey:@"message"];
					// Get rid of Mediamessage. Not needed
					mediamessage = nil;
				}
				else {
					//Send message only
					[request setPostValue:[fieldmessage stringValue] forKey:@"message"];
					[request setPostValue:@"MelScrobbleX" forKey:@"source"];
				}
				[request startSynchronous];
				// Get Status Code
				int statusCode = [request responseStatusCode];
				if (statusCode == 200 ) {
					if ([self reportoutput] == 1) {
					NSString *response = [request responseString];
					//Post suggessful... or is it?
					choice = NSRunAlertPanel(@"Post Successful", response, @"OK", nil, nil, 8);
					//release
					response = nil;
					}
					[scrobblestatus setObjectValue:@"Post Successful..."];
					//Clear Message
					[fieldmessage setObjectValue:@""];
					//Unset "Complete" checkbox
					[completecheckbox setState:0];
				}
				else {
					//Login Failed, show error message
					choice = NSRunCriticalAlertPanel(@"MelScrobbleX was unable to post an update since you don't have the correct username and/or password", @"Check your username and password and try posting again. If you recently changed your password, ener you new password and try again.", @"OK", nil, nil, 8);
					[scrobblestatus setObjectValue:@"Unable to Post..."];
				}
				//release
				request = nil;
				url = nil;
				//Reset Progress
				[APIProgress setDoubleValue:0];
			}
	}
}
-(IBAction)getnowplaying:(id)sender {
	if ([mediatypemenu indexOfSelectedItem] == 0) {
		// Init Anime Detection
		[self animedetect];
	}
	else if ([mediatypemenu indexOfSelectedItem] == 1) {
		// Init Music Detection
		[self musicdetect];
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
	//lsof -c 'mplayer' -Fn		
	[task setArguments: [NSArray arrayWithObjects:@"-c", @"mplayer", @"-F", @"n", nil]];
	
	NSPipe *pipe;
	pipe = [NSPipe pipe];
	[task setStandardOutput: pipe];
	
	NSFileHandle *file;
	file = [pipe fileHandleForReading];
	
	[task launch];
	
	NSData *data;
	data = [file readDataToEndOfFile];
	
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
	// Set Status
	[scrobblestatus setObjectValue:@"Scrobbling..."];
	//Scrobble the Title
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (apikey == nil || apikey !=[defaults objectForKey:@"APIKey"]) {
	//Load Login
	NSLog(@"Loading Login");
		apikey = [defaults objectForKey:@"APIKey"];
	}
	if ( apikey.length < 0 ) {
		//No account information. Show error message.
		choice = NSRunCriticalAlertPanel(@"MelScrobbleX was unable to scrobble since you didn't set any account information", @"Set your account information in Preferences and try again.", @"OK", nil, nil, 8);
		[scrobblestatus setObjectValue:@"No Account Info..."];
	}
	else {
		if ( [[segment stringValue] length] == 0 || [[mediatitle stringValue]length] == 0 ) {
			//No segment or title
			choice = NSRunCriticalAlertPanel(@"MelScrobbleX was unable to scrobble since you didn't enter a title or segment info.", @"Enter a media title or segment and try the scrobble command again", @"OK", nil, nil, 8);
			[scrobblestatus setObjectValue:@"Title/Segment Missing..."];
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
			if ( [mediatypemenu indexOfSelectedItem] == 0) {
				[request setPostValue:[mediatitle stringValue] forKey:@"anime"];
				[request setPostValue:@"episode" forKey:@"attribute_type"];
				[request setPostValue:[segment stringValue] forKey:@"attribute_name"];	
			}
			else if ([mediatypemenu indexOfSelectedItem] == 1) {
				[request setPostValue:[mediatitle stringValue] forKey:@"music"];
				[request setPostValue:@"track" forKey:@"attribute_type"];
				[request setPostValue:[segment stringValue] forKey:@"attribute_name"];
			}
		[request startSynchronous];
		// Get Status Code
		int statusCode = [request responseStatusCode];
			if (statusCode == 200 ) {
				if ([self reportoutput] == 1) {
					NSString *response = [request responseString];
					//Post suggessful... or is it?
					choice = NSRunAlertPanel(@"Scrobble Successful", response, @"OK", nil, nil, 8);
					//release
					response = nil;
				}
			[scrobblestatus setObjectValue:@"Scrobble Successful..."];
		}
		else {
			//Login Failed, show error message
			choice = NSRunCriticalAlertPanel(@"MelScrobbleX was unable to scrobble since you don't have the correct username and/or password", @"Check your username and password and try the scrobble command again. If you recently changed your password, ener you new password and try again.", @"OK", nil, nil, 8);
			// Set Status
			[scrobblestatus setObjectValue:@"Unable to Scrobble..."];
		}
		//release
		request = nil;
		url = nil;
		//Reset Progress
		[APIProgress setDoubleValue:0];
	}
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
		NSLog(@"Creating Timer");
		timer = [[NSTimer scheduledTimerWithTimeInterval:180
												  target:self
												selector:@selector(firetimer:)
												userInfo:nil
												 repeats:YES] retain];
		[togglescrobbler setTitle:@"Stop Auto Scrobbling"];
	}
	else {
		//Stop Timer
		NSLog(@"Stopping Timer");
		// Remove Timer
		[timer invalidate];
		[timer release];
		timer = nil;
		[togglescrobbler setTitle:@"Start Auto Scrobbling"];
	}

}
- (void)firetimer:(NSTimer *)aTimer {
	NSLog(@"BOO!");
	//Start Detection
	if ([mediatypemenu indexOfSelectedItem] == 0) {
		// Init Anime Detection
		[self animedetect];
	}
	else if ([mediatypemenu indexOfSelectedItem] == 1) {
		// Init Music Detection
		[self musicdetect];
	}
	if ([[segment stringValue] length] == 0 || [[mediatitle stringValue]length] == 0 ) {
		// Do Nothing
	}
	else if ([mediatitle stringValue] == ScrobbledMediaTitle && [segment stringValue] == ScrobbledMediaSegment && scrobblesuccess == YES) {
		// Do Nothing
		}
	else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if (apikey == nil || apikey !=[defaults objectForKey:@"APIKey"]) {
			//Load Login
			NSLog(@"Loading Login");
			apikey = [defaults objectForKey:@"APIKey"];
		}
		if ( apikey.length < 0 ) {
			//No account information. Show error message.
			[scrobblestatus setObjectValue:@"No Account Info..."];
			scrobblesuccess = NO;
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
		if ( [mediatypemenu indexOfSelectedItem] == 0) {
			[request setPostValue:[mediatitle stringValue] forKey:@"anime"];
			[request setPostValue:@"episode" forKey:@"attribute_type"];
			[request setPostValue:[segment stringValue] forKey:@"attribute_name"];	
		}
		else if ([mediatypemenu indexOfSelectedItem] == 1) {
			[request setPostValue:[mediatitle stringValue] forKey:@"music"];
			[request setPostValue:@"track" forKey:@"attribute_type"];
			[request setPostValue:[segment stringValue] forKey:@"attribute_name"];
		}
		[request startSynchronous];
		// Get Status Code
		int statusCode = [request responseStatusCode];
		if (statusCode == 200 ) {
			if ([self reportoutput] == 1) {
				NSString *response = [request responseString];
				//Post suggessful... or is it?
				choice = NSRunAlertPanel(@"Scrobble Successful", response, @"OK", nil, nil, 8);
				//release
				response = nil;
			}
			[scrobblestatus setObjectValue:@"Scrobble Successful..."];
			ScrobbledMediaTitle = [mediatitle stringValue];
			ScrobbledMediaSegment = [segment stringValue];
			scrobblesuccess = YES;
		}
		else {
			// Set Status
			[scrobblestatus setObjectValue:@"Unable to Scrobble..."];
			scrobblesuccess = NO;
		}
		//release
		request = nil;
		url = nil;
		//Reset Progress
		[APIProgress setDoubleValue:0];
	}
	}
}

- (void)dealloc {
    [fieldusername release];
	[apikey release];
    [super dealloc];
}
@end
