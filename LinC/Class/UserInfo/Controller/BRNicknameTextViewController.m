//
//  UserNameTextViewController.m
//  LinC
//
//  Created by zhe wu on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRNicknameTextViewController.h"

@interface BRNicknameTextViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;


@end

@implementation BRNicknameTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.nicknameTextField.text = self.nameText;
    [self.nicknameTextField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    [self.nicknameTextField becomeFirstResponder];
    
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"save" style:UIBarButtonItemStylePlain target:self action:@selector(saveBtn)];
    saveBtn.enabled = NO;
    self.navigationItem.rightBarButtonItem = saveBtn;
    
}

- (void)saveBtn {
    if (_delegate && [_delegate respondsToSelector:@selector(nicknameDidChangeTo:)]) {
        [_delegate nicknameDidChangeTo:[self.nicknameTextField.text trimString]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidChange {
    if ([self.nicknameTextField.text isEqualToString:self.nameText]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}


@end
