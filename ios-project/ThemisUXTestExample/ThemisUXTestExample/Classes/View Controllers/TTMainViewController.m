//
//  TTMainViewController.m
//  ThemisUXTestExample
//
//  Created by Vixentael on 13.04.15.
//  Copyright (c) 2015 Cossack Labs. All rights reserved.
//

#import "TTMainViewController.h"
#import "TTMainView.h"
#import "UIControl+RACSignalSupport.h"
#import "RACSignal.h"
#import "TTServerMessaging.h"


@interface TTMainViewController ()

@property (nonatomic, strong) TTMainView * customView;
@end

@implementation TTMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customView = [TTMainView new];
    [self.view addSubview:self.customView];

    __weak typeof(self) weakSelf = self;
    [[self.customView.generateNewNameButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [weakSelf cleanupKeys];
    }];
    [[self.customView.sendButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [weakSelf sendMessage];
    }];

}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    self.customView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateName];
}


#pragma mark - actions

- (void)updateName {
    TTServerMessaging * serverMessaging = [TTServerMessaging shared];
    NSString * name = serverMessaging.name;
    [self.customView updateNameLabel:name];
}

- (void)updateServerResponse:(NSString * )response {
    [self.customView updateServerResponseLabel:response];
}


- (void)cleanupKeys {
    TTServerMessaging * serverMessaging = [TTServerMessaging shared];
    [serverMessaging cleanup];
    [serverMessaging regenerateName];
    [self updateName];
}


- (void)sendMessage {
    TTServerMessaging * serverMessaging = [TTServerMessaging shared];
    NSString * message = self.customView.messageTextView.text;

    __weak typeof(self) weakSelf = self;
    [serverMessaging initializeClientSessionWithSuccess:^(id handshake) {

        [serverMessaging encryptAndSendMessage:message success:^(id response) {

             [weakSelf updateServerResponse:response];
        } error:^(NSError * error) {

            NSLog(@"message sending failed");
        }];

    } error:^(NSError * error) {
        NSLog(@"handshake failed");
    }];
}


@end
