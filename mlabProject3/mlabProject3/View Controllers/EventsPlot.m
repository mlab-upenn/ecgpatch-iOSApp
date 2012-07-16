//
//  EventsPlot.m
//  mlabProject3
//
//  Created by Abhijeet Mulay on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventsPlot.h"
const NSUInteger kMaxEventDataPoints = 100;
@implementation EventsPlot

@synthesize eventsGraph, eventsPlotView, eventData;

-(id)initWithEventPlotView:(CPTGraphHostingView *)eventPlot 
{
    self = [super init];
    
    if ( self != nil ) 
    {
        self.eventsPlotView = eventPlot;
        currentIndex = 0;
        //self.eventData = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)setupData
{
    ///HR data......////////////////////////////
    
    NSArray *data = [NSArray array];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"logged_cardiac_data_1" ofType:@"txt"];  
    NSString *dataString = [NSString stringWithContentsOfFile:filePath usedEncoding:nil error:nil];
    data = [dataString componentsSeparatedByString:@" "];
    self.eventData = [[NSMutableArray alloc] initWithArray:data];
    for (int i = 0; i< [self.eventData count]; i++) {
        NSString *temp = [self.eventData objectAtIndex:i];
        temp = [(NSString*)temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSNumber *dataPt = [NSNumber numberWithDouble:[temp doubleValue]];
        [self.eventData replaceObjectAtIndex:i withObject:dataPt];
        
    }
}

-(void)initialisePlot
{
    //Call indivisual plots
    [self initialiseEventPlot];
    
}

-(void)initialiseEventPlot
{
    // Start with some simple sanity checks before we kick off
    if ( (self.eventsPlotView == nil) || (self.eventData == nil) ) {
        NSLog(@"TUTSimpleScatterPlot: Cannot initialise plot without hosting view or data.");
        return;
    }
    
    if ( self.eventsGraph != nil ) {
        NSLog(@"TUTSimpleScatterPlot: Graph object already exists.");
        return;
    }
    
    // Create a graph object which we will use to host just one scatter plot.
    CGRect frame = [self.eventsPlotView bounds];
    self.eventsGraph = [[[CPTXYGraph alloc] initWithFrame:frame] autorelease];
    
    // Add some padding to the graph, with more at the bottom for axis labels.
    self.eventsGraph.plotAreaFrame.paddingTop = 10.0f;
    self.eventsGraph.plotAreaFrame.paddingRight = 10.0f;
    self.eventsGraph.plotAreaFrame.paddingBottom = 5.0f;
    self.eventsGraph.plotAreaFrame.paddingLeft = 10.0f;
    
	// Tie the graph we've created with the hosting view.
    self.eventsPlotView.hostedGraph = self.eventsGraph;
    
    // If you want to use one of the default themes - apply that here.
	//[self.eventsGraph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
	
	// Create a line style that we will apply to the axis and data line.
	CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
	lineStyle.lineColor = [CPTColor redColor];
	lineStyle.lineWidth = 4.0f;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineColor = [CPTColor clearColor];
	axisLineStyle.lineWidth = 2.0f;
	
    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];
	
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.1];    
    
    // Create a text style that we will use for the axis labels.
	CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
	textStyle.fontName = @"Helvetica";
	textStyle.fontSize = 14;
	textStyle.color = [CPTColor clearColor];
	
    // Create the plot symbol we're going to use.
//    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol crossPlotSymbol];
//    plotSymbol.lineStyle = lineStyle;
//    plotSymbol.size = CGSizeMake(1.0, 1.0); 	
	
    // Setup some floats that represent the min/max values on our axis.
    //float xAxisMin = -10;
    //float xAxisMax = 10;
    float yAxisMin = -70;
    float yAxisMax = 70;
    
	// We modify the graph's plot space to setup the axis' min / max values.
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.eventsGraph.defaultPlotSpace;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(kMaxEventDataPoints - 1)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yAxisMin) length:CPTDecimalFromFloat(yAxisMax - yAxisMin)];
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
    // Modify the graph's axis with a label, line style, etc.
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.eventsGraph.axisSet;
	
	axisSet.xAxis.title = @"Time";
	axisSet.xAxis.titleTextStyle = textStyle;
	axisSet.xAxis.titleOffset = 30.0f;
	axisSet.xAxis.axisLineStyle = axisLineStyle;
	axisSet.xAxis.majorTickLineStyle = axisLineStyle;
	axisSet.xAxis.minorTickLineStyle = axisLineStyle;
	axisSet.xAxis.labelTextStyle = textStyle;
	axisSet.xAxis.labelOffset = 3.0f;	
	axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(5.0f);
	axisSet.xAxis.minorTicksPerInterval = 1;
	axisSet.xAxis.minorTickLength = 5.0f;
	axisSet.xAxis.majorTickLength = 7.0f;
    axisSet.xAxis.majorGridLineStyle = majorGridLineStyle;
    axisSet.xAxis.minorGridLineStyle = minorGridLineStyle;
	
	axisSet.yAxis.title = @"Data x 100";
	axisSet.yAxis.titleTextStyle = textStyle;	
	axisSet.yAxis.titleOffset = 40.0f;	
	axisSet.yAxis.axisLineStyle = axisLineStyle;	
	axisSet.yAxis.majorTickLineStyle = axisLineStyle;
	axisSet.yAxis.minorTickLineStyle = axisLineStyle;
	axisSet.yAxis.labelTextStyle = textStyle;	
	axisSet.yAxis.labelOffset = 3.0f;	
	axisSet.yAxis.majorIntervalLength = CPTDecimalFromFloat(10.0f);
	axisSet.yAxis.minorTicksPerInterval = 1;
	axisSet.yAxis.minorTickLength = 5.0f;
	axisSet.yAxis.majorTickLength = 7.0f;	
	axisSet.yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    axisSet.yAxis.majorGridLineStyle = majorGridLineStyle;
    axisSet.yAxis.minorGridLineStyle = minorGridLineStyle;
    
	// Add a plot to our graph and axis. We give it an identifier so that we 
	// could add multiple plots (data lines) to the same graph if necessary.
	CPTScatterPlot *plot = [[[CPTScatterPlot alloc] init] autorelease];
	plot.dataSource = self;
	plot.identifier = @"eventPlot";
	plot.dataLineStyle = lineStyle;
	//plot.plotSymbol = plotSymbol;
    eventPlotRef = plot;
	[self.eventsGraph addPlot:plot];	
    
    // Add plot symbols
