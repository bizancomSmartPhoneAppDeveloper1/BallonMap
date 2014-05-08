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

@end

@implementation LoginViewController

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
    
    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    btnLogin.backgroundColor = [UIColor whiteColor];
    btnLogin.frame = CGRectMake(30, 150, 260, 34);
    [btnLogin setTitle:@"Login" forState:UIControlStateNormal];
    [btnLogin addTarget:self action:@selector(btnLoginOnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnLogin];
    
    UIButton *btnSignUp = [UIButton buttonWithType:UIButtonTypeSystem];
    btnSignUp.backgroundColor = [UIColor whiteColor];
    btnSignUp.frame = CGRectMake(30, 190, 260, 34);
    [btnSignUp setTitle:@"Sign Up" forState:UIControlStateNormal];
    [btnSignUp addTarget:self action:@selector(btnSignUpOnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSignUp];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

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
                    self.username = [[UITextField alloc] initWithFrame:CGRectMake(100.0, -1.0, 200.0, 50.0)];
                    self.username.returnKeyType = UIReturnKeyDone;
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
                    self.password = [[UITextField alloc] initWithFrame:CGRectMake(100.0, -1.0, 200.0, 50.0)];
                    self.password.returnKeyType = UIReturnKeyDone;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"mainView"]) {
        //画面遷移後のビューコントローラを取得
        MapViewController *mainViewController = [segue destinationViewController];
        
        //loginNameをtextField文字列から取得し次のViewプロパティへ受け渡し
        mainViewController.userName = _username.text;
    }
}

@end