//
//  StatsViewController.m
//  SolarPowered
//
//  Created by mkarlsru on 11/10/14.
//  Copyright (c) 2014 jkhart1. All rights reserved.
//

#import "StatsViewController.h"

@interface StatsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *numbers;
@property NSString *cost;
@property NSString *billnew;
@property NSString *bill;
@property NSString *result;
@property NSString *total;
@end

@implementation StatsViewController

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = [[PFUser currentUser]username];
        
        self.pullToRefreshEnabled = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

  
}

/*
-(void)loadInfo
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserData"];
    [query whereKey:@"user" equalTo:[[PFUser currentUser] username]];
    
    //[query findObjectsInBackgroundWithBlock:^(NSArray *transactions, NSError *error) {
    for (PFObject *transaction in [query findObjects]) {
        NSString *amount = transaction[@"save"];
        NSString *date = transaction[@"createdAt"];
        [self.numbers insertObject:amount atIndex:0];
        [self.numbers insertObject:date atIndex:0];
    }
}
*/
#pragma mark - Table view data source




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    // Configure the cell
    cell.textLabel.text = [object objectForKey:@"save"];
    
    NSDate *date = [object createdAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Date: %@", [dateFormat stringFromDate:date]];
    // NSString *date = [cell.detailTextLabel text];
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row % 2 == 0)
        cell.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:209.0/255.0 blue:20.0/255.0 alpha:1.0];
    else
        cell.backgroundColor = [UIColor colorWithRed:199.0/255.0 green:0.0 blue:6.0/255.0 alpha:1.0];
}




- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"history"]) {
        HistoryViewController *dest = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //get certain row
        PFObject *passObj = [self.objects objectAtIndex:indexPath.row];
        
        dest.total = [passObj objectForKey:@"save"];
        dest.cost = [passObj objectForKey:@"cost"];
        dest.result = [passObj objectForKey:@"result"];
        dest.billnew = [passObj objectForKey:@"billnew"];
        dest.bill = [passObj objectForKey:@"bill"];
        
        NSLog(@"%@",self.total);
    }
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
