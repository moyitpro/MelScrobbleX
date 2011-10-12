//
//  ImageServices.m
//  MelScrobbleX
//
//  Created by Fujibayashi Kyou on 9/6/10.
//  Copyright 2010 James M.. All rights reserved. Covered under the GNU Public License V3
//

#import "ImageServices.h"
#import "ASIFormDataRequest.h"
#import "Melative_ExampleAppDelegate.h"

@implementation ImageServices
-(IBAction)uploadimage:(id)sender
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
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		switch ([defaults integerForKey:@"ImageService"]) {
			case 0:
				//Upload Image to Imageshack
				[self UploadtoImageshack:[openPanel filename]];
				break;
			case 1:
				//Upload Image to Imgur
				[self UploadtoImgur:[openPanel filename]];
				break;
		}
	}
}
-(void)UploadtoImageshack:(NSString *)filename 
{ 
	//Start Upload
	//Set URL to Imageshack Upload API
	NSURL *url = [NSURL URLWithString:@"http://www.imageshack.us/upload_api.php"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	//Ignore Cookies
	[request setUseCookiePersistence:NO];
	//Set API Key
	[request setPostValue:@"5BSZ4EAH87ff1baa0805a78ac1ac39b55e213213" forKey:@"key"]; // DO NOT USE THIS KEY IN ANY OTHER APPLICATION EXCEPT THIS ONE
	//Set File
	[request setFile:filename forKey:@"fileupload"];
	//Set Progress
	[request setDownloadProgressDelegate:UploadProgress];
	[request startSynchronous];
	//Show API Output
	NSString *response = [request responseString];
	int httpcode = [request responseStatusCode];
	if (httpcode == 200) {
		//XML Parsing to retrieve Image Link
		NSError * error;
		NSArray *itemNodes;
		NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
		NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data 
														 options:0 
														   error:&error];
		NSMutableArray* imglinks = [[NSMutableArray alloc] initWithCapacity:13];
		itemNodes = [doc nodesForXPath:@"//links/image_link" error:&error];
		for(NSXMLElement* xmlElement in itemNodes)
			[imglinks addObject:[xmlElement stringValue]];
		//Insert Image Link to Message Textfield
		[message setString:[NSString stringWithFormat:@"#image %@ \n%@",[imglinks objectAtIndex:0],[message string]]];
		//Report Status
		[uploadstatus setObjectValue:@"Image Successfully Uploaded..."];
		//Release Unneeded Items
		[itemNodes release];
		[doc release];
		[data release];
		[imglinks release];
	}
	else {
		// If the Upload Fails...
		[self showsheetmessage:@"MelScrobbleX was unable to upload the image you selected" explaination:[NSString stringWithFormat:@"Error: %i \n \n%@", httpcode, response]];
		//Report Status
		[uploadstatus setObjectValue:@"Image Upload Unsuccessful..."];
	}
	
}
-(void)UploadtoImgur:(NSString *)filename
{ 
	//Start Upload
	//Set URL to Imgur Upload API
	NSURL *url = [NSURL URLWithString:@"http://api.imgur.com/2/upload.xml"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	//Ignore Cookies
	[request setUseCookiePersistence:NO];
	//Set API Key
	[request setPostValue:@"c8c106319f11dd5bb187d7f54caf696e" forKey:@"key"]; // DO NOT USE THIS KEY IN ANY OTHER APPLICATION EXCEPT THIS ONE
	//Set File
	[request setFile:filename forKey:@"image"];
	//Set Progress
	[request setDownloadProgressDelegate:UploadProgress];
	[request startSynchronous];
	//Show API Output
	NSString *response = [request responseString];
	int httpcode = [request responseStatusCode];
	if (httpcode == 200) {
		//XML Parsing to retrieve Image Link
		NSError * error;
		NSArray *itemNodes;
		NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
		NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data 
														 options:0 
														   error:&error];
		NSMutableArray* imglinks = [[NSMutableArray alloc] initWithCapacity:13];
		itemNodes = [doc nodesForXPath:@"//upload/links/original" error:&error];
		for(NSXMLElement* xmlElement in itemNodes)
			[imglinks addObject:[xmlElement stringValue]];
		//Insert Image Link to Message Textfield
		[message setString:[NSString stringWithFormat:@"#image %@ \n%@",[imglinks objectAtIndex:0],[message string]]];
		//Report Status
		[uploadstatus setObjectValue:@"Image Successfully Uploaded..."];
		//Release Unneeded Items
		[itemNodes release];
		[doc release];
		[data release];
		[imglinks release];
	}
	else {
		// If the Upload Fails...
		[self showsheetmessage:@"MelScrobbleX was unable to upload the image you selected" explaination:[NSString stringWithFormat:@"Error: %i \n \n%@", httpcode, response]];
		//Report Status
		[uploadstatus setObjectValue:@"Image Upload Unsuccessful..."];
	}
	
}
-(void)showsheetmessage:(NSString *)errmessage
		   explaination:(NSString *)explaination
{
	// Set Up Prompt Message Window
	NSAlert * alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:errmessage];
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
