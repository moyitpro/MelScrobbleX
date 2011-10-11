//
//  Melative.h
//  Melative Example
//
//  Created by Tohno Minagi on 3/14/10.
//  Copyright 2010-2011 James M.. All rights reserved. Covered under the New BSD License.
//

#import <Cocoa/Cocoa.h>
#import <OgreKit/OgreKit.h>

@interface Melative : NSObject {
	NSString * fieldusername;
	NSString * apikey;
	NSString * detectedmediatitle;
	NSString * detectedmediasegment;
	NSString * detectedmediaartist;
	NSString * scrobblerstatus;
	int choice;
    BOOL scrobblesuccess;
	NSString * ScrobbledMediaTitle;
	NSString * ScrobbledMediaSegment;
}
@property(copy, readwrite) NSString *apikey;
@property(copy, readwrite) NSString *fieldusername;

/* Accessors */
-(NSString *)getdetectedmediatitle;
-(NSString *)getdetectedmediasegment;
-(NSString *)getdetectedmediaartist;
-(NSString *)getscrobblerstatus;
-(NSString *)getScrobbledMediaTitle;
-(NSString *)getScrobbledMediaSegment;
-(BOOL)getscrobblesuccess;
/* Detection */
-(void)musicdetect;
-(void)animedetect;
-(NSString*) reportplayer;
/* Update Functions */
-(int)scrobble:(int)mediatypeid
         Title:(NSString *)title
       Segment:(NSString *)segment;
-(int)postupdate:(int)mediatypeid
           Title:(NSString *)title
         Segment:(NSString *)segment
      theMessage:(NSString *)postmessage
       completed:(int)state
         Twitter:(int)TwitterBridge;
-(void)setScrobbledMediaTitle:(NSString *)title;
-(void)setScrobbledMediaSegment:(NSString *)segment;
-(void)setScrobbleSuccess:(BOOL)success;
/* Other */
-(BOOL)reportoutput;
-(void)showsheetmessage:(NSString *)message
		   explaination:(NSString *)explaination;


@end
