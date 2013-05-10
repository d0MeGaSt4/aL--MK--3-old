#import "ViewController_OrbDevices.h"
#import "btn_SmallOrb.h"
#import "DeviceController.h"
#import "Protag_Device.h"
#import "ViewController_DevicesWithSideMenu.h"


//Internal Interface
@interface ViewController_OrbDevices ()<DeviceObserver>

@end

@implementation ViewController_OrbDevices

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _OrbDevices = [[NSMutableArray alloc]init];
    
    //Load the Nib
    UIView *mainView = [[[NSBundle mainBundle] loadNibNamed:@"View_OrbDevices" owner:self options:nil]objectAtIndex:0];
    [self setView: mainView];
    btn_BigButton = (UIButton*)[mainView viewWithTag:1];
    [btn_BigButton addTarget:self action:@selector(PressedLargeOrb:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    //Invisible button on the left side so that ViewController_DevicesWithSideMenu can scroll to the WarningMenu. This button does no action
    UIButton *btn_InvisibleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_InvisibleBtn setBackgroundColor:[UIColor clearColor]];
    
    [btn_InvisibleBtn setFrame:CGRectMake(0, 0, 32,self.view.frame.size.height)];
    [self.view addSubview:btn_InvisibleBtn];
    
    //Initialize the orbs
    for(int i=0;i<[[DeviceController sharedInstance]_currentDevices].count;i++)
    {
        [self CreateOrbWithDevice: (Protag_Device*)[[[DeviceController sharedInstance]_currentDevices]objectAtIndex:i] withIndex:i];
    }
    
    
    //Register for refresh with MainController
    [[DeviceController sharedInstance]registerObserver:self];
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self RefreshSmallOrbs];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    //deregister for refresh with MainController
    [[DeviceController sharedInstance]deregisterObserver:self]; 

}

-(void)CreateOrbWithDevice:(Protag_Device*)device withIndex:(int)index{
    btn_SmallOrb *temp_Orb = [[btn_SmallOrb alloc]initWithDevice:device];
    [self.view addSubview:temp_Orb];
    [self SetOrbLocation:temp_Orb withIndex:index];
    [temp_Orb addTarget:self action:@selector(PressedSmallOrb:)forControlEvents:UIControlEventTouchUpInside];
    
    [_OrbDevices addObject:temp_Orb];
}

-(void)SetOrbLocation:(btn_SmallOrb*)orb withIndex:(int)index{
    int orb_size = 45;
    int coord_x=0,coord_y=0;
    
    int rel_x = btn_BigButton.frame.origin.x;
    int rel_y = btn_BigButton.frame.origin.y;
    
#warning change orb positions
    if([[DeviceController sharedInstance]_currentDevices].count<=4)
    {
    //Set orb starting location here (use relative position to the Large Orb)
        switch(index){
            case 0:
                coord_x=rel_x+206;
                coord_y=rel_y-3;
                break;
            case 1:
                coord_x=rel_x-13;
                coord_y=rel_y+230;
                break;
            case 2:
                coord_x=rel_x+220;
                coord_y=rel_y+270;
                break;
            case 3:
                coord_x=rel_x;
                coord_y=rel_y+10;
                break;
            default:
                coord_x=0;
                coord_y=0;
                break;
        }
    }else{
        switch(index){
            case 0:
                coord_x=rel_x+200;
                coord_y=rel_y+15;
                break;
            case 1:
                coord_x=rel_x-10;
                coord_y=rel_y+190;
                break;
            case 2:
                coord_x=rel_x+200;
                coord_y=rel_y+190;
                break;
            case 3:
                coord_x=rel_x-5;
                coord_y=rel_y+15;
                break;
            case 4:
                coord_x=rel_x-37;
                coord_y=rel_y+100;
                break;
            case 5:
                coord_x=rel_x+100;
                coord_y=rel_y-33;
                break;
            case 6:
                coord_x=rel_x+232;
                coord_y=rel_y+100;
                break;
            default:
                coord_x=0;
                coord_y=0;
                break;
        }
    }
    
    [orb setFrame: CGRectMake(coord_x,coord_y,orb_size,orb_size)];
}

-(void)PressedLargeOrb:(id)sender{
    NSLog(@"Pressed Large Orb");
    for(int i=0;i<[[DeviceController sharedInstance]_currentDevices].count;i++)
    {
        Protag_Device *device = (Protag_Device*) [[[DeviceController sharedInstance]_currentDevices]objectAtIndex:i];
        [device Connect];
    }
}

-(void)PressedSmallOrb:(id)sender{
    NSLog(@"Pressed Small Orb");
    if([sender isKindOfClass:[btn_SmallOrb class]])
    {
        [[DeviceController sharedInstance]set_DetailsDevice:((btn_SmallOrb*)sender)._device];
        
        //Access Parent View to push to details view so that we only have 1 details viewcontroller
        UIViewController *tempController = [self parentViewController];
        while(![tempController isKindOfClass:[ViewController_DevicesWithSideMenu class]])tempController = [tempController parentViewController];
        
        [((ViewController_DevicesWithSideMenu*)tempController) PushToDetails];
    }
}

-(void)RefreshDeviceTable{
    //Called by MainController
    [self RefreshSmallOrbs];
}

-(void)RefreshSmallOrbs{
    
    for(int i=0;i<_OrbDevices.count;i++)
    {
        [((btn_SmallOrb*)[_OrbDevices objectAtIndex:i])removeFromSuperview];
    }
    
    [_OrbDevices removeAllObjects];
    
    //Initialize the orbs
    for(int i=0;i<[[DeviceController sharedInstance]_currentDevices].count;i++)
    {
        [self CreateOrbWithDevice: (Protag_Device*)[[[DeviceController sharedInstance]_currentDevices]objectAtIndex:i] withIndex:i];
    }
}

@end
