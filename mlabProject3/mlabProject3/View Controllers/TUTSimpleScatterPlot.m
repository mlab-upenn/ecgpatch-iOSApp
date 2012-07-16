//
//  TUTSimpleScatterPlot.m
//  Core Plot Introduction
//
//  Created by John Wordsworth on 20/10/2011.
//

#import "TUTSimpleScatterPlot.h"
#import "DetailViewController.h"
const double kFrameRate = 40;	// frames per second
const double kAlpha = 0.25;		// smoothing constant
const NSUInteger kMaxDataPoints = 100;
const NSUInteger kMaxECGDataPoints = 300;
const NSUInteger kMaxSpo2DataPoints = 200;
#define X_VAL @"X_VAL"
#define Y_VAL @"Y_VAL"

@implementation TUTSimpleScatterPlot

@synthesize graph = _graph;
@synthesize graphData = _graphData;
@synthesize pieChartData = _pieChartData;
@synthesize ecgView = _ecgView;
@synthesize pulsifierView = _pulsifierView;
@synthesize pieChartView = _pieChartView;
@synthesize ecgData = _ecgData;
@synthesize pulsifierData = _pulsifierData;
@synthesize pulsifierGraph = _pulsifierGraph;
@synthesize pieChartGraph = _pieChartGraph;
@synthesize spo2Label = _spo2Label;
@synthesize bpmLabel = _bpmLabel;
@synthesize hrTimer,ecgTimer,spO2Timer,spO2PlotTimer;
@synthesize detailViewController, barGraph, barChartView;

-(id)initWithEcgView:(CPTGraphHostingView *)ecgView pulsifierView:(CPTGraphHostingView *)pulsifierView pieChartView:(CPTGraphHostingView *)pieChartView spo2Label:(UILabel *)spo2Label bpmLabel:(UILabel *)bpmLabel andData:(NSMutableArray *)data
{
    self = [super init];
    
    if ( self != nil ) 
    {
        self.ecgView = ecgView;
        self.pieChartView = pieChartView;
        self.pulsifierView = pulsifierView;
        self.graphData = [[NSMutableArray alloc] initWithCapacity:kMaxECGDataPoints];
        self.pieChartData = [[NSMutableArray alloc] init];
        self.ecgData = [[NSMutableArray alloc] initWithCapacity:kMaxECGDataPoints];
        self.pulsifierData = [[NSMutableArray alloc] initWithCapacity:kMaxDataPoints];
        self.graph = nil;
        isRefreshing = NO;
        self.spo2Label = spo2Label;
        self.bpmLabel = bpmLabel;
    }
    
    return self;
}

/*******************************************************************************
 * Pull data from Txt files and store them in arrays to be plotted on graph
 *******************************************************************************/

