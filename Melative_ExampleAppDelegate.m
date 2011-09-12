//
//  Melative_ExampleAppDelegate.m
//  Melative Example
//
//  Created by Tohno Minagi on 3/14/10.
//  Copyright 2010 James M.. All rights reserved. Covered under the GNU Public License V3
//

#import "Melative_ExampleAppDelegate.h"
#import "PreferenceController.h"
#import "PFMoveApplication.h"
#import <QuartzCore/QuartzCore.h>

@implementation Melative_ExampleAppDelegate

@synthesize window;
@synthesize historywindow;
/**
 Returns the support directory for the application, used to store the Core Data
 store file.  This code uses a directory named "MAL Updater OS X" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"MelScrobbleX"];
}


/**
 Creates, retains, and returns the managed object model for the application 
 by merging all of the models found in the application bundle.
 */

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.  This 
 implementation will create and return a coordinator, having added the 
 store for the application to it.  (The directory for the store is created, 
 if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (persistentStoreCoordinator) return persistentStoreCoordinator;
	
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"Update History.meldb"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
												  configuration:nil 
															URL:url 
														options:nil 
														  error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    
	
    return persistentStoreCoordinator;
}

/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.) 
 */

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext) return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
	
    return managedObjectContext;
}
+ (void)initialize
{
	//Create a Dictionary
	NSMutableDictionary * defaultValues = [NSMutableDictionary dictionary];
	
	// Defaults
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:@"ShowAtStartup"];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:@"SuccessDebug"];
	[defaultValues setObject:@"" forKey:@"APIKey"];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:@"PlayerSel"];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:@"MediaType"];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:@"ImageService"];
	[defaultValues setObject:[NSNumber numberWithInt:21] forKey:@"FTPPort"];
	//Register Dictionary
	[[NSUserDefaults standardUserDefaults]
	 registerDefaults:defaultValues];

}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Check for Crash Reports
	[CMCrashReporter check];
	//Check if Application is in the /Applications Folder
	PFMoveToApplicationsFolderIfNecessary();
	//Since LSUIElement is set to 1 to hide the dock icon, it causes unattended behavior of having the program windows not show to the front.
		[NSApp activateIgnoringOtherApps:YES];
	//Show Scrobble Window at Launch?
	NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults]autorelease];
	if ([defaults boolForKey:@"ShowAtStartup"] == 0) {
		// Hide Window
		[window orderOut:self];
	}
	else {
		// Show the Window
		[window makeKeyAndOrderFront:nil];
	}
	//Register Growl
	NSBundle *myBundle = [NSBundle bundleForClass:[Melative_ExampleAppDelegate class]];
	NSString *growlPath = [[myBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl.framework"];
	NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];
	if (growlBundle && [growlBundle load]) {
		// Register ourselves as a Growl delegate
		[GrowlApplicationBridge setGrowlDelegate:self];
	}
	else {
		NSLog(@"ERROR: Could not load Growl.framework");
	}
    // Init Melative Engine
    melativeEngine = [[Melative alloc] init];
	
}

