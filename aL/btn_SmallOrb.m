#import "btn_SmallOrb.h"
#import "Protag_Device.h"

@implementation btn_SmallOrb

@synthesize Icon;
@synthesize _device;

-(id)initWithDevice:(Protag_Device*)device{
    
    if(self = [super init]){
        _device = device;
        [self setBackgroundImage:[UIImage imageNamed:@"small silver.png"] forState:UIControlStateNormal];
        
        [self setImage:[UIImage imageNamed:@"1+wallet icon.png"] forState:UIControlStateNormal];
    }
    [self updateImages];

    return self;
}

-(void)updateImages{
    if(_device!=NULL)
    {
        //Update Icon
        switch(_device.int_Icon)
        {
            case 6:
                [self setImage:[UIImage imageNamed:@"6+luggage icon.png"] forState:UIControlStateNormal];
                break;
            case 5:
                [self setImage:[UIImage imageNamed:@"5+purse icon.png"] forState:UIControlStateNormal];
                break;
            case 4:
                [self setImage:[UIImage imageNamed:@"4+briefcase icon.png"] forState:UIControlStateNormal];
                break;
            case 3:
                [self setImage:[UIImage imageNamed:@"3+laptop icon.png"] forState:UIControlStateNormal];
                break;
            case 2:
                [self setImage:[UIImage imageNamed:@"2+camera icon.png"] forState:UIControlStateNormal];
                break;
            case 1:
                [self setImage:[UIImage imageNamed:@"1+wallet icon.png"] forState:UIControlStateNormal];
                break;
            case 0:
            default:
                [self setImage:[UIImage imageNamed:@"none icon.png"] forState:UIControlStateNormal];
                break;
                
        }
        //Update Color of Orb (status)
        switch([_device get_StatusCode])
        {
            case STATUS_CONNECTED:
                [self setBackgroundImage:[UIImage imageNamed:@"small green.png"] forState:UIControlStateNormal];
                break;
            case STATUS_NOT_CONNECTED:
            case STATUS_DISCONNECTED:
            case STATUS_CONNECTING:
            default:
                [self setBackgroundImage:[UIImage imageNamed:@"small silver.png"] forState:UIControlStateNormal];
                break;
        }
    }
}

@end
