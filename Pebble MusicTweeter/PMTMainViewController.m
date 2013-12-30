//
//  PMTMainViewController.m
//  Pebble MusicTweeter
//
//  Created by Arnav Kumar on 11/12/13.
//  Copyright (c) 2013 Arnav Kumar. All rights reserved.
//

#import "PMTMainViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <MediaPlayer/MediaPlayer.h>
#import <PebbleKit/PebbleKit.h>
#import "LastFMFetcher.h"

@interface PMTMainViewController ()

@property (nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) IBOutlet UIButton *TweetButton;

@end

@implementation PMTMainViewController

- (ACAccountStore *) accountStore {
    if (!_accountStore) _accountStore = [[ACAccountStore alloc] init];
    return _accountStore;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"View loaded");
    [[PebbleConnectionManager sharedManager] registerDelegate:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return self;
}

- (void) respondToMessage:(NSDictionary *)message
{
    //[self tweetCurrentTrack];
    NSLog(@"Tweeted");
    NSNumber *first = [[NSNumber alloc] initWithInt:1];
    NSDictionary * dict;
    if ([[message objectForKey:first] isEqualToNumber:[NSNumber numberWithInt:0]])
    {
        dict = @{ first     : @"Tweet?" };
        [[PebbleConnectionManager sharedManager] sendMessage:dict];
    }
    else if ([[message objectForKey:first] isEqualToNumber:[NSNumber numberWithInt:42]])
    {
        dict = @{ first     : @"Tweeted" };
        [[PebbleConnectionManager sharedManager] sendMessage:dict];
    }
    NSLog(@"%@", dict);

}

- (void) respondToMessage:(NSDictionary *)message fromWatch:(PBWatch *)watch
{
    
}
- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}
- (IBAction)buttonPressed:(id)sender {
//    [self fetchTimelineForUser:@"arnavkumar10"];
    [self tweetCurrentTrack];
}

- (NSString *) getTweetText
{
    MPMusicPlayerController *musicPlayer = [[MPMusicPlayerController alloc] init];
    MPMediaItem *currentItem = musicPlayer.nowPlayingItem;
    NSString *title  = [currentItem valueForProperty:MPMediaItemPropertyTitle];
    NSString *artist = [currentItem valueForProperty:MPMediaItemPropertyArtist];
    NSURL *url = [LastFMFetcher urlForTrack:title byArtist:artist];
    NSString *tweet = [NSString stringWithFormat:@"#NowPlaying \"%@\" by %@. #pebbleTweets %@", title, artist, [url absoluteString]];
    return tweet;
}

- (void)tweetCurrentTrack
{
    NSString *tweet = [self getTweetText];
    NSLog(@"%@", tweet);
    [self postStatus:tweet];
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
