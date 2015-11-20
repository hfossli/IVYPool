//
//  MasterViewController.h
//  IVYPoolDemo
//
//  Created by Håvard Fossli on 20.11.2015.
//  Copyright © 2015 Håvard Fossli. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;


@end