-(void)setupData:(NSString *)fileName
{
    spo2Count = 0;
    hrCount = 0;
    //Make dynamic depending upon the data recieved....Abhijeet
    
    //SPO2 waveform data ....////////////////////////////
    
    
    /********************************************
     read from text file, parse the values,
     get rid on /n and spaces and store data in array
    **********************************************/
     
    [self.pulsifierData removeAllObjects];
    NSArray *pulsifierData = [NSArray array];
    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"spo2wav" ofType:@"txt"];  
    NSString *dataString2 = [NSString stringWithContentsOfFile:filePath2 usedEncoding:nil error:nil];
    pulsifierData = [dataString2 componentsSeparatedByString:@" "];
    dataArray2 = [[NSMutableArray alloc] initWithArray:pulsifierData];
    for (int i = 0; i< [dataArray2 count]; i++) {
        NSString *temp = [dataArray2 objectAtIndex:i];
        temp = [(NSString*)temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSNumber *dataPt = [NSNumber numberWithDouble:[temp doubleValue]];
        [dataArray2 replaceObjectAtIndex:i withObject:dataPt];
        
    }
    
    ///HR data......////////////////////////////
    
    [self.ecgData removeAllObjects];
    NSArray *data = [NSArray array];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"logged_cardiac_data_1" ofType:@"txt"];  
    NSString *dataString = [NSString stringWithContentsOfFile:filePath usedEncoding:nil error:nil];
    data = [dataString componentsSeparatedByString:@" "];
    dataArray = [[NSMutableArray alloc] initWithArray:data];
    for (int i = 0; i< [dataArray count]; i++) {
        NSString *temp = [dataArray objectAtIndex:i];
        temp = [(NSString*)temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSNumber *dataPt = [NSNumber numberWithDouble:[temp doubleValue]];
        [dataArray replaceObjectAtIndex:i withObject:dataPt];
        
    }
    
    //Spo2 data.... ////////////////////////////
    NSArray *tempDataArray = [NSArray array];
    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"hr_data" ofType:@"txt"];  
    NSString *dataString1 = [NSString stringWithContentsOfFile:filePath1 usedEncoding:nil error:nil];
    tempDataArray = [dataString1 componentsSeparatedByString:@" "];
    spO2Data = [[NSMutableArray alloc] initWithArray:tempDataArray];
    
    for (int i = 0; i< [tempDataArray count]; i++) {
        NSString *temp = [tempDataArray objectAtIndex:i];
        temp = [(NSString*)temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        [spO2Data replaceObjectAtIndex:i withObject:temp];
        
    }
    
    NSArray *tempDataArray2 = [NSArray array];
    NSString *filePath3 = [[NSBundle mainBundle] pathForResource:@"spo2" ofType:@"txt"];  
    NSString *dataString3 = [NSString stringWithContentsOfFile:filePath3 usedEncoding:nil error:nil];
    tempDataArray2 = [dataString3 componentsSeparatedByString:@" "];
    hrData = [[NSMutableArray alloc] initWithArray:tempDataArray2];
    
    for (int i = 0; i< [tempDataArray2 count]; i++) {
        NSString *temp1 = [tempDataArray2 objectAtIndex:i];
        temp1 = [(NSString*)temp1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        [hrData replaceObjectAtIndex:i withObject:temp1];
        
    }

    
	currentIndex = 0;
    dummyIndex = 0;
    spo2Index = 0;
    dummySpoIndex = 0;

}

-(void)resetIndices
{
    currentIndex = 0;
    spo2Index = 0;
}


/*******************************************************************************
 * stop timers 
 *******************************************************************************/

-(void)invalidateTimers
{
    [self.ecgTimer invalidate];
    [self.ecgTimer release];
    self.ecgTimer = nil;
    [self.spO2Timer invalidate];
    [self.spO2Timer release];
    self.spO2Timer = nil;
    [self.spO2PlotTimer invalidate];
    [self.spO2PlotTimer release];
    self.spO2PlotTimer = nil;
    [self.hrTimer invalidate];
    [self.hrTimer release];
    self.hrTimer = nil;
}

/*******************************************************************************
 * start timers
 *******************************************************************************/

-(void)fireTimers
{
    if (self.ecgTimer) 
        [self.ecgTimer release];
    if (self.hrTimer) 
        [self.hrTimer release];
    if (self.spO2Timer) 
        [self.spO2Timer release];
    if (self.spO2PlotTimer) 
        [self.spO2PlotTimer release];
    self.ecgTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0/kFrameRate 
                                                 target:self 
                                               selector:@selector(updateData:) 
                                               userInfo:nil repeats:YES] retain];
    self.spO2Timer = [[NSTimer scheduledTimerWithTimeInterval:2.0 
                                                  target:self 
                                                selector:@selector(updateSpo2Data:) 
                                                userInfo:nil repeats:YES] retain];
    self.hrTimer = [[NSTimer scheduledTimerWithTimeInterval:2.5
                                                target:self 
                                              selector:@selector(updateHeartRate:)
                                              userInfo:nil repeats:YES] retain];
    self.spO2PlotTimer = [[NSTimer scheduledTimerWithTimeInterval:1.5/kFrameRate
                                                target:self 
                                              selector:@selector(updateSpO2Plot:)
                                              userInfo:nil repeats:YES] retain];

    
    //[[NSRunLoop mainRunLoop] addTimer:spO2Timer forMode:NSDefaultRunLoopMode];
    
}

/*******************************************************************************
 * setup timers.....
 @param filename: txt file name
 *******************************************************************************/

-(void)setTimerToPlot:(NSString *)fileName
{
    [self setupData:fileName];
    [self fireTimers];
    
    //NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"ekg1" ofType:@"m4a"];
    //ekgAudio = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:nil] retain];
    //[ekgAudio play];
}

/*******************************************************************************
 Setup Plots
 *******************************************************************************/

