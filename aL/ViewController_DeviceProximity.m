#import "ViewController_DeviceProximity.h"
#import "DeviceController.h"

@interface ViewController_DeviceProximity ()

@end

@implementation ViewController_DeviceProximity

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //Load the Nib for tableviewcells
    UIView *mainView = [[[NSBundle mainBundle] loadNibNamed:@"View_DeviceProximity" owner:self options:nil]objectAtIndex:0];
    [self setView: mainView];
    
    [self.view setAutoresizesSubviews:true];
    
    self.title = @"Device Proximity";
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    //This is the fix the 20px bug created by UINavigationController
    [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    
    
    _DeviceProximity = [[DeviceProximity alloc]init];
    
    lbl_DeviceName  = (UILabel*)[mainView viewWithTag:1];
    lbl_Description = (UILabel*)[mainView viewWithTag:2];
    lbl_Distance  = (UILabel*)[mainView viewWithTag:3];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    Protag_Device *device = [[DeviceController sharedInstance]_DetailsDevice];
    [_DeviceProximity registerObserver:self];
    
    [_DeviceProximity startScanning:device];
    
    [lbl_DeviceName setText:device.str_Name];
    [lbl_Description setText:@"Initializing..."];
    [lbl_Distance setHidden:true];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_DeviceProximity stopScanning];
    [_DeviceProximity deregisterObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)UpdateStatus:(ProximityStatus)status{
    switch(status){
        case PROXIMITY_LONG_RANGE:
            [lbl_Distance setHidden:true];
            [lbl_Description setText:@"Long Reachable Distance"];
            break;
        case PROXIMITY_IN_RANGE:
            [lbl_Distance setHidden:false];
            [lbl_Description setText:@"Connected"];
            break;
        case PROXIMITY_NOT_IN_RANGE:
        default:
            [lbl_Distance setHidden:true];
            [lbl_Description setText:@"Unable To Reach Protag"];
            break;
    }
}

-(void)UpdateRSSI:(int)RSSI{
    [lbl_Distance setText:[NSString stringWithFormat:@"RSSI: %d",RSSI]];
}

@end
