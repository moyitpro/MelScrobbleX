//
//  FTPUpload.h
//  MelScrobbleX
//
//  Created by Fujibayashi Kyou on 9/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "S7FTPRequest.h"


@interface FTPUpload : NSObject {
	IBOutlet NSTextView * message;
	IBOutlet NSTextField * uploadstatus;
	NSString * UploadedFile;
	NSString * SiteURL;
}
-(IBAction)ftpuploadimage:(id)sender;
-(void)openPanelDidEnd:(NSOpenPanel *)openPanel
			returnCode:(int)returnCode
		   contextInfo:(void *)x;
-(void)showsheetmessage:(NSString *)alertmessage
		   explaination:(NSString *)explaination;
-(void)uploadFinished:(S7FTPRequest *)request;
-(void)uploadFailed:(S7FTPRequest *)request;
-(void)uploadWillStart:(S7FTPRequest *)request;
-(void)uploadBytesWritten:(S7FTPRequest *)request;
-(void)requestStatusChanged:(S7FTPRequest *)request;
@end
