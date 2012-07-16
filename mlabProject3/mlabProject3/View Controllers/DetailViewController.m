//
//  DetailViewController.m
//  test
//
//  Created by Abhijeet Mulay on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "FirstViewController.h"
#import "SettingsViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@end

@implementation DetailViewController
@synthesize patientName;
@synthesize fileName;
@synthesize scatterPlot = _scatterPlot;
@synthesize plotView;
@synthesize eventPlotView;
@synthesize eventView;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize firstViewController,gridSwitch;
@synthesize hrAlarm,spo2Alarm, spo2AlarmValue, shadowView;
- (void)dealloc
{
    self.patientName = nil;
    self.scatterPlot = nil;
    self.plotView = nil;
    self.eventPlotView = nil;
    [bluetoothSetting release];
    // TODO: Release outlets... Abhijeet
    [_masterPopoverController release];
    
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
       if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (!firstViewController)
    {
     firstViewController = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
        [settingView addSubview:firstViewController.view];
        
    }
    
    /*setting view frame set*/
    [settingView setFrame:CGRectMake(settingView.frame.origin.x + 320, settingView.frame.origin.y, settingView.frame.size.width, settingView.frame.size.height)];
    settingViewVisible = NO;
    self.navigationController.navigationItem.title = patientName;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarView];
    self.navigationItem.rightBarButtonItem  = rightBarButtonItem;
    //_pieChartView.hidden = YES;
    
    /*set alarm value*/
    
    self.spo2AlarmValue = [NSNumber numberWithInt:100];
    self.spo2Alarm.hidden = YES;
    
    /*events webview request*/
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test1" ofType:@"htm"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [eventsWebView.scrollView setScrollEnabled:NO];
    eventsWebView.delegate = self;
    [eventsWebView  loadRequest:request];

  //  self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
/*              Animate Image    /////////////////////////////////////////////////////
//    heartBeatTimer = [[NSTimer timerWithTimeInterval:0.5
//                                              target:self
//                                            selector:@selector(animateImage:)
//                                            userInfo:nil
//                                             repeats:YES] retain];
//    [[NSRunLoop mainRunLoop] addTimer:heartBeatTimer forMode:NSDefaultRunLoopMode];
*/     /////////////////////////////////////////////////////////////////// 
}

//-(void)animateImage:(NSTimer*)timer
//{
//    [UIView beginAnimations:nil context:NULL];
//    [UIView animateWithDuration:0.2 animations:nil];
//    CGRect frame = [heartImage frame];
//    if (frame.size.width == 25) 
//        [heartImage setFrame:CGRectMake(frame.origin.x, frame.origin.y, 30, 30)];
//    else
//        [heartImage setFrame:CGRectMake(frame.origin.x, frame.origin.y, 25, 25)];
//    
//    [UIView commitAnimations];
//    
//}


/*******************************************************************************
 * Load webview with patient events....
 *******************************************************************************/ 

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"Webview........");
    CFShow(request);
    NSURL *url = [NSURL URLWithString:@"http://www.highcharts.com/"];
    if ([request.URL isEqual:url]) {
        return NO;
    }
    return YES;
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
    self.title = patientName;
    firstViewController.detailViewController = self;
    if (patientName == nil) 
        self.title = @"Christopher";
    else
        self.navigationController.navigationItem.title = patientName;
    
    /********** Scatter Plot function calls******************************************************/
    /*data arrary to be passed to ECG PLot*/
    
    NSMutableArray *data = [NSMutableArray array];
    self.scatterPlot = [[TUTSimpleScatterPlot alloc] initWithEcgView:_ecgPlotView pulsifierView:_pulsifierPlotView pieChartView:_pieChartView spo2Label:_spO2Label bpmLabel:bpmLabel andData:data];
    [self.scatterPlot setBarChartView:_pieChartView]; //not used
    [self.scatterPlot setDetailViewController:self]; //set delegate to self
    [self.scatterPlot setTimerToPlot:fileName]; 
    [self.scatterPlot initialisePlot]; 
    [self.shadowView setFrame:CGRectMake(30 , 10, 10, 225)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //self.title = patientName;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation))
//    {
//        [_ecgPlotView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//        [_ecgPlotView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
//        [_ecgPlotView setFrame:CGRectMake(20, 20, 580 , 210)];
//        [_pulsifierPlotView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//        [_pulsifierPlotView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
//        [_pulsifierPlotView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//        [_pulsifierPlotView setFrame:CGRectMake(20, 240, 580, 210)];
//        [_pieChartView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//        [_pieChartView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
//        [_pieChartView setFrame:CGRectMake(20, 470, 400, 400)];
//        [bpmView setFrame:CGRectMake(610, 25, 200 , 200)];
//        [spO2View setFrame:CGRectMake(610, 240, 200, 200)];    
//    }
//    else
//    {
//        [_ecgPlotView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//        [_ecgPlotView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
//        [_ecgPlotView setFrame:CGRectMake(10, 10, 550 , 190)];
//        [_pulsifierPlotView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//        [_pulsifierPlotView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
//        [_pulsifierPlotView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//        [_pulsifierPlotView setFrame:CGRectMake(10, 200, 550, 190)];
//        [_pieChartView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//        [_pieChartView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
//        [_pieChartView setFrame:CGRectMake(150, 310, 400, 400)];
//        [bpmView setFrame:CGRectMake(530, 30, 200 , 200)];
//        [spO2View setFrame:CGRectMake(530, 200, 200, 200)];
//    }
//    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}
							
#pragma mark -  IBAction

-(void)bluetoothSetting
{
    if (bluetoothPopover.isPopoverVisible) {
        [bluetoothPopover dismissPopoverAnimated:YES];
    }
    else
    {
//        FirstViewController *firstViewController = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
//        bluetoothPopover = [[UIPopoverController alloc] initWithContentViewController:firstViewController];
//        [bluetoothPopover setPopoverContentSize:CGSizeMake(320, 480) animated:YES];
//        [bluetoothPopover presentPopoverFromRect:CGRectMake(670, 0, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//        [firstViewController release];
    }
    
}

/*******************************************************************************
 * hide/unhide grid...
 *******************************************************************************/ 

-(IBAction)gridImageSwitch:(id)sender
{
    if (((UISwitch*)sender).isOn) 
        gridImage.hidden = NO;
    else 
        gridImage.hidden = YES;
}

/*******************************************************************************
 * hide/unhide setting view...
 *******************************************************************************/

-(IBAction)generalSetting:(id)sender
{
//    if (settingPopover.isPopoverVisible) {
//        [settingPopover dismissPopoverAnimated:YES];
//    }
//    else
//    {
//        SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
//        settingPopover = [[UIPopoverController alloc] initWithContentViewController:settingsViewController];
//        [settingPopover setPopoverContentSize:CGSizeMake(320, 480) animated:YES];
//        [settingPopover presentPopoverFromRect:CGRectMake(630, 0, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//        [settingsViewController release];
//    }
    if (!settingViewVisible) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        [settingView setFrame:CGRectMake(settingView.frame.origin.x - 320, settingView.frame.origin.y, settingView.frame.size.width, settingView.frame.size.height)];
        settingViewVisible = YES;
        [UIView commitAnimations];
    }
    else
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        [settingView setFrame:CGRectMake(settingView.frame.origin.x + 320, settingView.frame.origin.y, settingView.frame.size.width, settingView.frame.size.height)];
        settingViewVisible = NO;
        [UIView commitAnimations];
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Patients", @"Patients");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
