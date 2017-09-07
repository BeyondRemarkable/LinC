//
//  BRLoginViewController.m
//  LinC
//
//  Created by zhe wu on 8/18/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRLoginViewController.h"
#import "BRTabBarController.h"
#import <AFNetworking.h>

@interface BRLoginViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;

@property (weak, nonatomic) IBOutlet UITextField *userID;
@property (weak, nonatomic) IBOutlet UITextField *password;



@end

@implementation BRLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];


    // Do any additional setup after loading the view.
//    NSString *URLString = @"http://result.eolinker.com/narZcZX99a011291c85f9c02ed38bd1e5219ede029d8ceb?uri=/api/v1/account/profile/show";
//    //    NSDictionary *parameters = @{@"foo": @"bar", @"baz": @[@1, @2, @3]};
//    
//    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//    
//    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)registerBtn:(id)sender {
}
- (IBAction)login {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    BRTabBarController *vc = [storyboard instantiateViewControllerWithIdentifier:@"BRTabBarController"];
    [[UIApplication sharedApplication].keyWindow setRootViewController:vc];
    
}

/**
 *  Close the keyboard
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
