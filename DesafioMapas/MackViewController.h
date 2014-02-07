//
//  MackViewController.h
//  DesafioMapas
//
//  Created by Lucas Saito on 05/02/14.
//  Copyright (c) 2014 Mack Mobile - BEPiD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MackViewController : UIViewController {
    CLLocationManager *locationManager;
}

@property (weak, nonatomic) IBOutlet MKMapView *worldMap;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicador;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
