//
//  MGDrawerViewController.h
//
//  Copyright (c) 2011 Mattieu Gamache-Asselin. All rights reserved.

#import <UIKit/UIKit.h>
#import "MGAMenuController.h"

typedef enum {
    kPUSH,
    kSET_ROOT,
    kACTION_BLOCK
} DrawerRowType;


@interface MGADrawerViewController: UIViewController <MGADrawerViewControllerProtocol, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) MGAMenuController *menuController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) UIImage *chevronImage;
@property (nonatomic, strong) UIImage *chevronImageActive;
@property (nonatomic, assign) NSInteger drawerWidth;
@property (nonatomic, assign) BOOL isLeftDrawer;

- (void) actionExample;

@end
