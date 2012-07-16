//
//  FirstViewController.m
//  mLabProject1
//
//  Created by Abhijeet Mulay on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "DetailViewController.h"
@implementation FirstViewController

@synthesize peripheralListView, scanButton, connectButton, bluetoothUtil, peripheral, alarmSwitch, bluetoothSwitch, spo2Level, alarmValueLabel,detailViewController;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        self.tabBarItem.title = @"Settings";
        self.title = @"Settings";
        
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)dealloc
{
    self.scanButton = nil;
    self.connectButton = nil;
    self.peripheral = nil;
    self.bluetoothSwitch = nil;
    self.alarmSwitch = nil;
    self.spo2Level = nil;
    [bluetoothUtil release];
    [peripheralListView release];
    [peripheralDevices release];
   
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"Initializing BLE");
    if(peripheralDevices)
        [peripheralDevices removeAllObjects];
    else
        peripheralDevices = [[NSMutableArray alloc] init];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    if (!bluetoothUtil.BluetoothReady) 
        self.bluetoothUtil = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark - IBActions

/*******************************************************************************
 Bluetooth scan...
 *******************************************************************************/


-(IBAction)scanForPeripherals:(id)sender
{
    if (self.bluetoothUtil.BluetoothReady) {
        // BLE HW is ready start scanning for peripherals now.
        NSLog(@"Button pressed, start scanning ...");
        [self.scanButton setTitle:@"Scanning ..." forState:UIControlStateNormal];
        [self.bluetoothUtil.bluetoothManager scanForPeripheralsWithServices:nil options:nil];
        //[self.bluetoothUtil.bluetoothManager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"180D"]] options:nil];
    }
    
}

/*******************************************************************************
 Bluetooth Connect
 *******************************************************************************/


-(IBAction)connectPeripherals:(id)sender
{
    if(self.peripheral) {
        if(!self.peripheral.isConnected) {
            [self.bluetoothUtil.bluetoothManager connectPeripheral:self.peripheral options:nil];
            [self.connectButton setTitle:@"Disconnect ..." forState:UIControlStateNormal];
        }
        else {
            [self.bluetoothUtil.bluetoothManager cancelPeripheralConnection:self.peripheral];
            [self.connectButton setTitle:@"Connect ..." forState:UIControlStateNormal];
        }
    }

}

/*******************************************************************************
 Enable/disable alarm
 *******************************************************************************/


- (IBAction)switchAlarm:(id)sender
{
    UISwitch *aSwitch = (UISwitch *)sender;
    if(aSwitch.isOn)
    {
        isAlarmOn = YES;
        self.detailViewController.spo2Alarm.hidden = NO;
        
    }
    else 
    {
        self.detailViewController.spo2Alarm.hidden = YES;
        isAlarmOn = NO;
    }
}

/*******************************************************************************
Enable/Disable bluetooth
 *******************************************************************************/


- (IBAction)switchBluetooth:(id)sender
{
    UISwitch *bSwitch = (UISwitch *)sender;
    if(bSwitch.isOn)
    {
        isBluetoothOn = YES;
        bluetoothView.hidden = NO;
        if (!self.bluetoothUtil) {
            self.bluetoothUtil = [[BluetoothUtil alloc] init];
            self.bluetoothUtil.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self.bluetoothUtil queue:nil];
            self.bluetoothUtil.delegate = self;
        }
    }
    else 
    {
        isBluetoothOn = NO;
        bluetoothView.hidden = YES;
        [self.bluetoothUtil.bluetoothManager stopScan];
    }
    
}

/*******************************************************************************
 Stepper call back..
 *******************************************************************************/

-(IBAction)selectSpO2Level:(id)sender
{
    NSLog(@"%f",spo2Level.value);
    alarmValueLabel.text = [NSString stringWithFormat:@"%d",[[NSNumber numberWithDouble:spo2Level.value] intValue]];
    self.detailViewController.spo2AlarmValue = [NSNumber numberWithDouble:spo2Level.value];
}

