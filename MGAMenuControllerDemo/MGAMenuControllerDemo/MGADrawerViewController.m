//
//  MGDrawerViewController.m
//
//  Copyright (c) 2011 Mattieu Gamache-Asselin. All rights reserved.

#import "MGADrawerViewController.h"
#import "MGADrawerCell.h"
#import "MGAMenuController.h"
#import "MainViewController.h"
#import "BlueViewController.h"
#import "RedViewController.h"
#import "GreenViewController.h"

@implementation MGADrawerViewController

@synthesize theMenuController, tableData, tableView, drawerView;
@synthesize drawerWidth = _drawerWidth;
@synthesize isLeftDrawer = _isLeftDrawer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.drawerWidth = 250;
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) style:UITableViewStylePlain];
        [tableView setSeparatorColor:[UIColor darkGrayColor]];
        [tableView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
        [tableView setDelegate:self];
        [tableView setDataSource:self];
                
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
        tableData = [[NSMutableArray alloc] initWithObjects:
                        [[NSMutableArray alloc] initWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:@"Set Root 1", @"title", [NSNumber numberWithInt:kSET_ROOT], @"rowType", mainVC, @"object", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"Set Root 2", @"title", [NSNumber numberWithInt:kSET_ROOT], @"rowType", greenVC, @"object", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"Push VC 1", @"title", [NSNumber numberWithInt:kPUSH], @"rowType", blueVC, @"object", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"Push VC 2", @"title", [NSNumber numberWithInt:kPUSH], @"rowType", redVC, @"object", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"Action 1", @"title", [NSNumber numberWithInt:kACTION_BLOCK], @"rowType", actionBlock, @"object", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"Action 2", @"title", [NSNumber numberWithInt:kACTION_SEL], @"rowType", [NSValue valueWithPointer:@selector(actionExample)], @"object", self, @"target", nil],
                        nil],
                     nil];
        
        sectionIndex = -1;
    }
    return self;
}

- (void) actionExample {
    [[[UIAlertView alloc] initWithTitle:@"Example Alert" message:@"This is an alert!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];//[[UIScreen mainScreen] bounds]];
    [view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    
    drawerView = tableView;
    
    [view addSubview:tableView];
    [self setView:view];
}

-(void)setMenuController:(MGAMenuController *)menuController {
    [self setTheMenuController:menuController];
}

- (void)viewWillAppear:(BOOL)animated {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO]; 
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *currentRow = [[tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    DrawerRowType rowType = [[currentRow objectForKey:@"rowType"] intValue];
    
    if (rowType == kPUSH) {
        [theMenuController pushViewController:[currentRow objectForKey:@"object"]];
    } else if (rowType == kSET_ROOT) {
        [theMenuController setRootViewController:[currentRow objectForKey:@"object"] animated:YES];
    } else if (rowType == kACTION_BLOCK) {
        void (^actionBlock)() = [currentRow objectForKey:@"object"];
        actionBlock();
        //[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES]; 
    } else if (rowType == kACTION_SEL) {
        [[currentRow objectForKey:@"target"] performSelector:[[currentRow objectForKey:@"object"] pointerValue]];
        //[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    }
}


#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [[tableData objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    // Acquire the cell. 
    MGADrawerCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MGADrawerCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryPosition = self.drawerWidth - 40;
        cell.indentationWidth = [UIScreen mainScreen].bounds.size.width - self.drawerWidth + 10;
        cell.indentationLevel = !self.isLeftDrawer;
        if (indexPath.row > 3) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    cell.textLabel.text = [[[tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    DrawerRowType rowType = [[[[tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"rowType"] intValue];
    if (rowType == kACTION_SEL || rowType == kACTION_BLOCK) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [cell layoutIfNeeded];
    
    return cell;
}


- (UIView *) tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(self.isLeftDrawer ? 10.0 : [UIScreen mainScreen].bounds.size.width - self.drawerWidth + 10, 0.0, [[UIScreen mainScreen] bounds].size.width, [self tableView:self.tableView heightForHeaderInSection:section])];
    customView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor grayColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.frame = CGRectMake(self.isLeftDrawer ? 11 : [UIScreen mainScreen].bounds.size.width - self.drawerWidth + 10,0, customView.frame.size.width, customView.frame.size.height);
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
