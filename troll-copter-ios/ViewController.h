//
//  ViewController.h
//  troll-copter-ios
//
//  Created by James Whelton on 05/10/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <UIWebViewDelegate, CLLocationManagerDelegate, CLLocationManagerDelegate>{
    IBOutlet UIWebView *serverWebView;
    CLLocationManager *userLocationManger;
    BOOL isConnected;
}

@end
