//
//  PebbleResponder.m
//  Pebble MusicTweeter
//
//  Created by Arnav Kumar on 30/12/13.
//  Copyright (c) 2013 Arnav Kumar. All rights reserved.
//

#import "ConnectionsManager.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <MediaPlayer/MediaPlayer.h>
#import <PebbleKit/PebbleKit.h>
#import "LastFMFetcher.h"

@interface ConnectionsManager ()

@property (nonatomic) ACAccountStore *accountStore;
@property (nonatomic, strong) NSString *tweetTemplate;
@property (nonatomic, strong) MPMediaItem *currentTrack;
@end

@implementation ConnectionsManager

+ (ConnectionsManager *)sharedManager {
    static ConnectionsManager *sharedManager = nil;
    @synchronized(self) {
        if (sharedManager == nil)
        {
            sharedManager = [[self alloc] init];
            sharedManager.tweetTemplate = [sharedManager tweetTemplate];
        }
    }
    return sharedManager;
}

+ (void) setup {
    [[PebbleConnectionManager sharedManager] registerDelegate:[self sharedManager]];
}

- (NSString *) tweetTemplate
{
    NSString * template = [[NSUserDefaults standardUserDefaults] stringForKey:NSUDTemplateTweetKey];
    if (!template)
        template = @"#NowPlaying <track> by <artist>. #pebbleTweets <link>";
    return template;
}

#pragma mark PebbleResponderDelegate methods

//[NSString stringWithFormat:@"\"%@\" by %@", [currentTrack valueForProperty:MPMediaItemPropertyTitle], [currentTrack valueForProperty:MPMediaItemPropertyAlbumArtist]]
- (void) respondToMessage:(NSDictionary *)message
{
    NSNumber *first = [NSNumber numberWithInt:1];
    NSDictionary * dict;
    if ([[message objectForKey:first] isEqualToNumber:PebbleRequestIDStatus])
    {
        self.currentTrack = [self getCurrentTrack];
        NSString *trackArtist = [self.currentTrack valueForProperty:MPMediaItemPropertyArtist];
        if ([trackArtist length] > 32)
            trackArtist = [[trackArtist substringToIndex:27] stringByAppendingString:@"..."];

        NSString *trackTitle = [self.currentTrack valueForProperty:MPMediaItemPropertyTitle];
        if ([trackTitle length] > 30)
            trackTitle = [[trackTitle substringToIndex:27] stringByAppendingString:@"..."];
        trackTitle = [@"\"" stringByAppendingString:[trackTitle stringByAppendingString:@"\""]];
        
        if (self.currentTrack)
        {
            
            dict = @{   PebbleMessageRequestIDKey   : PebbleRequestIDStatus,
                        PebbleMessageStatusKey      : [NSNumber numberWithInt:1],
                        PebbleMessageStringKey      : @"Getting track information...",
                        PebbleMessageTrackTitleKey  : trackTitle,
                        PebbleMessageTrackArtistKey : trackArtist
                        };
            
            [[PebbleConnectionManager sharedManager] sendMessage:dict];
        }
        else
        {
            dict = @{ PebbleMessageRequestIDKey     : PebbleRequestIDStatus,
                      PebbleMessageStatusKey        : [NSNumber numberWithInt:0],
                      PebbleMessageStringKey        : @"Nothing playing"
                    };
            [[PebbleConnectionManager sharedManager] sendMessage:dict];
        }
    }
    else if ([[message objectForKey:first] isEqualToNumber:PebbleMessageTrackArtistKey])
    {
        NSString *trackArtist = [self.currentTrack valueForProperty:MPMediaItemPropertyArtist];
        if ([trackArtist length] > 32)
            trackArtist = [[trackArtist substringToIndex:27] stringByAppendingString:@"..."];
        
        dict = @{   PebbleMessageRequestIDKey   : PebbleRequestIDStatus,
                    PebbleMessageStatusKey      : [NSNumber numberWithInt:1],
                    PebbleMessageTrackArtistKey : trackArtist
                    };
        [[PebbleConnectionManager sharedManager] sendMessage:dict];
    }
    else if ([[message objectForKey:first] isEqualToNumber:PebbleMessageTrackTitleKey])
    {
        NSString *trackTitle = [self.currentTrack valueForProperty:MPMediaItemPropertyTitle];
        if ([trackTitle length] > 30)
            trackTitle = [[trackTitle substringToIndex:27] stringByAppendingString:@"..."];
        trackTitle = [@"\"" stringByAppendingString:[trackTitle stringByAppendingString:@"\""]];

        dict = @{   PebbleMessageRequestIDKey   : PebbleRequestIDStatus,
                    PebbleMessageStatusKey      : [NSNumber numberWithInt:1],
                    PebbleMessageTrackTitleKey : trackTitle,
                    };
        [[PebbleConnectionManager sharedManager] sendMessage:dict];
        
    }
    else if ([[message objectForKey:first] isEqualToNumber:PebbleRequestIDTweet])
    {
        dict = @{PebbleMessageRequestIDKey   : PebbleRequestIDTweet,
                 PebbleMessageTweetedKey     : @"Tweeted" };
        [self tweetCurrentTrack];
        [[PebbleConnectionManager sharedManager] sendMessage:dict];
    }
    NSLog(@"%@", dict);
}

