//
//  PebbleConnectionManager.h
//  Pebble MusicTweeter
//
//  Created by Arnav Kumar on 21/12/13.
//  Copyright (c) 2013 Arnav Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PebbleKit/PebbleKit.h>

@protocol PebbleResponderDelegate

- (void) respondToMessage:(NSDictionary *)message fromWatch:(PBWatch *)watch;
- (void) respondToMessage:(NSDictionary *)message;

@end

@interface PebbleConnectionManager : NSObject <PBPebbleCentralDelegate>

+ (PebbleConnectionManager *) sharedManager;

- (PBWatch *) lastConnectedWatch;
- (void) registerDelegate:(id<PebbleResponderDelegate>)delegate;
- (void) sendMessage:(NSDictionary *)message;

@end
