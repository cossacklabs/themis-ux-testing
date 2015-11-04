//
// Created by Vixentael on 13.04.15.
// Copyright (c) 2015 Cossack Labs. All rights reserved.
//

#import "TTServerMessaging.h"
#import "AFHTTPRequestOperationManager.h"
#import "NSString+Random.h"
#import <objcthemis/skeygen.h>
#import <objcthemis/smessage.h>


static NSString * kBaseURL = @"http://127.0.0.1:8828";

// assume that you already have server public key
static char kServerPublicKey[] = "\x55\x45\x43\x32\x00\x00\x00\x2d\x75\x58\x33\xd4\x02\x12\xdf\x1f\xe9\xea\x48\x11\xe1\xf9\x71\x8e\x24\x11\xcb\xfd\xc0\xa3\x6e\xd6\xac\x88\xb6\x44\xc2\x9a\x24\x84\xee\x50\x4c\x3e\xa0";


// saving data keys
static NSString * kUserDefaultsPublicKey = @"kUserDefaultsPublicKey";
static NSString * kUserDefaultsPrivateKey = @"kUserDefaultsPrivateKey";
static NSString * kUserDefaultsNameKey = @"kUserDefaultsNameKey";


@interface TTServerMessaging ()

@property (nonatomic, strong) NSData * publicKey;
@property (nonatomic, strong) NSData * privateKey;

@property (nonatomic, strong) NSMutableData * serverPublicKey;

@property (nonatomic, readwrite, strong) NSString * name;

@property (nonatomic, strong) TSMessage * messageEncrypter;

@end

@implementation TTServerMessaging


+ (instancetype)shared {
    static TTServerMessaging * _instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });

    return _instance;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        [self postInitialization];
    }
    return self;
}


- (void)postInitialization {
    self.name = @"ios";

    [self loadKeys];
}


// 1a generate own public/private keys
- (void)generateOwnKeys {
    TSKeyGen * keygenEC = [[TSKeyGen alloc] initWithAlgorithm:TSKeyGenAsymmetricAlgorithmEC];
    
    if (!keygenEC) {
        NSLog(@"%s Error occured while initializing object keygenEC", sel_getName(_cmd));
        return;
    }
    
    self.privateKey = keygenEC.privateKey;
    self.publicKey = keygenEC.publicKey;
}


// 1. initialize client session:
// - generate keys
// - send client public key to server
// - get server key
- (void)initializeClientSessionWithSuccess:(SFSuccessBlock)successBlock error:(SFErrorBlock)errorBlock {
    if (!self.privateKey || !self.publicKey) {
        [self generateOwnKeys];
        [self saveKeys];
        [self sendKeyToServerWithSuccess:successBlock error:errorBlock];
    } else {
        if (successBlock) {
            successBlock(@"using old keys");
        }
    }
}


