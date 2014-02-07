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

@end
