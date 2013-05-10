#import "ViewController_Map.h"
#import "DeviceController.h"
#import "MapAnnotations.h"
#import "AppDelegate.h"

@interface ViewController_Map ()

@end

@implementation ViewController_Map

- (void)viewDidLoad
{
    [super viewDidLoad];
	mapView = [[MKMapView alloc]init];
    [mapView setFrame:self.view.frame];
    
    [self.view addSubview:mapView];
    
    mapView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    self.title = @"Lost Location";
    
    [mapView setMapType:MKMapTypeStandard];
    [self.view setAutoresizesSubviews:true];
    [mapView setDelegate:self];
    
    //This is the fix the 20px bug created by UINavigationController
    [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    [mapView setFrame:self.view.frame];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _device = [[DeviceController sharedInstance]_DetailsDevice];
    
    CLLocationCoordinate2D _coord = CLLocationCoordinate2DMake(_device._latitude,_device._longitude);

    NSLog(@"show latitude: %f, longitude: %f",_coord.latitude,_coord.longitude);
    
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    [mapView setShowsUserLocation:YES];
    
    [mapView setCenterCoordinate:_coord];
    
    MapAnnotations *PointonMap = [[MapAnnotations alloc]init];
    [PointonMap setCoordinate:_coord];
    [PointonMap setTitle:[[DeviceController sharedInstance]_DetailsDevice].str_Name];
    [PointonMap setSubtitle:@"Last Known Location"];
   if([[_device str_DateLost]isEqual:@""])
    {
        UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Last Location" message:@"No Co-ordinates Found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];
        [mapView setShowsUserLocation:YES];
    }
    else
    {
        [mapView addAnnotation:PointonMap];
        mapView.showsUserLocation = NO;
    }
}

// When a map annotation point is added, zoom to it (1500 range)
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
	MKAnnotationView *annotationView = [views objectAtIndex:0];
	id <MKAnnotation> mp = [annotationView annotation];
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 1500, 1500);
	[mv setRegion:region animated:YES];
	[mv selectAnnotation:mp animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    mapView.showsUserLocation = NO;
}
@end
