//
//  CustomAnnotation.h
//  awsDynamoDBtest
//
//  Created by bizan.com.mac07 on 2014/05/06.
//  Copyright (c) 2014年 teammusubi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *annotationTitle;
@property (nonatomic, retain) NSString *annotationSubtitle;
- (id)initWithLocationCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)annotationTitle;
- (NSString *)title;
- (NSString *)subtitle;

@end
