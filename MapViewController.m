//
//  MapViewController.m
//  BallonMap
//
//  Created by bizan.com.mac07 on 2014/05/08.
//  Copyright (c) 2014年 TeamMusubi. All rights reserved.
//

#import "MapViewController.h"

#define ACCESS_KEY_ID           @""
#define SECRET_KEY              @""
#define TABLE_NAME              @""
#define TABLE_HASH_KEY          @""
#define TABLE_RANGE_KEY         @""

@interface MapViewController ()

@property (nonatomic, retain) UITextField *commentTextField;
@property (nonatomic, retain) CLLocationManager *locationManager;

@end

@implementation MapViewController{
    UIButton *button;
    UIButton *button1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //コメント用のテキストフィールド生成
    _commentTextField =
    [[UITextField alloc] initWithFrame:CGRectMake(20, 200, 280, 30)];
    _commentTextField.delegate = self;
    _commentTextField.borderStyle = UITextBorderStyleRoundedRect;
    _commentTextField.returnKeyType = UIReturnKeySend;
    _commentTextField.clearButtonMode = UITextFieldViewModeAlways;
    _commentTextField.placeholder = @"コメントを入力してください";
    _commentTextField.backgroundColor = [UIColor colorWithRed:0.82 green:0.93 blue:0.99 alpha:1.0];
    
    [self.view addSubview:_commentTextField];
    
    // 位置情報サービスが利用できるかどうかをチェック
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager.delegate = self;
        // 測位開始
        [_locationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services not available.");
    }
    
    //ユーザートラッキング(ON/OFF)用ボタン作成
    UIButton *userTrackingbtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [userTrackingbtn addTarget:self action:@selector(userTrackingButton:) forControlEvents:UIControlEventTouchDown];
    userTrackingbtn.frame = CGRectMake(0, 20, 35, 35);
    [self.view addSubview:userTrackingbtn];
    
    //デリゲート処理
    _mapview.delegate = self;
    
    //ユーザーロケーションを追跡
    _mapview.showsUserLocation = YES;
    
    //ツールバー生成
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 50, self.view.bounds.size.width, 50)];
    
    //reloadボタン作成
    UIBarButtonItem *reloadbtn = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"reload.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]                                                                  style:UIBarButtonItemStylePlain target:self action:@selector(mapReload)];
    
    //投稿ボタンを作成
    UIBarButtonItem *contributebtn = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"contribute.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]                                                                  style:UIBarButtonItemStylePlain target:self action:@selector(contribute)];
    
    //informationボタン
    UIBarButtonItem *informationbtn = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"information.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]                                                                  style:UIBarButtonItemStylePlain target:self action:@selector(intoInformation)];
    
    //ツールバーへボタンアイテムを設置
    toolBar.items = [NSArray arrayWithObjects:reloadbtn,contributebtn,informationbtn, nil];
    
    //ビューへツールバーを配置
    [self.view addSubview:toolBar];
    
    [_mapview addAnnotation:
     [[CustomAnnotation alloc]initWithLocationCoordinate:CLLocationCoordinate2DMake(35.685623, 139.763153)
                                                   title:@"大手町駅" subtitle:@"千代田線・半蔵門線・丸ノ内線・東西線・三田線"]];
    
    [_mapview addAnnotation:
     [[CustomAnnotation alloc]initWithLocationCoordinate:CLLocationCoordinate2DMake(35.690747,139.756866)
                                                   title:@"竹橋駅"
                                                subtitle:@"東西線"]];
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark 位置情報処理
// 位置情報更新時
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    //緯度・経度を出力
    NSLog(@"didUpdateToLocation latitude=%f, longitude=%f",
          [newLocation coordinate].latitude,[newLocation coordinate].longitude);
    
    MKCoordinateRegion region = MKCoordinateRegionMake([newLocation coordinate], MKCoordinateSpanMake(1.75, 1.75));
    [_mapview setCenterCoordinate:[newLocation coordinate]];
    [_mapview setRegion:region];
}

// 測位失敗時や、5位置情報の利用をユーザーが「不許可」とした場合などに呼ばれる
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    //エラーコードにより処理分岐
    if (error) {
		NSString *message = nil;
		switch ([error code]) {
                // アプリでの位置情報サービスが許可されていない場合
			case kCLErrorDenied:
				// 位置情報取得停止
				[manager stopUpdatingLocation];
				message = [NSString stringWithFormat:@"このアプリは位置情報サービスが許可されていません。"];
				break;
			default:
				message = [NSString stringWithFormat:@"位置情報の取得に失敗しました。"];
				break;
		}
		if (message) {
			// アラートを表示
			UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil
                                                 cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		}
	}
}

- (void) onResume {
    if (nil == _locationManager && [CLLocationManager locationServicesEnabled])
        [_locationManager startUpdatingLocation]; //測位再開
}

- (void) onPause {
    if (nil == _locationManager && [CLLocationManager locationServicesEnabled])
        [_locationManager stopUpdatingLocation]; //測位停止
}

#pragma mark ユーザートラッキングボタン処理
- (void)userTrackingButton:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        //ONに変わった場合の処理、ユーザー追跡Off
        [_mapview setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    } else {
        //OFFに変わった場合の処理、ユーザー追跡ON
        [_mapview setUserTrackingMode:MKUserTrackingModeNone];
    }
}

