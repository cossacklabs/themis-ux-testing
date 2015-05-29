//
// Created by Vixentael on 13.04.15.
// Copyright (c) 2015 Cossack Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsefulBlocks.h"


@interface TTServerMessaging : NSObject


@property (nonatomic, readonly) NSString * name;

+ (instancetype)shared;

- (void)initializeClientSessionWithSuccess:(SFSuccessBlock)successBlock error:(SFErrorBlock)errorBlock;

- (void)encryptAndSendMessage:(NSString *)string success:(SFSuccessBlock)successBlock error:(SFErrorBlock)errorBlock;

- (void)cleanup;

- (void)regenerateName;
@end