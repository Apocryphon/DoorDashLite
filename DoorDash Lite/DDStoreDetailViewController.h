//
//  DDStoreDetailViewController.h
//  DoorDash Lite
//
//  Created by Richard Yeh on 12/27/16.
//  Copyright © 2016 Richard Yeh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDStoreDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSDictionary *storeDict;
@end
