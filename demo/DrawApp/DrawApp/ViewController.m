//
//  ViewController.m
//  DrawApp
//
//  Created by 周登杰 on 2020/11/7.
//

#import "ViewController.h"
#import "DrawView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DrawView *drawView = [[DrawView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:drawView];
    
    
}


@end