- (void) awakeFromNib{
    //Window Animation
    CAAnimation *anim = [CABasicAnimation animation];
    [anim setDelegate:self];
    [self.window setAnimations:[NSDictionary dictionaryWithObject:anim forKey:@"alphaValue"]];
    //Create the NSStatusBar and set its length
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
    
    //Used to detect where our files are
    NSBundle *bundle = [NSBundle mainBundle];
    
    //Allocates and loads the images into the application which will be used for our NSStatusItem
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"melativeicon" ofType:@"tiff"]];
    statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"melativeicon" ofType:@"tiff"]];
    
    //Sets the images in our NSStatusItem
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];
    
    //Tells the NSStatusItem what menu to load
    [statusItem setMenu:statusMenu];
    //Sets the tooptip for our item
    [statusItem setToolTip:@"MelScrobbleX"];
    //Enables highlighting
    [statusItem setHighlightMode:YES];
	//Sort Date Column by default
	NSSortDescriptor* sortDescriptor = [[[NSSortDescriptor alloc]
										 initWithKey: @"Date" ascending: NO] autorelease];
	[historytable setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    // Set Default Font Values for fieldmessage
	[fieldmessage setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
}
- (void) dealloc {
    //Releases the 2 images we loaded into memory
    [statusImage release];
    [statusHighlightImage release];
	[window release];
	[managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
	if (!preferenceController) {
	}
	else {
		[preferenceController release];
	}

    [super dealloc];
}

-(IBAction)togglescrobblewindow:(id)sender
{
	if ([window isVisible]) { 
        [self.window.animator setAlphaValue:0.0];
	} else { 
        //Since LSUIElement is set to 1 to hide the dock icon, it causes unattended behavior of having the program windows not show to the front.
		[NSApp activateIgnoringOtherApps:YES];
        self.window.alphaValue = 0.0;
        [self.window.animator setAlphaValue:1.0];
		[window makeKeyAndOrderFront:self]; 
	} 
}
-(void)showPreferences:(id)sender
{
	//Is preferenceController nil?
	if (!preferenceController) {
		preferenceController = [[PreferenceController alloc] init];
	}
	//Since LSUIElement is set to 1 to hide the dock icon, it causes unattended behavior of having the program windows not show to the front.
	[NSApp activateIgnoringOtherApps:YES];
	[preferenceController showWindow:self];
}
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	
    if (!managedObjectContext) return NSTerminateNow;
	
    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }
	
    if (![managedObjectContext hasChanges]) return NSTerminateNow;
	
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
		
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.
		
        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
		
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;
		
        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
		
        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;
		
    }
	
    return NSTerminateNow;
}
-(void)addrecord:(NSString *)rectitle
	mediasegment:(NSString *)recsegment
			Date:(NSDate *)date
			type:(int)mediatype
{
	// Add scrobble history record to the SQLite Database via Core Data
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSManagedObject *obj = [NSEntityDescription 
							insertNewObjectForEntityForName :@"History" 
							inManagedObjectContext: moc];
	// Set values in the new record
	[obj setValue:rectitle forKey:@"Title"];
	[obj setValue:recsegment forKey:@"Segment"];
	[obj setValue:date forKey:@"Date"];
	switch (mediatype) {
		case 0:
			[obj setValue:@"Anime" forKey:@"Type"];
			break;
		case 1:
			[obj setValue:@"Music" forKey:@"Type"];
			break;
	}
	
	// Release Managed Object
	[obj release];
}
-(IBAction)clearhistory:(id)sender
{
	// Set Up Prompt Message Window
	NSAlert * alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert setMessageText:@"Are you sure you want to clear the Update History?"];
	[alert setInformativeText:@"Once done, this action cannot be undone."];
	// Set Message type to Warning
	[alert setAlertStyle:NSWarningAlertStyle];
	// Show as Sheet on historywindow
	[alert beginSheetModalForWindow:historywindow 
					  modalDelegate:self
					 didEndSelector:@selector(clearhistoryended:code:conext:)
						contextInfo:NULL];
}
-(void)clearhistoryended:(NSAlert *)alert
					code:(int)choice
				  conext:(void *)v
{
	if (choice == 1000) {
		// Remove All Data
		NSManagedObjectContext *moc = [self managedObjectContext];
		NSFetchRequest * allHistory = [[NSFetchRequest alloc] init];
		[allHistory setEntity:[NSEntityDescription entityForName:@"History" inManagedObjectContext:moc]];
		
		NSError * error = nil;
		NSArray * histories = [moc executeFetchRequest:allHistory error:&error];
		[allHistory release];
		//error handling goes here
		for (NSManagedObject * history in histories) {
			[moc deleteObject:history];
		}
	}

}		
-(void)setStatusToolTip:(NSString*)toolTip
{
    [statusItem setToolTip:toolTip];
}
-(IBAction)showhistory:(id)sender
{
	//Since LSUIElement is set to 1 to hide the dock icon, it causes unattended behavior of having the program windows not show to the front.
	[NSApp activateIgnoringOtherApps:YES];
	[historywindow makeKeyAndOrderFront:self];	
}
-(void)scrobblebypass:(NSAlert *)alert
				 code:(int)achoice
			   conext:(void *)v {
	if (achoice == 1000) {
		[segment setObjectValue:@"1"];
		int httperror = [melativeEngine scrobble:[mediatypemenu indexOfSelectedItem] Title:[mediatitle stringValue]  Segment:[segment stringValue]];
		switch (httperror) {
			case 200:
				[scrobblestatus setObjectValue:@"Scrobble Successful..."];
				//Set up Delegate
				Melative_ExampleAppDelegate* appDelegate=[NSApp delegate];
				[appDelegate addrecord:[mediatitle stringValue] mediasegment:[segment stringValue] Date:[NSDate date] type:[mediatypemenu indexOfSelectedItem]];
				break;
			case 401:
				//Login Failed, show error message
				[self showsheetmessage:@"MelScrobbleX was unable to scrobble since you don't have the correct username and/or password" explaination:@"Check your username and password and try the scrobble command again. If you recently changed your password, enter your new password and try again."];
				// Set Status
				[scrobblestatus setObjectValue:@"Unable to Scrobble..."];
				break;
			default:
				//Login Failed, show error message
				[self showsheetmessage:@"MelScrobbleX was unable to scrobble because of an unknown error." explaination:[NSString stringWithFormat:@"Error %i", httperror]];
				// Set Status
				[scrobblestatus setObjectValue:@"Unable to Scrobble..."];
				break;
		}
	}
	else {
		[scrobblestatus setObjectValue:@"Title/Segment Missing..."];
	}
	
}
- (IBAction)toggletimer:(id)sender {
	if (timer == nil) {
		//Create Timer
		timer = [[NSTimer scheduledTimerWithTimeInterval:180
												  target:self
												selector:@selector(firetimer:)
												userInfo:nil
												 repeats:YES] retain];
		[togglescrobbler setTitle:@"Stop Auto Scrobbling"];
		[GrowlApplicationBridge notifyWithTitle:@"MelScrobbleX"
									description:@"Auto Scrobble is now turned on."
							   notificationName:@"Message"
									   iconData:nil
									   priority:0
									   isSticky:NO
								   clickContext:[NSDate date]];
	}
	else {
		//Stop Timer
		// Remove Timer
		[timer invalidate];
		[timer release];
		timer = nil;
		[togglescrobbler setTitle:@"Start Auto Scrobbling"];
		[GrowlApplicationBridge notifyWithTitle:@"MelScrobbleX"
									description:@"Auto Scrobble is now turned off."
							   notificationName:@"Message"
									   iconData:nil
									   priority:0
									   isSticky:NO
								   clickContext:[NSDate date]];
	}
	
}
- (void)firetimer:(NSTimer *)aTimer {
	switch ([mediatypemenu indexOfSelectedItem]) {
		case 0:
			// Init Anime Detection
			[melativeEngine animedetect];
			break;
		case 1:
			// Init Music Detection
			[melativeEngine musicdetect];
			break;
        case 2:
			// Init Anime Detection
			[melativeEngine animedetect];
			break;
	}
	if ([[segment stringValue] length] == 0 || [[mediatitle stringValue]length] == 0 ) {
		// Do Nothing
	}
	else if ([[mediatitle stringValue] isEqualToString:[melativeEngine getScrobbledMediaTitle]] && [[segment stringValue] isEqualToString: [melativeEngine getScrobbledMediaSegment]] && [melativeEngine  getscrobblesuccess] == 1) {
		// Do Nothing
		NSLog(@"Already Scrobbled");
	}
	else {
		//Execute Scrobble Command and retrieve HTTPCode
		int httperror = [melativeEngine scrobble:[mediatypemenu indexOfSelectedItem] Title:[mediatitle stringValue] Segment:[segment stringValue]];
		switch (httperror) {
			case 200:
				[scrobblestatus setObjectValue:@"Scrobble Successful..."];
				[GrowlApplicationBridge notifyWithTitle:@"Scrobble Successful"
											description:[NSString stringWithFormat:@"%@ - %@", [mediatitle stringValue], [segment stringValue]] 
									   notificationName:@"Message"
											   iconData:nil
											   priority:0
											   isSticky:NO
										   clickContext:[NSDate date]];
				[melativeEngine setScrobbledMediaTitle:[mediatitle stringValue]];
				[melativeEngine setScrobbledMediaSegment:[segment stringValue]];
                [melativeEngine setScrobbleSuccess: YES];
				//Set up Delegate
				Melative_ExampleAppDelegate* appDelegate=[NSApp delegate];
				//Set last successful scrobble to statusItem Tooltip
				[appDelegate setStatusToolTip:[NSString stringWithFormat:@"MelScrobbleX - Last Scrobble: %@ - %@", [mediatitle stringValue], [segment stringValue]]];						
				//Add to History
				[appDelegate addrecord:[melativeEngine getScrobbledMediaTitle] mediasegment:[melativeEngine getScrobbledMediaSegment] Date:[NSDate date] type:[mediatypemenu indexOfSelectedItem]];
				break;
			case 401:
				// Set Status
				[scrobblestatus setObjectValue:@"Unable to Scrobble..."];
				[GrowlApplicationBridge notifyWithTitle:@"Scrobble Unsuccessful"
											description:@"Check your login information and try scrobbling again." 
									   notificationName:@"Message"
											   iconData:nil
											   priority:0
											   isSticky:NO
										   clickContext:[NSDate date]];
				[melativeEngine setScrobbleSuccess: NO];
				break;
			default: // Any error codes thats not 200 or 401
				// Set Status
				[scrobblestatus setObjectValue:@"Unable to Scrobble..."];
				[GrowlApplicationBridge notifyWithTitle:@"Scrobble Unsuccessful"
											description:[NSString stringWithFormat:@"Unknown Error. Error %i", httperror]
									   notificationName:@"Message"
											   iconData:nil
											   priority:0
											   isSticky:NO
										   clickContext:[NSDate date]];
                [melativeEngine setScrobbleSuccess: NO];
				break;				
		}
		
	}
}
-(IBAction)resetfields:(id)sender
{
	// Clear All Fields
	[fieldmessage setString:@""];
	[mediatitle setObjectValue:@""];
	[segment setObjectValue:@""];
	[artist setObjectValue:@""];
	[scrobblestatus setObjectValue:@"All fields cleared..."];
}
-(IBAction)scrobble:(id)sender {
	if ([[segment stringValue] length] == 0 || [[mediatitle stringValue]length] == 0 ) {
		switch ([mediatypemenu indexOfSelectedItem]) {
			case 0:
			case 2:
				if ([[mediatitle stringValue] length] != 0) {
					// Set Up Prompt Message Window
					NSAlert * alert = [[[NSAlert alloc] init] autorelease];
					[alert addButtonWithTitle:@"Yes"];
					[alert addButtonWithTitle:@"No"];
					[alert setMessageText:@"Do you really want to perform a scrobble commend with the current information?"];
					[alert setInformativeText:@"No segment has been entered. It will default to 1 if you continue."];
					// Set Message type to Warning
					[alert setAlertStyle:NSWarningAlertStyle];
					Melative_ExampleAppDelegate* appDelegate=[NSApp delegate];	
					// Show as Sheet on historywindow
					[alert beginSheetModalForWindow:[appDelegate window]
									  modalDelegate:self
									 didEndSelector:@selector(scrobblebypass:code:conext:)
										contextInfo:NULL];
					break;
				}
			default:
				// No segment or title	
				[self showsheetmessage:@"MelScrobbleX was unable to scrobble since you didn't enter a title or segment info." explaination:@"Enter a media title or segment and try the scrobble command again."];
				[scrobblestatus setObjectValue:@"Title/Segment Missing..."];
				break;
		}
	}
	else {
		int httperror = [melativeEngine scrobble:[mediatypemenu indexOfSelectedItem] Title:[mediatitle stringValue] Segment:[segment stringValue]];
		switch (httperror) {
			case 200:
				[scrobblestatus setObjectValue:@"Scrobble Successful..."];
				//Set up Delegate
				Melative_ExampleAppDelegate* appDelegate=[NSApp delegate];
				[appDelegate addrecord:[mediatitle stringValue] mediasegment:[segment stringValue] Date:[NSDate date] type:[mediatypemenu indexOfSelectedItem]];
				break;
			case 401:
				//Login Failed, show error message
				[self showsheetmessage:@"MelScrobbleX was unable to scrobble since you don't have the correct username and/or password" explaination:@"Check your username and password and try the scrobble command again. If you recently changed your password, enter your new password and try again."];
				// Set Status
				[scrobblestatus setObjectValue:@"Unable to Scrobble..."];
				break;
			default:
				//Login Failed, show error message
				[self showsheetmessage:@"MelScrobbleX was unable to scrobble because of an unknown error." explaination:[NSString stringWithFormat:@"Error %i", httperror]];
				// Set Status
				[scrobblestatus setObjectValue:@"Unable to Scrobble..."];
				break;
		}
	}
}
-(IBAction)getnowplaying:(id)sender {
	switch ([mediatypemenu indexOfSelectedItem]) {
		case 0:
			// Init Anime Detection
			[melativeEngine animedetect];
			break;
		case 1:
			// Init Music Detection
			[melativeEngine musicdetect];
			break;
		case 2:
			// Init Adrama Detection
			[melativeEngine animedetect];
			break;
	}
	[mediatitle setObjectValue:[melativeEngine getdetectedmediatitle]];
	[segment setObjectValue:[melativeEngine getdetectedmediasegment]];
    [scrobblestatus setObjectValue:[melativeEngine getscrobblerstatus]];
}

