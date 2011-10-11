//
//  ImageServices.h
//  MelScrobbleX
//
//  Created by Fujibayashi Kyou on 9/6/10.
//  Copyright 2010-2011 James M.. All rights reserved. Covered under the New BSD License.
//

#import <Cocoa/Cocoa.h>


@interface ImageServices : NSObject {
	IBOutlet NSTextView * message;
	IBOutlet NSTextField * uploadstatus;
	IBOutlet NSProgressIndicator * UploadProgress;
}
-(IBAction)uploadimage:(id)sender;
-(void)openPanelDidEnd:(NSOpenPanel *)openPanel
			returnCode:(int)returnCode
		   contextInfo:(void *)x;
-(void)UploadtoImageshack:(NSString *)filename;
-(void)UploadtoImgur:(NSString *)filename;
-(void)showsheetmessage:(NSString *)message
		   explaination:(NSString *)explaination;
@end
