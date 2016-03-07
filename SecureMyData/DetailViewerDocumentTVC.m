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


@interface DetailViewerDocumentTVC ()

@end


@implementation DetailViewerDocumentTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.keychain = [[Keychain alloc] initWithService:SERVICE_NAME withGroup:nil];
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
    
    /*
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
#if TARGET_OS_SIMULATOR
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
#else
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
#endif
    
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    */
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePickerCamera =[[UIImagePickerController alloc] init];
        imagePickerCamera.delegate = self;
        imagePickerCamera.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil];
        imagePickerCamera.allowsEditing = YES;
        imagePickerCamera.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:imagePickerCamera  animated:YES completion:nil];
    }
    
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePickerAlbum =[[UIImagePickerController alloc] init];
        imagePickerAlbum.delegate = self;
        imagePickerAlbum.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil];
        imagePickerAlbum.allowsEditing = YES;
        imagePickerAlbum.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:imagePickerAlbum animated:YES completion:nil];
    }
    
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
    //return 60.f;
    
    if ([self.currentDoc.arrayPhotos[indexPath.row] isKindOfClass:[UIImage class]]) {
        
        UIImage* img = self.currentDoc.arrayPhotos[indexPath.row];
        UIImageView* imgView = [[UIImageView alloc] initWithImage:img];
        NSLog(@"%f",CGRectGetWidth(imgView.bounds));
        
        //return CGRectGetWidth(imgView.bounds);
        return 250.f;
    }
    
    
    return 50.f;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentDoc.arrayPhotos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    
//    static NSString *CellIdentifier = @"CellDetail";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    
//    cell.textLabel.text = @"s";
//    
//    return cell;
    
//////////////////
    
//    static NSString *CellIdentifier = @"CellDetail";
//
//    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    
//    
//        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CellDetail" owner:self options:nil];
//        cell = [topLevelObjects objectAtIndex:0];
//
//    }
//    cell.textLabel.text = @"s";
//    return cell;

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
