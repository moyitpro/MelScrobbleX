//
//  FTPUpload.m
//  MelScrobbleX
//
//  Created by Fujibayashi Kyou on 9/5/10.
//  Copyright 2010 James M.. All rights reserved. Covered under the GNU Public License V3
//

#import "FTPUpload.h"
#import "Melative_ExampleAppDelegate.h"
#import "Melative.h"
#import "EMKeychainItem.h"

@implementation FTPUpload

@synthesize upload;

-(IBAction)ftpuploadimage:(id)sender
{
	NSOpenPanel *op = [NSOpenPanel openPanel];
	
	// Create Delegate to Main App Controller
	Melative_ExampleAppDelegate* appDelegate=[NSApp delegate];	
	//Show Open Panel
	[op beginSheetForDirectory:nil 
						  file:nil 
						 types:[NSImage imageFileTypes]
				modalForWindow:[appDelegate window] 
				 modalDelegate:self 
				didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
				   contextInfo:NULL];
}
-(void)openPanelDidEnd:(NSOpenPanel *)openPanel
			returnCode:(int)returnCode
		   contextInfo:(void *)x
{
	// Did they chosose "Open"
	if (returnCode == NSOKButton) {
		[openPanel close];
		//Load FTP Info
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		//Load Keychain for FTP
		EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"MelScrobbleX" withUsername: @"ftp"];
		if ([[defaults objectForKey:@"FTPServer"] length] == 0 || [[defaults objectForKey:@"FTPUsername"] length] == 0 || [[defaults objectForKey:@"FTPWebAddress"] length] == 0)
		{
			[self showsheetmessage:@"MelScrobbleX was unable to upload the image you selected." explaination:@"FTP Server, Username and/or Web Address is missing. Please fill in the missing information in Preferences and try uploading the image again."];
		}
		else if(keychainItem.password.length == 0) {
			[self showsheetmessage:@"MelScrobbleX was unable to upload the image you selected." explaination:@"FTP Password is missing. Please fill in the missing information in Preferences and try uploading the image again."];
		}
		else {
			ftp = [[CurlFTP alloc] init];
			id <CurlClient>client = (id <CurlClient>)ftp;
			[ftp setVerbose:YES];
			[ftp setShowProgress:YES];
			//Set Delegate
			[ftp setDelegate:self];	
			// Upload File
			UploadedFile = [openPanel filename];
			//Start Upload
			Upload *newUpload = [client uploadFilesAndDirectories:[NSArray arrayWithObjects:UploadedFile, NULL]
														   toHost:[defaults objectForKey:@"FTPServer"] 
														 username:[defaults objectForKey:@"FTPUsername"]
														 password:keychainItem.password
														directory:[defaults objectForKey:@"FTPUploadDirectory"]];
			//Generate Site URL
			SiteURL = [defaults objectForKey:@"FTPWebAddress"];
			UploadedFile = [UploadedFile lastPathComponent];
			//Upload
			[self setUpload:newUpload];
		}
	}
}

#pragma mark ConnectionDelegate methods


- (void)curlIsConnecting:(RemoteObject *)record
{
	[uploadstatus setObjectValue:@"Connecting to FTP Server..."];
	NSLog(@"curlIsConnecting");
}

- (void)curlDidConnect:(RemoteObject *)record
{
	[uploadstatus setObjectValue:@"Connected..."];
	NSLog(@"curlDidConnect");
}


#pragma mark UploadDelegate methods


- (void)uploadDidBegin:(Upload *)record
{
    [uploadstatus setObjectValue:@"Starting Upload..."];
	NSLog(@"uploadDidBegin");
}


- (void)uploadDidProgress:(Upload *)record toPercent:(NSNumber *)percent;
{
    [uploadstatus setObjectValue:[NSString stringWithFormat:@"Uploading Image... %i%",[record progress]]];
}


- (void)uploadDidFinish:(Upload *)record
{
	[message setString:[NSString stringWithFormat:@"#image %@ \n%@",[NSString stringWithFormat:@"%@/%@",SiteURL,UploadedFile],[message string]]];
	UploadedFile = @"";
	[uploadstatus setObjectValue:@"Image Upload Successful..."];
}


- (void)uploadWasCancelled:(Upload *)record
{
	NSLog(@"uploadWasCancelled");
}


- (void)uploadDidFail:(Upload *)record message:(NSString *)errmessage;
{
	[self showsheetmessage:@"MelScrobbleX was unable to upload the image you selected" explaination:errmessage];
	[uploadstatus setObjectValue:@"Image Upload Unsuccessful..."];
}

-(void)showsheetmessage:(NSString *)alertmessage
		   explaination:(NSString *)explaination
{
	// Set Up Prompt Message Window
	NSAlert * alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:alertmessage];
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
@end
