//
//  BluetoothUtil.h
//  mlabProject3
//
//  Created by Abhijeet Mulay on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@protocol BluetoothDelegate <NSObject,CBPeripheralDelegate>

@required
- (void) foundPeripheral:(CBPeripheral *)p;
- (void) peripheralConnected;

@end

@interface BluetoothUtil : NSObject<CBCentralManagerDelegate>
{
    
    
}
@property bool BluetoothReady;
@property (nonatomic,strong) CBCentralManager *bluetoothManager;
@property (nonatomic,assign) id delegate;
@end
