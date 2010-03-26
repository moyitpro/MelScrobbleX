//
//  Login.m
//  MelScrobbleX
//
//  Created by Tohno Minagi on 3/25/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "Login.h"
#import "ASIHTTPRequest.h"
#import "EMKeychainItem.h"


@implementation Login
- (NSString *)title
{
	return NSLocalizedString(@"Login", @"Title of 'Login' preference pane");
}

- (NSString *)identifier
{
	return @"Login";
}

- (NSImage *)image
{
	return [NSImage imageNamed:@"Login.tiff"];
}
-(void)awakeFromNib
{
	// Load Username
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString * KeyUsername = nil;
	KeyUsername = [defaults objectForKey:@"Username"];
	// Load Keychain, if exists
	EMInternetKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"MelScrobblerX" withUsername: KeyUsername];
	KeyUsername = nil;
if (keychainItem != nil) {
	[clearbut setEnabled: YES];
	[savebut setEnabled: NO];
	[fieldusername setObjectValue:keychainItem.username];
	[fieldpassword setObjectValue:keychainItem.password];
	}
	else {
		//Disable Clearbut
		[clearbut setEnabled: NO];
		[savebut setEnabled: YES];
	}
	//Release Keychain Item
	[keychainItem release];

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
				statusCode = nil;
				request = nil;
				url = nil;
			}
		}
	}
}
@end
