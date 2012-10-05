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
    
    //Setup Webview
    serverWebView.delegate = self;
    [serverWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.4:3000"]]];
    
    //Setup Location Manger
    userLocationManger = [[CLLocationManager alloc] init];
    userLocationManger.delegate = self;
    //[userLocationManger startUpdatingHeading];
    
    //Setup Accelerometer
    accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.updateInterval = .1;
    accelerometer.delegate = self;
    
    //Setup state
    isFlying = false;
    isConnected = false;
    isFLipping = false;
    
    //Setup gesture recognition
    
    UISwipeGestureRecognizer *oneFingerSwipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(takeOff)];
    [oneFingerSwipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:oneFingerSwipeUp];
    
    UISwipeGestureRecognizer *oneFingerSwipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(land)];
    [oneFingerSwipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:oneFingerSwipeDown];

}

#pragma mark - UISwipeGestureRecognizer

- (void)takeOff {
    NSLog(@"Taking off");
    [serverWebView stringByEvaluatingJavaScriptFromString:@"takeOff();"];
}

- (void)land {
    NSLog(@"Landing");
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


#pragma mark - UIAccelerometer methods

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    if (acceleration.z < -2 && isFLipping==false && isConnected == true) {
        NSLog(@"Flipping!");
        isFLipping = true;
        [serverWebView stringByEvaluatingJavaScriptFromString:@"doFlip();"];
    }
}

#pragma mark - CLLocationManger Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    if (isConnected) {
        //float oldRad =  manager.heading.trueHeading;
        //float newRad =  newHeading.trueHeading;

     }
}

#pragma mark - WebView Methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *theAnchor = [[[request URL] fragment] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([theAnchor hasPrefix:@"connected"]){
        isConnected = true;
        NSLog(@"Now connected, waiting for gesture...");
    } else if ([theAnchor hasPrefix:@"isFlying"]) {
        isFlying = true;
    } else if ([theAnchor hasPrefix:@"doneflip"]){
        isFLipping = false; 
    }
    
    return YES;
}

@end
