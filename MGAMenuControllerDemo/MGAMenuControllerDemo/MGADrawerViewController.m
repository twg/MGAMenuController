//
//  MGDrawerViewController.m
//
//  Copyright (c) 2011 Mattieu Gamache-Asselin. All rights reserved.

#import "MGADrawerViewController.h"
#import "MGAMenuController.h"
#import "MainViewController.h"
#import "BlueViewController.h"
#import "RedViewController.h"
#import "GreenViewController.h"

@implementation MGADrawerViewController

@synthesize menuController = _menuController; 
@synthesize tableData = _tableData;
@synthesize tableView = _tableView;
@synthesize drawerView = _drawerView;
@synthesize drawerWidth = _drawerWidth;
@synthesize isLeftDrawer = _isLeftDrawer;
@synthesize chevronImage = _chevronImage;
@synthesize chevronImageActive = _chevronImageActive;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.drawerWidth = 250;
        
        self.chevronImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UITableNext" ofType:@"png"]];
        self.chevronImageActive = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UITableNextSelected" ofType:@"png"]];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) style:UITableViewStylePlain];
        [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
        [self.tableView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
                
        //Test Data
        void (^actionBlock)() = ^{        
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Test sheet" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"asd" otherButtonTitles: nil];
            [sheet showInView:self.view];
        };
        MainViewController *mainVC = [[MainViewController alloc] init];
        BlueViewController *blueVC = [[BlueViewController alloc] init];
        RedViewController *redVC = [[RedViewController alloc] init];
        GreenViewController *greenVC = [[GreenViewController alloc] init];
        
        /*
         tableData has this format:
         NSArray                //Container Array
            NSArray             //Represents a Section of the table
                NSDictionary    //Represents a Row of the table, in the given section
                NSDictionary    //keys: label (title displayed), rowType (one of enum DrawerRowType), object (parameter)
            NSArray
         ...
         */
        self.tableData = [[NSMutableArray alloc] initWithObjects:
                        [[NSMutableArray alloc] initWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:@"Set Root 1", @"title", [NSNumber numberWithInt:kSET_ROOT], @"rowType", mainVC, @"object", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"Set Root 2", @"title", [NSNumber numberWithInt:kSET_ROOT], @"rowType", greenVC, @"object", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"Push VC 1", @"title", [NSNumber numberWithInt:kPUSH], @"rowType", blueVC, @"object", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"Push VC 2", @"title", [NSNumber numberWithInt:kPUSH], @"rowType", redVC, @"object", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"Action 1", @"title", [NSNumber numberWithInt:kACTION_BLOCK], @"rowType", actionBlock, @"object", nil],
                        nil],
                     nil];        
    }
    return self;
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];//[[UIScreen mainScreen] bounds]];
    [view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    
    self.drawerView = self.tableView;
    
    [view addSubview:self.tableView];
    [self setView:view];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO]; 
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *currentRow = [[self.tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    DrawerRowType rowType = [[currentRow objectForKey:@"rowType"] intValue];
    
    if (rowType == kPUSH) {
        [self.menuController pushViewController:[currentRow objectForKey:@"object"]];
    } else if (rowType == kSET_ROOT) {
        [self.menuController setRootViewController:[currentRow objectForKey:@"object"] animated:YES];
    } else if (rowType == kACTION_BLOCK) {
        void (^actionBlock)() = [currentRow objectForKey:@"object"];
        actionBlock();
    }
}


#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [[self.tableData objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    // Acquire the cell. 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.chevronImage highlightedImage:self.chevronImageActive];
        imageView.tag = indexPath.row;
        
        if (self.menuController.leftDrawer == self) {
            imageView.frame = CGRectMake(self.drawerWidth - imageView.image.size.width - 10, ([self tableView:tableView heightForRowAtIndexPath:indexPath] - imageView.image.size.height) * 0.5, imageView.image.size.width, imageView.image.size.height);        
        }
        else {
            imageView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - imageView.image.size.width - 10, ([self tableView:tableView heightForRowAtIndexPath:indexPath] - imageView.image.size.height) * 0.5, imageView.image.size.width, imageView.image.size.height);        
        }
        
        [cell addSubview:imageView];
        
        // Set indentation level for right drawer
        cell.indentationWidth = [UIScreen mainScreen].bounds.size.width - self.drawerWidth + 10;
    }
    
    // Indent cell for right drawer
    if (self.menuController.leftDrawer == self) {
        cell.indentationLevel = 0;
    }
    else if (self.menuController.rightDrawer == self) {
        cell.indentationLevel = 1;
    }
    
    cell.textLabel.text = [[[self.tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    DrawerRowType rowType = [[[[self.tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"rowType"] intValue];
    if (rowType == kACTION_BLOCK) {
        [[cell.contentView viewWithTag:indexPath.row] setHidden:YES];
    } else {
        [[cell.contentView viewWithTag:indexPath.row] setHidden:NO];
    }
        
    return cell;
}

- (UIView *) tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
    UIView* customView = [[UIView alloc] init];
    if (self.menuController.leftDrawer == self) {
        customView.frame = CGRectMake(7, 0, [[UIScreen mainScreen] bounds].size.width, [self tableView:self.tableView heightForHeaderInSection:section]);
    }
    else {
        customView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - self.menuController.rightDrawerWidth + 15, 0, [UIScreen mainScreen].bounds.size.width, [self tableView:self.tableView heightForHeaderInSection:section]);
    }
    
    customView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor grayColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    if (self.menuController.leftDrawer == self) {
        headerLabel.frame = CGRectMake(8, 0, customView.frame.size.width, customView.frame.size.height);
    }
    else {
        headerLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - self.menuController.rightDrawerWidth + 16, 0, customView.frame.size.width, customView.frame.size.height);
    }
    headerLabel.textAlignment = UITextAlignmentLeft;
    headerLabel.text = [self tableView:aTableView titleForHeaderInSection:section];
    [customView addSubview:headerLabel];
    return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
        return 30.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Default Menu";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
