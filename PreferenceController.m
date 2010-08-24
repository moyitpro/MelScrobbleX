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
	// Set Up Prompt Message Window
	NSAlert * alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert setMessageText:@"Are you sure you want to remove this token?"];
	[alert setInformativeText:@"Once done, this action cannot be undone."];
	// Set Message type to Warning
	[alert setAlertStyle:NSWarningAlertStyle];
	// Show as Sheet on historywindow
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:self
					 didEndSelector:@selector(clearcookieended:code:conext:)
						contextInfo:NULL];
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
			[self showsheetmessage:@"MelScrobbleX was unable to log you in since you didn't enter a username." explaination:@"Enter a valid username and try logging in again"];
			[savebut setEnabled: YES];
		}
		else {
			if ( [[fieldpassword stringValue] length] == 0 ) {
				//No Password Entered! Show error message.
				[self showsheetmessage:@"MelScrobbleX was unable to log you in since you didn't enter a password." explaination:@"Enter a valid password and try logging in again."];
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
					[self showsheetmessage:@"Login Successful." explaination:response];
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
					[self showsheetmessage:@"MelScrobbleX was unable to log you in since you don't have the correct username and/or password." explaination:@"Check your username and password and try logging in again. If you recently changed your password, ener you new password and try again."];
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
		[self showsheetmessage:@"MelScrobbleX was unable to log you in since you don't have the correct username and/or password" explaination:@"Check your username and password and try logging in again. If you recently changed your password, ener you new password and try again."];
		[savebut setEnabled: YES];
		[savebut setKeyEquivalent:@"\r"];
	}
	//release
	request = nil;
	url = nil;
	
}
-(void)clearcookieended:(NSAlert *)alert
					code:(int)achoice
				  conext:(void *)v
{
		if (achoice == 1000) {
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setObject:@"" forKey:@"APIKey"];
			// Clear Username
			[defaults setObject:@"" forKey:@"Username"];
			//Disable Clearbut
			[clearbut setEnabled: NO];
			[savebut setEnabled: YES];
		}
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
	// Show as Sheet on Preference Window
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:self
					 didEndSelector:nil
						contextInfo:NULL];
}
@end
