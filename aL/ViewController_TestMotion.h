
#import <UIKit/UIKit.h>
#import "DeviceFinder.h"

@interface ViewController_TestMotion : UIViewController<FinderObserver>{
    DeviceFinder *_Finder;
    //Altitude meter
    UILabel *lbl_pitch;
    UILabel *lbl_yaw;
    UILabel *lbl_roll;
    
    UILabel *lbl_direction;
    UILabel *lbl_Tilt;
    UILabel *lbl_Speed;
    UILabel *lbl_distance;
    
    UILabel *lbl_ToGoDirection;
    UILabel *lbl_ToGoDistance;
    
    //Accelerometer
    UILabel *lbl_x;
    UILabel *lbl_y;
    UILabel *lbl_z;
    
    int axis_y;
}

@end
