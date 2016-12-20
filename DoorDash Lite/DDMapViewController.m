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
- (IBAction)chooseAddress:(id)sender;

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
  
  CLLocationCoordinate2D startLocation;
  
  //TODO: set to previous location after persistence is implemented
  startLocation.latitude = 37.787072;
  startLocation.longitude = -122.400451;
  self.currentLocation = startLocation;
  
  MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(startLocation, 2.0 * METERS_PER_MILE, 2.0 * METERS_PER_MILE);
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
