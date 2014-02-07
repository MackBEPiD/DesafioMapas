//
//  MackViewController.m
//  DesafioMapas
//
//  Created by Lucas Saito on 05/02/14.
//  Copyright (c) 2014 Mack Mobile - BEPiD. All rights reserved.
//

#import "MackViewController.h"

@interface MackViewController ()

@end

@implementation MackViewController

- (void)viewDidLoad
{
    locationManager = [[CLLocationManager alloc]init];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDelegate:self];
    [locationManager startUpdatingLocation];
    [_indicador startAnimating];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Métodos do locationManager

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    CLLocationCoordinate2D loc = [newLocation coordinate];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
    
    [_worldMap setRegion:region animated:YES];
    [_worldMap setShowsUserLocation:YES];
    [_indicador stopAnimating];
    _indicador.hidden = TRUE;
    [locationManager stopUpdatingLocation];
    MKPointAnnotation *pm = [[MKPointAnnotation alloc]init];
    [pm setCoordinate : loc];
    [_indicador stopAnimating];
    _indicador.hidden = TRUE;
    //ponto de marcaçao
    [_worldMap addAnnotation:pm];
}
- (IBAction)Seg:(id)sender {
    //SegmentControl switch para selecao dos tipos
    switch (((UISegmentedControl *) sender).selectedSegmentIndex) {
        case 0:
            [self viewDidDisappear:nil];
            [_worldMap setMapType:MKMapTypeStandard];
            
            break;
            
        case 1:
            [self viewDidDisappear:nil];
            [_worldMap setMapType:MKMapTypeSatellite];
            break;
            
        case 2:
            [self viewDidDisappear:nil];
            [_worldMap setMapType:MKMapTypeHybrid];
            break;
            
    }
    
}
- (IBAction)search:(id)sender { //botao de busca
    
    [_textField resignFirstResponder];//esconder a caixa de texto
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:_textField.text completionHandler:^(NSArray *placemarks, NSError *error) {
        //Error checking
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        MKCoordinateRegion region;
        region.center.latitude = placemark.region.center.latitude;
        region.center.longitude = placemark.region.center.longitude;
        MKCoordinateSpan span;
        double radius = placemark.region.radius / 1000; // convert to km
        
        NSLog(@"[searchBarSearchButtonClicked] Radius is %f", radius);
        span.latitudeDelta = radius / 112.0;
        
        region.span = span;
        
        [_worldMap setRegion:region animated:YES];
        [_indicador stopAnimating];
        _indicador.hidden = TRUE;
    }];
    
}


@end
