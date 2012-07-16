//
//  SettingsViewController.h
//  mlabProject3
//
//  Created by Abhijeet Mulay on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
{
    IBOutlet UIStepper *alarmValue;
    IBOutlet UILabel *alarmValueLabel;
}
-(IBAction)updateAlarmValue:(id)sender;
@end
