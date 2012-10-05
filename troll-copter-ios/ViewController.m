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
    [serverWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.2:3000"]]];
    
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
    

    isConnected = false;
    isFLipping = false;
    isMoving = false;
    isGoingUpHall = true;

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
        NSLog(@"flip");
        isFLipping = true;
        [serverWebView stringByEvaluatingJavaScriptFromString:@"doFlip()"];
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
    
    if([theAnchor hasPrefix:@"connected"]){
        isConnected = true;
        NSLog(@"now connected, make flight");
        [webView stringByEvaluatingJavaScriptFromString:@"makeFlight()"];
    } else if ([theAnchor hasPrefix:@"doneflip"]){
        isFLipping = false; 
    } 
    
    return YES;
}

@end
