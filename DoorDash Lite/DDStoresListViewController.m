//
//  DDStoresListViewController.m
//  DoorDash Lite
//
//  Created by Richard Yeh on 12/17/16.
//  Copyright © 2016 Richard Yeh. All rights reserved.
//

#import "DDStoresListViewController.h"
#import "DDStoreTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "DDStoreDetailViewController.h"

#import "AFNetworking.h"

@interface DDStoresListViewController ()
@property (nonatomic, strong) NSArray *storesListArray;
@property (nonatomic, strong) NSDictionary *chosenStoreDict;
@end

@implementation DDStoresListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
  self.navigationController.navigationBar.translucent = NO;
  self.tabBarController.tabBar.translucent = NO;
  
  if (self.tabBarController.selectedIndex == 0) {
    [self fetchFavorites];
  } else {
    [self fetchLocalStores];
  }
  
}

- (void)fetchLocalStores {

  self.navigationItem.title = @"DoorDash";
  
  NSString *rootURLString = @"https://api.doordash.com";
  
  __weak UINavigationController *weakNavController = self.navigationController;
  __weak typeof(self) weakSelf = self;
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  NSString *requestString = [NSString stringWithFormat:@"%@/v1/store_search/?lat=%f&lng=%f", rootURLString, self.listLocation.latitude, self.listLocation.longitude];
  [manager GET:requestString
    parameters:nil
      progress:nil
       success:^(NSURLSessionTask *task, id responseObject) {
         if ([responseObject count] > 0) {
           weakSelf.storesListArray = responseObject;       // this is the data source for Explore
           [weakSelf.tableView reloadData];
         }
  }    failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        UIAlertController *downloadErrorAlert = [UIAlertController alertControllerWithTitle:@"Download Error" message:@"Please try again" preferredStyle:UIAlertControllerStyleAlert];
        [downloadErrorAlert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakNavController popViewControllerAnimated:YES];
    }]];
  }];
}

- (void)fetchFavorites {
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSDictionary *favesDictionary = (NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:[prefs dataForKey:@"FavoriteStores"]];
  
  self.storesListArray = [favesDictionary allValues];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if ([self.storesListArray count] > 0) {
    return [self.storesListArray count];
  } else {
    return 0;
  }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  DDStoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDStoreCell" forIndexPath:indexPath];
    
  // Configure the cell...
  NSDictionary *storeDict = self.storesListArray[indexPath.row];
  cell.nameLabel.text         = storeDict[@"name"];
  cell.cuisineLabel.text      = storeDict[@"description"];
  cell.deliveryTimeLabel.text = storeDict[@"status"];
  
  NSNumber *deliveryCost      = [NSNumber numberWithDouble:([(NSNumber *)storeDict[@"delivery_fee"] longValue] * 0.01)];
  NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
  [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  cell.priceLabel.text        = [NSString stringWithFormat:@"%@ delivery", [priceFormatter stringFromNumber:deliveryCost]];
  
  NSURL *logoImgUrl           = [NSURL URLWithString:storeDict[@"cover_img_url"]];
  NSURLRequest *logoRequest   = [NSURLRequest requestWithURL:logoImgUrl];
  
  __weak DDStoreTableViewCell *weakCell = cell;
  [weakCell.logoImageView setImageWithURLRequest:logoRequest
                            placeholderImage:nil
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       weakCell.logoImageView.image = image;
                                       [weakCell setNeedsLayout];
                                     }
                                     failure:nil];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  self.chosenStoreDict = self.storesListArray[indexPath.row];
  [self performSegueWithIdentifier:@"exploreToStoreDetail" sender:self];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
  DDStoreDetailViewController *storeDetailVC = segue.destinationViewController;
  storeDetailVC.storeDict = self.chosenStoreDict;

}


@end
