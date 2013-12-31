//
//  PebbleResponder.h
//  Pebble MusicTweeter
//
//  Created by Arnav Kumar on 30/12/13.
//  Copyright (c) 2013 Arnav Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PebbleConnectionManager.h"

@interface ConnectionsManager : NSObject <PebbleResponderDelegate, UITextViewDelegate>

+ (ConnectionsManager *) sharedManager;
+ (void) setup;

- (NSString *) tweetTemplate;

@end
