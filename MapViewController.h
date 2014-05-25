//
//  MapViewController.h
//  BallonMap
//
//  Created by bizan.com.mac07 on 2014/05/08.
//  Copyright (c) 2014年 TeamMusubi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSRuntime/AWSRuntime.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CustomAnnotation.h"
#import "LKKeychain.h"
#import "NSDate+Escort.h"
#import "Reachability.h"

@interface MapViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapview;

//userName受け取り用
@property NSString *userName;
//バックグラウンドから復帰時に呼ばれる
-(void) onResume;
//バックグラウンド移行時に呼ばれる
-(void) onPause;

@end
