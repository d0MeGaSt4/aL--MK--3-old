
#import "ViewController_Radar.h"

@interface ViewController_Radar ()

@end

@implementation ViewController_Radar

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *mainView = [[[NSBundle mainBundle] loadNibNamed:@"View_Radar" owner:self options:nil]objectAtIndex:0];
    view_Loading = [[[NSBundle mainBundle] loadNibNamed:@"View_Radar" owner:self options:nil]objectAtIndex:1];
    [self setView: mainView];
    
    [self.view setAutoresizesSubviews:true];
    
    self.title = @"Radar";
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    //This is the fix the 20px bug created by UINavigationController
    [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    
	// Do any additional setup after loading the view.
     _DeviceProximity = [[DeviceProximity alloc]init];
    
    img_Dot  = (UIImageView*)[mainView viewWithTag:1];
    lbl_Distance = (UILabel*)[mainView viewWithTag:2];
    img_Radar = (UIImageView*)[mainView viewWithTag:3];
    int_accumulatedRSSI=0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self showLoading];
    
    Protag_Device *device = [[DeviceController sharedInstance]_DetailsDevice];
    [_DeviceProximity registerObserver:self];
    [_DeviceProximity startScanning:device];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_DeviceProximity stopScanning];
    [_DeviceProximity deregisterObserver:self];
    [self hideLoading];
}

-(void)showLoading{
    if(view_Loading.superview != self.view){
        [view_Loading setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
        [self.view addSubview:view_Loading];
    }
}

-(void)hideLoading{
    if(view_Loading.superview!=NULL && view_Loading.superview==self.view){
        [view_Loading removeFromSuperview];
    }
}


- (void) UpdateStatus:(ProximityStatus)status{
    switch(status){
        case PROXIMITY_IN_RANGE:
            [self hideLoading];
            break;
        case PROXIMITY_NOT_IN_RANGE:
        case PROXIMITY_LONG_RANGE:
        default:
            [self showLoading];
            break;
    }
}


- (void) UpdateRSSI:(int)RSSI{
    double scale = 0.6;
    int_accumulatedRSSI = int_accumulatedRSSI*scale + RSSI*(1-scale);
    int_accumulatedRSSI = RSSI;
    //range is 0 to -90, max as 8 meters
    int int_Estimate = RSSI;//8*(0-RSSI);
    [lbl_Distance setText:[NSString stringWithFormat:@"Approxi. Distance: %d",int_Estimate]];
    
    double percentage = fmod(((90.0/-int_accumulatedRSSI)-1),0.99999);
    if(percentage<0)
        percentage=0;
    
    double dbl_NewY = img_Radar.frame.origin.y + ((img_Radar.frame.size.height-20)*percentage);
    
    //update the dot here
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         [img_Dot setFrame:CGRectMake(img_Dot.frame.origin.x, dbl_NewY, img_Dot.frame.size.width, img_Dot.frame.size.height)];
                     }
                     completion:nil];
}

@end
