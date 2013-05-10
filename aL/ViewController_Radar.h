
#import <UIKit/UIKit.h>
#import "DeviceProximity.h"
#import "DeviceController.h"
#import "Protag_Device.h"

@interface ViewController_Radar : UIViewController<ProximityObserver>{
    DeviceProximity *_DeviceProximity;
    UILabel *lbl_Distance;
    UIImageView *img_Dot;
    UIImageView *img_Radar;
    UIView *view_Loading;
    int int_accumulatedRSSI;
}

@end