// This does the actual work of creating the plot if we don't already have a graph object.
-(void)initialisePlot
{
    //Call indivisual plots
    [self initialiseEcgPlot];
    [self initialisePulsifierPlot];
    //[self initialisePieChartPlot];
    [self initialiseBarPlot];
}

/*******************************************************************************
 Dummy data for Bar graph...
 *******************************************************************************/

-(void) generateDataSamples
{
	int rawSamples [] = {1,2,3,2,1};
	int numSamples = sizeof(rawSamples) / sizeof(int);
	
	samples = [[NSMutableArray alloc] initWithCapacity:numSamples];
	
	for (int i = 0; i < numSamples; i++){
		double x = i;
		double y = rawSamples[i];
		NSDictionary *sample = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithDouble:x],X_VAL,
								[NSNumber numberWithDouble:y],Y_VAL,
								nil];
		[samples addObject:sample];
	}	
}

-(void)initialiseBarPlot
{
    [self generateDataSamples];
    double xAxisStart = 0;
	double xAxisLength = [samples count];
	
	double yAxisStart = 1;
	double yAxisLength = [[samples valueForKeyPath:@"@max.Y_VAL"] doubleValue];
	
	
    
	self.barGraph = [[CPTXYGraph alloc] initWithFrame:self.barChartView.bounds];
	self.barChartView.hostedGraph = self.barGraph;
	
	
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.barGraph.defaultPlotSpace;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xAxisStart)
												   length:CPTDecimalFromDouble(xAxisLength+1)];
	
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(yAxisStart)
												   length:CPTDecimalFromDouble(yAxisLength)];	
	
	CPTBarPlot *plot = [[CPTBarPlot alloc] initWithFrame:CGRectZero];
	plot.plotRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0)
												 length:CPTDecimalFromDouble(xAxisLength)];
    plot.paddingBottom = 10;
	plot.dataSource = self;
    plot.fill = [CPTFill fillWithColor:[CPTColor greenColor]];
	//plot.barBasesVary = YES;
    plot.barWidth = CPTDecimalFromFloat(0.3f); // bar is 50% of the available space
	plot.barCornerRadius = 5.0f;
    plot.barsAreHorizontal = YES;
	[self.barGraph addPlot:plot];
	
	[plot release];
	
}

