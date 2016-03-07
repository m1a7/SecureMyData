//
//  LoginVC.h
//  SecureMyData
//
//  Created by MD on 27.02.16.
//  Copyright © 2016 MD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Security/Security.h>

@interface LoginVC : UIViewController

- (IBAction)goRegisterAction:(UIButton *)sender;

- (void) showMessage:(NSString*) message andTitle:(NSString*) title withButtons:(NSArray*) bntArray;
- (BOOL) checkPasswordWithLogin:(NSString*) login withPass:(NSString*) password;

@end
