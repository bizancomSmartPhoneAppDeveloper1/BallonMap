//
//  CustomAnnotation.m
//  awsDynamoDBtest
//
//  Created by bizan.com.mac07 on 2014/05/06.
//  Copyright (c) 2014年 teammusubi. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation

- (NSString *)title {
    return _annotationTitle;
}

- (NSString *)subtitle {
    return _annotationSubtitle;
}

- (id)initWithLocationCoordinate:(CLLocationCoordinate2D)coordinate
                           title:(NSString *)annotationTitle subtitle:(NSString *)annotationannSubtitle{
    _coordinate = coordinate;
    self.annotationTitle = annotationTitle;
    self.annotationSubtitle = annotationannSubtitle;
    return self;
}

@end
