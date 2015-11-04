//
//  AppDelegate.m
//  ThemisUXTestExample
//
//  Created by Vixentael on 13.04.15.
//  Copyright (c) 2015 Cossack Labs. All rights reserved.
//

#import "AppDelegate.h"
#import "TTServerMessaging.h"
#import <objcthemis/skeygen.h>


@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self testingServer];

    return YES;
}


- (void)testingServer {
    TTServerMessaging * serverMessaging = [TTServerMessaging shared];

    [serverMessaging cleanup];
    [serverMessaging initializeClientSessionWithSuccess:^(id response) {

        [serverMessaging encryptAndSendMessage:@"hello, young padawan!" success:nil error:nil];

    } error:^(NSError * error) {
        NSLog(@"handshake failed");
    }];
}

@end
