//
//  EventsViewController.h
//  mlabProject3
//
//  Created by Abhijeet Mulay on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "EventsPlot.h"
@interface EventsViewController : UITableViewController
{
    DetailViewController *detailViewController;
    NSString *patientName;
    EventsPlot *eventPlot;
    IBOutlet UIView *backButtonView;
}
@property (nonatomic,retain) NSString *patientName;
@property (nonatomic,retain) DetailViewController *detailViewController;

@end
