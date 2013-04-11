//
//  WWDCPageLoader.h
//  WWDCAlert
//
//  Created by Tim Mecking on 4/1/13.
//  Copyright (c) 2013 RMatta. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* WWDCPageLoaderUpdateNotification;

@interface WWDCPageLoader : NSObject
+(WWDCPageLoader*)sharedLoader;
@property (nonatomic,strong) NSURL* url;
@property (nonatomic,readonly) NSString* htmlString;
@property (nonatomic,readonly) NSDate* loadDate;
@property (nonatomic,readonly) NSDate* lastCheck;
@property (nonatomic,readonly) BOOL loading;
@property (nonatomic,readonly) NSError* lastError;
@property (nonatomic,readonly) BOOL contentChanged;

-(void)refresh;

@end
