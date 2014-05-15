//
//  MapViewController.m
//  BallonMap
//
//  Created by bizan.com.mac07 on 2014/05/08.
//  Copyright (c) 2014年 TeamMusubi. All rights reserved.
//

#import "MapViewController.h"

#define ACCESS_KEY_ID           @"AKIAJSLRM43M5TTQCWHQ"
#define SECRET_KEY              @"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"
#define TABLE_NAME              @"testTable"
#define TABLE_HASH_KEY          @"id"
#define TABLE_RANGE_KEY         @"date"

@interface MapViewController ()
{
    //Annotation管理用配列
    NSMutableArray *annotationData;
}
@property (nonatomic, retain) UITextField *commentTextField;
@property (nonatomic, retain) CLLocationManager *locationManager;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Annotation管理用配列生成
    annotationData = [NSMutableArray array];
    
    //コメント用のテキストフィールド生成
    _commentTextField =
    [[UITextField alloc] initWithFrame:CGRectMake(20, 20, 280, 30)];
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
    }
    
    //MapViewデリゲート処理
    _mapview.delegate = self;
    
    //ユーザーロケーションを表示
    _mapview.showsUserLocation = YES;
    
    //地図の拡大縮小操作を禁止
    _mapview.zoomEnabled = NO;
    
    //地図のスクロール操作を禁止
    _mapview.scrollEnabled = NO;
    
    //ツールバー生成
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 50, self.view.bounds.size.width, 50)];
    
    //reloadボタン作成
    UIBarButtonItem *reloadbtn = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"reload.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]                                                                  style:UIBarButtonItemStylePlain target:self action:@selector(mapReload)];
    
    //投稿ボタンを作成
    UIBarButtonItem *contributebtn = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"contribute.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]                                                                  style:UIBarButtonItemStylePlain target:self action:@selector(contribute)];
    
    //informationボタン
    UIBarButtonItem *informationbtn = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"information.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]                                                                  style:UIBarButtonItemStylePlain target:self action:@selector(intoInformation)];
    
    //可変スペース
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //ツールバーへボタンアイテムを設置
    toolBar.items = [NSArray arrayWithObjects:reloadbtn,space,contributebtn,space,informationbtn, nil];
    
    //ツールバーのバックグラウンドカラーを設定
    toolBar.backgroundColor = [UIColor colorWithRed:(229/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0f];
    
    //ビューへツールバーを配置
    [self.view addSubview:toolBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark 位置情報処理
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    //ユーザーの現在地をフォローし縮尺を設定
    [_mapview setUserTrackingMode:MKUserTrackingModeFollow];
    [_mapview setCenterCoordinate:userLocation.location.coordinate];
    MKCoordinateRegion theRegion = _mapview.region;
    theRegion.span.longitudeDelta /= 4;
    theRegion.span.latitudeDelta /= 4;
    [_mapview setRegion:theRegion];
}

// 位置情報更新時
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //緯度・経度を出力
    NSLog(@"didUpdateToLocation latitude=%f, longitude=%f",
          [newLocation coordinate].latitude,[newLocation coordinate].longitude);
    
    MKCoordinateRegion region = MKCoordinateRegionMake([newLocation coordinate], MKCoordinateSpanMake(1, 1));
    [_mapview setRegion:region];
}

// 測位失敗時や、位置情報の利用をユーザーが「不許可」とした場合などに呼ばれる
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

//バックグラウンドから復帰時にGPS始動
- (void) onResume {
    if (nil == _locationManager && [CLLocationManager locationServicesEnabled])
        [_locationManager startUpdatingLocation]; //測位再開
}

//バックグラウンド時にGPS停止
- (void) onPause {
    if (nil == _locationManager && [CLLocationManager locationServicesEnabled])
        [_locationManager stopUpdatingLocation]; //測位停止
}

#pragma mark AnnotationView処理
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
        annotationView.image = [UIImage imageNamed:@"ballon_unchosen.png"];
        annotationView.annotation = annotation;
        annotationView.canShowCallout = YES;
        return annotationView;
    }
}

#pragma mark -
#pragma mark テキストフィールドReturn押下時の処理
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //コメントとUserLocation情報を渡しCustomAnnotationインスタンス作成
    CustomAnnotation *annotation = [[CustomAnnotation alloc]initWithLocationCoordinate:_mapview.userLocation.location.coordinate title:_commentTextField.text];
    
    //AWSDynamoDBのTableへコメントをUpload
    [self commentSender:annotation];
    
    //Annnotation管理用配列へカスタムAnnotationインスタンスを追加
    [annotationData addObject:annotation];
    
    //AnnotationViewの配列へ管理配列へ追加したオブジェクトを代入
    [_mapview addAnnotation:annotation];
    
    //送信時にコメント文字列を消去
    _commentTextField.text = nil;
    
    //Annotation削除用カウンター設定
    [NSTimer scheduledTimerWithTimeInterval:300
                                     target:self
                                   selector:@selector(deleteAnnotation)
                                   userInfo:nil
                                    repeats:NO];
    
    //texrfieldのフォーカス解除
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark サーバーへコメント送信処理
- (void)commentSender:(CustomAnnotation *)annotation{
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
    
    //ユーザー用のパスワードを取得
    NSString *paswword = [LKKeychain getPasswordWithAccount:_userName service:@"CommentMap"];
    
    NSString *latitudeStr = [NSString stringWithFormat:@"%f",annotation.coordinate.latitude];
    NSString *longitudeStr = [NSString stringWithFormat:@"%f",annotation.coordinate.longitude];
    
    //更新用配列を作成
    NSMutableDictionary *valueDic =
    (NSMutableDictionary *)[NSDictionary dictionaryWithObjectsAndKeys:
                            [[DynamoDBAttributeValue alloc] initWithS:_userName], TABLE_HASH_KEY,
                            [[DynamoDBAttributeValue alloc] initWithS:dateStr], TABLE_RANGE_KEY,
                            [[DynamoDBAttributeValue alloc] initWithS:paswword], @"num",
                            [[DynamoDBAttributeValue alloc] initWithS:latitudeStr], @"latitude",
                            [[DynamoDBAttributeValue alloc] initWithS:longitudeStr], @"longitude",
                            [[DynamoDBAttributeValue alloc] initWithS:_commentTextField.text], @"comment",
                            nil];
    
    //更新用テーブル名と更新用Itemを格納
    DynamoDBPutItemRequest *puItemRequest = [[DynamoDBPutItemRequest alloc] initWithTableName:TABLE_NAME andItem:valueDic];
    
    //更新処理実行
    [dbClient putItem:puItemRequest];
}

