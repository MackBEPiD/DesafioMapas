//
//  MackViewController.m
//  DesafioMapas
//
//  Created by Lucas Saito on 05/02/14.
//  Copyright (c) 2014 Mack Mobile - BEPiD. All rights reserved.
//

#import "MackViewController.h"

@interface MackViewController (){
    CLLocationCoordinate2D loc;
}

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
    
    loc = [newLocation coordinate];
    
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

#pragma mark - Traçar rotas
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    CLLocationCoordinate2D destino = [[view annotation] coordinate];
    MKPlacemark *pmOrigem = [[MKPlacemark alloc] initWithCoordinate:loc addressDictionary:nil];
    MKPlacemark *pmDestino = [[MKPlacemark alloc] initWithCoordinate:destino addressDictionary:nil];
    
    MKMapItem *miOrigem = [[MKMapItem alloc]initWithPlacemark:pmOrigem];
    MKMapItem *miDestino = [[MKMapItem alloc]initWithPlacemark:pmDestino];
    
    [self rotaEntreDoisPontosDe:miOrigem para:miDestino];
}
-(void)rotaEntreDoisPontosDe:(MKMapItem *)origem para:(MKMapItem *)destino{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    request.source = origem;
    request.destination = destino;
    request.requestsAlternateRoutes = YES;
    
    MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if(error){
            NSLog(@"%@", error.localizedDescription);
        }else{
            [_worldMap removeOverlays: _worldMap.overlays];
            if([response.routes count] > 0){
                MKRoute *rota = response.routes[0];
                [_worldMap addOverlay:rota.polyline level:MKOverlayLevelAboveRoads];
            }else{
                //NSLog(@"Rotas não encontrada");
                UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"Nenhuma rota encontrada!" message:@"Tente algo diferente" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [msg show];
            }
        }
    }];
}
-(MKOverlayRenderer *)mapView: (MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 3.0;
    
    return renderer;
}

@end