//    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
//    symbolLineStyle.lineColor = [CPTColor blackColor];
//    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
//    plotSymbol.fill = [CPTFill fillWithColor:[CPTColor blueColor]];
//    plotSymbol.lineStyle = symbolLineStyle;
//    plotSymbol.size = CGSizeMake(10.0, 10.0);
//    plot.plotSymbol = plotSymbol;
//    
//    // Set plot delegate, to know when symbols have been touched
//    // We will display an annotation when a symbol is touched
      plot.delegate = self; 
//    plot.plotSymbolMarginForHitDetection = 5.0f;

}
// Delegate method that returns the number of points on the plot
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot 
{
	if ( [plot.identifier isEqual:@"eventPlot"] ) 
	{
        return [self.eventData count];
	} 
   	return 0;
}

// Delegate method that returns a single X or Y value for a given plot.
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{
    
    NSNumber *num = nil;
    if (index == 10) 
    {
        CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
        symbolLineStyle.lineColor = [CPTColor blackColor];
        CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        plotSymbol.fill = [CPTFill fillWithColor:[CPTColor blueColor]];
        plotSymbol.lineStyle = symbolLineStyle;
        plotSymbol.size = CGSizeMake(10.0, 10.0);
        eventPlotRef.plotSymbol = plotSymbol;
        
        // Set plot delegate, to know when symbols have been touched
        // We will display an annotation when a symbol is touched
        eventPlotRef.delegate = self; 
        eventPlotRef.plotSymbolMarginForHitDetection = 5.0f;
    }
    else
    {
        eventPlotRef.plotSymbol = nil;
    }
    if ( [plot.identifier isEqual:@"eventPlot"] ) 
	{
        switch ( fieldEnum ) {
            case CPTScatterPlotFieldX:
                num = [NSNumber numberWithDouble:index];
                break;
                
            case CPTScatterPlotFieldY:
                num = [self.eventData objectAtIndex:index];
                double temp = [num doubleValue];
                temp = temp/100;
                num = [NSNumber numberWithDouble:temp];
                break;
                
            default:
                break;
        }
        
	}     return num;
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldScaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint
{
    return YES;
}

//-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
//{
//    // Impose a limit on how far user can scroll in x
//    if (coordinate == CPTCoordinateX) {
//        CPTPlotRange *maxRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0f) length:CPTDecimalFromFloat(6.0f)];
//        CPTPlotRange *changedRange = [[newRange copy] autorelease];
//        [changedRange shiftEndToFitInRange:maxRange];
//        [changedRange shiftLocationToFitInRange:maxRange];
//        newRange = changedRange;
//    }
//    
//    return newRange;
//}


#pragma mark -
#pragma mark CPTScatterPlot delegate method


-(CPTPlotSymbol *)plotSymbolForRecordIndex:(NSUInteger)index
{
    // Add plot symbols
    
    if (index == 20) 
    {
        CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
        symbolLineStyle.lineColor = [CPTColor blackColor];
        CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        plotSymbol.fill = [CPTFill fillWithColor:[CPTColor blueColor]];
        plotSymbol.lineStyle = symbolLineStyle;
        plotSymbol.size = CGSizeMake(10.0, 10.0);
        eventPlotRef.plotSymbol = plotSymbol;
        
        // Set plot delegate, to know when symbols have been touched
        // We will display an annotation when a symbol is touched
        eventPlotRef.delegate = self; 
        eventPlotRef.plotSymbolMarginForHitDetection = 5.0f;
        return plotSymbol;
    }
    return nil;
}

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    CPTXYGraph *graph;
    graph = self.eventsGraph;
    if (symbolTextAnnotation) {
        [graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
        [symbolTextAnnotation release];
        symbolTextAnnotation = nil;
    }
    
    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color = [CPTColor blackColor];
    hitAnnotationTextStyle.fontSize = 16.0f;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    
    // Determine point of symbol in plot coordinates
    NSNumber *x = [NSNumber numberWithDouble:index];
    NSNumber *y ;
    y = [self.eventData objectAtIndex:index];
    double temp = [y doubleValue];
    temp = temp/100;
    y = [NSNumber numberWithDouble:temp];
    NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
    
    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:y];
    
    // Now add the annotation to the plot area
    CPTTextLayer *textLayer = [[[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle] autorelease];
    symbolTextAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:graph.defaultPlotSpace anchorPlotPoint:anchorPoint];
    symbolTextAnnotation.contentLayer = textLayer;
    symbolTextAnnotation.displacement = CGPointMake(0.0f, 20.0f);
    [graph.plotAreaFrame.plotArea addAnnotation:symbolTextAnnotation];    
}


-(void)dealloc
{
    self.eventData = nil;
    self.eventsGraph = nil;
    self.eventsPlotView = nil;
    [super dealloc];
}
@end