-(void)initialiseEcgPlot
{
    
    // Start with some simple sanity checks before we kick off
    if ( (self.ecgView == nil) || (self.ecgData == nil) ) {
        NSLog(@"TUTSimpleScatterPlot: Cannot initialise plot without hosting view or data.");
        return;
    }
    
    if ( self.graph != nil ) {
        NSLog(@"TUTSimpleScatterPlot: Graph object already exists.");
        return;
    }
    
    // Create a graph object which we will use to host just one scatter plot.
    CGRect frame = [self.ecgView bounds];
    self.graph = [[[CPTXYGraph alloc] initWithFrame:frame] autorelease];
    
    // Add some padding to the graph, with more at the bottom for axis labels.
    self.graph.plotAreaFrame.paddingTop = 10.0f;
    self.graph.plotAreaFrame.paddingRight = 10.0f;
    self.graph.plotAreaFrame.paddingBottom = 5.0f;
    self.graph.plotAreaFrame.paddingLeft = 10.0f;
    
	// Tie the graph we've created with the hosting view.
    self.ecgView.hostedGraph = self.graph;
    
    // If you want to use one of the default themes - apply that here.
	//[self.graph applyTheme:[CPTTheme themeNamed:kCPTSlateTheme]];
	
	// Create a line style that we will apply to the axis and data line.
	CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
	lineStyle.lineColor = [CPTColor greenColor];
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
    minorGridLineStyle.lineColor = [[CPTColor grayColor] colorWithAlphaComponent:0.7];    
    
    // Create a text style that we will use for the axis labels.
	CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
	textStyle.fontName = @"Helvetica";
	textStyle.fontSize = 14;
	textStyle.color = [CPTColor clearColor];
	
    // Create the plot symbol we're going to use.
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol crossPlotSymbol];
    plotSymbol.lineStyle = lineStyle;
    plotSymbol.size = CGSizeMake(1.0, 1.0); 	
	
    // Setup some floats that represent the min/max values on our axis.
    //float xAxisMin = -10;
    //float xAxisMax = 10;
    float yAxisMin = -70;
    float yAxisMax = 70;
    
	// We modify the graph's plot space to setup the axis' min / max values.
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(kMaxECGDataPoints - 1)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yAxisMin) length:CPTDecimalFromFloat(yAxisMax - yAxisMin)];
    
    // Modify the graph's axis with a label, line style, etc.
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
	
	axisSet.xAxis.title = @"Time";
	axisSet.xAxis.titleTextStyle = textStyle;
	axisSet.xAxis.titleOffset = 30.0f;
	axisSet.xAxis.axisLineStyle = axisLineStyle;
	axisSet.xAxis.majorTickLineStyle = axisLineStyle;
	axisSet.xAxis.minorTickLineStyle = axisLineStyle;
	axisSet.xAxis.labelTextStyle = textStyle;
	axisSet.xAxis.labelOffset = 3.0f;	
	axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(5.0f);
	axisSet.xAxis.minorTicksPerInterval = 4;
	axisSet.xAxis.minorTickLength = 5.0f;
	axisSet.xAxis.majorTickLength = 7.0f;
    axisSet.xAxis.majorGridLineStyle = nil;
    axisSet.xAxis.minorGridLineStyle = nil;
	
	axisSet.yAxis.title = @"Data x 100";
	axisSet.yAxis.titleTextStyle = textStyle;	
	axisSet.yAxis.titleOffset = 40.0f;	
	axisSet.yAxis.axisLineStyle = axisLineStyle;	
	axisSet.yAxis.majorTickLineStyle = axisLineStyle;
	axisSet.yAxis.minorTickLineStyle = axisLineStyle;
	axisSet.yAxis.labelTextStyle = textStyle;	
	axisSet.yAxis.labelOffset = 3.0f;	
	axisSet.yAxis.majorIntervalLength = CPTDecimalFromFloat(5.0f);
	axisSet.yAxis.minorTicksPerInterval = 4;
	axisSet.yAxis.minorTickLength = 5.0f;
	axisSet.yAxis.majorTickLength = 7.0f;	
	axisSet.yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    axisSet.yAxis.majorGridLineStyle = nil;
    axisSet.yAxis.minorGridLineStyle = nil;
    
	// Add a plot to our graph and axis. We give it an identifier so that we 
	// could add multiple plots (data lines) to the same graph if necessary.
	CPTScatterPlot *plot = [[[CPTScatterPlot alloc] init] autorelease];
	plot.dataSource = self;
	plot.identifier = @"ecgPlot";
    plot.doubleSided = NO;
	plot.dataLineStyle = lineStyle;
	plot.plotSymbol = plotSymbol;
	[self.graph addPlot:plot];	

}

