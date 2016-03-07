//
//  DocumentsTVC.m
//  SecureMyData
//
//  Created by MD on 27.02.16.
//  Copyright © 2016 MD. All rights reserved.
//

#import "DocumentsTVC.h"
#import "DetailViewerDocumentTVC.h"
#import "DocModel.h"
#import "Keychain.h"

#define ArraySaveInKeyChain @"ArraySaveInKeyChain"
#define SERVICE_NAME @"ANY_NAME_FOR_YOU"

@interface DocumentsTVC () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, DelegatePassDataToFirstVC>

@property (strong, nonatomic) NSMutableArray* arrayDocuments;
@property (strong, nonatomic) UITextField* textFieldDocuments;
@property (strong, nonatomic) Keychain* keychain;

@property (strong, nonatomic) NSIndexPath* selectedIndexPath;
@end

@implementation DocumentsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.keychain = [[Keychain alloc] initWithService:SERVICE_NAME withGroup:nil];
    
    self.arrayDocuments = [NSMutableArray array];
    self.textFieldDocuments = [[UITextField alloc] initWithFrame:CGRectZero];
    
    self.navigationController.navigationBar.barStyle     = UIBarStyleBlackOpaque;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.333 green:0.584 blue:0.820 alpha:1.000];
    self.navigationController.navigationBar.tintColor    = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addNewDocument:)];
    
    UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                               target:self
                                                                               action:@selector(trashAllDocument:)];
    
    self.navigationItem.title = @"My Documents";
    self.navigationItem.rightBarButtonItems = @[addButton,trashButton];    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self parseDataFromKeyChain];
}

#pragma mark - DelegatePassDataToFirstVC

-(void)sendDataToA:(DocModel*)model {
    
    self.arrayDocuments[self.selectedIndexPath.row] = model;
    [self saveInMemory];
}

#pragma mark - Action

-(void) addNewDocument:(UIBarButtonItem*) sender{
    
    UIAlertAction* cancle = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction* createNewDoc =  [UIAlertAction actionWithTitle:@"Create"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction* action) {
                                                                     
                                                                     DocModel* doc = [[DocModel alloc] initWithName:self.textFieldDocuments.text];
                                                                     [self.arrayDocuments insertObject:doc atIndex:0];
                                                                     
                                                                     // Update
                                                                     [self saveInMemory];
                                                                     self.textFieldDocuments = nil;
                                                                     
                                                                     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                                                     [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                                                     }];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Add New Document"
                                                                        message:@"Enter your text"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.delegate = self;
        textField.placeholder = @"Enter name new doc";
        self.textFieldDocuments = textField;
    }];
    
    [controller addAction:cancle];
    [controller addAction:createNewDoc];
    [self presentViewController:controller animated:YES completion:nil];
}



-(void) trashAllDocument:(UIBarButtonItem*) sender{
    
    UIAlertAction* cancle = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction* deleteAllDocs =  [UIAlertAction actionWithTitle:@"Delete All"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction* action) {

                                                              [self.arrayDocuments removeAllObjects];
                                                              [self.keychain remove:ArraySaveInKeyChain];
                                                              NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,1)];
                                                              [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationTop];
                                                          }];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Delete all Documents"
                                                                        message:@"Delete permanently"
                                                                 preferredStyle:UIAlertControllerStyleAlert];

    [controller addAction:cancle];
    [controller addAction:deleteAllDocs];
    
    [self presentViewController:controller animated:YES completion:nil];
}



#pragma mark - Work with data

-(void) parseDataFromKeyChain
{
        NSData* data = [self.keychain find:ArraySaveInKeyChain];
        NSArray* array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self.arrayDocuments removeAllObjects];
        [self.arrayDocuments addObjectsFromArray:array];
   
        [self.tableView reloadData];
}


-(void) saveInMemory {

    ANDispatchBlockToBackgroundQueue(^{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.arrayDocuments];
        
        if (![self.keychain find:ArraySaveInKeyChain]) {
            NSLog(@"Не нашел! Создаем");
            
            if ([self.keychain insert:ArraySaveInKeyChain :data]) {
                NSLog(@"Успешно создали!");
            }
        } else {
            [self.keychain update:ArraySaveInKeyChain :data]?  NSLog(@"Ошибка сохранения!") : NSLog(@"Нормально обновили!");
        }
    });
   
}



#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Row
    return 40.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // Header
    return 40.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    self.selectedIndexPath = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    DetailViewerDocumentTVC *detailDocTVC = [[DetailViewerDocumentTVC alloc] initWithStyle:UITableViewStylePlain];
    detailDocTVC.currentDoc = [DocModel new];
    detailDocTVC.currentDoc = self.arrayDocuments[indexPath.row];
    detailDocTVC.delegate   = self;


    [self.navigationController pushViewController:detailDocTVC animated:YES];
}


#pragma mark - UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.arrayDocuments removeObjectAtIndex:indexPath.row];
        [self saveInMemory];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrayDocuments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    DocModel* model = self.arrayDocuments[indexPath.row];
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos",model.arrayPhotos.count];
    return cell;
}

@end
