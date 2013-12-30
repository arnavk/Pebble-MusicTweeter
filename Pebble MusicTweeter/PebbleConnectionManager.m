//
//  PebbleConnectionManager.m
//  Pebble MusicTweeter
//
//  Created by Arnav Kumar on 21/12/13.
//  Copyright (c) 2013 Arnav Kumar. All rights reserved.
//

#import "PebbleConnectionManager.h"

@interface PebbleConnectionManager()

@property (nonatomic, strong) PBWatch *connectedWatch;
@property (nonatomic, weak) id<PebbleResponderDelegate> delegate;

@end

@implementation PebbleConnectionManager


+ (PebbleConnectionManager *)sharedManager {
    static PebbleConnectionManager *sharedManager = nil;
    @synchronized(self) {
        if (sharedManager == nil)
            sharedManager = [[self alloc] init];
    }
    return sharedManager;
}

- (id)init {
    if (self = [super init]) {
        self.connectedWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
        [[PBPebbleCentral defaultCentral] setDelegate:self];
        [self setupCommunication];
        NSLog(@"Last connected watch: %@", self.connectedWatch);
    }
    return self;
}

- (void) registerDelegate:(id<PebbleResponderDelegate>)delegate
{
    self.delegate = delegate;
}

- (PBWatch *)lastConnectedWatch {
    return self.connectedWatch;
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    NSLog(@"Pebble connected: %@", [watch name]);
    self.connectedWatch = watch;
    [self setupCommunication];
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    NSLog(@"Pebble disconnected: %@", [watch name]);
    
    if (self.connectedWatch == watch || [watch isEqual:self.connectedWatch]) {
        self.connectedWatch = nil;
    }
}

- (NSString *) getConnectedWatchName {
    return self.connectedWatch.name;
}

- (NSString *) getConnectedWatchSerialNumber
{
    return self.connectedWatch.serialNumber;
}

- (void) setupCommunication
{
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:@"df04464f-aba9-40ad-90e4-88a5968d6964"];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    
    [self.connectedWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
        [self receivedMessage:update fromWatch:watch];
        return YES;
    }];
}

- (void) sendMessage:(NSDictionary *)message
{
    [self.connectedWatch appMessagesPushUpdate:message onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent message.");
        }
        else {
            NSLog(@"Error sending message: %@", error);
        }
    }];
}

- (void) receivedMessage: (NSDictionary *)update fromWatch:(PBWatch *)watch
{
    NSLog(@"Received message yo: %@", update);
    [self.delegate respondToMessage:update];
}

@end
