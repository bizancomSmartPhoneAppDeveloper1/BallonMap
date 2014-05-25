//
//  InfoViewController.m
//  BallonMap
//
//  Created by bizan.com.mac07 on 2014/05/25.
//  Copyright (c) 2014年 TeamMusubi. All rights reserved.
//

#import "InfoViewController.h"
#define TABLE_COLUMN_TITLE      @"title"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //ツールバー生成
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 65)];
    
    //backviewボタン
    UIBarButtonItem *backViewBtn = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backview.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]                                                                  style:UIBarButtonItemStylePlain target:self action:@selector(backMapView:)];
    
    //ツールバーへボタンアイテムを設置
    toolBar.items = [NSArray arrayWithObjects:backViewBtn, nil];
    
    //ビューへツールバーを配置
    [self.view addSubview:toolBar];
    
    UITextView *detailTexitView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    [detailTexitView setTextContainerInset:UIEdgeInsetsMake(30, 0, 0, 0)];
    
    detailTexitView.font = [UIFont fontWithName:@"Helvetica" size:20];
    
    [self.view addSubview:detailTexitView];
    
    DynamoDBAttributeValue *element = [_detailArray valueForKey:TABLE_COLUMN_TITLE];
    detailTexitView.text = element.s;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark exit
- (void)backMapView:(id)sender{
    [self performSegueWithIdentifier:@"fromInfoVIew" sender:self];
}

@end
