//
//  LoginViewController.m
//  BallonMap
//
//  Created by bizan.com.mac07 on 2014/05/08.
//  Copyright (c) 2014年 TeamMusubi. All rights reserved.
//

#import "LoginViewController.h"
#import "MapViewController.h"

@interface LoginViewController ()
{
@private
    UITableView *loginTableView;
    UIAlertView *createAccountAlert;
    UIAlertView *loginAlert;
}

@property (retain, nonatomic) UITextField *username;
@property (retain, nonatomic) UITextField *password;
@property (retain, nonatomic) UIButton *checkbox;

@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated
{
    //チェックボックスの状態を読み込む
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _checkbox.selected = [userDefaults boolForKey:@"checkButton"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Sign in";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    loginTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 15, 300, 240) style:UITableViewStyleGrouped];
    loginTableView.dataSource = self;
    loginTableView.delegate = self;
    loginTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:loginTableView];
    
    //Loginボタン作成
    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    btnLogin.backgroundColor = [UIColor whiteColor];
    btnLogin.frame = CGRectMake(30, 180, 260, 34);
    [btnLogin setTitle:@"Login" forState:UIControlStateNormal];
    [btnLogin addTarget:self action:@selector(btnLoginOnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnLogin];
    
    //サインアップボタン作成
    UIButton *btnSignUp = [UIButton buttonWithType:UIButtonTypeSystem];
    btnSignUp.backgroundColor = [UIColor whiteColor];
    btnSignUp.frame = CGRectMake(30, 220, 260, 34);
    [btnSignUp setTitle:@"Sign Up" forState:UIControlStateNormal];
    [btnSignUp addTarget:self action:@selector(btnSignUpOnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSignUp];
    
    //チェックボックス作成
    _checkbox = [[UIButton alloc]initWithFrame:CGRectMake(12,145,14,14)];
    [_checkbox setImage:[UIImage imageNamed:@"check_off.jpg"] forState:UIControlStateNormal];
    [_checkbox setImage:[UIImage imageNamed:@"check_on.jpg"] forState:UIControlStateSelected];
    [_checkbox addTarget:self action:@selector(checkbox:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_checkbox];
    
    //ラベル生成
    UILabel *announceLabel = [[UILabel alloc] initWithFrame:CGRectMake(30,146,150,14)];
    announceLabel.font = [UIFont boldSystemFontOfSize:11];
    announceLabel.text = @"ユーザーIDを保存する";
    [self.view addSubview:announceLabel];
}

-(void)viewDidAppear:(BOOL)animated{
    //チェックボックスがONだった場合保存されたusernameを書き込む
    if (_checkbox.selected) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _username.text = [userDefaults objectForKey:@"username"];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

//username、password用TableViewを作成
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        switch (indexPath.section) {
            case 0:
                if (indexPath.row == 0) {
                    self.username = [[UITextField alloc] initWithFrame:CGRectMake(100, -1, 190, 50)];
                    self.username.returnKeyType = UIReturnKeyDone;
                    self.username.tag = 0;
                    self.username.placeholder = @"UserID";
                    self.username.delegate = self;
                    self.username.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
                    [cell addSubview:self.username];
                    cell.textLabel.text = @"Username";
                    cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
                    if ([self.username resignFirstResponder]) {
                        [self.username becomeFirstResponder];
                    }
                } else if (indexPath.row == 1) {
                    self.password = [[UITextField alloc] initWithFrame:CGRectMake(100, -1, 190, 50)];
                    self.password.returnKeyType = UIReturnKeyDone;
                    self.password.tag = 1;
                    self.password.placeholder = @"Password";
                    self.password.secureTextEntry = YES;
                    self.password.delegate = self;
                    self.password.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
                    [cell addSubview:self.password];
                    cell.textLabel.text = @"Password";
                    cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
                }
                break;
                
        }
    }
    return cell;
}

#pragma mark -
#pragma mark textField処理
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //キーボードを閉じる
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.tag == 1) {
        return YES;
    }
    //チェックボックスON時にTextfieldに編集があった場合チェックをOFFに
    if (_checkbox.selected) {
        _checkbox.selected = NO;
    }
    return YES;
}

#pragma mark -
#pragma mark ログインボタン押下処理
- (void)btnLoginOnClicked:(id)sender{
    //UsernameとPasswordが記入されていなければ処理停止
    if ((![_username.text isEqualToString:@""] && ![_password.text isEqualToString:@""])){
        //ライブラリを使用し保管したアカウントに紐付けされたパスワードを取得
        NSString *paswword = [LKKeychain getPasswordWithAccount:_username.text service:@"CommentMap"];
        
        if ([paswword isEqualToString:_password.text]) {
            //Segueで画面遷移を実行
            [self performSegueWithIdentifier:@"mainView" sender:self];
        }else{
            //ログイン時にパスワードが一致しなかった時のアラート処理
            loginAlert = [[UIAlertView alloc] initWithTitle:@"UsernameとPasswordが一致しません" message:nil
                                                   delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            [loginAlert show];
        }
    }
}

#pragma mark -
#pragma mark 新規アカウント作成ボタン処理
- (void)btnSignUpOnClicked:(id)sender{
    //UsernameとPasswordが記入されていなければ処理停止
    if ((![_username.text isEqualToString:@""] && ![_password.text isEqualToString:@""])) {
        //新規アカウント作成確認用アラート処理
        createAccountAlert =
        [[UIAlertView alloc] initWithTitle:@"新規アカウント作成" message:@"新しくアカウントを作成しますか？"
                                  delegate:self cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい", nil];
        createAccountAlert.delegate = self;
        [createAccountAlert show];
    }
}

// アラートボタン押下時の処理
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //新規アカウント作成確認用アラート処理
    if (createAccountAlert == alertView) {
        switch (buttonIndex) {
            case 0:
                NSLog(@"Cancel");
                break;
            case 1:
                NSLog(@"OK");
                //ライブラリを使用しアカウントとパスワードを作成管理
                [LKKeychain updatePassword:_password.text account:_username.text service:@"CommentMap"];
                break;
        }
    }
    
}

#pragma mark -
#pragma mark 画面遷移処理
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"mainView"]) {
        //画面遷移後のビューコントローラを取得
        MapViewController *mainViewController = [segue destinationViewController];
        
        //loginNameをtextField文字列から取得し次のViewプロパティへ受け渡し
        mainViewController.userName = _username.text;
    }
}

#pragma mark -
#pragma mark チェックボックス設定
-(void)checkbox:(UIButton *)button{
    //usernameへ入力がされていればチェックボックスをONに出来る
    if (![_username.text isEqualToString:@""]) {
        //ボタンの選択状態を設定
        _checkbox.selected = !_checkbox.selected;
        //usernameをUserDefaultsへ保存
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //スイッチの状態を保存
        [userDefaults setBool:_checkbox.selected forKey:@"checkButton"];
        //usernameを保存
        [userDefaults setObject:_username.text forKey:@"username"];
        [userDefaults synchronize];
    }
    NSLog(@"button %d",_checkbox.selected);
}
@end