//
//  DetailViewController.h
//  test
//
//  Created by Abhijeet Mulay on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "TUTSimpleScatterPlot.h"
#import "FirstViewController.h"
@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate>
{
    IBOutlet CPTGraphHostingView  *_ecgPlotView;
    IBOutlet CPTGraphHostingView  *_pulsifierPlotView;
    IBOutlet CPTGraphHostingView  *_pieChartView;
    IBOutlet UILabel *_spO2Label;
    IBOutlet UILabel *bpmLabel;
    IBOutlet UIImageView *heartImage;
    IBOutlet UIView *bpmView;
    IBOutlet UIView *spO2View;
    IBOutlet UIView *plotView;
    IBOutlet UIView *eventView;
    IBOutlet UIView *rightBarView;
    IBOutlet UIView *settingView;
    IBOutlet UIImageView *hrAlarm;
    IBOutlet UIImageView *spo2Alarm;
    IBOutlet UIButton *bluetoothSetting;
    IBOutlet UIButton *generalSetting;
    IBOutlet UITableView *bluetoothListView;
    IBOutlet CPTGraphHostingView *eventPlotView;
    IBOutlet UIWebView *eventsWebView;
    IBOutlet UISwitch *gridSwitch;
    IBOutlet UIImageView *gridImage;
    IBOutlet UIView *shadowView;
    BOOL settingViewVisible;
    UIPopoverController *bluetoothPopover;
    UIPopoverController *settingPopover;
    FirstViewController *firstViewController;
    NSString *patientName;
    NSString *fileName;
    NSTimer *heartBeatTimer;
    NSNumber *spo2AlarmValue;
    TUTSimpleScatterPlot *_scatterPlot;
}
-(IBAction)bluetoothSetting;
-(IBAction)generalSetting:(id)sender;
-(IBAction)gridImageSwitch:(id)sender;
@property (nonatomic, retain) IBOutlet UIImageView *hrAlarm;
@property (nonatomic, retain) IBOutlet UIImageView *spo2Alarm;
@property (nonatomic, retain) IBOutlet UIView *shadowView;
@property (nonatomic, retain) UISwitch *gridSwitch;
@property (nonatomic, retain) UIView *plotView;
@property (nonatomic, retain) UIView *eventView;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *patientName;
@property (nonatomic, retain) CPTGraphHostingView *eventPlotView;
@property (nonatomic, retain) TUTSimpleScatterPlot *scatterPlot;
@property (nonatomic, retain) FirstViewController *firstViewController;
@property (nonatomic, retain) NSNumber *spo2AlarmValue;
@end
