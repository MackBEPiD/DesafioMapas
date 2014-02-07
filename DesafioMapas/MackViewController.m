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
    //NSLog(@"%@", newLocation);
    CLLocationCoordinate2D loc = [newLocation coordinate];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
    
    [_worldMap setRegion:region animated:YES];
    [_worldMap setShowsUserLocation:YES];
    
    if (!_btnAtualizacao.on) {
        [locationManager stopUpdatingLocation];
    }
}

#pragma mark - Métodos do btnAtualizacao
- (IBAction)btnAtualizacao:(id)sender {
    UISwitch *btnAtualizacao = (UISwitch *)sender;
    
    if (btnAtualizacao.on){
        [locationManager startUpdatingLocation];
    }else{
        [locationManager stopUpdatingLocation];
    }
}

#pragma mark - Métodos do mapType
- (IBAction)mapType:(id)sender {
    UISegmentedControl *mapType = (UISegmentedControl *)sender;
    NSInteger selectedMapType = mapType.selectedSegmentIndex;
    
    switch (selectedMapType) {
        case 0:
            [_worldMap setMapType:MKMapTypeStandard];
            break;
        case 1:
            [_worldMap setMapType:MKMapTypeSatellite];
            break;
        case 2:
            [_worldMap setMapType:MKMapTypeHybrid];
            break;
        default:
            break;
    }
}

#pragma mark - Métodos dos UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txtLocal) {
        //NSLog(@"txtLocal");
        
        MKLocalSearchRequest *busca = [[MKLocalSearchRequest alloc]init];
        busca.naturalLanguageQuery = textField.text;
        busca.region = _worldMap.region;
        
        MKLocalSearch *doBusca = [[MKLocalSearch alloc] initWithRequest:busca];
        [doBusca startWithCompletionHandler:^(MKLocalSearchResponse *busca, NSError *error) {
            //Se existirem PointAnnotation no mapa, remover
            if(buscaPointAnnotation != nil){
                [_worldMap removeAnnotations:buscaPointAnnotation];
            }
            buscaPointAnnotation = [[NSMutableArray alloc]init];
            
            if (busca.mapItems.count == 0) {
                //NSLog(@"Sem resultados!");
                
                textField.textColor = [UIColor redColor];
                textField.font = [UIFont fontWithName:@"Verdana" size:17.0];
                
                UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"Nenhum local encontrado!" message:@"Tente algo diferente" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [msg show];
            }else{
                textField.textColor = [UIColor blueColor];
                textField.font = [UIFont fontWithName:@"Arial" size:17.0];
                
                //Semente para gerar números randômicos para os flags de indicação de lugar cheio/vazio
                srand(time(0));
                
                for (MKMapItem *item in busca.mapItems) {
                    //NSLog(@"Item: %@", item);
                    //NSLog(@"%@", item.placemark.addressDictionary);
                    
                    //PINO MARCAÇÃO
                    MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
                    [annotation setCoordinate:item.placemark.coordinate];
                    [annotation setTitle:item.name];
                    [annotation setSubtitle:[NSString stringWithFormat:@"%@", [item.placemark.addressDictionary valueForKey:@"Street"]]];
                    
                    //Armazenar os locais da busca no array
                    [buscaPointAnnotation addObject:annotation];
                    [_worldMap addAnnotation:annotation];
                }
                
                //ZOOM no primeiro resultado
                MKMapItem *primeiro = (MKMapItem *)busca.mapItems.firstObject;
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(primeiro.placemark.coordinate, 500, 500);
                [_worldMap setRegion:region animated:YES];
                
            }
        }];
    }
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - AnnotationView
//- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKPinAnnotationView *)view {
//    view.pinColor = MKPinAnnotationColorGreen;
//
//}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>) annotation {
    //Percorre o array dos locais encontrados na busca
    for (MKPointAnnotation *point in buscaPointAnnotation) {
        if(point == annotation){ //Se o annotation for resultado da busca
            MKPinAnnotationView *customPinview = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
            
            int randomico = rand();
            int keyIndicacaoLugar = randomico%3;
            //NSLog(@"%d - %d", randomico, keyIndicacaoLugar);
            switch (keyIndicacaoLugar) {
                case 0:
                    customPinview.pinColor = MKPinAnnotationColorGreen;
                    break;
                case 1:
                    customPinview.pinColor = MKPinAnnotationColorPurple;
                    break;
                case 2:
                    customPinview.pinColor = MKPinAnnotationColorRed;
                    break;
                    
                default:
                    customPinview.pinColor = MKPinAnnotationColorRed;
                    break;
            }
            customPinview.animatesDrop = YES;
            customPinview.canShowCallout = YES;
            
            return customPinview;
        }
    }
    
    return nil;
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
