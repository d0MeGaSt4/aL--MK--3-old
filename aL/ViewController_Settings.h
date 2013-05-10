#import <UIKit/UIKit.h>
#import "ViewController_Ringtone.h"

@interface ViewController_Settings : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    ViewController_Ringtone * _RingtoneController;
}

@property (nonatomic,retain) IBOutlet UITableViewCell *Cell_Settings;
@property (nonatomic,retain) IBOutlet UITableViewCell *Cell_OnOff;

-(void)ToggleVibration:(id)sender;
-(void)ToggleAlarmOnSilent:(id)sender;

@end
