//
//  MyTripsViewController.h
//  MyTrips
//
//  Created by Charles Konkol on 4/20/14.
//  Copyright (c) 2014 Rock Valley College. All rights reserved.
//
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface MyTripsViewController : UIViewController <MKMapViewDelegate>
- (IBAction)btnback:(id)sender;
- (IBAction)btnsave:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnsave;
@property (weak, nonatomic) IBOutlet UITextField *txtname;
@property (weak, nonatomic) IBOutlet UITextView *txtdesc;
@property (weak, nonatomic) IBOutlet UITextField *txtstart;
@property (weak, nonatomic) IBOutlet UITextField *txtend;

//hide keyboard
-(IBAction) doneEditing:(id) sender;

//coredata
@property (strong) NSManagedObject *tripsdb;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet MKMapView *mapview;


- (IBAction)btnroute:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtDistance;
@property (weak, nonatomic) IBOutlet UITextView *txtDir;


@property (strong) NSString *allSteps;



@end
