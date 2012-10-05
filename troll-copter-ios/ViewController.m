//
//  ViewController.m
//  troll-copter-ios
//
//  Created by James Whelton on 05/10/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Setup Webview
    serverWebView.delegate = self;
    [serverWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.5:3000"]]];
    
    //Setup Location Manger
    userLocationManger = [[CLLocationManager alloc] init];
    [userLocationManger startUpdatingHeading];
    
    isConnected = false;
    
    //Setup gesture recognition
    
    UISwipeGestureRecognizer *oneFingerSwipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(takeOff)];
    [oneFingerSwipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [serverWebView addGestureRecognizer:oneFingerSwipeUp];
    
    UISwipeGestureRecognizer *oneFingerSwipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(land)];
    [oneFingerSwipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [serverWebView addGestureRecognizer:oneFingerSwipeDown];

}

- (void)takeOff {
    [serverWebView stringByEvaluatingJavaScriptFromString:@"takeOff();"];
}

- (void)land {
    [serverWebView stringByEvaluatingJavaScriptFromString:@"land();"];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - CLLocationManger Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    //Something
    if (isConnected) {
        
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *theAnchor = [[[request URL] fragment] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([theAnchor hasPrefix:@"connected"]){
        NSLog(@"now connected, make flight");
        [webView stringByEvaluatingJavaScriptFromString:@"makeFlight()"];
    }
    
    return YES;
}

@end
