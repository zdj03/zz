//
//  ZzViewController.m
//  ZzResponderEvent
//
//  Created by 周登杰 on 2019/9/25.
//  Copyright © 2019 zdj. All rights reserved.
//

#import "ZzViewController.h"
#import "AView.h"
@interface ZzViewController ()
@property (nonatomic, strong)AView *b ;

@end

@implementation ZzViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundColor:UIColor.blackColor];
    [btn setFrame:CGRectMake(10, 200, 40, 40)];
    [btn addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    AView *b = [AView new];
    b.frame = CGRectMake(100, 100, 100, 100);
    b.backgroundColor = UIColor.redColor;
    [b addTarget:self selector:@selector(tapAView)];
    [self.view addSubview:b];
    self.b = b;
}

- (void)tapAView {
    NSLog(@"tapAView");
}

- (void)btnClicked{
    [self dismissViewControllerAnimated:YES   completion:nil];
}

- (void)dealloc{
    NSLog(@"ZzVC dealloc");
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
