//
//  MasterViewController.m
//  test
//
//  Created by Abhijeet Mulay on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "EventsViewController.h"
#import "AppDelegate.h"
#import "Patient.h"

#define kRowHeight 60.0f

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Patients", @"Patients");
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)dealloc
{
    [_detailViewController release];
    [patientsDict release];
    [super dealloc];
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
    //[self setupData];
    
    /***********************************************************************
     * Dummy Patients Namr to be displayed 
     **********************************************************************/  

    patientsDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"logged_cardiac_data_1",@"Jennifer",@"Rahul",@"Sam",@"rajib",@"John",@"logged_cardiac_data_1",@"Christopher",@"logged_cardiac_data_1",@"Sylvia" ,nil];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
   
    self.tabBarController.tabBarItem.title = @"Patients";
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

-(void)setupData
{
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Patient" 
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (Patient  *patient in fetchedObjects) {
        NSLog(@"Name: %@", patient.name);
        NSLog(@"fileName: %@", patient.fileName);
    }        
    [fetchRequest release];
}

#pragma mark - TableView datasource


// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [patientsDict count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRowHeight;  
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableViewCellBackground.png"]];
    [cell setBackgroundView:imageView];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    NSArray *names = [patientsDict allKeys];
    cell.textLabel.text = [names objectAtIndex:indexPath.row];
    [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
    switch (indexPath.row)
    {
        case 0:
            cell.imageView.image = [UIImage imageNamed:@"green.png"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Heart Rate: 76"];
            break;
        case 1:
            cell.imageView.image = [UIImage imageNamed:@"yellow.png"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Heart Rate: 90"];
            break;
        case 2:
            cell.imageView.image = [UIImage imageNamed:@"red.png"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Heart Rate: 120"];
            break;

        default:
            cell.imageView.image = [UIImage imageNamed:@"green.png"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Heart Rate: 72"];
            break;
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - TableView delegate

/***********************************************************************
 * Events View is called on tapping the blue accesory button...
 **********************************************************************/  

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSArray *names = [patientsDict allKeys];
    EventsViewController *eventsViewController = [[EventsViewController alloc]initWithNibName:@"EventsViewController" bundle:nil];
    [eventsViewController setDetailViewController:self.detailViewController];
    [eventsViewController setPatientName:[names objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:eventsViewController animated:YES];
    [eventsViewController release];
    self.detailViewController.view.backgroundColor = [UIColor whiteColor];
}

/*******************************************************************************
 * Selecting a particular patient refreshes the detail screen with patient feed
 *******************************************************************************/ 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailViewController) 
    {
        self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil] autorelease];
    }
    
    NSArray *fileNames = [patientsDict allValues]; 
    [self.detailViewController setFileName:[fileNames objectAtIndex:indexPath.row]];
    
    NSArray *names = [patientsDict allKeys];
    [self.detailViewController setPatientName:[names objectAtIndex:indexPath.row]];
    [self.detailViewController.scatterPlot invalidateTimers];
    [self.detailViewController viewWillAppear:YES];
    [self.detailViewController.scatterPlot resetIndices];
   
    
}

@end
