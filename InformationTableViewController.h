//
//  InformationTableViewController.h
//  BallonMap
//
//  Created by bizan.com.mac07 on 2014/05/21.
//  Copyright (c) 2014年 TeamMusubi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSRuntime/AWSRuntime.h>
#import "Reachability.h"
#import "NSDate+Escort.h"

@interface InformationTableViewController : UITableViewController<UITextViewDelegate>

//userName受け取り用
@property NSString *userName;

@end