-(IBAction)postmessage:(id)sender {
	// Set Status
	[scrobblestatus setObjectValue:@"Posting..."];
	//Post the update		
    if ( [[fieldmessage string] length] == 0 && [[mediatitle stringValue]length] == 0 ) {
        //No message, show error
        [self showsheetmessage:@"MelScrobbleX was unable to post an update since you didn't enter a message." explaination:@"Enter a message and try posting again"];
        [scrobblestatus setObjectValue:@"No Message Entered.."];
    }
    else {
        int httperror = [melativeEngine postupdate:[mediatypemenu indexOfSelectedItem] Title:[mediatitle stringValue] Segment:[segment stringValue] theMessage:[fieldmessage string] completed:[completecheckbox state] Twitter:[sendtotwitter state]];
        switch (httperror) {
            case 200: // 200 - OK
                [scrobblestatus setObjectValue:@"Post Successful..."];
                //Clear Message
                [fieldmessage setString:@""];
                //Unset "Complete" and "Send to Twitter" checkboxes
                [completecheckbox setState:0];
                [sendtotwitter setState:0];
                break;
					
            case 401: // 401 - Unauthorized
                //Login Failed, show error message
                [self showsheetmessage:@"MelScrobbleX was unable to post an update since you don't have the correct username and/or password" explaination:@"Check your username and password and try posting again. If you recently changed your password, enter you new password and try again."];
                [scrobblestatus setObjectValue:@"Unable to Post..."];
                break;
					
            default:
                //Some other error...
                [self showsheetmessage:@"MelScrobbleX was unable to post an update because of an unknown error." explaination:[NSString stringWithFormat:@"Error %i", httperror]];
                [scrobblestatus setObjectValue:@"Unable to Post..."];
                break;
			}
		}
	}
-(void)showsheetmessage:(NSString *)message
		   explaination:(NSString *)explaination
{
	// Set Up Prompt Message Window
	NSAlert * alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:message];
	[alert setInformativeText:explaination];
	// Set Message type to Warning
	[alert setAlertStyle:1];
	// Show as Sheet on Preference Window
	[alert beginSheetModalForWindow:window
					  modalDelegate:self
					 didEndSelector:nil
						contextInfo:NULL];
}
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag 
{
    if(self.window.alphaValue == 0.00) 		
        [window orderOut:self];  //detect end of fade out and hide the window
}
- (BOOL)windowShouldClose:(id)window
{
    // Animate the window's alpha value so it fades out.
     [self.window.animator setAlphaValue:0.0];
    // Don't close the window immediately so we can see the animation.
    return NO;
}

@end
