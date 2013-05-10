//
//  ViewController_ProtagDetails.h
//  aL
//
//  Created by macbook on 5/7/13.
//
//

#import <UIKit/UIKit.h>

@interface ViewController_ProtagDetails : UIViewController


@property (nonatomic)IBOutlet UIButton *button_Belongings;
@property (nonatomic)IBOutlet UIButton *button_Battery;
@property (nonatomic)IBOutlet UIButton *button_UUID;
@property (nonatomic)IBOutlet UIButton *button_DistanceSettings;
@property (nonatomic)IBOutlet UIButton *button_RadarTracking;
@property (nonatomic)IBOutlet UIButton *button_LastKnownLocation;

-(void)LoadButton;

@end
