//
//  InformationTableViewController.m
//  BallonMap
//
//  Created by bizan.com.mac07 on 2014/05/21.
//  Copyright (c) 2014年 TeamMusubi. All rights reserved.
//

#import "InformationTableViewController.h"

#define ACCESS_KEY_ID           @""
#define SECRET_KEY              @""
#define TABLE_INFO_NAME         @"testTable0"
#define TABLE_INFO_HASH_KEY     @"id"
#define TABLE_INFO_RANGE_KEY    @"date"
#define TABLE_COLUMN_TITLE      @"title"

@interface InformationTableViewController ()
{
    UIButton *sendServerButton;
    UIButton *commentCancelButton;
    UIView *commentbackView;
    CGRect keyboardFrameSize;
    //awsユーザー情報
    AmazonCredentials *aCredentials;
    //DynamoDBクライアント
    AmazonDynamoDBClient *dbClient;
    //infomation用管理配列
    NSMutableArray *infoElements;
}

@property (nonatomic, retain) UITextView *commentTextView;

@end

@implementation InformationTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    infoElements = [NSMutableArray array];
    
    //ツールバー生成
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 65)];
    
    //informationボタン
    UIBarButtonItem *backViewBtn = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backview.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]                                                                  style:UIBarButtonItemStylePlain target:self action:@selector(backMapView:)];
    
    //可変スペース
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //投稿ボタンを作成
    UIBarButtonItem *contributebtn = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"contribute.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]                                                                  style:UIBarButtonItemStylePlain target:self action:@selector(contribute)];
    
    //ツールバーへボタンアイテムを設置
    toolBar.items = [NSArray arrayWithObjects:backViewBtn,space,contributebtn, nil];
    
    //ビューへツールバーを配置
    [self.view addSubview:toolBar];
    
    //awsアクセスキー情報格納
    aCredentials = [[AmazonCredentials alloc]
                    initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    //ユーザー情報を元にDynamoDB用クライアント作成
    dbClient = [[AmazonDynamoDBClient alloc]initWithCredentials:aCredentials];
    
    //DynamoDB用クライアントへエンドポイント(東京サーバー)設定
    dbClient.endpoint = [AmazonEndpoints ddbEndpoint:AP_NORTHEAST_1];
    
    //保存してあるデバイスのキーボードサイズを取得
    keyboardFrameSize = CGRectFromString([[NSUserDefaults standardUserDefaults] objectForKey:@"keyboardSize"]);
    
    [self infoLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return infoElements.count;
}

#pragma mark -
#pragma mark セル情報出力
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:CellIdentifier];
    
    //配列の後ろから順にセルへ配置
    NSMutableArray *elementsArray = [infoElements objectAtIndex:(infoElements.count - (indexPath.row + 1))];
    DynamoDBAttributeValue *element = [elementsArray valueForKey:TABLE_COLUMN_TITLE];
    cell.textLabel.text = element.s;
    element = [elementsArray valueForKey:TABLE_INFO_RANGE_KEY];
    cell.detailTextLabel.text = element.s;
    
    return cell;
}

#pragma mark -
#pragma mark タイムラインコメント投稿処理
- (void)contribute{
    //TextViewの背景Viewを差し込み
    commentbackView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];
    commentbackView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:commentbackView];
    
    // UITextViewのインスタンス化
    CGRect rect1 = CGRectMake(0, 65, self.view.bounds.size.width, (self.view.bounds.size.height - keyboardFrameSize.size.height) - 65);
    _commentTextView = [[UITextView alloc]initWithFrame:rect1];
    
    // テキストの編集を可不を選ぶ
    _commentTextView.editable = YES;
    
    // テキストを左寄せにする
    _commentTextView.textAlignment = NSTextAlignmentLeft;//新しい書き方
    
    // テキストのフォントを設定
    _commentTextView.font = [UIFont fontWithName:@"Helvetica" size:20];
    
    // テキストの背景色を設定
    _commentTextView.backgroundColor = [UIColor whiteColor];
    //リターンキーの種類
    _commentTextView.returnKeyType = UIReturnKeyDone;
    //デリケート設定
    _commentTextView.delegate = self;
    // 枠線
    _commentTextView.layer.borderWidth = 1;
    // 角丸
    _commentTextView.layer.cornerRadius = 5;
    
    // UITextViewのインスタンスをビューに追加
    [self.view addSubview:_commentTextView];
    
    //textviemにフォーカスを移している
    [_commentTextView becomeFirstResponder];
    //ボタン生成
    sendServerButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    //タイトル文字を決めている
    [sendServerButton setTitle:@"送信" forState:UIControlStateNormal];
    //フォントサイズを決めている
    sendServerButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    //ボタンの領域と縦横サイズ
    sendServerButton.frame =CGRectMake(self.view.bounds.size.width - 60, keyboardFrameSize.origin.y - 160, 50, 40);
    //タッチアクションとメソッドを設定
    [sendServerButton addTarget:self action:@selector(sendServer) forControlEvents:UIControlEventTouchUpInside];
    //ボタンを表示する
    [self.view addSubview:sendServerButton];
    
    commentCancelButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    //タイトル文字を決めている
    [commentCancelButton setTitle:@"キャンセル" forState:UIControlStateNormal];
    //フォントサイズを決めている
    commentCancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    //ボタンの領域と縦横サイズ
    commentCancelButton.frame =CGRectMake(10, keyboardFrameSize.origin.y - 160, 80, 40);
    //タッチアクションとメソッドを設定
    [commentCancelButton addTarget:self action:@selector(commentCancel) forControlEvents:UIControlEventTouchUpInside];
    
    //ボタンを表示する
    [self.view addSubview:commentCancelButton];
}

