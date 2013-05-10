#import <UIKit/UIKit.h>
#import "ViewController_DeviceDetails.h"
#import "DeviceController.h"

@interface ViewController_TableDevices : UIViewController <UITableViewDelegate,UITableViewDataSource,DeviceObserver>

@property (retain, nonatomic) UITableView *currentDeviceTable;
@property IBOutlet UITableViewCell *Cell_DeviceName;
@property IBOutlet UITableViewCell *Cell_DeviceStatus;
@property IBOutlet UITableViewCell *Cell_Snooze;


-(void)toggleOnOff:(id)sender;

@end