-(void)initialisePulsifierPlot
{
    // Start with some simple sanity checks before we kick off
    if ( (self.pulsifierView == nil) || (self.pulsifierData == nil) ) {
        NSLog(@"TUTSimpleScatterPlot: Cannot initialise plot without hosting view or data.");
        return;
    }
    
    if ( self.pulsifierGraph != nil ) {
        NSLog(@"TUTSimpleScatterPlot: Graph object already exists.");
        return;
    }
    
    // Create a graph object which we will use to host just one scatter plot.
    CGRect frame = [self.pulsifierView bounds];
    self.pulsifierGraph = [[[CPTXYGraph alloc] initWithFrame:frame] autorelease];
    
    // Add some padding to the graph, with more at the bottom for axis labels.
    self.pulsifierGraph.plotAreaFrame.paddingTop = 10.0f;
    self.pulsifierGraph.plotAreaFrame.paddingRight = 10.0f;
    self.pulsifierGraph.plotAreaFrame.paddingBottom = 15.0f;
    self.pulsifierGraph.plotAreaFrame.paddingLeft = 10.0f;
    
	// Tie the graph we've created with the hosting view.
    self.pulsifierView.hostedGraph = self.pulsifierGraph;
    
    // If you want to use one of the default themes - apply that here.
	//[self.pulsifierGraph applyTheme:[CPTTheme themeNamed:kCPTSlateTheme]];
	
	// Create a line style that we will apply to the axis and data line.
	CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
	lineStyle.lineColor = [CPTColor greenColor];
	lineStyle.lineWidth = 4.0f;
	
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineColor = [CPTColor clearColor];
	axisLineStyle.lineWidth = 2.0f;
    
    // Create a text style that we will use for the axis labels.
	CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
	textStyle.fontName = @"Helvetica";
	textStyle.fontSize = 14;
	textStyle.color = [CPTColor clearColor];
	
    // Create the plot symbol we're going to use.
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol crossPlotSymbol];
    plotSymbol.lineStyle = lineStyle;
    plotSymbol.size = CGSizeMake(1.0, 1.0); 	
	
    // Setup some floats that represent the min/max values on our axis.
    //float xAxisMin = -10;
    //float xAxisMax = 10;
    float yAxisMin = -40;
    float yAxisMax = 80;
    
	// We modify the graph's plot space to setup the axis' min / max values.
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.pulsifierGraph.defaultPlotSpace;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(kMaxDataPoints - 1)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yAxisMin) length:CPTDecimalFromFloat(yAxisMax - yAxisMin)];
    
    // Modify the graph's axis with a label, line style, etc.
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.pulsifierGraph.axisSet;
	
	axisSet.xAxis.title = @"Time";
	axisSet.xAxis.titleTextStyle = textStyle;
	axisSet.xAxis.titleOffset = 30.0f;
	axisSet.xAxis.axisLineStyle = axisLineStyle;
	axisSet.xAxis.majorTickLineStyle = axisLineStyle;
	axisSet.xAxis.minorTickLineStyle = axisLineStyle;
	axisSet.xAxis.labelTextStyle = textStyle;
	axisSet.xAxis.labelOffset = 3.0f;	
	axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(10.0f);
	axisSet.xAxis.minorTicksPerInterval = 1;
	axisSet.xAxis.minorTickLength = 5.0f;
	axisSet.xAxis.majorTickLength = 7.0f;
	
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
    
    
	// Add a plot to our graph and axis. We give it an identifier so that we 
	// could add multiple plots (data lines) to the same graph if necessary.
	CPTScatterPlot *plot = [[[CPTScatterPlot alloc] init] autorelease];
	plot.dataSource = self;
	plot.identifier = @"pulsifierPlot";
	plot.dataLineStyle = lineStyle;
	plot.plotSymbol = plotSymbol;
    plot.doubleSided = NO;
	[self.pulsifierGraph addPlot:plot];	
   
}

-(void)initialisePieChartPlot
{

    //UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        [_pieChartView setFrame:CGRectMake(200, 310, 300, 300)];
    }
    self.pieChartGraph = [[CPTXYGraph alloc] initWithFrame:[self.pieChartView bounds]];
    //[self addGraph:pieChart toHostingView:self.hostingView];
    //[self applyTheme:theme toGraph:pieChart withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.pieChartView.hostedGraph = self.pieChartGraph;
    self.pieChartGraph.plotAreaFrame.masksToBorder = NO;
    
    [self setPaddingDefaultsForGraph:self.pieChartGraph withBounds:[self.pieChartView bounds]];
    
    self.pieChartGraph.axisSet = nil;
    
    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius = MIN(0.6 * (self.pieChartView.frame.size.height - 2 * self.pieChartGraph.paddingLeft) / 2.0,
                            0.6 * (self.pieChartView.frame.size.width - 2 * self.pieChartGraph.paddingTop) / 2.0);
    piePlot.identifier = @"Pie Chart 1";
    piePlot.startAngle = M_PI_4;
    piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
    piePlot.borderLineStyle = [CPTLineStyle lineStyle];
    //piePlot.sliceLabelOffset = 5.0;
    [self.pieChartGraph addPlot:piePlot];
    [piePlot release];
    
    // Add some initial data
    NSMutableArray *contentArray = [NSMutableArray arrayWithObjects:
                                    [NSNumber numberWithDouble:40.0],
                                    [NSNumber numberWithDouble:10.0],
                                    [NSNumber numberWithDouble:60.0],
                                    nil];
    self.pieChartData = contentArray;	
   
}

- (void)setPaddingDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds
{
    float boundsPadding = round(bounds.size.width / 20.0f); // Ensure that padding falls on an integral pixel
    graph.paddingLeft = boundsPadding;
    
    if (graph.titleDisplacement.y > 0.0) {
        graph.paddingTop = graph.titleDisplacement.y * 2;
    }
    else {
        graph.paddingTop = boundsPadding;
    }
    
    graph.paddingRight = boundsPadding;
    graph.paddingBottom = boundsPadding;    
}


