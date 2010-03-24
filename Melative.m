//
//  Melative.m
//  MelScrobbleX
//
//  Created by Tohno Minagi on 3/14/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "Melative.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"


@implementation Melative
-(IBAction)postmessage:(id)sender
{
	NSLog(@"%i",[mediatypemenu indexOfSelectedItem]);
//Post the update
	if ( [[fieldusername stringValue] length] == 0) {
		//No Username Entered! Show error message
		int choice = NSRunCriticalAlertPanel(@"MelScrobbleX was unable to post an update since you didn't enter a username", @"Enter a valid username and try posting again", @"OK", nil, nil, 8);
	}
	else {
		if ( [[fieldpassword stringValue] length] == 0 ) {
			//No Password Entered! Show error message.
			int choice = NSRunCriticalAlertPanel(@"MelScrobbleX was unable to post an update since you didn't enter a password", @"Enter a valid password and try posting again", @"OK", nil, nil, 8);
		}
		else {
			if ( [[fieldmessage stringValue] length] == 0 ) {
				//No Password Entered! Show error message.
			int choice = NSRunCriticalAlertPanel(@"MelScrobbleX was unable to post an update since you didn't enter a message", @"Enter a message and try posting again", @"OK", nil, nil, 8);
			
			}
			else {
			//Set Login URL
			NSURL *url = [NSURL URLWithString:@"http://melative.com/api/micro/update.json"];
				ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
			//Set Username
			[request setUsername:[fieldusername stringValue]];
				[request setPassword:[fieldpassword stringValue]];
			if ([[mediatitle stringValue]length] >= 0) {
					
				//Generate the mediamessage in /<action> /<mediatype>/<mediatitle>/<segment>: <message> format
				NSString * mediamessage = @"/";
				if ( [mediatypemenu indexOfSelectedItem] == 0) {
					mediamessage = @"watching /anime/";
					// From Mplayer?
					[request setPostValue:@"mplayer" forKey:@"source"];
				}
				else if ([mediatypemenu indexOfSelectedItem] == 1) {
					mediamessage = @"listening /mu/";
					// Music Playing, must be from iTunes
					[request setPostValue:@"iTunes" forKey:@"source"];
				}
				if ([[segment stringValue]length] >=0) {
					mediamessage = [mediamessage stringByAppendingFormat:@"%@/%@: %@",[mediatitle stringValue], [segment stringValue], [fieldmessage stringValue]];
				}
				else{
				mediamessage = [mediamessage stringByAppendingFormat:@"%@/: %@",[mediatitle stringValue], [fieldmessage stringValue]];
				}
							/*[request setPostValue:[mediatitle stringValue] forKey:@"lime_name"];
								[request setPostValue:@"track" forKey:@"attribute_type"];	
								[request setPostValue:@"Last regrets" forKey:@"attribute_name"];*/	
				NSLog(@"%@",mediamessage);
				[request setPostValue:mediamessage forKey:@"message"];
				// Get rid of Mediamessage. Not needed
				mediamessage = nil;
				}
				else {
					//Send message only
							[request setPostValue:[fieldmessage stringValue] forKey:@"message"];
								[request setPostValue:@"Melative Cocoa Test" forKey:@"source"];
				}
			[request startSynchronous];
			// Get Status Code
			int statusCode = [request responseStatusCode];
			if (statusCode == 200 ) {
				NSString *response = [request responseString];
				//Post suggessful... or is it?
				int choice = NSRunAlertPanel(@"Post Successful", response, @"OK", nil, nil, 8);
				
				/* If ( [rememberpassword state] == YES) {
				 // Save UsernamePassword to Keychain
				 
				 }
				 else if ( [rememberpassword state] == NO) {
				 //Check if Keychain for MelScrobbleX Exists
				 }*/
				//release
				response = nil;
				//Clear Message
				[fieldmessage setObjectValue:@""];
			}
			else {
				//Login Failed, show error message
				int choice = NSRunCriticalAlertPanel(@"MelScrobbleX was unable to post an update since you don't have the correct username and/or password", @"Check your username and password and try posting again. If you recently changed your password, ener you new password and try again.", @"OK", nil, nil, 8);
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
