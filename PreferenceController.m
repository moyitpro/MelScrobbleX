//
//  PreferenceController.m
//  MelScrobbleX
//
//  Created by Tohno Minagi on 3/25/10.
//  Copyright 2010 James M.. All rights reserved. Covered under the GNU Public License V3
//

#import "PreferenceController.h"
#import "ASIHTTPRequest.h"
#import "EMKeychainItem.h"
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
	NSLog(@"Nib file is loaded");
	[self loadlogin];
}

-(void)loadlogin
{
	// Load Username
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	// Load Keychain, if exists
	EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"MelScrobbleX" withUsername: [defaults objectForKey:@"Username"]];
	if (keychainItem.password != nil) {
		[clearbut setEnabled: YES];
		[savebut setEnabled: NO];
	}
	else {
		//Disable Clearbut
		[clearbut setEnabled: NO];
		[savebut setEnabled: YES];
	}
	//Release Keychain Item
	keychainItem = nil;
	
}
-(IBAction)clearlogin:(id)sender
{
	choice = NSRunCriticalAlertPanel(@"Are you sure you want to remove the login from your Keychain?", @"Once done, this action cannot be undone,", @"Yes", @"No", nil, 8);
	NSLog(@"%i", choice);
	if (choice == 1) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[[EMGenericKeychainItem genericKeychainItemForService:@"MelScrobbleX" withUsername: [defaults objectForKey:@"Username"]]remove];
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
					// Save Password
					[EMGenericKeychainItem addGenericKeychainItemForService:@"MelScrobbleX" withUsername:[fieldusername stringValue] password:[fieldpassword stringValue]];
					NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
					[defaults setObject:[fieldusername stringValue] forKey:@"Username"];
					//[Melative setFieldusername:[fieldusername stringValue]];
					//[Melative setFieldpassword:[fieldpassword stringValue]];
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

@end