- (void) respondToMessage:(NSDictionary *)message fromWatch:(PBWatch *)watch
{
    //TODO
}

#pragma mark UITextViewDelegate methods

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"Edited");
    self.tweetTemplate = textView.text;
    [[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:NSUDTemplateTweetKey];
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:NSUDTemplateTweetKey]);
}

#pragma mark Other class methods

- (ACAccountStore *) accountStore {
    if (!_accountStore) _accountStore = [[ACAccountStore alloc] init];
    return _accountStore;
}

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

- (MPMediaItem *)getCurrentTrack {
    MPMusicPlayerController *musicPlayer = [[MPMusicPlayerController alloc] init];
    MPMediaItem *currentItem = musicPlayer.nowPlayingItem;
    return currentItem;
}

- (NSString *)stripDoubleSpaceFrom:(NSString *)string {
    while ([string rangeOfString:@"  "].location != NSNotFound) {
        string = [string stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    return string;
}

- (NSString *) getTweetText
{
    MPMediaItem *currentItem = [self getCurrentTrack];
    NSString *title  = [currentItem valueForProperty:MPMediaItemPropertyTitle];
    NSString *artist = [currentItem valueForProperty:MPMediaItemPropertyArtist];
    NSURL *url = [LastFMFetcher urlForTrack:title byArtist:artist];
    NSString *tweet = self.tweetTemplate;//[NSString stringWithFormat:@"#NowPlaying \"%@\" by %@. #pebbleTweets %@", title, artist, [url absoluteString]];
    tweet = [tweet stringByReplacingOccurrencesOfString:@"<artist>" withString:artist];
    tweet = [tweet stringByReplacingOccurrencesOfString:@"<link>" withString:[url absoluteString]];
    tweet = [tweet stringByReplacingOccurrencesOfString:@"<track>" withString:[NSString stringWithFormat:@"\"%@\"", title]];
    tweet = [self stripDoubleSpaceFrom:tweet];
    return tweet;
}

- (void)tweetCurrentTrack
{
    NSString *tweet = [self getTweetText];
    NSLog(@"%@", tweet);
//    [self postStatus:tweet];
}

- (void) postStatus:(NSString *) status
{
    ACAccountType *twitterType =
    [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    SLRequestHandler requestHandler =
    ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *postResponseData =
                [NSJSONSerialization JSONObjectWithData:responseData
                                                options:NSJSONReadingMutableContainers
                                                  error:NULL];
                NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
            }
            else {
                NSLog(@"[ERROR] Server responded: status code %lD %@", (long)statusCode,
                      [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
            }
        }
        else {
            NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
        }
    };
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler =
    ^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [self.accountStore accountsWithAccountType:twitterType];
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                          @"/1.1/statuses/update.json"];
            NSDictionary *params = @{@"status" : status};
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodPOST
                                                              URL:url
                                                       parameters:params];
            [request setAccount:[accounts lastObject]];
            [request performRequestWithHandler:requestHandler];
        }
        else {
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
                  [error localizedDescription]);
        }
    };
    
    [self.accountStore requestAccessToAccountsWithType:twitterType
                                               options:NULL
                                            completion:accountStoreHandler];
}

@end
