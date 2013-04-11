//
//  AppDelegate.m
//  WWDCAlert
//
//  Created by Tim Mecking on 4/2/13.
//  Copyright (c) 2013 Tim Mecking. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "WWDCPageLoader.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{
	 @"url":								@"https://developer.apple.com/wwdc/",
	 @"contentChangeNotification":		@"Squeeze Toy.aif",
	 @"notRunningNotification":			@"<default>",
	 @"backgroundLaunchNotification":	@"<disabled>"
	 }];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = [[ViewController alloc] initWithNibName:nil bundle:nil];
    [self.window makeKeyAndVisible];
	
	[self updateScheduledLocalNotifications];
	[[WWDCPageLoader sharedLoader] refresh];
	
	[application setKeepAliveTimeout:UIMinimumKeepAliveTimeout handler:^{
		[self updateScheduledLocalNotifications];
		[[WWDCPageLoader sharedLoader] refresh];
	}];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[(ViewController*)self.window.rootViewController applicationDidEnterBackground];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	[(ViewController*)self.window.rootViewController update];
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	[self updateScheduledLocalNotifications];
}

-(void)updateScheduledLocalNotifications {
	NSArray* localNotifications=[[UIApplication sharedApplication] scheduledLocalNotifications];
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	for(UILocalNotification* notification in localNotifications) {
		if(([notification.userInfo[@"cancelDate"] timeIntervalSinceNow]>0.0) &&
		   ([[UIApplication sharedApplication] applicationState]!=UIApplicationStateActive)) {
			[[UIApplication sharedApplication] scheduleLocalNotification:notification];
		}
	}
	NSString* soundName=[[NSUserDefaults standardUserDefaults] stringForKey:@"notRunningNotification"];
	if(![soundName isEqualToString:@"<disabled>"]) {
		if([soundName isEqualToString:@"<nosound>"]) {
			soundName=nil;
		}
		else if([soundName isEqualToString:@"default"]) {
			soundName=UILocalNotificationDefaultSoundName;
		}
		UILocalNotification* notification=[[UILocalNotification alloc] init];
		notification.alertBody = @"App not running";
		notification.alertAction = @"Launch";
		notification.applicationIconBadgeNumber = 1;
		notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:UIMinimumKeepAliveTimeout+5.0];
		notification.soundName = soundName;
		notification.repeatInterval=NSMinuteCalendarUnit;
		[[UIApplication sharedApplication] scheduleLocalNotification:notification];
	}
}

@end
