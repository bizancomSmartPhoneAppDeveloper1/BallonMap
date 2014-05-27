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
    
    UITextView *detailTexitView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    [detailTexitView setTextContainerInset:UIEdgeInsetsMake(70, 0, 0, 0)];
    
    detailTexitView.font = [UIFont fontWithName:@"Helvetica" size:20];
    
    detailTexitView.editable = NO;
    
    [self.view addSubview:detailTexitView];
    
    // 全画面のサイズを取得する
    CGRect fullScreen = [[UIScreen mainScreen] bounds];
    
    //ステータスバー領域を除いた領域を取得する
    CGRect stsExceptScreen = [[UIScreen mainScreen] applicationFrame];
    
    float stsbarf = fullScreen.size.height - stsExceptScreen.size.height;
    
    //ツールバー生成
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, stsExceptScreen.origin.y, self.view.bounds.size.width, 45)];
    
    //backviewボタン
    UIBarButtonItem *backViewBtn = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backview.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]                                                                  style:UIBarButtonItemStylePlain target:self action:@selector(backMapView:)];
    
    //ツールバーへボタンアイテムを設置
    toolBar.items = [NSArray arrayWithObjects:backViewBtn, nil];
    
    //ビューへツールバーを配置
    [self.view addSubview:toolBar];
    
    //ツールバー生成
    UIToolbar *stsBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, stsbarf)];
    
    //ビューへツールバーを配置
    [self.view addSubview:stsBar];
    
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