#pragma mark -
#pragma mark Timer callback

/*******************************************************************************
 SPO2 label update method for ECG signal...
 Alarm is set off if the value reads above the set threshold..
 *******************************************************************************/


-(void)updateSpo2Data:(NSTimer *)theTimer
{
    NSError *error;
    NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"smokealarm" ofType:@"wav"];
    AVAudioPlayer* theAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:&error];
//    
    if (spo2Count > 230) {
        spo2Count = 0;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    self.spo2Label.alpha = 0.3;
    self.spo2Label.text = [NSString stringWithFormat:@"%@",[hrData objectAtIndex:spo2Count] ];
    if (/*[self.spo2Label.text isEqualToString:@"94"]||*/[self.spo2Label.text isEqualToString:[NSString stringWithFormat:@"%d",[self.detailViewController.spo2AlarmValue intValue]]]) {
        self.spo2Label.textColor = [UIColor redColor];
        if ((![theAudio isPlaying]) && (!self.detailViewController.spo2Alarm.hidden)) 
            [theAudio play];
    }
    else
    {
        self.spo2Label.textColor = [UIColor greenColor];
        if ([theAudio isPlaying]) 
            [theAudio stop];
    }
    if (error) {
        NSLog(@"Error in audioPlayer: %@", 
              [error localizedDescription]);
    }
    self.spo2Label.alpha = 1;
    [UIView commitAnimations];
    spo2Count++;
    
}

/*******************************************************************************
 BPM value is updated...
 currently read from a file but needs to calculated based on data...
 *******************************************************************************/


