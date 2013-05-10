#import <Foundation/Foundation.h>
#import "BluetoothController.h"

@interface Wizard : NSObject<UIAlertViewDelegate,DiscoveryObserver>{
    UIView *_WizardView;
    UITextView *lbl_Top;
    UITextView *lbl_Btm;
    UIActivityIndicatorView *LoadingCircle;
    UIButton *btn_Button;
    int int_step;
    int int_DevicesFound;
    int int_DevicesFailed;
    bool bol_DimissingWizard;
    NSTimer *timer;
}

+(id)sharedInstance;//Singleton
-(void)ShowWizard;
-(void)DismissWizard;
-(void)FinishDismissAnimation;
-(void)UpdateUI;
-(void)connectNextDiscoveredDevice;
-(void)showAlert;

@end
