//
//  RCMicAgreementWebVC.m
//  SealMic
//
//  Created by rongyun on 2020/11/16.
//  Copyright © 2020 rongyun. All rights reserved.
//

#import "RCMicAgreementWebVC.h"
#import <WebKit/WebKit.h>
#import "RCMicMacro.h"

@interface RCMicAgreementWebVC ()
@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backBtn;
@end

@implementation RCMicAgreementWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = RCMicColor(HEXCOLOR(0xF8F9FB, 1.0), HEXCOLOR(0xF8F9FB, 1.0));
    [self addSubviews];
    [self addConstraints];
    [self loadLocalHtml];
}

- (void)addSubviews {
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.webView];
}

- (void)addConstraints {
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat margin = [RCMicUtil statusBarHeight] + 10;
        make.top.equalTo(self.view).with.offset(margin);
        make.left.mas_equalTo(16);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat margin = [RCMicUtil statusBarHeight];
        make.top.equalTo(self.view).with.offset(margin);
        make.height.mas_equalTo(44);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat margin = [RCMicUtil topSafeAreaHeight];
        make.top.mas_equalTo(margin);
        make.left.right.bottom.mas_equalTo(0);
    }];
}

- (void)loadLocalHtml {
    NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"agreement_zh" ofType:@"html"];
    NSString *html;
    NSURL *baseURL = [NSURL fileURLWithPath:htmlFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:htmlFilePath]) {
            NSString *string = [NSString stringWithContentsOfFile:htmlFilePath
                                                         encoding:NSUTF8StringEncoding
                                                            error:nil];
            if (string) {
                html = string;
            }
    }
    
    [self.webView loadHTMLString:html baseURL:baseURL];
}

#pragma mark - Actions
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getters & Setters
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.text = RCMicLocalizedNamed(@"rongcloud_product_Usage_Agreement");
        _titleLabel.font = RCMicFont(18, @"PingFangSC-Medium");
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = RCMicColor(HEXCOLOR(0x000000, 1.0), HEXCOLOR(0x000000, 1.0));
    }
    return _titleLabel;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_backBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (WKWebView *)webView {
    if (!_webView){
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    }
    return _webView;
}
@end
