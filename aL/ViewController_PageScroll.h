#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"

//Includes WarningMenu

@interface ViewController_PageScroll : UIViewController<UIScrollViewDelegate>{
    NSInteger numOfPages;
    NSInteger PageBeforeChange;
    bool bol_initializedPages;
}

@property (retain, nonatomic) IBOutlet UIScrollView *PagesScrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *PageControl;
@property (nonatomic) BOOL pageControlUsed;

-(void)changePage:(id)sender;
-(void)loadScrollViewWithChildController:(int)index;
-(int)PageInView;

@end
