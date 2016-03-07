//
//  DetailViewerDocumentTVC.h
//  SecureMyData
//
//  Created by MD on 27.02.16.
//  Copyright © 2016 MD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "Keychain.h"
#import "DocModel.h"

@protocol DelegatePassDataToFirstVC <NSObject>
-(void)sendDataToA:(DocModel*)model;
@end


@interface DetailViewerDocumentTVC : UITableViewController  <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) Keychain* keychain;
@property (strong, nonatomic) DocModel* currentDoc;
@property (weak, nonatomic) id <DelegatePassDataToFirstVC>    delegate;

@end
