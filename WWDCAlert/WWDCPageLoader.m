//
//  WWDCPageLoader.m
//  WWDCAlert
//
//  Created by Tim Mecking on 4/1/13.
//  Copyright (c) 2013 RMatta. All rights reserved.
//

#import "WWDCPageLoader.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AFNetworking/AFNetworking.h>

NSString* WWDCPageLoaderUpdateNotification=@"WWDCPageLoaderUpdateNotification";

@interface WWDCPageLoader ()
@property (nonatomic,strong) NSString* htmlString;
@property (nonatomic,strong) NSDate* loadDate;
@property (nonatomic,strong) NSDate* lastCheck;
@property (nonatomic,assign) BOOL loading;
@property (nonatomic,strong) NSError* lastError;
@property (nonatomic,assign) BOOL contentChanged;
@end

@implementation WWDCPageLoader

+(WWDCPageLoader *)sharedLoader {
	static WWDCPageLoader* sharedLoader=nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedLoader=[[self alloc] init];
	});
	return sharedLoader;
}

-(void)refresh {
	NSLog(@"start loading");
	NSString* urlString=[[NSUserDefaults standardUserDefaults] stringForKey:@"url"];
	if((![urlString hasPrefix:@"http://"]) && (![urlString hasPrefix:@"https://"])) {
		urlString=@"https://developer.apple.com/wwdc/";
		[[NSUserDefaults standardUserDefaults] setObject:urlString forKey:@"url"];
	}
	self.url=[NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
	
    UIBackgroundTaskIdentifier backgroundTask=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
		
	}];
	AFHTTPClient *client = [AFHTTPClient new];
    AFHTTPRequestOperation *operation =
    [client HTTPRequestOperationWithRequest:request
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
										NSLog(@"page loaded");
										NSString* htmlString=[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
										self.lastError=nil;
										self.loading=NO;
										if(!self.htmlString) {
											self.htmlString=htmlString;
											self.loadDate=[NSDate date];
											
											NSNumber* previousHash=[[NSUserDefaults standardUserDefaults] objectForKey:@"pageContentHash"];
											NSNumber* previousLength=[[NSUserDefaults standardUserDefaults] objectForKey:@"pageContentLength"];
											self.contentChanged=(((previousHash) && (![previousHash isEqual:@([htmlString hash])])) ||
																 ((previousLength) && (![previousLength isEqual:@([htmlString length])])));
											[self notify];
										}
										else if([self.htmlString isEqual:htmlString]){
											self.lastCheck=[NSDate date];
											self.contentChanged=NO;
										}
										else {
											self.lastCheck=[NSDate date];
											self.loadDate=self.lastCheck;
											self.htmlString=htmlString;
											self.contentChanged=YES;
											[self notify];
										}
																				
										if(self.contentChanged) {
											[[NSUserDefaults standardUserDefaults] setObject:@([htmlString hash]) forKey:@"pageContentHash"];
											[[NSUserDefaults standardUserDefaults] setObject:@([htmlString length]) forKey:@"pageContentLength"];
											[[NSUserDefaults standardUserDefaults] synchronize];
										}

										[[NSNotificationCenter defaultCenter] postNotificationName:WWDCPageLoaderUpdateNotification object:self];
										[[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
										NSLog(@"failed loading %@",error);
                                        self.lastCheck=[NSDate date];
										self.lastError=error;
										self.loading=NO;
										
										[[NSNotificationCenter defaultCenter] postNotificationName:WWDCPageLoaderUpdateNotification object:self];
										[[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                                    }];
	self.loading=YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:WWDCPageLoaderUpdateNotification object:self];
    [operation start];
}

-(void)notify {
	if(self.contentChanged) {
		NSLog(@"page content changed");
		if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
			NSString* soundName=[[NSUserDefaults standardUserDefaults] stringForKey:@"contentChangeNotification"];
			if(![soundName isEqualToString:@"<disabled>"]) {
				if([soundName isEqualToString:@"<nosound>"]) {
					soundName=nil;
				}
				else if([soundName isEqualToString:@"default"]) {
					soundName=UILocalNotificationDefaultSoundName;
				}
				UILocalNotification* notification=[[UILocalNotification alloc] init];
				notification.alertBody=@"Webpage content changed.";
				notification.soundName=soundName;
				notification.alertAction=@"Show";
				notification.fireDate=[NSDate date];
				notification.repeatInterval=NSMinuteCalendarUnit;
				notification.applicationIconBadgeNumber=1;
				notification.userInfo=@{@"cancelDate":[NSDate dateWithTimeIntervalSinceNow:3600.0]};
				[[UIApplication sharedApplication] scheduleLocalNotification:notification];
			}
		}
		else {
			[[[UIAlertView alloc] initWithTitle:nil
										message:@"Webpage content changed."
									   delegate:nil
							  cancelButtonTitle:@"Dismiss"
							  otherButtonTitles:nil] show];
		}
	}
	else if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
		NSLog(@"background launch");
		NSString* soundName=[[NSUserDefaults standardUserDefaults] stringForKey:@"backgroundLaunchNotification"];
		if(![soundName isEqualToString:@"<disabled>"]) {
			if([soundName isEqualToString:@"<nosound>"]) {
				soundName=nil;
			}
			else if([soundName isEqualToString:@"default"]) {
				soundName=UILocalNotificationDefaultSoundName;
			}
			UILocalNotification* notification=[[UILocalNotification alloc] init];
			notification.alertBody=@"App launched in background";
			notification.hasAction=NO;
			notification.fireDate=nil;
			notification.soundName=soundName;
			[[UIApplication sharedApplication] scheduleLocalNotification:notification];
		}
	}
}

@end
