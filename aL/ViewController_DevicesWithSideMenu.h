#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"
#import "ViewController_PageScroll.h"
#import "ViewController_WarningMenu.h"
#import "ViewController_DeviceDetails.h"
#import "WarningController.h"
#import "ViewController_ProtagDetails.h"

@interface ViewController_DevicesWithSideMenu : IIViewDeckController<IIViewDeckControllerDelegate,WarningObserver>{
    ViewController_PageScroll *CenterController;
    ViewController_DeviceDetails *DetailsController;
    ViewController_WarningMenu *WarningMenu;
    ViewController_ProtagDetails *ProtagDetailsController;
}

@property (nonatomic,retain) UIBarButtonItem *btn_Warning;
-(void)ToggleSideMenu;
-(void)PushToDetails;
-(void)UpdateVisibilityOfWarningMenuBtn;
-(void)AlertEvent:(WarningEvents)event;

@end
