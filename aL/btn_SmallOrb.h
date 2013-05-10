#import <UIKit/UIKit.h>
#import "Protag_Device.h"

//btn_SmallOrb only used to display and store the device, does not manupilate anything

@interface btn_SmallOrb : UIButton

-(id)initWithDevice:(Protag_Device*)device;
@property (nonatomic) UIImageView *Icon;
@property (nonatomic) Protag_Device *_device;
-(void)updateImages;

@end