-(void)updateHeartRate:(NSTimer *)theTimer
{
//    NSError *error;
//    NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"smokealarm" ofType:@"wav"];
//    AVAudioPlayer* theAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:&error];
    
    if (hrCount > 230) {
        hrCount = 0;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    self.bpmLabel.alpha = 0.3;
    self.bpmLabel.text = [NSString stringWithFormat:@"%@",[spO2Data objectAtIndex:hrCount] ];
    if ([self.bpmLabel.text isEqualToString:@"94"]||[self.bpmLabel.text isEqualToString:@"100"]) {
        self.bpmLabel.textColor = [UIColor redColor];
        //[theAudio play];
    }
    else
    {
        self.bpmLabel.textColor = [UIColor greenColor];
        //[theAudio stop];
    }
//    if (error) {
//        NSLog(@"Error in audioPlayer: %@", 
//              [error localizedDescription]);
//    }
    self.bpmLabel.alpha = 1;
    [UIView commitAnimations];
    hrCount++;
    
}


/*******************************************************************************
 Pie chart update method 
 *******************************************************************************/


-(void)updatePieData:(NSTimer *)theTimer
{
    int Number = arc4random() % 12;
    NSMutableArray *contentArray = [NSMutableArray arrayWithObjects:
                                    [NSNumber numberWithDouble:(Number*2.0)],
                                    [NSNumber numberWithDouble:30.0],
                                    [NSNumber numberWithDouble:60.0],
                                    nil];
    self.pieChartData = contentArray;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    [self.pieChartGraph reloadData];
    [UIView commitAnimations];

}


/*******************************************************************************
 Graph update method for ECG signal...
 *******************************************************************************/

-(void)updateData:(NSTimer *)theTimer
{

    currentIndex++;
    //if (currentIndex > 1) {
        isRefreshing = NO;
    //}
    CPTGraph *theGraph = self.graph;
    CPTPlot *thePlot = [theGraph plotWithIdentifier:@"ecgPlot"];
   
    dummyIndex++;
   
   
    //NSLog(@"%d",currentIndex);
	
    
	
	if ( thePlot) {
       
        if (!isRefreshing)
        {
            if ( self.ecgData.count >= kMaxECGDataPoints ) 
            {
                [self.ecgData removeObjectAtIndex:0];
                [thePlot deleteDataInIndexRange:NSMakeRange(0, 1)];
              
            }
        }

//		CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
//		plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(currentIndex >= kMaxECGDataPoints ? currentIndex - kMaxECGDataPoints + 1: 0)
//														length:CPTDecimalFromUnsignedInteger(kMaxECGDataPoints - 1)];
		
		
        //NSLog(@"%d",thePlot.cachedDataCount);
        //CFShow(self.ecgData);
        if (currentIndex > kMaxECGDataPoints)
        {
            isRefreshing = YES;
            currentIndex = 0;
            
////            CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
////            lineStyle.lineColor = [CPTColor greenColor];
////            lineStyle.lineWidth = 4.0f;
//            
//            CPTMutableLineStyle *lineStyle1 = [CPTMutableLineStyle lineStyle];
//            lineStyle1.lineColor = [CPTColor redColor];
//            lineStyle1.lineWidth = 4.0f;
//            
////            ([[(CPTScatterPlot *)thePlot dataLineStyle] lineColor] == [CPTColor greenColor])?[((CPTScatterPlot *)thePlot) setDataLineStyle:lineStyle1]:[((CPTScatterPlot *)thePlot) setDataLineStyle:lineStyle];
//            [((CPTScatterPlot *)thePlot) setDataLineStyle:lineStyle1];
            [thePlot reloadDataInIndexRange:NSMakeRange(kMaxECGDataPoints - 2,1)];
        }
        if (dummyIndex > 2920)
        {
            dummyIndex = 0;
            
        }
        if (!isRefreshing) {
            [self.ecgData addObject:[dataArray objectAtIndex:dummyIndex]];
            [thePlot insertDataAtIndex:self.ecgData.count - 1 numberOfRecords:1];
            
        }
        if (currentIndex==0) {
            [self.detailViewController.shadowView setFrame:CGRectMake(30 , 10, 10, 225)];
        }
        [self.detailViewController.shadowView setFrame:CGRectMake(self.detailViewController.shadowView.frame.origin.x+1.6, self.detailViewController.shadowView.frame.origin.y, self.detailViewController.shadowView.frame.size.width, self.detailViewController.shadowView.frame.size.height)];
	}
    

}

/*******************************************************************************
 Graph update method for SPO2 signal...
 *******************************************************************************/

-(void)updateSpO2Plot:(NSTimer *)theTimer
{
    //[ekgAudio play];
    spo2Index++;
    if (spo2Index> 1) 
        isSpo2refreshing = NO;
    CPTGraph *theGraph = self.pulsifierGraph;
    CPTPlot *thePlot = [theGraph plotWithIdentifier:@"pulsifierPlot"];
    dummySpoIndex++;
	if ( thePlot) 
    {
        if (!isSpo2refreshing)
        {
            if ( self.pulsifierData.count >= kMaxDataPoints ) {
                [self.pulsifierData removeObjectAtIndex:0];
                [thePlot deleteDataInIndexRange:NSMakeRange(0, 1)];
            }
        }
        
        //		CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
        //		plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(currentIndex >= kMaxECGDataPoints ? currentIndex - kMaxECGDataPoints + 1: 0)
        //														length:CPTDecimalFromUnsignedInteger(kMaxECGDataPoints - 1)];
		
        if (spo2Index > kMaxDataPoints)
        {
            isSpo2refreshing = YES;
            spo2Index = 0;
            [thePlot reloadData];
            //[thePlot reloadDataInIndexRange:NSMakeRange(kMaxDataPoints - 2,1)];
        }
        if (dummySpoIndex > 2920)
        {
            dummySpoIndex = 0;
            
        }
        if (!isSpo2refreshing) {
            [self.pulsifierData addObject:[dataArray2 objectAtIndex:dummySpoIndex]];
            [thePlot insertDataAtIndex:self.pulsifierData.count - 1 numberOfRecords:1];
        }
        
	}

    //    CPTGraph *thePGraph = self.pulsifierGraph;
    //	CPTPlot *thePPlot = [thePGraph plotWithIdentifier:@"pulsifierPlot"];
    //	if ( thePPlot) {
    //        
    //        if ( self.pulsifierData.count >= kMaxDataPoints ) {
    //			[self.pulsifierData removeObjectAtIndex:0];
    //			[thePPlot deleteDataInIndexRange:NSMakeRange(0, 1)];
    //            
    //		}
    //        
    ////		CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)thePGraph.defaultPlotSpace;
    ////		plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(currentIndex >= kMaxDataPoints ? currentIndex  - kMaxDataPoints + 1: 0)
    ////														length:CPTDecimalFromUnsignedInteger(kMaxDataPoints - 1)];
    //		
    //		//currentIndex++;
    //        //CFShow(dataArray);
    //        //CFShow(self.graphData);
    //        if (currentIndex > 100) {
    //            currentIndex = 0;
    //            
    //        }
    //        if (dummyIndex > 2920) {
    //            dummyIndex = 0;
    //        }
    //		[self.pulsifierData addObject:[dataArray2 objectAtIndex:dummyIndex]];
    //		[thePPlot insertDataAtIndex:self.pulsifierData.count - 1 numberOfRecords:1];
    //	}

}



/*******************************************************************************
 Delegate methods
 *******************************************************************************/

#pragma mark -
#pragma mark  Delegate methods


// Delegate method that returns the number of points on the plot
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot 
{
	if ( [plot.identifier isEqual:@"ecgPlot"] ) 
	{
            return [self.ecgData count];
	} 
    else if ( [plot.identifier isEqual:@"pulsifierPlot"] ) 
	{
            return [self.pulsifierData count];
	} 
    else if ([plot isKindOfClass:[CPTPieChart class]]) {
        return [self.pieChartData count];
    }
	else  if ([plot isKindOfClass:[CPTBarPlot class]]) {
        return [samples count];
    }
	return 0;
}

// Delegate method that returns a single X or Y value for a given plot.

/*******************************************************************************
 
 // Delegate method that returns a single X or Y value for a given plot.
 
    The value is divided by 100 to keep the graph within bounds....
 *******************************************************************************/


-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{
    
    NSNumber *num =   nil;
	
    if ([plot isKindOfClass:[CPTPieChart class]]) {
        if (index >= [self.pieChartData count]) return nil;
        
        if (fieldEnum == CPTPieChartFieldSliceWidth) {
            return [self.pieChartData objectAtIndex:index];
        }
        else {
            return [NSNumber numberWithInt:index];
        }
    }
    
    else if ( [plot.identifier isEqual:@"ecgPlot"] ) 
	{
        if (!isRefreshing) 
        {
            switch ( fieldEnum )
            {
                case CPTScatterPlotFieldX:
                    num = [NSNumber numberWithDouble:index + currentIndex - self.ecgData.count];
                    
                    break;
                    
                case CPTScatterPlotFieldY:
                    num = [self.ecgData objectAtIndex:index];
                    double temp = [num doubleValue];
                    temp = temp/100; 
                    num = [NSNumber numberWithDouble:temp];
                    break;
                    
                default:
                    break;
            }
        }
	} 
    else if ( [plot.identifier isEqual:@"pulsifierPlot"] ) 
	{
        if (!isSpo2refreshing) 
        {
            switch ( fieldEnum ) {
                case CPTScatterPlotFieldX:
                    num = [NSNumber numberWithDouble:index + spo2Index - self.pulsifierData.count];
                    
                    break;
                    
                case CPTScatterPlotFieldY:
                    num = [self.pulsifierData objectAtIndex:index];
                    double temp = [num doubleValue];
                    temp = temp;
                    num = [NSNumber numberWithDouble:temp];
                    break;
                    
                default:
                    break;
            }
        }
	} 
	else if ([plot isKindOfClass:[CPTBarPlot class]]) {
       // switch (fieldEnum) {
                NSDictionary *sample = [samples objectAtIndex:index];
                
                if (fieldEnum == CPTScatterPlotFieldX)
                    return [sample valueForKey:X_VAL];
                else
                    return [sample valueForKey:Y_VAL];
        //}
    }

		
    return num;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    if ([plot isKindOfClass:[CPTBarPlot class]]) 
    {
        
        static CPTMutableTextStyle *whiteText = nil;
        
        if (!whiteText) {
            whiteText = [[CPTMutableTextStyle alloc] init];
            whiteText.fontSize = 14.0f;
            whiteText.color = [CPTColor blackColor];
        }
        
        CPTTextLayer *newLayer = nil;
        
        switch (index) {
            case 1:
                newLayer = [[[CPTTextLayer alloc] initWithText:@"Walking"
                                                         style:whiteText] autorelease];
                
                break;
            case 2:
                newLayer = [[[CPTTextLayer alloc] initWithText:@"Running"
                                                         style:whiteText] autorelease];
                break;
            default:
                newLayer = [[[CPTTextLayer alloc] initWithText:@"Sleeping"
                                                         style:whiteText] autorelease];
                break;
        }
    
        return newLayer;
    }
    return nil;
}

@end
