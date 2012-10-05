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
    [serverWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.3:3000"]]];
    
    //Setup Location Manger
    userLocationManger = [[CLLocationManager alloc] init];
    userLocationManger.delegate = self;
    [userLocationManger setDesiredAccuracy:kCLLocationAccuracyBest];
    [userLocationManger startUpdatingHeading];
    //[userLocationManger startUpdatingLocation];
    
    //Setup Accelerometer
    accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.updateInterval = .1;
    accelerometer.delegate = self;
    
    //Setup state
    isFlying = false;
    isConnected = false;
    isFLipping = false;
    isMoving = false;
    isGoingUpHall = true; // A weird way of saying 'going forward or backward in a straight line' :P
    
    //Setup gesture recognition
    
    UITapGestureRecognizer *oneFingerTwoTaps = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takeOffOrLand)];
    [oneFingerTwoTaps setNumberOfTapsRequired:2];
    [oneFingerTwoTaps setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:oneFingerTwoTaps];
    
    UISwipeGestureRecognizer *oneFingerSwipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveBackward)];
    [oneFingerSwipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:oneFingerSwipeUp];
    
    UISwipeGestureRecognizer *oneFingerSwipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveBackward)];
    [oneFingerSwipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:oneFingerSwipeDown];

}

#pragma mark - UISwipeGestureRecognizer

- (void)takeOffOrLand {
    NSLog(@"herderp");
    if (isFlying) {
        [serverWebView stringByEvaluatingJavaScriptFromString:@"land();"];
    } else {
        [serverWebView stringByEvaluatingJavaScriptFromString:@"takeOff();"];
    }
}

- (void)moveForward {
    NSLog(@"Moving forward..");
   [serverWebView stringByEvaluatingJavaScriptFromString:@"moveForward();"]; 
}

- (void)moveBackward {
    NSLog(@"Moving backward..");
    [serverWebView stringByEvaluatingJavaScriptFromString:@"moveBackward();"];
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
        float newRad =  newHeading.trueHeading;
        NSLog(@"%f", newRad);


    if (newRad < 319 && newRad >= 125) {
        //follow up the room
        if (isGoingUpHall == false) {
            NSLog(@"turning 180");
            [serverWebView stringByEvaluatingJavaScriptFromString:@"turn180()"];
        }
        isMoving = true;
        isGoingUpHall = true;
        //[serverWebView stringByEvaluatingJavaScriptFromString:@"moveForward()"];
        
    } else if (newRad > 0 && newRad <= 125) {
        //go back down
        if (isGoingUpHall == true) {
            NSLog(@"turning 180");
            [serverWebView stringByEvaluatingJavaScriptFromString:@"turn180()"];
        }
        isMoving = true;
        isGoingUpHall = false;
        //[serverWebView stringByEvaluatingJavaScriptFromString:@"moveForward()"];
    }
   } 
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    //if (isConnected) {
        NSLog(@"lat: %f lng: %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    //}
}

#pragma mark - WebView Methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *theAnchor = [[[request URL] fragment] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //Handle change of copter state
    if([theAnchor hasPrefix:@"connected"]){
        isConnected = true;
        NSLog(@"Now connected, waiting for gesture...");
    } else if ([theAnchor hasPrefix:@"isFlying"]) {
        isFlying = true;
    } else if ([theAnchor hasPrefix:@"hasLanded"]) {
        isFlying = false;
    } else if ([theAnchor hasPrefix:@"doneflip"]) {
        isFLipping = false; 
    } 
    
    return YES;
}

@end
