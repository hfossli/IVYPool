//
//  DetailViewController.h
//  IVYPoolDemo
//
//  Created by Håvard Fossli on 20.11.2015.
//  Copyright © 2015 Håvard Fossli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

