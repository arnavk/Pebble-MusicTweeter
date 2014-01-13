//
//  LastFMFetcher.m
//  Pebble MusicTweeter
//
//  Created by Arnav Kumar on 12/12/13.
//  Copyright (c) 2013 Arnav Kumar. All rights reserved.
//

#import "LastFMFetcher.h"

@implementation LastFMFetcher

+ (NSDictionary *)executeLastFMFetch:(NSString *)query
{
    query = [NSString stringWithFormat:@"%@&api_key=%@&format=json", query, LastFMKey];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"[%@ %@] sent %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), query);
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    NSLog(@"[%@ %@] received %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), results);
    return results;
}

+ (NSDictionary *)infoForTrack:(NSString *)title byArtist:(NSString *)artist
{
    NSString *request = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=track.search&limit=1&artist=%@&track=%@", artist, title];
    return [self executeLastFMFetch:request];
}

+ (NSDictionary *)infoForTrack:(NSString *)title
{
    NSString *request = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=track.search&limit=1&track=%@", title];
    return [self executeLastFMFetch:request];
}

+ (NSURL *)urlForTrack:(NSString *)title byArtist:(NSString *)artist
{
    NSDictionary *trackInfo = [self infoForTrack:title byArtist:artist];
    if ([trackInfo[@"results"][@"opensearch:totalResults"] isEqualToString:@"0"]) {
//        NSLog(@"track matches - %@", trackInfo[@"results"][@"trackmatches"]);
        return nil;
    }
    NSURL *url = [NSURL URLWithString:trackInfo[@"results"][@"trackmatches"][@"track"][@"url"]];
    return url;
}

//http://ws.audioscrobbler.com/2.0/?method=track.search&limit=1&artist=oasis&track=wonderwall&api_key=1808fdf8f08dc463dd748e97c9eb2f19&format=json

@end
