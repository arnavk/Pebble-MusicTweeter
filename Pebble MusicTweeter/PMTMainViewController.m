//
//  PMTMainViewController.m
//  Pebble MusicTweeter
//
//  Created by Arnav Kumar on 11/12/13.
//  Copyright (c) 2013 Arnav Kumar. All rights reserved.
//

#import "PMTMainViewController.h"
#import "RFKeyboardToolbar.h"
#import <QuartzCore/QuartzCore.h>

@interface PMTMainViewController ()

@property (strong, nonatomic) IBOutlet UITextView *tweetTemplateField;


@end

@implementation PMTMainViewController

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBarTintColor:[UIColor orangeColor]];
    [ConnectionsManager setup];
    [self.tweetTemplateField setDelegate:[ConnectionsManager sharedManager]];
    self.tweetTemplateField.text = [[ConnectionsManager sharedManager] tweetTemplate];
    [self decorateTextView];
}

- (void) decorateTextView
{
//    [self.tweetTemplateField.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
//    [self.tweetTemplateField.layer setBorderColor: [[UIColor grayColor] CGColor]];
//    [self.tweetTemplateField.layer setBorderWidth: 1.0];
//    [self.tweetTemplateField.layer setCornerRadius:8.0f];
//    [self.tweetTemplateField.layer setMasksToBounds:YES];
    self.tweetTemplateField.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"View loaded");
    RFToolbarButton *button1 = [[RFToolbarButton alloc] initWithTitle:@"Title" andText:@" <track> "];
    RFToolbarButton *button2 = [[RFToolbarButton alloc] initWithTitle:@"Artist" andText:@" <artist> "];
    RFToolbarButton *button3 = [[RFToolbarButton alloc] initWithTitle:@"Link" andText:@" <link> "];
    

    [RFKeyboardToolbar addToTextView:self.tweetTemplateField withButtons:@[button1, button2, button3]];
}



@end
