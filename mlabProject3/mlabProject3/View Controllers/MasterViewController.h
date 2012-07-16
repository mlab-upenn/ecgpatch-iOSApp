//
//  MasterViewController.h
//  test
//
//  Created by Abhijeet Mulay on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController
{
    NSMutableDictionary *patientsDict;

}
-(void)setupData;
@property (strong, nonatomic) DetailViewController *detailViewController;

@end
