//
//  DDStoresListViewController.h
//  DoorDash Lite
//
//  Created by Richard Yeh on 12/17/16.
//  Copyright © 2016 Richard Yeh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DDStoresListViewController : UITableViewController
@property (assign, nonatomic) CLLocationCoordinate2D listLocation;
@end
