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
    
    UILabel *infoTitleLabel = [UILabel new];
    
    infoTitleLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
    
    infoTitleLabel.frame = CGRectMake(0, 0, self.view.bounds.size.width, 10000);
    
    infoTitleLabel.frame = CGRectMake(0, stsExceptScreen.origin.y + 45, self.view.bounds.size.width, [self adjustHeight:element.s label:infoTitleLabel]);
    
    infoTitleLabel.numberOfLines = 0;
    
    infoTitleLabel.backgroundColor = [UIColor colorWithRed:0/255.0f green:142/255.0f blue:255/255.0f alpha:1.0f];
    
    infoTitleLabel.textColor = [UIColor whiteColor];
    
    [self.view addSubview:infoTitleLabel];
    
    infoTitleLabel.text = element.s;
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

- (float)adjustHeight:(NSString *)show_word label:(UILabel *)label{
    CGFloat fontSize = label.font.pointSize;
    float  labelWidth  = label.bounds.size.width;
    float  labelHeight = label.bounds.size.height;
    
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    CGSize size = CGSizeMake(labelWidth, labelHeight);
    
    CGRect totalRect = [show_word boundingRectWithSize:size
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                            attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]
                                               context:nil];
    float fitSizeHeight = totalRect.size.height;
    
    return fitSizeHeight;
}
@end
