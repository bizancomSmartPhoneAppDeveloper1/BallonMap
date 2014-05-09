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

@implementation MapViewController

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
    
    [textField resignFirstResponder];
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
    
}

//informationページへ移動
- (void)intoInformation{
    [self performSegueWithIdentifier:@"informationView" sender:self];
}
@end
