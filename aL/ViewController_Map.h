#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Protag_Device.h"

@interface ViewController_Map : UIViewController<MKMapViewDelegate>{
    MKMapView * mapView;
    Protag_Device *_device;
}

@end