#pragma mark -
#pragma mark ツールバーのボタン処理
#pragma mark AnnotaionReload
- (void)mapReload{
    //awsアクセスキー情報格納
    AmazonCredentials *aCredentials = [[AmazonCredentials alloc]
                                       initWithAccessKey:ACCESS_KEY_ID
                                       withSecretKey:SECRET_KEY];
    //ユーザー情報を元にDynamoDB用クライアント作成
    AmazonDynamoDBClient *dbClient = [[AmazonDynamoDBClient alloc]initWithCredentials:aCredentials];
    
    //DynamoDB用クライアントへエンドポイント(東京サーバー)設定
    dbClient.endpoint = [AmazonEndpoints ddbEndpoint:AP_NORTHEAST_1];
    
    //DynamoDBスキャンリクエスト用オブジェクトを生成
    DynamoDBScanRequest *scanRequest = [DynamoDBScanRequest new];
    
    //リクエスト用オブジェクトにTable名を設定
    scanRequest.tableName = TABLE_NAME;
    
    //検索条件用オブジェクトを生成
    DynamoDBCondition *condition = [DynamoDBCondition new];
    
    //検索オプションを設定(BETWEEN)
    condition.comparisonOperator = @"BETWEEN";
    
    //日付フォーマットを指定
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat  = @"yyyy/MM/dd HH:mm:ss";
    
    //5分前の時間を取得し文字列で格納
    NSDate *beforeMinutes = [NSDate dateWithMinutesBeforeNow:5];
    NSTimeZone *tz = [NSTimeZone systemTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate:beforeMinutes];
    NSDate *localDate = [beforeMinutes dateByAddingTimeInterval:seconds];
    NSString *beforMinutesStr = [dateFormatter stringFromDate:localDate];
    
    //検索条件その1
    DynamoDBAttributeValue *date1 = [[DynamoDBAttributeValue alloc]initWithS:beforMinutesStr];
    
    //検索条件その1を追加
    [condition addAttributeValueList:date1];
    
    //現在のローカル時間を取得し文字列で格納
    NSString *nowStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:
                                                       [[NSTimeZone systemTimeZone] secondsFromGMT]]];
    
    //検索条件その2
    DynamoDBAttributeValue *date2 = [[DynamoDBAttributeValue alloc]initWithS:nowStr];
    
    //検索条件その2を追加
    [condition addAttributeValueList:date2];
    
    //検索条件と検索対象カラムを設定
    [scanRequest setScanFilterValue:condition forKey:@"date"];
    
    //DDBクライアントからスキャンを実行しサーバーからのレスポンスを取得
    DynamoDBScanResponse *response = [dbClient scan:scanRequest];
    
    //取得したレスポンスから必要な要素をCustomAnnotaionのインスタンスへ格納し、それらをAnnotation管理用配列へ追加(全要素分)
    for (NSMutableArray *elements in response.items) {
        DynamoDBAttributeValue *comment = [elements valueForKey:@"comment"];
        NSString *commentStr = comment.s;
        DynamoDBAttributeValue *latitude = [elements valueForKey:@"latitude"];
        NSString *latitudeStr = latitude.s;
        DynamoDBAttributeValue *longitude = [elements valueForKey:@"longitude"];
        NSString *longitudeStr = longitude.s;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([latitudeStr doubleValue], [longitudeStr doubleValue]);
        CustomAnnotation *annotations = [[CustomAnnotation alloc]
                                         initWithLocationCoordinate:coordinate title:commentStr];
        
        //Annotation管理配列へCustomAnnotationを追加
        [annotationData addObject:annotations];
        
        //Annotation配列へCustomAnnotationを追加
        [_mapview addAnnotation:annotations];
        
        //Annotation削除用カウンター設定
        [NSTimer scheduledTimerWithTimeInterval:300
                                         target:self
                                       selector:@selector(deleteAnnotation)
                                       userInfo:nil
                                        repeats:NO];
    }
}

#pragma mark コメント投稿処理
- (void)contribute{
    
}

#pragma mark Informationページへ移動
- (void)intoInformation{
    [self performSegueWithIdentifier:@"informationView" sender:self];
}

#pragma mark -
#pragma mark Annotation時間削除処理
- (void)deleteAnnotation{
    [_mapview removeAnnotation:[annotationData objectAtIndex:0]];
    [annotationData removeObjectAtIndex:0];
}
@end
