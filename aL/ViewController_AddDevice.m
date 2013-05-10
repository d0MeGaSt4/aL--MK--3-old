#import "ViewController_AddDevice.h"
#import "Wizard.h"
#import "BluetoothController.h"
#import "Alarm.h"


@implementation ViewController_AddDevice

-(void)viewDidLoad{
    [super viewDidLoad];
    UIView *mainview = [[[NSBundle mainBundle] loadNibNamed:@"View_AddDevice" owner:self options:nil]objectAtIndex:0];
    
    UIButton *btn_Proceed = (UIButton*)[mainview viewWithTag:1];
    
    [btn_Proceed addTarget:self action:@selector(ProceedWithWizard:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mainview];
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    mainview.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    self.title = @"Add Device";
    
    //This is the fix the 20px bug created by UINavigationController
    [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    [mainview setFrame:self.view.frame];
    
}

-(void)ProceedWithWizard:(id)sender{
    if([[BluetoothController sharedInstance]is_BluetoothOn])
    {
        [[Wizard sharedInstance]ShowWizard];
    }
    else
    {
        [[BluetoothController sharedInstance] CheckBluetoothStatus];
    }
}
@end
