#import <UIKit/UIKit.h>
#import "Protag_Device.h"
#import "ViewController_Map.h"
#import "DeviceController.h"
#import "ViewController_DeviceFinder.h"
#import "ViewController_DeviceProximity.h"
#import "ViewController_Radar.h"

//Alert view used to change name
@interface ViewController_DeviceDetails : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,DeviceObserver>{
    Protag_Device *_device;
    ViewController_DeviceFinder *DeviceFinderController;
    ViewController_DeviceProximity *DeviceProximityController;
    ViewController_Radar *RadarController;
}
@property (nonatomic) UITableView *DetailsTable;
@property (nonatomic) UISwitch *btn_OnOff;
@property (nonatomic) UISegmentedControl *btn_Distance;
@property (nonatomic) UISegmentedControl *btn_Icons;
@property (nonatomic) IBOutlet UITableViewCell *Cell_DetailsName;
@property (nonatomic) IBOutlet UITableViewCell *Cell_DetailsDelete;
@property (nonatomic) IBOutlet UITableViewCell *Cell_DetailsRSSI;
@property (nonatomic) IBOutlet UITableViewCell *Cell_DetailsPhoneRSSI;
@property (nonatomic) IBOutlet UITableViewCell *Cell_DetailsStatus;
@property (nonatomic) IBOutlet UITableViewCell *Cell_DetailsOnOff;
@property (nonatomic) IBOutlet UITableViewCell *Cell_DetailsUUID;
@property (nonatomic) IBOutlet UITableViewCell *Cell_DetailsBattery;
@property (nonatomic) IBOutlet UITableViewCell *Cell_DetailsIcons;
@property (nonatomic) IBOutlet UITableViewCell *Cell_DetailsDistance;
@property (nonatomic) IBOutlet UITableViewCell *Cell_DetailsLastDisconnected;
@property (nonatomic) IBOutlet UITableViewCell *Cell_DetailsLastLocation;
@property (nonatomic) IBOutlet UITableViewCell *Cell_DetailsFindProtag;
@property (nonatomic) IBOutlet UITableViewCell *Cell_DetailsProximityProtag;

- (void)UpdateDistance: (id)sender;
- (void)UpdateIcon: (id)sender;
- (void)toggleOnOff:(id)sender;
-(void)Show_NameInput;
-(void)Show_DeleteConfirmation;
-(void)PushToDeviceFinder;


@end
