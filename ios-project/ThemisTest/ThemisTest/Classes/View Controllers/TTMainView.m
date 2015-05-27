//
// Created by Vixentael on 13.04.15.
// Copyright (c) 2015 Cossack Labs. All rights reserved.
//

#import "TTMainView.h"
#import "UIView+Center.h"
#import "UIView+SFAdditions.h"


@interface TTMainView ()<UITextFieldDelegate>
@end


@implementation TTMainView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self postInitialization];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self postInitialization];
    }
    return self;
}


- (void)postInitialization {
    self.nameLabel = [UILabel new];
    [self addSubview:self.nameLabel];

    self.serverResponseLabel = [UILabel new];
    [self addSubview:self.serverResponseLabel];

    self.messageTextView = ({
        UITextField * textField = [UITextField new];
        textField.placeholder = @"message";
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.returnKeyType = UIReturnKeyDone;
        textField.text = @"your message here!";
        textField.delegate = self;
        textField;
    });
    [self addSubview:self.messageTextView];

    self.sendButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTintColor:[UIColor blueColor]];
        [button setTitle:@"Send" forState:UIControlStateNormal];
        button;
    });
    [self addSubview:self.sendButton];

    self.generateNewNameButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTintColor:[UIColor blueColor]];
        [button setTitle:@"generate new name" forState:UIControlStateNormal];
        button;
    });
    [self addSubview:self.generateNewNameButton];
}


#pragma mark - layout

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat offset = 10;

    [self.nameLabel sizeToFit];
    [self.nameLabel centerWidthInView:self];
    self.nameLabel.top = 60;
    self.nameLabel.left = offset;

    [self.generateNewNameButton sizeToFit];
    self.generateNewNameButton.right = self.width - offset;
    self.generateNewNameButton.centerY = self.nameLabel.centerY;

    // --------------

    [self.serverResponseLabel sizeToFit];
    [self.serverResponseLabel centerWidthInView:self];
    self.serverResponseLabel.top = self.nameLabel.bottom + offset;
    self.serverResponseLabel.left = offset;

    // --------------

    self.sendButton.size = CGSizeMake(60, 44);
    self.sendButton.right = self.width - offset;
    [self.sendButton centerHeightInView:self];

    self.messageTextView.size = CGSizeMake(self.sendButton.left - 2 * offset, 44);
    self.messageTextView.top = self.sendButton.top;
    self.messageTextView.left = offset;
}


#pragma mark - Public

- (void)updateNameLabel:(NSString * )name {
    NSString * longName = [NSString stringWithFormat:@"my name is: %@", name];
    [self.nameLabel setText:longName];
    [self.nameLabel sizeToFit];
}


- (void)updateServerResponseLabel:(NSString *)name {
    NSString * longName = [NSString stringWithFormat:@"server responds: %@", name];
    [self.serverResponseLabel setText:longName];
    [self.serverResponseLabel sizeToFit];
}


#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.sendButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    return YES;
}


@end