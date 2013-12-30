//
//  LastFMFetcher.h
//  Pebble MusicTweeter
//
//  Created by Arnav Kumar on 12/12/13.
//  Copyright (c) 2013 Arnav Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LastFMFetcher : NSObject

+ (NSURL *)urlForTrack:(NSString *)title byArtist:(NSString *)artist;

@end
