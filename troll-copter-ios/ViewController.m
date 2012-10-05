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
    [serverWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.3   :3000"]]];
    
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
    isGoingUpHall = true;    
    //Setup gesture recognition
    
    UISwipeGestureRecognizer *oneFingerSwipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(takeOff)];
    [oneFingerSwipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:oneFingerSwipeUp];
    
    UISwipeGestureRecognizer *oneFingerSwipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(land)];
    [oneFingerSwipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:oneFingerSwipeDown];
    
    followTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(copterGoForward:) userInfo:self repeats:YES];
    


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

- (void)copterGoForward:(id)sender{
    if (isConnected) {
        [serverWebView stringByEvaluatingJavaScriptFromString:@"moveForward()"];
    }
}


#pragma mark - UIAccelerometer methods

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    if (acceleration.z < -1.9 && acceleration.x < -1 && acceleration.y > 1 && isFLipping==false) {
        NSLog(@"back Flipping!");
       // isFLipping = true;
        [serverWebView stringByEvaluatingJavaScriptFromString:@"doFlip();"];
    }
    
 /*   if (acceleration.z < - 0.9 && acceleration.x < - 0 && acceleration.y > 0 && acceleration.y < 0.8 && isFLipping==false ) {
        NSLog(@"side Flipping!");
      //  isFLipping = true;
        [serverWebView stringByEvaluatingJavaScriptFromString:@"doSideFlip();"];
    }*/
    
  // NSLog(@"x:%f y:%f z:%f", acceleration.x, acceleration.y,  acceleration.z );
}

#pragma mark - CLLocationManger Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
  if (isConnected) {
        //float oldRad =  manager.heading.trueHeading;
        float newRad =  newHeading.trueHeading;
       // NSLog(@"%f", newRad);


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
      //  [serverWebView stringByEvaluatingJavaScriptFromString:@"moveForward()"];
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
