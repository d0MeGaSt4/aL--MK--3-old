#import <UIKit/UIKit.h>
#import "DeviceFinder.h"

@interface ViewController_DeviceFinder : UIViewController<FinderObserver>{
    UIImageView *img_Arrow;
    UILabel *lbl_Distance;
    DeviceFinder *_DeviceFinder;
}

@end
