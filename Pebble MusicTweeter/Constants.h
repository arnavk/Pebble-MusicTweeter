//
//  Constants.h
//  Pebble MusicTweeter
//
//  Created by Arnav Kumar on 12/12/13.
//  Copyright (c) 2013 Arnav Kumar. All rights reserved.
//

#ifndef Pebble_MusicTweeter_Constants_h
#define Pebble_MusicTweeter_Constants_h

#define LastFMKey @"1808fdf8f08dc463dd748e97c9eb2f19"
#define NSUDTemplateTweetKey @"PMT_TEMPALTE_TWEET"
#define NSUDTwitterAccessKey @"PMT_TWITTER_ACCESS"
#define NSUDTwitterChosenAccountIndexKey @"PMT_CHOSEN_ACCCOUNT_INDEX"
#define NSUDTwitterChosenAccountUsernameKey @"PMT_CHOSEN_ACCOUNT_USERNAME"
#define NSUDSavedUsername [[NSUserDefaults standardUserDefaults] stringForKey:NSUDTwitterChosenAccountUsernameKey]

#define PebbleMessageRequestIDKey [NSNumber numberWithInt:0]
#define PebbleMessageStatusKey [NSNumber numberWithInt:1]
#define PebbleMessageIntKey [NSNumber numberWithInt:2]
#define PebbleMessageStringKey [NSNumber numberWithInt:3]
#define PebbleMessageTrackInformationKey [NSNumber numberWithInt:4]
#define PebbleMessageTweetedKey [NSNumber numberWithInt:5]
#define PebbleMessageTrackTitleKey [NSNumber numberWithInt:6]
#define PebbleMessageTrackArtistKey [NSNumber numberWithInt:7]

#define PebbleRequestIDStatus [NSNumber numberWithInt:0]
#define PebbleRequestIDTrackInfo [NSNumber numberWithInt:1]
#define PebbleRequestIDTweet [NSNumber numberWithInt:2]
#define PebbleRequestIDTrackTitle [NSNumber numberWithInt:3]
#define PebbleRequestIDTrackArtist [NSNumber numberWithInt:4]
#define PebbleRequestError [NSNumber numberWithInt:4]


#endif
