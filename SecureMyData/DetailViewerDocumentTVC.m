//
//  DetailViewerDocumentTVC.m
//  SecureMyData
//
//  Created by MD on 27.02.16.
//  Copyright © 2016 MD. All rights reserved.
//

#import "DetailViewerDocumentTVC.h"
#import "CellDetail.h"


#define ArraySaveInKeyChain @"ArraySaveInKeyChain"
#define SERVICE_NAME @"ANY_NAME_FOR_YOU"

typedef enum {
    OpenLibrary,
    OpenCamera
} ActionOpenImagePicker;

@interface DetailViewerDocumentTVC ()

@end


@implementation DetailViewerDocumentTVC

-(void) loadView {
    [super loadView];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.keychain = [[Keychain alloc] initWithService:SERVICE_NAME withGroup:nil];
    self.navigationItem.title = @"Secret`s Doc";
    
    UIBarButtonItem *addPhoto = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewPhoto:)];
    self.navigationItem.rightBarButtonItem = addPhoto;
}

-(void) dealloc {
    
    if ([self.delegate respondsToSelector:@selector(sendDataToA:)]){
        [self.delegate sendDataToA:self.currentDoc];
    }    
}


#pragma mark - Action

-(void) addNewPhoto:(UIBarButtonItem*) sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                @"Add Photo" message:@"Select action" preferredStyle:UIAlertControllerStyleActionSheet];
  
    UIAlertAction* actionDel = [UIAlertAction actionWithTitle:@"From Library" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [self openCamera:OpenLibrary];
                                                      }];
    
    UIAlertAction* actionAdd = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [self openCamera:OpenCamera];
                                                      }];
   
    UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Cancle" style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:actionDel];
    [alert addAction:actionAdd];
    [alert addAction:actionCancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma marl - Open UIImagePickerController

-(void) openCamera:(ActionOpenImagePicker) action {
    
    UIImagePickerController *imagePicker =[[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil];
    imagePicker.allowsEditing = YES;

    
    if (action == OpenLibrary){
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    } else if (action == OpenCamera){
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
    }
    
    [self presentViewController:imagePicker  animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];

    if (!self.currentDoc.arrayPhotos){
        self.currentDoc.arrayPhotos = [NSMutableArray array];
    }
    
    [self.currentDoc.arrayPhotos insertObject:chosenImage atIndex:0];
    
    // save in memory in dealoc
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.currentDoc.arrayPhotos[indexPath.row] isKindOfClass:[UIImage class]]) {
         return 250.f;
    }
    return 50.f;
}


#pragma mark - UITableViewDataSource


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.currentDoc.arrayPhotos removeObjectAtIndex:indexPath.row];        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentDoc.arrayPhotos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"CellDetailPhoto";
    CellDetail *cell = (CellDetail *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellDetailPhoto" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if ([self.currentDoc.arrayPhotos[indexPath.row] isKindOfClass:[UIImage class]]) {
        UIImage* img = self.currentDoc.arrayPhotos[indexPath.row];
        cell.imgView.image = img;
    }

    cell.txtabel.text = self.currentDoc.name;
    return cell;
}


@end
