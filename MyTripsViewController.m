//
//  MyTripsViewController.m
//  MyTrips
//
//  Created by Charles Konkol on 4/20/14.
//  Copyright (c) 2014 Rock Valley College. All rights reserved.
//

#import "MyTripsViewController.h"


@interface MyTripsViewController ()


@end

@implementation MyTripsViewController
CLPlacemark *thePlacemarkStart;
CLPlacemark *thePlacemarkEnd;

MKPlacemark *startplacemark;
MKPlacemark *endplacemark;

MKRoute *routeDetails;



- (void)viewDidLoad
{
    
    [super viewDidLoad];
   

      // [self FinishAddress];

}
- (void) loadmap{
    [self clearroute];
    self.mapview.delegate = self;
    // Do any additional setup after loading the view.
    if (self.tripsdb) {
        [self.txtname setText:[self.tripsdb valueForKey:@"name"]];
        [self.txtdesc setText:[self.tripsdb valueForKey:@"desc"]];
        [self.txtstart setText:[self.tripsdb valueForKey:@"start"]];
        [self.txtend setText:[self.tripsdb valueForKey:@"finish"]];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [self startroute];
    [self endroute];
   
}
-(void)viewWillAppear:(BOOL)animated
{
    [self loadmap];
}
-(void)dismissKeyboard {
    // add textfields and textviews
    [self.txtname resignFirstResponder];
     [self.txtdesc resignFirstResponder];
     [self.txtstart resignFirstResponder];
     [self.txtend resignFirstResponder];
     [self.txtDir resignFirstResponder];
     [self.txtDistance resignFirstResponder];
}

- (void) startroute{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:self.txtstart.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            thePlacemarkStart = [placemarks lastObject];
            float spanX = 1.00725;
            float spanY = 1.00725;
            MKCoordinateRegion region;
            region.center.latitude = thePlacemarkStart.location.coordinate.latitude;
            region.center.longitude = thePlacemarkStart.location.coordinate.longitude;
            region.span = MKCoordinateSpanMake(spanX, spanY);
            [self.mapview setRegion:region animated:YES];
      
            [self addAnnotation:thePlacemarkStart];
           
        }
    }];
}
- (void) endroute{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:self.txtend.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            thePlacemarkEnd = [placemarks lastObject];
            float spanX = 1.00725;
            float spanY = 1.00725;
            MKCoordinateRegion region;
            region.center.latitude = thePlacemarkEnd.location.coordinate.latitude;
            region.center.longitude = thePlacemarkEnd.location.coordinate.longitude;
            region.span = MKCoordinateSpanMake(spanX, spanY);
            [self.mapview setRegion:region animated:YES];
            [self addAnnotation:thePlacemarkEnd];
           
        }
    }];
   
}
- (void)addAnnotation:(CLPlacemark *)placemark {
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
    point.title = [placemark.addressDictionary objectForKey:@"Street"];
    point.subtitle = [placemark.addressDictionary objectForKey:@"City"];
    [self.mapview addAnnotation:point];
}
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[self.mapview dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

- (void) createroutemap{
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    startplacemark = [[MKPlacemark alloc] initWithPlacemark:thePlacemarkStart];
     endplacemark = [[MKPlacemark alloc] initWithPlacemark:thePlacemarkEnd];
    [directionsRequest setSource:[[MKMapItem alloc] initWithPlacemark:startplacemark]];
    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:endplacemark]];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            routeDetails = response.routes.lastObject;
            [self.mapview addOverlay:routeDetails.polyline];
            //self.destinationLabel.text = [placemark.addressDictionary objectForKey:@"Street"];
           self.txtDistance.text = [NSString stringWithFormat:@"%0.1f Miles", routeDetails.distance/1609.344];
            //self.transportLabel.text = [NSString stringWithFormat:@"%u" ,routeDetails.transportType];
            self.allSteps = @"";
          for (int i = 0; i < routeDetails.steps.count; i++) {
                MKRouteStep *step = [routeDetails.steps objectAtIndex:i];
             NSString *newStep = step.instructions;
              self.allSteps = [self.allSteps stringByAppendingString:newStep];
              self.allSteps = [self.allSteps stringByAppendingString:@"\n\n"];
                self.txtDir.text = self.allSteps;
            }
        }
   }];
     
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:routeDetails.polyline];
    routeLineRenderer.strokeColor = [UIColor redColor];
    routeLineRenderer.lineWidth = 5;
    return routeLineRenderer;
}

//right-click drag textfield to fileowner select delegate
-(IBAction) doneEditing:(id) sender {
    [sender resignFirstResponder];
}
//If you need a scrollview do the following then #4
//1) Select all items on view (shift > select with mouse)
//2) Editor > Embed > Scrollview


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGPoint scrollPoint = CGPointMake(0, textField.frame.origin.y);
    [self.scrollview setContentOffset:scrollPoint animated:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.scrollview setContentOffset:CGPointZero animated:YES];
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGPoint scrollPoint = CGPointMake(0, textView.frame.origin.y);
    [self.scrollview setContentOffset:scrollPoint animated:YES];
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.scrollview setContentOffset:CGPointZero animated:YES];
}
- (NSManagedObjectContext *)managedObjectContext { NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext]; }
    return context;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation


*/

- (IBAction)btnback:(id)sender {
    [self clearroute];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) clearroute{
    self.txtDir.text = @"";
    self.txtDistance.text = @"";
    self.txtDir.text = @"turn by turn directions";
    [self.mapview removeOverlay:routeDetails.polyline];

}
- (IBAction)btnsave:(id)sender {
    NSManagedObjectContext *context = [self managedObjectContext];
    if (self.tripsdb) {
        // Update existing device
        [self.tripsdb setValue:self.txtname.text forKey:@"name"];
        [self.tripsdb setValue:self.txtdesc.text forKey:@"desc"];
        [self.tripsdb setValue:self.txtstart.text forKey:@"start"];
        [self.tripsdb setValue:self.txtend.text forKey:@"finish"];
    } else {
        // Create a new device
        NSManagedObject *newDevice = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"Trips" inManagedObjectContext:context];
        [newDevice setValue:self.txtname.text forKey:@"name"];
        [newDevice setValue:self.txtdesc.text forKey:@"desc"];
        [newDevice setValue:self.txtstart.text forKey:@"start"];
         [newDevice setValue:self.txtend.text forKey:@"finish"];
    }
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    [self clearroute];
[self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)btnroute:(id)sender {
   // [self startroute];
    [self createroutemap];

}
@end
