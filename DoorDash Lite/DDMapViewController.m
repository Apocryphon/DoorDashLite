//
//  DDMapViewController.m
//  DoorDash Lite
//
//  Created by Richard Yeh on 12/17/16.
//  Copyright © 2016 Richard Yeh. All rights reserved.
//

#import "DDMapViewController.h"
#import "DDStoresListViewController.h"

@interface DDMapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (assign, nonatomic) CLLocationCoordinate2D currentLocation;
@property (copy, nonatomic) NSString *currentAddress;

@end

#define METERS_PER_MILE 1609.344

@implementation DDMapViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // set map center to location selected previously
  if ([[NSUserDefaults standardUserDefaults] doubleForKey:@"LastLatitude"] && [[NSUserDefaults standardUserDefaults] doubleForKey:@"LastLongitude"]) {
    self.currentLocation = CLLocationCoordinate2DMake([[NSUserDefaults standardUserDefaults] doubleForKey:@"LastLatitude"],
                                                      [[NSUserDefaults standardUserDefaults] doubleForKey:@"LastLongitude"]);
  } else {
    self.currentLocation = CLLocationCoordinate2DMake(37.787072, -122.400451);
  }
  
  MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation, 2.0 * METERS_PER_MILE, 2.0 * METERS_PER_MILE);
  [self.mapView setRegion:viewRegion animated:YES];
  
  [self updateAddressWithCoordinate:self.currentLocation];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)updateAddressWithCoordinate:(CLLocationCoordinate2D)coord {

  __weak typeof(self) weakSelf = self;
  CLGeocoder *geocoder = [[CLGeocoder alloc] init];
  [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:coord.latitude
                                                              longitude:coord.longitude]
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                   if (error == nil && [placemarks count] > 0) {
                     CLPlacemark *placemark = [placemarks lastObject];
                     weakSelf.currentAddress = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
                     // update address text
                     dispatch_async(dispatch_get_main_queue(), ^{
                       weakSelf.addressLabel.text = weakSelf.currentAddress;
                     });
                   } else {
                     NSLog(@"%@", error.debugDescription);
                   }
                 }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"mapToTabBar"]) {
    
    // save confirmed location for persistence
    [[NSUserDefaults standardUserDefaults] setDouble:self.currentLocation.latitude forKey:@"LastLatitude"];
    [[NSUserDefaults standardUserDefaults] setDouble:self.currentLocation.longitude forKey:@"LastLongitude"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // send location to list view to load local stores
    UITabBarController *tabBarVC = (UITabBarController *)segue.destinationViewController;
    DDStoresListViewController *exploreVC = (DDStoresListViewController *)tabBarVC.viewControllers[0];
    exploreVC.listLocation = self.currentLocation;
  }
}

#pragma mark - MKMapView

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  self.currentLocation = self.mapView.centerCoordinate;
  [self updateAddressWithCoordinate:self.currentLocation];
}


@end
