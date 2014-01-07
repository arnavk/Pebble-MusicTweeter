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

@interface PMTMainViewController () <UIDocumentInteractionControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *tweetTemplateField;
@property (strong, nonatomic) IBOutlet UILabel *connectionLabel;
@property (strong, nonatomic) IBOutlet UIButton *downloadWatchappButton;
@property (strong, nonatomic) UIDocumentInteractionController *documentController;

@end

@implementation PMTMainViewController

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:188/255.0 green:34/255.0 blue:5/255.0 alpha:1.0]];

    [ConnectionsManager setup];
    [[ConnectionsManager sharedManager] registerDelegate:self];
    [self connectedToWatch:[[ConnectionsManager sharedManager] connectedWatch]];
    
    [self.tweetTemplateField setDelegate:[ConnectionsManager sharedManager]];
    self.tweetTemplateField.text = [[ConnectionsManager sharedManager] tweetTemplate];
    [self decorateTextView];
    
}

- (void) decorateTextView
{

    self.tweetTemplateField.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"View loaded");
    RFToolbarButton *button1 = [[RFToolbarButton alloc] initWithTitle:@"Title" andText:@" <title> "];
    RFToolbarButton *button2 = [[RFToolbarButton alloc] initWithTitle:@"Artist" andText:@" <artist> "];
    RFToolbarButton *button3 = [[RFToolbarButton alloc] initWithTitle:@"Link" andText:@" <link> "];
    

    [RFKeyboardToolbar addToTextView:self.tweetTemplateField withButtons:@[button1, button2, button3]];
}

- (void) connectedToWatch:(PBWatch *)watch
{
    if (!watch)
        self.connectionLabel.text = [NSString stringWithFormat:@"No watch connected."];
    else
        self.connectionLabel.text = [NSString stringWithFormat:@"Connected to %@", [watch name]];
}

- (void) disconnectedFromWatch:(PBWatch *)watch
{
    self.connectionLabel.text = [NSString stringWithFormat:@"No watch connected."];
}
     
- (IBAction)downloadWatchappButtonPressed:(id)sender {
    NSURL *pbwURL = [[NSBundle mainBundle] URLForResource: @"Tweeter" withExtension:@"xyz"];
    BOOL isMobileAppInstalled = [[UIApplication sharedApplication] canOpenURL:pbwURL];

//    if ([[PBPebbleCentral defaultCentral] isMobileAppInstalled])
    if (isMobileAppInstalled)
    {
//        [[UIApplication sharedApplication] openURL:pbwURL];
        self.documentController = [UIDocumentInteractionController interactionControllerWithURL:pbwURL];
        self.documentController.delegate = self;
        [self.documentController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    }
    else
    {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"No Pebble App :("
                                                             message:@"The Pebble App was not found on your phone. Please download it from the App Store"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"App Store", nil];
        [errorAlert show];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/pebble-smartwatch/id592012721?mt=8"]];
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate

//===================================================================
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return self.view.frame;
}


@end
