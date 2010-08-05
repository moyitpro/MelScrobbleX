//
//  PreferenceController.m
//  MelScrobbleX
//
//  Created by Tohno Minagi on 3/25/10.
//  Copyright 2010 James M.. All rights reserved. Covered under the GNU Public License V3
//

#import "PreferenceController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Melative.h"


@implementation PreferenceController
- (id)init
{
	if(![super initWithWindowNibName:@"Preferences"])
	   return nil;
	   return self;
}
	 
-(void)windowDidLoad
{
//Check Login Keychain
	[self loadlogin];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
	[self release];
}

-(void)loadlogin
{
	// Load Username
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *APIKey = [defaults objectForKey:@"APIKey"];
	if (APIKey.length > 0) {
		[clearbut setEnabled: YES];
		[savebut setEnabled: NO];
	}
	else {
		//Disable Clearbut
		[clearbut setEnabled: NO];
		[savebut setEnabled: YES];
	}
	//Release Keychain Item
	[APIKey release];
	
}
-(IBAction)clearlogin:(id)sender
{
	choice = NSRunCriticalAlertPanel(@"Are you sure you want to remove this token?", @"Once done, this action cannot be undone,", @"Yes", @"No", nil, 8);
	NSLog(@"%i", choice);
	if (choice == 1) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:@"" forKey:@"APIKey"];
		// Clear Username
		[defaults setObject:@"" forKey:@"Username"];
		//Disable Clearbut
		[clearbut setEnabled: NO];
		[savebut setEnabled: YES];
	}
}
-(IBAction)startlogin:(id)sender
{
	{
		//Start Login Process
		//Disable Login Button
		[savebut setEnabled: NO];
		[savebut displayIfNeeded];
		if ( [[fieldusername stringValue] length] == 0) {
			//No Username Entered! Show error message
			choice = NSRunCriticalAlertPanel(@"MelScrobbleX was unable to log you in since you didn't enter a username", @"Enter a valid username and try logging in again", @"OK", nil, nil, 8);
			[savebut setEnabled: YES];
		}
		else {
			if ( [[fieldpassword stringValue] length] == 0 ) {
				//No Password Entered! Show error message.
				choice = NSRunCriticalAlertPanel(@"MelScrobbleX was unable to log you in since you didn't enter a password", @"Enter a valid password and try logging in again", @"OK", nil, nil, 8);
				[savebut setEnabled: YES];
			}
			else {
				//Set Login URL
				NSURL *url = [NSURL URLWithString:@"http://melative.com/api/account/verify_credentials.xml"];
				ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
				//Ignore Cookies
				[request setUseCookiePersistence:NO];
				//Set Username
				[request setUsername:[fieldusername stringValue]];
				[request setPassword:[fieldpassword stringValue]];
				//Vertify Username/Password
				[request startSynchronous];
				// Get Status Code
				int statusCode = [request responseStatusCode];
				if (statusCode == 200 ) {
					NSString *response = [request responseString];
					//Login successful
					choice = NSRunAlertPanel(@"Login Successful", response, @"OK", nil, nil, 8);
					// Generate API Key
						NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] autorelease];
					[self createcookie:[fieldusername stringValue] :[fieldpassword stringValue]];
					[defaults setObject:[fieldusername stringValue] forKey:@"Username"];
					//Melative.fieldusername = [fieldusername stringValue];
					//Melative.fieldpassword = [fieldpassword stringValue];
					[clearbut setEnabled: YES];
					//release
					response = nil;
				}
				else {
					//Login Failed, show error message
					choice = NSRunCriticalAlertPanel(@"MelScrobbleX was unable to log you in since you don't have the correct username and/or password", @"Check your username and password and try logging in again. If you recently changed your password, ener you new password and try again.", @"OK", nil, nil, 8);
					[savebut setEnabled: YES];
					[savebut setKeyEquivalent:@"\r"];
				}
				//release
				request = nil;
				url = nil;
			}
		}
	}
}
-(IBAction)checkupdates:(id)sender
{
	//Initalize Update
	[[SUUpdater sharedUpdater] checkForUpdates:sender];
}
-(IBAction)registermelative:(id)sender
{
	//Show Melative Registration Page
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://melative.com/register"]];
}
-(void)createcookie:(NSString *)Username:(NSString *)Password
{
	//Set Login URL
	NSURL *url = [NSURL URLWithString:@"http://melative.com/api/session/create.xml"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	//Ignore Cookies
	[request setUseCookiePersistence:NO];
	//Set Username
	[request setPostValue:Username forKey:@"user"];
	[request setPostValue:Password forKey:@"password"];
	//Vertify Username/Password
	[request startSynchronous];
	// Get Status Code
	int statusCode = [request responseStatusCode];
	if (statusCode == 200 ) {
		//Store cookie
			NSString *apikey = [[request responseHeaders] objectForKey:@"Set-Cookie"];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:apikey forKey:@"APIKey"];

	}
	else {
		//Login Failed, show error message
		choice = NSRunCriticalAlertPanel(@"MelScrobbleX was unable to log you in since you don't have the correct username and/or password", @"Check your username and password and try logging in again. If you recently changed your password, ener you new password and try again.", @"OK", nil, nil, 8);
		[savebut setEnabled: YES];
		[savebut setKeyEquivalent:@"\r"];
	}
	//release
	request = nil;
	url = nil;
	
}

@end
