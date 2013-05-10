#import <UIKit/UIKit.h>

@interface ViewController_OrbDevices : UIViewController{
    NSMutableArray *_OrbDevices;
    UIButton* btn_BigButton;
}

-(void)PressedLargeOrb:(id)sender;
-(void)PressedSmallOrb:(id)sender;
-(void)RefreshSmallOrbs;

@end