- (void) foundPeripheral:(CBPeripheral *)p
{
    CBPeripheral *peripherals;
    for (peripherals in peripheralDevices)
    {
        if (p.UUID != peripherals.UUID) {
            [peripheralDevices addObject:p];
        }
    }
    [self.peripheralListView setFrame:CGRectMake(self.peripheralListView.frame.origin.x, self.peripheralListView.frame.origin.y, self.peripheralListView.frame.size.width, self.peripheralListView.frame.size.height*[peripheralDevices count])];
    [peripheralListView reloadData];
}

- (void) peripheralConnected
{
    self.peripheral.delegate = self;
    [self.peripheral discoverServices:nil];
}


#pragma mark - TableView delegate and Data source methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [peripheralDevices count];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.peripheral = [peripheralDevices objectAtIndex:indexPath.row];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.text = ((CBPeripheral *)[peripheralDevices objectAtIndex:indexPath.row]).name;
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - CBPeripheral delegate methods
/*
 Invoked upon completion of a -[discoverServices:] request.
 Discover available characteristics on interested services
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error 
{
    for (CBService *aService in aPeripheral.services) 
    {
        NSLog(@"Service found with UUID: %@", aService.UUID);
        
        /* Heart Rate Service */
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180D"]]) 
        {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
        
        /* Device Information Service */
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) 
        {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
        
        /* GAP (Generic Access Profile) for Device Name */
        if ( [aService.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] )
        {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
    }
}

/*
 Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 Perform appropriate operations on interested characteristics
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error 
{    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]]) 
    {
        for (CBCharacteristic *aChar in service.characteristics) 
        {
            /* Set notification on heart rate measurement */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]]) 
            {
                [peripheral setNotifyValue:YES forCharacteristic:aChar];
                NSLog(@"Found a Heart Rate Measurement Characteristic");
            }
            /* Read body sensor location */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A38"]]) 
            {
                [aPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Body Sensor Location Characteristic");
            } 
            
            /* Write heart rate control point */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A39"]])
            {
                uint8_t val = 1;
                NSData* valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
                [aPeripheral writeValue:valData forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
            }
        }
    }
    
    if ( [service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] )
    {
        for (CBCharacteristic *aChar in service.characteristics) 
        {
            /* Read device name */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]]) 
            {
                [aPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Name Characteristic");
            }
        }
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) 
    {
        for (CBCharacteristic *aChar in service.characteristics) 
        {
            /* Read manufacturer name */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]]) 
            {
                [aPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Manufacturer Name Characteristic");
            }
        }
    }
}

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error 
{
    /* Updated value for heart rate measurement received */
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]]) 
    {
        if( (characteristic.value)  || !error )
        {
            /* Update UI with heart rate data */
            [self updateHRMData:characteristic.value];
        }
    } 
    /* Value for body sensor location received */
    else  if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A38"]]) 
    {
        NSData * updatedValue = characteristic.value;        
        uint8_t* dataPointer = (uint8_t*)[updatedValue bytes];
        if(dataPointer)
        {
            uint8_t location = dataPointer[0];
            NSString*  locationString;
            switch (location)
            {
                case 0:
                    locationString = @"Other";
                    break;
                case 1:
                    locationString = @"Chest";
                    break;
                case 2:
                    locationString = @"Wrist";
                    break;
                case 3:
                    locationString = @"Finger";
                    break;
                case 4:
                    locationString = @"Hand";
                    break;
                case 5:
                    locationString = @"Ear Lobe";
                    break;
                case 6: 
                    locationString = @"Foot";
                    break;
                default:
                    locationString = @"Reserved";
                    break;
            }
            NSLog(@"Body Sensor Location = %@ (%d)", locationString, location);
        }
    }
    /* Value for device Name received */
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]])
    {
        NSString * deviceName = [[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] autorelease];
        NSLog(@"Device Name = %@", deviceName);
    } 
    /* Value for manufacturer name received */
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]]) 
    {
       
        NSLog(@"Manufacturer Name = %@", characteristic.value);
    }
}

-(void)updateHRMData:(NSData *)data 
{
    //TODO: Abhijeet
}

@end
