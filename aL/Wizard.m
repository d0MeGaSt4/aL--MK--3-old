#import "Wizard.h"
#import <QuartzCore/QuartzCore.h>
#import "BluetoothController.h"
#import "AppDelegate.h"

//Animation guide
//http://iphonedevelopment.blogspot.sg/2010/05/custom-alert-views.html
#define kAnimationDuration  0.2555

@implementation Wizard

//Singleton
+(id)sharedInstance{
    static Wizard *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}



-(id)init{
    self = [super init];
    if(self)
    {
        NSArray *theView =  [[NSBundle mainBundle] loadNibNamed:@"Wizard" owner:self options:nil];
        _WizardView = [theView objectAtIndex:0];
        lbl_Top = (UITextView*)[_WizardView viewWithTag:1];
        LoadingCircle = (UIActivityIndicatorView*)[_WizardView viewWithTag:2];
        lbl_Btm = (UITextView*)[_WizardView viewWithTag:3];
        btn_Button = (UIButton*)[_WizardView viewWithTag:4];
        
        [btn_Button addTarget:self action:@selector(DismissWizard) forControlEvents:UIControlEventTouchUpInside];
        //Observe BluetoothController
        [[BluetoothController sharedInstance]set_discoveryObserver:self];
    
    }
    return self;
}

-(void)ShowWizard{
    
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    [window addSubview:_WizardView];
    
    _WizardView.alpha = 1;
    _WizardView.frame = window.frame;
    _WizardView.center = window.center;
    bol_DimissingWizard=false;
    
    int_step=1;
    
    [self UpdateUI];
    [self animateBackgroundFadeIn];
    [self animateBoxPopIn];
    //Start scanning
    [[BluetoothController sharedInstance]startScanning];
    timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(showAlert) userInfo:nil repeats:false];
}

-(void)DismissWizard{
    //Stop Scanning
    [[BluetoothController sharedInstance]stopScanning];
    [UIView beginAnimations:nil context:nil];
    _WizardView.alpha = 0.0;
    [UIView commitAnimations];
    
    [self performSelector:@selector(FinishDismissAnimation) withObject:nil afterDelay:0.5];
    bol_DimissingWizard=true;
    if(timer !=NULL)
    {
        [timer invalidate];
        timer = NULL;
    }
    if(btn_Button.tag == 20)
    {
        UITabBarController *MyTabController = (UITabBarController *)((AppDelegate*) [[UIApplication sharedApplication] delegate]).window.rootViewController;
        
        [MyTabController setSelectedIndex:1];
    }
}

-(void)FinishDismissAnimation{
    if(bol_DimissingWizard==true)
        [_WizardView removeFromSuperview];
}

-(void)animateBoxPopIn{
    //pop in animation
    CALayer *viewLayer = [_WizardView viewWithTag:10].layer;
    CAKeyframeAnimation* popInAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    popInAnimation.duration = kAnimationDuration;
    popInAnimation.values = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.6],
                             [NSNumber numberWithFloat:1.1],
                             [NSNumber numberWithFloat:.9],
                             [NSNumber numberWithFloat:1],
                             nil];
    popInAnimation.keyTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.6],
                               [NSNumber numberWithFloat:0.8],
                               [NSNumber numberWithFloat:1.0],
                               nil];
    popInAnimation.delegate = nil;
    
    [viewLayer addAnimation:popInAnimation forKey:@"transform.scale"];
}

-(void)animateBackgroundFadeIn{
    CALayer *viewLayer = [_WizardView viewWithTag:11].layer;
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeInAnimation.toValue = [NSNumber numberWithFloat:0.4];
    fadeInAnimation.duration = kAnimationDuration;
    fadeInAnimation.delegate = nil;
    [viewLayer addAnimation:fadeInAnimation forKey:@"opacity"];
}

