//
//  EventsPlot.h
//  mlabProject3
//
//  Created by Abhijeet Mulay on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*******************************************************************************
 * Not Used
 *******************************************************************************/

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"
@interface EventsPlot : NSObject< CPTPlotSpaceDelegate,CPTPlotDataSource,CPTScatterPlotDelegate>
{
    CPTGraphHostingView *eventsPlotView;
    CPTXYGraph *eventsGraph;
    CPTLayerAnnotation   *symbolTextAnnotation;
    CPTScatterPlot *eventPlotRef;
    NSUInteger currentIndex;
    NSMutableArray *eventData;
}
-(id)initWithEventPlotView:(CPTGraphHostingView *)eventPlot ;
-(void)setupData;
-(void)initialisePlot;
-(void)initialiseEventPlot;
@property(nonatomic, retain) CPTGraphHostingView *eventsPlotView;
@property(nonatomic, retain) CPTXYGraph *eventsGraph;
@property(nonatomic, retain) NSMutableArray *eventData;
@end
