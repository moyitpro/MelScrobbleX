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
/* Accessors */
-(NSString *)getdetectedmediatitle
{
    return detectedmediatitle;
}
-(NSString *)getdetectedmediasegment
{
    return detectedmediasegment;
}
-(NSString *)getdetectedmediaartist
{
    return detectedmediaartist;
}
-(NSString *)getscrobblerstatus
{
    return scrobblerstatus;
}
-(NSString *)getScrobbledMediaTitle
{
    return ScrobbledMediaTitle;
}
-(NSString *)getScrobbledMediaSegment
{
    return ScrobbledMediaSegment;
}
-(BOOL)getscrobblesuccess
{
    return scrobblesuccess;
}
/* Media Detection */
-(void)musicdetect {
	// Init iTunes Scripting 
	iTunesApplication *iTunes = [[SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"]autorelease];
	if (iTunes.currentTrack == nil) {
		//Show Error Message
		scrobblerstatus =  NSLocalizedString(@"Detect Failed: Nothing is playing...", @"Nothing Detected");
	}
	else {
		//Obtain the Album, Artist and Track Name and place them in the Media Title and Segment Fields
		detectedmediatitle = iTunes.currentTrack.album;
		detectedmediasegment = iTunes.currentTrack.name;
		detectedmediaartist = iTunes.currentTrack.artist;
		scrobblerstatus = NSLocalizedString(@"Detected current iTunes track...", @"Detected Track");
        [detectedmediatitle retain];
        [detectedmediasegment retain];
        [detectedmediaartist retain];
	}
    [scrobblerstatus retain];
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
		//Accented e temporary fix
		regex = [OGRegularExpression regularExpressionWithString:@"e\\\\xcc\\\\x81"];
		string = [regex replaceAllMatchesInString:string
									   withString:@"è"];
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
		detectedmediatitle = [regex replaceAllMatchesInString:string
														 withString:@""];
		// Set Segment Info
		regex = [OGRegularExpression regularExpressionWithString:@" - "];
		string = [regex replaceAllMatchesInString:string
									   withString:@""];
		regex = [OGRegularExpression regularExpressionWithString: detectedmediatitle];
		string = [regex replaceAllMatchesInString:string
									   withString:@""];
		regex = [OGRegularExpression regularExpressionWithString:@"v[\\d]"];
		detectedmediasegment = [regex replaceAllMatchesInString:string
													  withString:@""];
		// Trim Whitespace
		detectedmediatitle = [detectedmediatitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		//release
		regex = nil;
		enumerator = nil;
		// Set Status
		scrobblerstatus = NSLocalizedString(@"Detected currently playing video...",@"Detected Video");
	}
	else {
		// Show error
        detectedmediatitle = @"";
        detectedmediasegment = @"";
		scrobblerstatus = NSLocalizedString(@"Detect Failed: Nothing is playing...", @"Nothing Detected");
	}
    [detectedmediatitle retain];
    [detectedmediasegment retain];
    [scrobblerstatus retain];
	string = nil;

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
		default:
			return @"MelScrobbleX";
			break;
	}
}


/* Update Functions */

-(int)scrobble:(int)mediatypeid
         Title:(NSString *)title
       Segment:(NSString *)segment {
	// Scrobble Command 
	// Usage: <integer> = [self scrobble];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (apikey == nil || apikey !=[defaults objectForKey:@"APIKey"]) {
		//Load Login
		NSLog(@"Loading Login");
		apikey = [defaults objectForKey:@"APIKey"];
	}
	if ( apikey.length == 0 ) {
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
		switch (mediatypeid) {
			case 0:
				[request setPostValue:title forKey:@"anime"];
				[request setPostValue:@"episode" forKey:@"attribute_type"];
				[request setPostValue:segment forKey:@"attribute_name"];	
				break;
			case 1:
				[request setPostValue:title forKey:@"music"];
				[request setPostValue:@"track" forKey:@"attribute_type"];
				[request setPostValue:segment forKey:@"attribute_name"];
				break;
			case 2:
				[request setPostValue:title forKey:@"adrama"];
				[request setPostValue:@"episode" forKey:@"attribute_type"];
				[request setPostValue:segment forKey:@"attribute_name"];	
				break;

		}
		[request startSynchronous];
		// Get Status Code
		if ([self reportoutput] == 1) {
			//Post suggessful... or is it?
		    NSString *response = [request responseString];
			choice = NSRunAlertPanel(NSLocalizedString(@"API Response",@"API Response Alert Title"), response, NSLocalizedString(@"OK",@"OK button"), nil, nil, 8);
		}
		return [request responseStatusCode];
	}
}
-(int)postupdate:(int)mediatypeid
           Title:(NSString *)title
         Segment:(NSString *)segment
      theMessage:(NSString *)postmessage
       completed:(int)state
         Twitter:(int)TwitterBridge
{
	//Update command
	//Set micro/update API
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (apikey == nil || apikey !=[defaults objectForKey:@"APIKey"]) {
		//Load Login
		NSLog(@"Loading Login");
		apikey = [defaults objectForKey:@"APIKey"];
	}
	if ( apikey.length == 0 ) {
        return 401;
    }
    else {
        NSURL *url = [NSURL URLWithString:@"http://melative.com/api/micro/update.json"];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        //Ignore Cookies
        [request setUseCookiePersistence:NO];
        //Set API Key
        [request addRequestHeader:@"Cookie" value:apikey];
        //Twitter Bridge
        if (TwitterBridge == 1) {
            postmessage = [NSString stringWithFormat:@"%@ @tw", postmessage];
        }
        if ([title length] > 0) {
		
            //Generate the mediamessage in /<action> /<mediatype>/<mediatitle>/<segment>: <message> format
            NSString * mediamessage = @"/";
            switch (mediatypeid) {
                case 0:
                    // Check if the media title is complete or not
                    //[completecheckbox state]
                    if (state == 1) {
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
                    if (state == 1) {
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
                    if (state == 1) {
                        mediamessage = @"watched /adrama/";
                    }
                    else {
                        mediamessage = @"watching /adrama/";
                    }
				
                    // Set Player Source
                    [request setPostValue:[self reportplayer] forKey:@"source"];
            }
            if ([segment length] >0) {
                switch (mediatypeid) {
                    case 0:
                        mediamessage = [mediamessage stringByAppendingFormat:@"%@/episode/%@: %@",title, segment, postmessage];
                        break;
                    case 1:
                        mediamessage = [mediamessage stringByAppendingFormat:@"%@/track/%@: %@",title, segment, postmessage];
                        break;
                    case 2:
                        mediamessage = [mediamessage stringByAppendingFormat:@"%@/episode/%@: %@",title, segment, postmessage];
                        break;

                }
            }
            else {
                mediamessage = [mediamessage stringByAppendingFormat:@"%@/: %@",title, postmessage];
            }
            [request setPostValue:mediamessage forKey:@"message"];
            // Get rid of Mediamessage. Not needed
            mediamessage = nil;
        }
        else {
            //Send message only
            [request setPostValue:postmessage forKey:@"message"];
            [request setPostValue:@"MelScrobbleX" forKey:@"source"];
        }
        [request startSynchronous];
        // Show API Output
        if ([self reportoutput] == 1) {
            NSString *response = [request responseString];
            //Post suggessful... or is it?
            choice = NSRunAlertPanel(NSLocalizedString(@"API Response",@"API Response Alert Title"), response, NSLocalizedString(@"OK",@"OK button"), nil, nil, 8);
            //release
            response = nil;
        }
        if ([request responseStatusCode] == 200 && state == 1 ) {
            //Record Completed Title to History
            Melative_ExampleAppDelegate* appDelegate=[NSApp delegate];					
            //Add to History
            [appDelegate addrecord:title mediasegment:segment Date:[NSDate date] type:mediatypeid];
        }
        // Get Status Code
        return [request responseStatusCode];
    }
}
-(void)setScrobbledMediaTitle:(NSString *)title
{
    ScrobbledMediaTitle = title;
}
-(void)setScrobbledMediaSegment:(NSString *)segment
{
    ScrobbledMediaSegment = segment;
}
-(void)setScrobbleSuccess:(BOOL)success
{
    scrobblesuccess = success;
}
-(void)showsheetmessage:(NSString *)message
		   explaination:(NSString *)explaination
{
	// Set Up Prompt Message Window
	NSAlert * alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:NSLocalizedString(@"OK",@"OK button")];
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

-(BOOL)reportoutput {
    // Load Settings
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:@"SuccessDebug"];
	[defaults release];
}

- (void)dealloc {
    [fieldusername release];
	[apikey release];
    [super dealloc];
}
@end