-(void)UpdateUI{
    switch(int_step)
    {
        case 1:
            [lbl_Top setText:@"Please turn on your Protag Elite device(s)"];
            [LoadingCircle setHidden:false];
            [btn_Button setTitle:@"Cancel" forState:UIControlStateNormal];
            [btn_Button setTag:10];
            [lbl_Btm setText:@"Scanning for any Protag Elite device(s) nearby..."];
            break;
        case 2:
            [lbl_Top setText:[NSString stringWithFormat:@"Discovered %d Protag Elite device(s)",int_DevicesFound]];
            
            [lbl_Btm setText:@"Still detecting for Protag Elite device(s)"];
            break;
        case 3:
            [lbl_Top setText:[NSString stringWithFormat:@"Connecting to %d Protag Elite device(s)",int_DevicesFound]];
            
            int tempInt = int_DevicesFound-[[BluetoothController sharedInstance]Discovered_Peripherals].count;
            if(tempInt == 0)
                [lbl_Btm setText:@""];
            else
                [lbl_Btm setText:[NSString stringWithFormat:@"Connected to %d Protag Elite device(s)",tempInt]];
            break;
        case 4:
            [btn_Button setTitle:@"Done" forState:UIControlStateNormal];
            [btn_Button setTag:20];
            [LoadingCircle setHidden:true];
            if(int_DevicesFound>int_DevicesFailed)
            {
                [lbl_Top setText:[NSString stringWithFormat:@"You have successfully linked %d Protag Elite device(s)",int_DevicesFound-int_DevicesFailed]];
                if(int_DevicesFailed<=0)
                    [lbl_Btm setText:@"Please proceed to Protag Devices to access card options"];
                else
                    [lbl_Btm setText:[NSString stringWithFormat:@"Failed to connect to %d device(s)...",int_DevicesFailed]];
            }
            else
            {
                [lbl_Top setText:[NSString stringWithFormat:@"Failed to link %d device(s)\nPlease try again :( sorry for the inconvenience",int_DevicesFailed]];
                [lbl_Btm setText:@""];
            }
            if(timer !=NULL)
            {
                [timer invalidate];
                timer = NULL;
            }
            break;
        default:
            break;
    }
}

-(void)AlertEvent:(DiscoveryEvents)event{
    switch(event){
        case DISCOVERING_DEVICES:
            int_step=1;
            int_DevicesFailed=0;
            int_DevicesFound=0;
            break;
        case DISCOVERED_DEVICE:
            if(int_step<=2)
                int_DevicesFound++;
            if(int_step==1)
            {
                int_step=2;
                //A timer to wait for more devices to be discovered before attempting to connect to all of them
                [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(connectNextDiscoveredDevice) userInfo:nil repeats:false];
            }
            break;
        case CONNECTING_DEVICE:
            if(int_step==2)
            {
                //Stop Scanning
                [[BluetoothController sharedInstance]stopScanning];
                int_step=3;
            }
            break;
        case CONNECTED_DEVICE:
            if(int_step==3)
            {
                if([[BluetoothController sharedInstance]Discovered_Peripherals].count<=0)
                    int_step=4;
                else if([[BluetoothController sharedInstance]Discovered_Peripherals].count>0)
                    [self connectNextDiscoveredDevice];
            }
            break;
        case FAIL_CONNECT_DEVICE:
            int_DevicesFailed++;
            [self connectNextDiscoveredDevice];
            break;
        default:
            break;
    }
    
    [self UpdateUI];
}

-(void)connectNextDiscoveredDevice{
    if([[BluetoothController sharedInstance]Discovered_Peripherals].count>0)
    {
        NSLog(@"connectNextDiscoveredDevice");
        CBPeripheral *tempPeripheral = (CBPeripheral*)[[[BluetoothController sharedInstance]Discovered_Peripherals]objectAtIndex:0];
        
        if(![tempPeripheral isConnected]){
            [[[BluetoothController sharedInstance]CentralManager] connectPeripheral:tempPeripheral options:nil];
            
            [self AlertEvent:CONNECTING_DEVICE];
        }
        else
        {
            //If Device already connected
            [[[BluetoothController sharedInstance]Discovered_Peripherals]removeObjectAtIndex:0];
            [self AlertEvent:CONNECTED_DEVICE];
        }
    }
}

-(void)showAlert{
    UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Information" message:@"Either No Protag Found or Adding the exists Protag?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [message setAlertViewStyle:UIAlertViewStyleDefault];
    [message setTag:1];
    [message show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==1)
    {
        //To Dismiss AlertView
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"OK"])
            [self DismissWizard];
        
    }
}


@end
