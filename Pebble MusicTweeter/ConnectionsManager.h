//
//  PebbleResponder.h
//  Pebble MusicTweeter
//
//  Created by Arnav Kumar on 30/12/13.
//  Copyright (c) 2013 Arnav Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PebbleConnectionManager.h"
#import <PebbleKit/PebbleKit.h>

@protocol PebbleInformationDisplayDelegate

- (void) connectedToWatch:(PBWatch *)watch;
- (void) disconnectedFromWatch:(PBWatch *)watch;

@end

@interface ConnectionsManager : NSObject <PebbleResponderDelegate, UITextViewDelegate>

+ (ConnectionsManager *) sharedManager;
+ (void) setup;

- (NSString *) tweetTemplate;
- (void) registerDelegate:(id<PebbleInformationDisplayDelegate>)delegate;
- (PBWatch *) connectedWatch;

@end
