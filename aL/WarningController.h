#import <Foundation/Foundation.h>

typedef enum {
    BLUETOOTH_ON,
    BLUETOOTH_OFF,
    BLUETOOTH_ALLOWED,
    BLUETOOTH_NOT_ALLOWED,
    BLUETOOTH_NOT_COMPATABLE,
    GPS_ON,
    GPS_OFF,
    GPS_ALLOWED,
    GPS_NOT_ALLOWED
} WarningEvents;

@protocol WarningObserver <NSObject>
-(void)AlertEvent:(WarningEvents)event;
@end

@interface WarningController : NSObject{
    NSString *WARNING_BLUETOOTH_OFF;
    NSString *WARNING_BLUETOOTH_NOT_ALLOWED;
    NSString *WARNING_GPS_OFF;
    NSString *WARNING_GPS_NOT_ALLOWED;
    NSString *WARNING_BLUETOOTH_NOT_COMPATABLE;
    NSMutableArray *_ObserverList;
}

@property (nonatomic,retain) NSMutableArray *_WarningList;

+(id)sharedInstance;//Singleton
-(void)registerObserver:(id<WarningObserver>)Observer;
-(void)deregisterObserver:(id<WarningObserver>)Observer;
-(void)AlertEvent:(WarningEvents)event;

@end
