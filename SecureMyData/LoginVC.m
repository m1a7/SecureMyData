//
//  LoginVC.m
//  SecureMyData
//
//  Created by MD on 27.02.16.
//  Copyright © 2016 MD. All rights reserved.
//

#import "LoginVC.h"
#import "DocumentsTVC.h"

#import "Keychain.h"

#define SERVICE_NAME @"ANY_NAME_FOR_YOU"


@interface LoginVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) Keychain* keychain;

@end


@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.keychain =[[Keychain alloc] initWithService:SERVICE_NAME withGroup:nil];
    self.loginTextField.text = @"rostov888";
    self.passwordTextField.text = @"zvezda";
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


#pragma mark - Action

- (IBAction)goRegisterAction:(UIButton *)sender {
    
    UIAlertAction* cancle = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    // Check on empty field
    if (self.loginTextField.text.length<1 || self.passwordTextField.text.length<1) {
        [self showMessage:@"Enter login & password" andTitle:@"Error" withButtons:@[cancle]];
        
    } else { // if the fields are filled in
        BOOL successFoundLoginAndPass = [self checkPasswordWithLogin:self.loginTextField.text withPass:self.passwordTextField.text];
        
        if (!successFoundLoginAndPass) {
            [self createNewAccount:self.loginTextField.text withPass:self.passwordTextField.text];
        } else {
            DocumentsTVC *docTVC = [[DocumentsTVC alloc] initWithStyle:UITableViewStylePlain];
            UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:docTVC];
            [self presentViewController:nav animated:YES completion:nil];  
        }
    }
}

#pragma mark - Helper methods

-(void) showMessage:(NSString*) message andTitle:(NSString*) title withButtons:(NSArray*) bntArray {
    
    UIAlertController * alert=   [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (bntArray.count>0) {
        for (UIAlertAction* button in bntArray) {
            [alert addAction:button];
        }
    }
    [self presentViewController:alert animated:YES completion:nil];
}


-(void) createNewAccount:(NSString*) login withPass:(NSString*) password {
    
    UIAlertAction* cancle = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction* createAccountButton =  [UIAlertAction actionWithTitle:@"Create"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction* action) {
                                                                     
                                                                     NSData *  value = [password dataUsingEncoding:NSUTF8StringEncoding];
                                                                     
                                                                     if ([self.keychain insert:login :value]) {
                                                                         [self showMessage:@"Account successfully created" andTitle:@"Success" withButtons:@[cancle]];
                                                                     }else {
                                                                         [self showMessage:@"Failed to add data" andTitle:@"Error" withButtons:@[cancle]];
                                                                     }}];
    
    [self showMessage:@"Create new account ?" andTitle:@"Stop" withButtons:@[createAccountButton,cancle]];
}


-(BOOL) checkPasswordWithLogin:(NSString*) login withPass:(NSString*) password  {
    
    UIAlertAction* cancle = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    NSData*   data = [self.keychain find:login];
    
    if (data) {
        NSString* pass = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (![self.passwordTextField.text isEqualToString:pass]) {
             [self showMessage:@"Wrong password" andTitle:@"Error" withButtons:@[cancle]];
             return NO;
        } else {
            NSLog(@"Login is success");
        }
        return YES;
    }
    return NO;
}

@end
