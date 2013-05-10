#import <UIKit/UIKit.h>
#import "DeviceProximity.h"

@interface ViewController_DeviceProximity : UIViewController<ProximityObserver>{
    DeviceProximity *_DeviceProximity;
    UILabel *lbl_DeviceName;
    UILabel *lbl_Description;
    UILabel *lbl_Distance;
}

@end
