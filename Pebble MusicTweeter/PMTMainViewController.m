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
#import "MBProgressHUD.h"

@interface PMTMainViewController () <UIDocumentInteractionControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITextView *tweetTemplateField;
@property (strong, nonatomic) IBOutlet UILabel *connectionLabel;
@property (strong, nonatomic) IBOutlet UIButton *downloadWatchappButton;
@property (strong, nonatomic) IBOutlet UIButton *twitterConnectionButton;
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
    
//    BOOL shouldDisplayTwitterAccessButton = [[NSUserDefaults standardUserDefaults] boolForKey:NSUDTwitterAccessKey];
//    if (shouldDisplayTwitterAccessButton)
//    {
//        [self connectedToTwitterWithUsername:NSUDSavedUsername];
//    }
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
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                                   [UIColor whiteColor], NSForegroundColorAttributeName,
//                                                                   nil];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"VERDANA" size:18], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    RFToolbarButton *button1 = [[RFToolbarButton alloc] initWithTitle:@"Title" andText:@" <title> "];
    RFToolbarButton *button2 = [[RFToolbarButton alloc] initWithTitle:@"Artist" andText:@" <artist> "];
    RFToolbarButton *button3 = [[RFToolbarButton alloc] initWithTitle:@"Link" andText:@" <link> "];

    [RFKeyboardToolbar addToTextView:self.tweetTemplateField withButtons:@[button1, button2, button3]];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:NSUDTwitterAccessKey])
    {
        [self connectedToTwitterWithUsername:NSUDSavedUsername];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[ConnectionsManager sharedManager] enableTwitterForUsername:NSUDSavedUsername];
            
        });
    }
    
}


#pragma mark PebbleInformationDisplayDelegate
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

- (void) presentTwitterUsernames:(NSArray *)usernames
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIActionSheet *twitterAccountsActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an account:"
                                                                            delegate:self
                                                                cancelButtonTitle:nil
                                                              destructiveButtonTitle:nil
                                                                   otherButtonTitles:nil];
    for (NSString *username in usernames)
    {
        [twitterAccountsActionSheet addButtonWithTitle:username];
    }
    [twitterAccountsActionSheet addButtonWithTitle:@"Cancel"];
    [twitterAccountsActionSheet setCancelButtonIndex:[twitterAccountsActionSheet numberOfButtons] - 1];
    [twitterAccountsActionSheet showInView:self.view];
}

#pragma mark UIMethods
     
- (IBAction)downloadWatchappButtonPressed:(id)sender {
    NSURL *pbwURL = [[NSBundle mainBundle] URLForResource: @"Tweeter" withExtension:@"pbw"];
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
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"App Store"])
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/pebble-smartwatch/id592012721?mt=8"]];
    }
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if (![buttonTitle isEqualToString:@"Cancel"])
        {
            [[ConnectionsManager sharedManager] enableTwitterForUsername:buttonTitle];
        }
        
    });
    
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

#pragma mark - Twitter Login code
- (IBAction)twitterConnectionButtonPressed:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.twitterConnectionButton setTitle:@"Authenticating ..." forState:UIControlStateDisabled];
        [[ConnectionsManager sharedManager] enableTwitter];
        //self.twitterConnectionButton.titleLabel.text = @"Authenticating...";
        self.twitterConnectionButton.enabled = NO;
        
    });
}

//- (void) connectedToTwitter
//{
//    [self.twitterConnectionButton setTitle:[@"Connected to Twitter as "stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:NSUDTwitterChosenAccountUsernameKey]] forState:UIControlStateDisabled];
//    self.twitterConnectionButton.enabled = NO;
//    [self.view setNeedsDisplay];
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//}
- (void) connectedToTwitterWithUsername:(NSString *) username
{
    if (username)
    {
        [self.twitterConnectionButton setTitle:[@"Connected as " stringByAppendingString:username] forState:UIControlStateDisabled];
        self.twitterConnectionButton.enabled = NO;
        [self.view setNeedsDisplay];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    else
    {
        [self.twitterConnectionButton setTitle:@"Connect to Twitter" forState:UIControlStateNormal];
        self.twitterConnectionButton.enabled = YES;
        [self.view setNeedsDisplay];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"You are either not logged into any Twitter accounts, or not logged into the account you used previously. Please check settings to verify."
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
        [errorAlert show];
    }
}

@end
