//
//  ViewController.m
//  ZzResponderEvent
//
//  Created by 周登杰 on 2019/9/25.
//  Copyright © 2019 zdj. All rights reserved.
//

#import "ViewController.h"
#import "BView.h"
#import "CView.h"
#import "DView.h"
#import "ZzTapGestureRecognizer.h"
#import "ZzViewController.h"
@interface ViewController ()

@property (nonatomic, strong)AView *b ;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   
//    AView *b = [AView new];
//    b.frame = CGRectMake(100, 100, 100, 100);
//    b.backgroundColor = UIColor.redColor;
//   // [b addTarget:self selector:@selector(tapAView)];
//    [self.view addSubview:b];
//    self.b = b;
    
    ZzTapGestureRecognizer *tapb = [[ZzTapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAView)];
    [self.view addGestureRecognizer:tapb];
}

- (void)tapAView {
    
    [self presentViewController:ZzViewController.new animated:YES completion:nil];
    
}


- (void)addGestureToResponderChain {
    BView *b = [BView new];
    b.frame = CGRectMake(100, 100, 100, 100);
    b.backgroundColor = UIColor.redColor;
    [self.view addSubview:b];
    
    
    ZzTapGestureRecognizer *tapb = [[ZzTapGestureRecognizer alloc] initWithTarget:self action:@selector(tapB)];
    [b addGestureRecognizer:tapb];
    
    
    CView *c = [CView new];
    c.frame = CGRectMake(10, 10, 80, 80);
    c.backgroundColor = UIColor.greenColor;
    [b addSubview:c];
    
    
    ZzTapGestureRecognizer *tapc = [[ZzTapGestureRecognizer alloc] initWithTarget:self action:@selector(tapC)];
    [c addGestureRecognizer:tapc];
    
    DView *d = [DView new];
    d.frame = CGRectMake(10, 10, 60, 60);
    d.backgroundColor = UIColor.orangeColor;
    [c addSubview:d];
    
    
    ZzTapGestureRecognizer *tapd = [[ZzTapGestureRecognizer alloc] initWithTarget:self action:@selector(tapD)];
    [d addGestureRecognizer:tapd];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundColor:UIColor.blackColor];
    [btn setFrame:CGRectMake(10, 10, 40, 40)];
    [btn addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
    [d addSubview:btn];
    
    ZzTapGestureRecognizer *tapdBtn = [[ZzTapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBtn)];
    [btn addGestureRecognizer:tapdBtn];
}

- (void)tapBtn {
    NSLog(@"tapBtn");
}

- (void)btnClicked {
    NSLog(@"btnClicked");
}

- (void)tapB{
    NSLog(@"BView tapped");
}

- (void)tapC{
    NSLog(@"CView tapped");
}

- (void)tapD{
    NSLog(@"DView tapped");
}

- (void)addSubviews {
    
    BView *b = [BView new];
    b.frame = CGRectMake(100, 100, 100, 100);
    b.backgroundColor = UIColor.redColor;
    [self.view addSubview:b];
    
   
    ZzTapGestureRecognizer *tap = [[ZzTapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [b addGestureRecognizer:tap];
}

- (void)tap{
    NSLog(@"BView tapped");
}

@end
