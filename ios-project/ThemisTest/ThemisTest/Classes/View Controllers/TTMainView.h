//
// Created by Vixentael on 13.04.15.
// Copyright (c) 2015 Cossack Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@interface TTMainView : UIView

@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * serverResponseLabel;

@property (nonatomic, strong) UITextField * messageTextView;

@property (nonatomic, strong) UIButton * sendButton;
@property (nonatomic, strong) UIButton * generateNewNameButton;

- (void)updateNameLabel:(NSString *)name;

- (void)updateServerResponseLabel:(NSString *)name;

@end