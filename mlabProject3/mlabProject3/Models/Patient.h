//
//  Patient.h
//  mlabProject3
//
//  Created by Abhijeet Mulay on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Patient : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * fileName;

@end
