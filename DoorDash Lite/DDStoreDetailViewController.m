//
//  DDStoreDetailViewController.m
//  DoorDash Lite
//
//  Created by Richard Yeh on 12/27/16.
//  Copyright © 2016 Richard Yeh. All rights reserved.
//

#import "DDStoreDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface DDStoreDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *faveButton;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) NSDictionary *menuDictionary;
@end

@implementation DDStoreDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.navigationItem.title = self.storeDict[@"name"];
  self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
  
  NSURL *logoImgUrl         = [NSURL URLWithString:self.storeDict[@"cover_img_url"]];
  NSURLRequest *logoRequest = [NSURLRequest requestWithURL:logoImgUrl];
  
  __weak typeof(self) weakSelf = self;
  [self.logoImageView setImageWithURLRequest:logoRequest
                                placeholderImage:nil
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           weakSelf.logoImageView.image = image;
                                           [weakSelf.view setNeedsLayout];
                                         }
                                         failure:nil];

  self.statusLabel.text = [NSString stringWithFormat:@"Free delivery in %@ mins", self.storeDict[@"asap_time"]];

  NSString *rootURLString = @"https://api.doordash.com";
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  NSString *menuRequestString = [NSString stringWithFormat:@"%@/v2/restaurant/%@/menu/", rootURLString, (NSNumber *)self.storeDict[@"id"]];
  [manager GET:menuRequestString
    parameters:nil
      progress:nil
       success:^(NSURLSessionTask *task, id responseObject) {
         if ([responseObject count] > 0) {
           weakSelf.menuDictionary = responseObject[0];     // responseObject is __NSSingleObjectArrayI
           [weakSelf.menuTableView reloadData];
         }
       }    failure:^(NSURLSessionTask *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         UIAlertController *downloadErrorAlert = [UIAlertController alertControllerWithTitle:@"Download Error" message:@"Couldn't load menus" preferredStyle:UIAlertControllerStyleAlert];
         [downloadErrorAlert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
         }]];
       }];

}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[self.faveButton layer] setBorderWidth:2.0f];
  [[self.faveButton layer] setBorderColor:[UIColor colorWithRed:246.0/255 green:24.0/255 blue:69.0/255 alpha:1.0].CGColor];
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
  if ([self.menuDictionary[@"menu_categories"] count] > 0) {
    return [self.menuDictionary[@"menu_categories"] count];
  } else {
    return 0;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *menuCell = [tableView dequeueReusableCellWithIdentifier:@"DDMenuCell" forIndexPath:indexPath];
  
  NSDictionary *categoryDictionary = [self.menuDictionary[@"menu_categories"] objectAtIndex:indexPath.row];
  
  menuCell.textLabel.text = categoryDictionary[@"title"];
  
  return menuCell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return @"Menu";
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
