//
//  TUTSimpleScatterPlot.h
//  Core Plot Introduction
//  mLabProject1
//
//  Created by Abhijeet Mulay on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//




/*******************************************************************************
 This file has the main setup methods and working logic for the graphs
 *******************************************************************************/


#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"
#import <AVFoundation/AVFoundation.h>
@class DetailViewController;

@interface TUTSimpleScatterPlot : NSObject <CPTPlotSpaceDelegate,CPTPlotDataSource,CPTScatterPlotDelegate,CPTBarPlotDelegate,CPTPieChartDataSource,CPTPieChartDelegate,AVAudioPlayerDelegate> 
{
	
    CPTGraphHostingView *_ecgView;
    CPTGraphHostingView *_pulsifierView;
    CPTGraphHostingView *_pieChartView;
    CPTGraphHostingView *barChartView;
    
	CPTXYGraph *_graph;
    CPTXYGraph *_pulsifierGraph;
    CPTXYGraph *_pieChartGraph;
    CPTXYGraph *barGraph;
    
    DetailViewController *detailViewController;
    UILabel *_spo2Label;
	UILabel *_bpmLabel;
    NSMutableArray *_graphData;
    NSMutableArray *_ecgData;
    NSMutableArray *_pulsifierData;
    NSMutableArray *dataArray;
    NSMutableArray *dataArray2;
    NSMutableArray *_pieChartData;
    NSMutableArray *spO2Data;
    NSMutableArray *hrData;
	NSMutableArray *samples;
    NSUInteger currentIndex;
    NSUInteger dummyIndex;
    NSUInteger spo2Index;
    NSUInteger dummySpoIndex;
   
    AVAudioPlayer *ekgAudio;
    BOOL isRefreshing;
    BOOL isSpo2refreshing;
    int spo2Count;
    int hrCount;
}


@property (nonatomic, retain) CPTGraphHostingView *ecgView;  
@property (nonatomic, retain) CPTGraphHostingView *pulsifierView;
@property (nonatomic, retain) CPTGraphHostingView *pieChartView;
@property (nonatomic, retain) CPTGraphHostingView *barChartView;

@property (nonatomic, retain) DetailViewController *detailViewController;

@property (nonatomic, retain) CPTXYGraph *graph;
@property (nonatomic, retain) CPTXYGraph *pulsifierGraph;
@property (nonatomic, retain) CPTXYGraph *pieChartGraph;
@property (nonatomic, retain) CPTXYGraph *barGraph;

@property (nonatomic, retain) UILabel *spo2Label;
@property (nonatomic, retain) UILabel *bpmLabel;

@property (nonatomic, retain) NSMutableArray *graphData;
@property (nonatomic, retain) NSMutableArray *pieChartData;
@property (nonatomic, retain) NSMutableArray *ecgData;
@property (nonatomic, retain) NSMutableArray *pulsifierData;

@property (nonatomic, retain) NSTimer *ecgTimer;
@property (nonatomic, retain) NSTimer *spO2Timer;
@property (nonatomic, retain) NSTimer *spO2PlotTimer;
@property (nonatomic, retain) NSTimer *hrTimer;



// Methods to create this object and attach it to it's hosting view.
//+(TUTSimpleScatterPlot *)plotWithHostingView:(CPTGraphHostingView *)hostingView andData:(NSMutableArray *)data;
-(id)initWithEcgView:(CPTGraphHostingView *)ecgView pulsifierView:(CPTGraphHostingView *)pulsifierView pieChartView:(CPTGraphHostingView *)pieChartView spo2Label:(UILabel *)spo2Label bpmLabel:(UILabel *)bpmLabel andData:(NSMutableArray *)data;
-(void)setSpo2Label:(UILabel *)spo2Label;
// Specific code that creates the scatter plot.
-(void)initialisePlot;
-(void)setTimerToPlot:(NSString *)fileName;
-(void)updateData:(NSTimer *)theTimer;
-(void)updateSpo2Data:(NSTimer *)theTimer;
-(void)updatePieData:(NSTimer *)theTimer;
-(void)updateSpO2Plot:(NSTimer *)theTimer;
-(void)setupData:(NSString *)fileName;
-(void)initialiseEcgPlot;
-(void)initialisePulsifierPlot;
-(void)initialisePieChartPlot;
-(void)setPaddingDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds;
-(void)updtData;
-(void)invalidateTimers;
-(void)fireTimers;
-(void)resetIndices;
@end