#pragma mark キャンセルボタン処理
-(void)commentCancel{
    
    //テキストビューを削除
    [_commentTextView removeFromSuperview];
    
    //送信ボタンを削除
    [sendServerButton removeFromSuperview];
    
    //キャンセルボタンを削除
    [commentCancelButton removeFromSuperview];
    
    //コメント投稿時の背景Viewを削除
    [commentbackView removeFromSuperview];
}

#pragma mark サーバー送信処理
- (void)sendServer{
    Reachability *reachablity = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reachablity currentReachabilityStatus];
    if ([_commentTextView.text length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"コメントを入力してください" message:nil delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
    }else if (status == NotReachable) {
        [self disconnectionAlert];
    } else {
        //AWSDynamoDBのTableへコメントをUpload
        [self commentSender];
        
        //送信時にコメント文字列を消去
        _commentTextView.text = nil;
        
        //テキストビューを削除
        [_commentTextView removeFromSuperview];
        
        //送信ボタンを削除
        [sendServerButton removeFromSuperview];
        
        //キャンセルボタンを削除
        [commentCancelButton removeFromSuperview];
        
        //コメント投稿時の背景Viewを削除
        [commentbackView removeFromSuperview];
    }
}

#pragma mark -
#pragma mark サーバーへコメント送信処理
- (void)commentSender{
    //日付フォーマットを指定
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat  = @"yyyy/MM/dd HH:mm:ss";
    
    //現在のローカル時間を取得し文字列で格納
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:
                                                       [[NSTimeZone systemTimeZone] secondsFromGMT]]];
    
    //更新用配列を作成
    NSMutableDictionary *valueDic =
    (NSMutableDictionary *)[NSDictionary dictionaryWithObjectsAndKeys:
                            [[DynamoDBAttributeValue alloc] initWithS:_userName], TABLE_INFO_HASH_KEY,
                            [[DynamoDBAttributeValue alloc] initWithS:dateStr], TABLE_INFO_RANGE_KEY,
                            [[DynamoDBAttributeValue alloc] initWithS:_commentTextView.text], TABLE_COLUMN_TITLE,
                            nil];
    
    //更新用テーブル名と更新用Itemを格納
    DynamoDBPutItemRequest *puItemRequest = [[DynamoDBPutItemRequest alloc] initWithTableName:TABLE_INFO_NAME andItem:valueDic];
    
    //更新処理実行
    [dbClient putItem:puItemRequest];
}

#pragma mark -
#pragma mark Network切断時のAlert表示
- (void)disconnectionAlert{
    UIAlertView *networkAlert = [[UIAlertView alloc]initWithTitle:@"インターネット接続出来ません" message:nil delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
    [networkAlert show];
}

#pragma mark exit
- (void)backMapView:(id)sender{
    [self performSegueWithIdentifier:@"fromInformationView" sender:self];
}

- (void)infoLoad{
    Reachability *reachablity = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reachablity currentReachabilityStatus];
    if (status == NotReachable) {
        [self disconnectionAlert];
    } else {
        //DynamoDBスキャンリクエスト用オブジェクトを生成
        DynamoDBScanRequest *scanRequest = [DynamoDBScanRequest new];
        
        //リクエスト用オブジェクトにTable名を設定
        scanRequest.tableName = TABLE_INFO_NAME;
        
        //検索条件用オブジェクトを生成
        DynamoDBCondition *condition = [DynamoDBCondition new];
        
        //検索オプションを設定(GE >=)
        condition.comparisonOperator = @"GE";
        
        //日付フォーマットを指定
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat  = @"yyyy/MM/dd HH:mm:ss";
        
        //1日前の時間を取得し文字列で格納
        NSDate *beforeMinutes = [NSDate dateWithDaysBeforeNow:1];
        NSTimeZone *tz = [NSTimeZone systemTimeZone];
        NSInteger seconds = [tz secondsFromGMTForDate:beforeMinutes];
        NSDate *localDate = [beforeMinutes dateByAddingTimeInterval:seconds];
        NSString *beforDaysStr = [dateFormatter stringFromDate:localDate];
        
        //検索条件その1
        DynamoDBAttributeValue *dateGE = [[DynamoDBAttributeValue alloc]initWithS:beforDaysStr];
        
        //検索条件その1を追加
        [condition addAttributeValueList:dateGE];
        
        //検索条件と検索対象カラムを設定
        [scanRequest setScanFilterValue:condition forKey:@"date"];
        
        //DDBクライアントからスキャンを実行しサーバーからのレスポンスを取得
        DynamoDBScanResponse *response = [dbClient scan:scanRequest];
        
        infoElements = [response.items mutableCopy];
        }
}
@end
