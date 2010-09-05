//
//  FTPUpload.m
//  MelScrobbleX
//
//  Created by Fujibayashi Kyou on 9/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FTPUpload.h"
#import "Melative_ExampleAppDelegate.h"
#import "Melative.h"
#import "S7FTPRequest.h"


@implementation FTPUpload
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
		if ([[defaults objectForKey:@"FTPServer"] length] == 0 || [[defaults objectForKey:@"FTPUsername"] length] == 0 || [[defaults objectForKey:@"FTPWebAddress"] length] == 0)
		{
			NSLog(@"Insufficient Info to Upload File");
		}
		else {
			// Upload File
			UploadedFile = [openPanel filename];
			SiteURL = [defaults objectForKey:@"FTPWebAddress"];
			UploadedFile = [[UploadedFile lastPathComponent] stringByDeletingPathExtension];
			S7FTPRequest *ftpRequest = [[S7FTPRequest alloc] initWithURL:
										[NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@:%@%@",[defaults objectForKey:@"FTPServer"], [defaults objectForKey:@"FTPPort"],[defaults objectForKey:@"FTPUploadDirectory"]]]
															toUploadFile:[openPanel filename]];
			
			ftpRequest.username = [defaults objectForKey:@"FTPUsername"];
			ftpRequest.password = @"";
			
			ftpRequest.delegate = self;
			ftpRequest.didFinishSelector = @selector(uploadFinished:);
			ftpRequest.didFailSelector = @selector(uploadFailed:);
			ftpRequest.willStartSelector = @selector(uploadWillStart:);
			ftpRequest.didChangeStatusSelector = @selector(requestStatusChanged:);
			ftpRequest.bytesWrittenSelector = @selector(uploadBytesWritten:);
			
			[ftpRequest startRequest];
		}
	}
}
-(void)uploadFinished:(S7FTPRequest *)request {
	//Insert Image Link to Message Textfield
	[message setString:[NSString stringWithFormat:@"#image %@ \n%@",[NSString stringWithFormat:@"%@/%@",SiteURL,UploadedFile],[message string]]];
	UploadedFile = @"";
	[uploadstatus setObjectValue:@"Image Upload Successful..."];
	[request release];
}

-(void)uploadFailed:(S7FTPRequest *)request {
	[self showsheetmessage:@"MelScrobbleX was unable to upload the image you selected" explaination:[NSString stringWithFormat:@"Error: %@", [request.error localizedDescription]]];
	[uploadstatus setObjectValue:@"Image Upload Unsuccessful..."];
	[request release];
}

-(void)uploadWillStart:(S7FTPRequest *)request {
	
	NSLog(@"Will transfer %d bytes.", request.fileSize);
}

-(void)uploadBytesWritten:(S7FTPRequest *)request {
	
	NSLog(@"Transferred: %d", request.bytesWritten);
}

- (void)requestStatusChanged:(S7FTPRequest *)request {
	
	switch (request.status) {
		case S7FTPRequestStatusOpenNetworkConnection:
			NSLog(@"Opened connection.");
			break;
		case S7FTPRequestStatusReadingFromStream:
			NSLog(@"Reading from stream...");
			break;
		case S7FTPRequestStatusWritingToStream:
			NSLog(@"Writing to stream...");
			break;
		case S7FTPRequestStatusClosedNetworkConnection:
			NSLog(@"Closed connection.");
			break;
		case S7FTPRequestStatusError:
			NSLog(@"Error occurred.");
			break;
	}
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
