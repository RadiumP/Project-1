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

@end

@implementation StatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.numbers = [[NSMutableArray alloc]init];
    [self loadInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadInfo{
    PFQuery *query = [PFQuery queryWithClassName:@"UserData"];
    [query whereKey:@"user" equalTo:[[PFUser currentUser] username]];
    
    //[query findObjectsInBackgroundWithBlock:^(NSArray *transactions, NSError *error) {
    for (PFObject *transaction in [query findObjects]) {
        NSString *amount = transaction[@"amount"];
        [self.numbers insertObject:amount atIndex:0];
    }
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // this method is more complicated with multiple sections
    return self.numbers.count;
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    //cell.imageView.image = ; // UIImage
    NSString *number = [self.numbers objectAtIndex:indexPath.row];
    cell.textLabel.text = number; // title
    // cell.detailTextLabel.text = ; // subtitle
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row % 2 == 0)
        cell.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.1];
    else
        cell.backgroundColor = [UIColor whiteColor];
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