#pragma mark CustomAnnotation処理
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    } else {
        MKAnnotationView *annotationView;
        //再利用可能なannotationがあるかどうかを判断するための識別子を定義
        NSString *identifier = @"Pin";
        //"Pin"という識別子の使いまわせるannotationがあるかチェック
        annotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        //使い回しができるannotationがない場合、annotationの初期化
        if(annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        //画像をannotationとして設定
        annotationView.image = [UIImage imageNamed:@"pin.jpg"];
        annotationView.annotation = annotation;
        //        annotationView.canShowCallout = YES;
        return annotationView;
    }
    
}

#pragma mark -
#pragma mark テキストフィールドReturn押下時の処理
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //AWSDynamoDBのTableへコメントをUpload
    [self commentSender];
    
    //送信時にコメント文字列を消去
    _commentTextField.text = nil;
    
    
    //キーボードを閉じる
    [self.view endEditing:YES];
    return YES;
}

#pragma mark -
#pragma mark コメント送信処理
- (void)commentSender{
    //awsアクセスキー情報格納
    AmazonCredentials *aCredentials = [[AmazonCredentials alloc]
                                       initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    //ユーザー情報を元にDynamoDB用クライアント作成
    AmazonDynamoDBClient *dbClient = [[AmazonDynamoDBClient alloc]initWithCredentials:aCredentials];
    
    //DynamoDB用クライアントへエンドポイント(東京サーバー)設定
    dbClient.endpoint = [AmazonEndpoints ddbEndpoint:AP_NORTHEAST_1];
    
    //日付フォーマットを指定
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat  = @"yyyy/MM/dd HH:mm:ss";
    
    //現在のローカル時間を取得し文字列で格納
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:
                                                       [[NSTimeZone systemTimeZone] secondsFromGMT]]];
    
    //更新用配列を作成
    NSMutableDictionary *valueDic =
    (NSMutableDictionary *)[NSDictionary dictionaryWithObjectsAndKeys:
                            [[DynamoDBAttributeValue alloc] initWithS:_userName], TABLE_HASH_KEY,
                            [[DynamoDBAttributeValue alloc] initWithS:dateStr], TABLE_RANGE_KEY,
                            [[DynamoDBAttributeValue alloc] initWithS:_commentTextField.text], @"comment",
                            nil];
    
    //更新用テーブル名と更新用Itemを格納
    DynamoDBPutItemRequest *puItemRequest = [[DynamoDBPutItemRequest alloc] initWithTableName:TABLE_NAME andItem:valueDic];
    
    //更新処理実行
    [dbClient putItem:puItemRequest];
}

#pragma mark -
#pragma mark ツールバーのボタン処理
- (void)mapReload{
    
}

- (void)contribute{
    
    // UITextViewのインスタンス化
    CGRect rect1 = CGRectMake(0, 20, 320, 240);//self.view.bounds;
    UITextView *textView = [[UITextView alloc]initWithFrame:rect1];
    
    // テキストの編集を可不を選ぶ
    textView.editable = YES;
    
    // テキストを左寄せにする
    textView.textAlignment = NSTextAlignmentLeft;//新しい書き方
    
    // テキストのフォントを設定
    textView.font = [UIFont fontWithName:@"Helvetica" size:14];
    
    // テキストの背景色を設定
    textView.backgroundColor = [UIColor whiteColor];
    //リターンキーの種類
    textView.returnKeyType = UIReturnKeyDone;
    //デリケート設定
    textView.delegate = self;
    // 枠線
    textView.layer.borderWidth = 1;
    //textView.layer.borderColor = [[UIColorblackColor] CGColor];
    // 角丸
    textView.layer.cornerRadius = 5;
    
    // UITextViewのインスタンスをビューに追加
    [self.view addSubview:textView];
    //textviemにフォーカスを移している
    [textView becomeFirstResponder];
    //ボタン生成
    button =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    //タイトル文字を決めている
    [button setTitle:@"送信" forState:UIControlStateNormal];
    //フォントサイズを決めている
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    //ボタンの領域と縦横サイズ
    button.frame =CGRectMake(260, 220, 50, 40);
    //ボタンを表示する
    [self.view addSubview:button];
    
    button1 =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    //タイトル文字を決めている
    [button1 setTitle:@"戻る" forState:UIControlStateNormal];
    //フォントサイズを決めている
    button1.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    //ボタンの領域と縦横サイズ
    button1.frame =CGRectMake(220, 220, 50, 40);
    //ボタンを表示する
    [self.view addSubview:button1];
    
}



//informationページへ移動
- (void)intoInformation{
    [self performSegueWithIdentifier:@"informationView" sender:self];
}

////フォーカスを動かせば走る　キーボードを閉じて画面を戻す処理を書く
//-(BOOL)textViewShouldEndEditing:(UITextView *)textView
//{
//    
//    // 編集終了時の処理
//    
//    // キーボードを隠す
//    [textView resignFirstResponder];
//    NSLog(@"2");
//    return YES;
//    
//}

/* 1. TextView の文字が変更される度に処理をする */
- (void) textViewDidChange: (UITextView *) textView {
    
    NSRange searchResult = [textView.text rangeOfString:@"送信"];
    if (searchResult.location != NSNotFound) {
        /* 1-1. 改行の文字が押された場合 = Doneが押された場合 */
        
        // 1-1-1. 改行文字を消す
        textView.text = [textView.text stringByReplacingOccurrencesOfString:@"n" withString:@""];
        //テキストビューを隠す
        textView.hidden =YES;
        //ボタンを隠す
        button.titleLabel.hidden =YES;
        button1.titleLabel.hidden =YES;
        
        // 1-1-2. キーボードをしまう
        [textView resignFirstResponder];
    }
    
}
@end
