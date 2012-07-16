//
//  FirstViewController.h
//  mLabProject1
//
//  Created by Abhijeet Mulay on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BluetoothUtil.h"
@class DetailViewController;

@interface FirstViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,CBPeripheralDelegate, BluetoothDelegate>
{
    IBOutlet UITableView *peripheralListView;
    IBOutlet UIButton *scanButton;
    IBOutlet UIButton *connectButton;
    IBOutlet UIStepper *spo2Level;
    IBOutlet UISwitch *bluetoothSwitch;
    IBOutlet UISwitch *alarmSwitch;
    IBOutlet UIView *bluetoothView;
    IBOutlet UILabel *alarmValueLabel;
    DetailViewController *detailViewController;
    BOOL isBluetoothOn;
    BOOL isAlarmOn;
    BluetoothUtil *bluetoothUtil;
    CBPeripheral *peripheral;
    NSMutableArray *peripheralDevices;
}
-(IBAction)scanForPeripherals:(id)sender;
-(IBAction)connectPeripherals:(id)sender;
-(IBAction)switchAlarm:(id)sender;
-(IBAction)switchBluetooth:(id)sender;
-(IBAction)selectSpO2Level:(id)sender;

-(void)updateHRMData:(NSData *)data ;
@property(nonatomic, retain) CBPeripheral *peripheral;
@property(nonatomic, retain) UITableView *peripheralListView;
@property(nonatomic, retain) BluetoothUtil *bluetoothUtil;
@property(nonatomic, retain) IBOutlet UIButton *scanButton;
@property(nonatomic, retain) IBOutlet UIButton *connectButton;
@property(nonatomic, retain) IBOutlet UIStepper *spo2Level;
@property(nonatomic, retain) IBOutlet UISwitch *bluetoothSwitch;
@property(nonatomic, retain) IBOutlet UISwitch *alarmSwitch;
@property(nonatomic, retain) IBOutlet UILabel *alarmValueLabel;
@property(nonatomic, retain) DetailViewController *detailViewController;
@end
