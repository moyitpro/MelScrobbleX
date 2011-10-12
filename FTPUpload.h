//
//  FTPUpload.h
//  MelScrobbleX
//
//  Created by Fujibayashi Kyou on 9/5/10.
//  Copyright 2010 James M.. All rights reserved. Covered under the GNU Public License V3
//

#import <Cocoa/Cocoa.h>
#import <objective-curl/objective-curl.h>

@class Upload, CurlFTP;

@interface FTPUpload : NSObject {
	IBOutlet NSTextView * message;
	IBOutlet NSTextField * uploadstatus;
	IBOutlet NSProgressIndicator * UploadProgress;
	NSString * UploadedFile;
	NSString * SiteURL;
	CurlFTP *ftp;
	Upload *upload;
}
@property(readwrite, retain) Upload *upload;
-(IBAction)ftpuploadimage:(id)sender;
-(void)openPanelDidEnd:(NSOpenPanel *)openPanel
			returnCode:(int)returnCode
		   contextInfo:(void *)x;
-(void)showsheetmessage:(NSString *)alertmessage
		   explaination:(NSString *)explaination;
@end
