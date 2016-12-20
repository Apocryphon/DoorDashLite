//
//  DDStoreTableViewCell.h
//  DoorDash Lite
//
//  Created by Richard Yeh on 12/17/16.
//  Copyright © 2016 Richard Yeh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDStoreTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cuisineLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryTimeLabel;

@end