// 1b send own public key to server
- (void)sendKeyToServerWithSuccess:(SFSuccessBlock)successBlock error:(SFErrorBlock)errorBlock {
    // convert key into string
    NSData * base64 = [self.publicKey base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString * stringKey = [[NSString alloc] initWithData:base64 encoding:NSUTF8StringEncoding];
    
    NSLog(@"%s\nkey ---> %@", sel_getName(_cmd), stringKey);
    [self sendRequestWithMessage:stringKey success:successBlock error:errorBlock];
}


// 2. send messages to server
// - create message enrypter
// - encrypt message
// - send encrypted message
- (void)encryptAndSendMessage:(NSString *)string success:(SFSuccessBlock)successBlock error:(SFErrorBlock)errorBlock {
    NSString * resultString = [self encryptMessage:string];
    if (resultString) {
        [self sendRequestWithMessage:resultString success:successBlock error:errorBlock];
        
    } else {
        if (errorBlock) {
            NSDictionary * details = @{NSLocalizedDescriptionKey:@"Error occured during message encryption before sending"};
            NSError * error = [NSError errorWithDomain:@"com.cossacklabs.ThemisTest" code:-1 userInfo:details];
            errorBlock(error);
        }
    }
}


// 2a. initialize encrypter using server public key
- (void)setupMessageEncrypter {
    if (!self.serverPublicKey) {
        self.serverPublicKey = [[NSData dataWithBytes:kServerPublicKey length:sizeof(kServerPublicKey) - 1] mutableCopy];
    }
    if (!self.messageEncrypter) {
        self.messageEncrypter = [[TSMessage alloc] initInEncryptModeWithPrivateKey:self.privateKey peerPublicKey:self.serverPublicKey];
    }
}


// 2b. encrypt message using encrypter
- (NSString *)encryptMessage:(NSString *)message {
    if (!self.messageEncrypter) {
        [self setupMessageEncrypter];
    }
    NSError * error;
    NSData * encryptedMessage = [self.messageEncrypter wrapData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                                          error:&error];
    if (error) {
        NSLog(@"ERROR in encrypting message %@", error);
        return nil;
    }
    
    NSData * base64 = [encryptedMessage base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString * resultString = [[NSString alloc] initWithData:base64 encoding:NSUTF8StringEncoding];
    return resultString;
}


// 3. send enrypted message to server
// - send request with encrypted message
// - parse response
// - decrypt response message
- (void)sendRequestWithMessage:(NSString *)message success:(SFSuccessBlock)successBlock error:(SFErrorBlock)errorBlock {
    if (!message) {
        NSLog(@"ERROR while sending message: no message %@", message);
        return;
    }
    
    NSURL * url = [NSURL URLWithString:kBaseURL];
    AFHTTPRequestOperationManager * manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    NSString * name = self.name;
    NSDictionary * parameters = @{ name : message };

    //NSLog(@"sending message %@", parameters);
    
    __weak typeof(self) weakSelf = self;
    [manager POST:@"" parameters:parameters success:^(AFHTTPRequestOperation * operation, id responseObject) {
        NSLog(@"send message %@\nresponse SUCCESS:\n%@", parameters, responseObject);

        NSString * response = [weakSelf parseResponse:responseObject];
        
        if (successBlock) {
            successBlock(response);
        }
        
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        NSLog(@"send message %@\nresponse ERROR:\n%@", parameters, error);
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

// 3a. parse response
- (NSString *)parseResponse:(NSDictionary *)responseObject {
    NSDictionary * dictionary = (NSDictionary *)responseObject;
    NSString * responseBase64 = dictionary[@"answer"];
    NSString * response = [self decryptMessage:responseBase64];
    return response;
}


// 3b. decrypt response
- (NSString * )decryptMessage:(NSString * )base64Message {
    NSData * base64Data = [[NSData alloc] initWithBase64EncodedString:base64Message options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (!base64Data) {
        return nil;
    }
    NSError * error;
    
    [self setupMessageEncrypter];
    
    NSData * decryptedMessage = [self.messageEncrypter unwrapData:base64Data error:&error];
    if (error) {
        NSLog(@"ERROR in decrypting message %@", error);
        return nil;
    }

    NSString * resultString = [[NSString alloc] initWithData:decryptedMessage encoding:NSUTF8StringEncoding];
    return resultString;
}


#pragma mark - Public

- (void)cleanup {
    self.privateKey = nil;
    self.publicKey = nil;
    self.messageEncrypter = nil;
    [self saveKeys];
    [self regenerateName];
}


- (void)regenerateName {
    self.name = [NSString randomStringWithLength:4];
}


#pragma mark - Save & load data

- (void)saveKeys {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.publicKey forKey:kUserDefaultsPublicKey];
    [defaults setObject:self.privateKey forKey:kUserDefaultsPrivateKey];
    [defaults setObject:self.name forKey:kUserDefaultsNameKey];
}


- (void)loadKeys {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData * data = [defaults objectForKey:kUserDefaultsPublicKey];
    if (data && [data length] > 0) {
        self.publicKey = [data mutableCopy];
    }

    data = [defaults objectForKey:kUserDefaultsPrivateKey];
    if (data && [data length] > 0) {
        self.privateKey = [data mutableCopy];
    }

    NSString * name = [defaults objectForKey:kUserDefaultsNameKey];
    if (name) {
        self.name = name;
    }
}


@end