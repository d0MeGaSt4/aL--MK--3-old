#import <UIKit/UIKit.h>
#import "WarningController.h"

@interface ViewController_WarningMenu : UIViewController<UITableViewDelegate,UITableViewDataSource,WarningObserver>{
    UIView *_superView;
}

@property (nonatomic,retain) UITableView *_tableView;
@property (nonatomic,retain) IBOutlet UITableViewCell *Cell_Fine;
@property (nonatomic,retain) IBOutlet UITableViewCell *Cell_Warning;

@end
