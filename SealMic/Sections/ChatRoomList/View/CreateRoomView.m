//
//  CreateRoomView.m
//  SealMic
//
//  Created by 孙浩 on 2019/5/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "CreateRoomView.h"
#import "RandomUtil.h"

#define BgViewHeight 267
#define TypeBtnWidth 90
#define TypeBtnHeight 27
#define MaxLength 15

@interface CreateRoomView ()<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UILabel *roomNamePrompt;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *randomBtn;
@property (nonatomic, strong) UIView *typeBtnBgView;
@property (nonatomic, strong) UIButton *createBtn;

@property (nonatomic, strong) NSArray *titleArrays;
@property (nonatomic, strong) NSMutableArray *btnArray;

@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, assign) int roomType;

@end

@implementation CreateRoomView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.titleArrays = @[MicLocalizedNamed(@"TopicTitle1"), MicLocalizedNamed(@"TopicTitle2"), MicLocalizedNamed(@"TopicTitle3"), MicLocalizedNamed(@"TopicTitle4"), MicLocalizedNamed(@"TopicTitle5")];
        self.btnArray = [[NSMutableArray alloc] initWithCapacity:self.titleArrays.count];
        [self addSubviews];
        [self addGesture];
        [self addObserver];
        [self randomRoomName];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addSubviews {
    
    self.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.4];
    
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.closeBtn];
    [self.bgView addSubview:self.roomNamePrompt];
    [self.bgView addSubview:self.randomBtn];
    [self.bgView addSubview:self.textField];
    [self.bgView addSubview:self.typeBtnBgView];
    [self.bgView addSubview:self.createBtn];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self.mas_bottom).offset(-BgViewHeight);
    }];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView).offset(11);
        make.right.equalTo(self.bgView).offset(-10);
        make.width.height.offset(20);
    }];
    
    [self.randomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView).offset(44);
        make.right.equalTo(self.bgView).offset(-22);
        make.width.offset(80);
        make.height.offset(30);
    }];
    
    [self.roomNamePrompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(15);
        make.top.equalTo(self.randomBtn);
        make.width.offset(80);
        make.height.offset(30);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.randomBtn);
        make.left.equalTo(self.roomNamePrompt.mas_right).offset(2);
        make.right.equalTo(self.randomBtn.mas_left).offset(-5);
    }];
    
    [self.typeBtnBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.bgView).inset(23);
        make.top.equalTo(self.textField.mas_bottom).offset(3);
        make.height.offset(2 * (21 + TypeBtnHeight));
    }];
    
    [self.createBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.typeBtnBgView.mas_bottom).offset(42);
        make.centerX.equalTo(self);
        make.width.offset(120);
        make.height.offset(27);
    }];
    
    [self addTypewButtons];
}

- (void)addTypewButtons {
    for (int i = 0; i < self.titleArrays.count; i ++) {
        UIButton *button = [[UIButton alloc] init];
        button.tag = i;
        if (i == 0) {
            button.selected = YES;
            self.roomType = i;
        }
        if (@available(iOS 8.2, *)) {
            button.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        } else {
            button.titleLabel.font = [UIFont systemFontOfSize:12];
        }
        [button setTitleColor:[UIColor colorWithHexString:@"999999" alpha:1] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:@"FFFFFF" alpha:1] forState:UIControlStateSelected];
        // 计算 typeButton 间距
        CGFloat space = (UIScreenWidth - 3 * TypeBtnWidth - 23 * 2) / 2;
        button.frame = CGRectMake((i % 3 * (TypeBtnWidth + space)), 21 + (i / 3) * (TypeBtnHeight + 21), TypeBtnWidth, TypeBtnHeight);
        [button setTitle:self.titleArrays[i] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"chatlist_type_normal"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"chatlist_type_select"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
        [self.typeBtnBgView addSubview:button];
        [self.btnArray addObject:button];
    }
}
- (void)addGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(didTapView)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textEditChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)close {
    [self removeFromSuperview];
}

- (void)randomRoomName {
    NSString *randomString = [RandomUtil randomSubject];
    self.textField.text = randomString;
    self.roomName = randomString;
}

- (void)createChatRoom {
    if (self.roomName.length == 0) {
        [self showHUDMessage:MicLocalizedNamed(@"PleaseInputRoomName")];
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(createRoom:type:)]) {
            [self.delegate createRoom:self.roomName type:self.roomType];
        }
    }
}

- (void)selectType:(UIButton *)btn {
    for (UIButton *button in self.btnArray) {
        button.selected = NO;
    }
    btn.selected = YES;
    self.roomType = (int)btn.tag;
}

- (void)didTapView {
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
}

// 字数限制
- (void)textEditChanged:(NSNotification *)notification {
    
    UITextField *textField = (UITextField *)notification.object;
    UITextRange *range = textField.markedTextRange;
    if (!range) {
        NSString *text = textField.text;
        if (text.length > MaxLength) {
            NSRange rangeRange = [text rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, MaxLength)];
            textField.text = [text substringWithRange:rangeRange];
        }
    }
    self.roomName = textField.text;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Notification Action
- (void)keyboardWillShow:(NSNotification*)notification {
    CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:0.5 animations:^{
        [UIView setAnimationCurve:curve];
        CGRect originalFrame = [UIScreen mainScreen].bounds;
        if([self.textField isFirstResponder] && CGRectGetMaxY(self.frame) > keyboardBounds.origin.y){
            originalFrame.origin.y = originalFrame.origin.y-(CGRectGetMaxY(self.frame) - keyboardBounds.origin.y);
        }
        self.frame = originalFrame;
        [UIView commitAnimations];
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [UIView animateWithDuration:0.5 animations:^{
        [UIView setAnimationCurve:0];
        CGRect originalFrame = self.frame;
        originalFrame.origin.y = 0;
        self.frame = originalFrame;
        [UIView commitAnimations];
    }];
}

#pragma mark - getter or setter
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.userInteractionEnabled = YES;
        _bgView.backgroundColor = [UIColor colorWithHexString:@"FAFAFA" alpha:1];
    }
    return _bgView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setImage:[UIImage imageNamed:@"chatlist_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    }
    return _closeBtn;
}

- (UILabel *)roomNamePrompt {
    if (!_roomNamePrompt) {
        _roomNamePrompt = [[UILabel alloc] init];
        _roomNamePrompt.text = MicLocalizedNamed(@"RoomName");
        _roomNamePrompt.font = [UIFont systemFontOfSize:14];
    }
    return _roomNamePrompt;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.delegate = self;
        _textField.font = [UIFont systemFontOfSize:14];
        _textField.placeholder = MicLocalizedNamed(@"NameInputPromat");
        _textField.textColor = [UIColor colorWithHexString:@"000000" alpha:1];
        _textField.background = [UIImage imageNamed:@"chatlist_roomname_bg"];

        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatlist_edit"]];
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [leftView addSubview:imgView];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(leftView);
        }];
        _textField.leftView = leftView;
        _textField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _textField;
}

- (UIButton *)randomBtn {
    if (!_randomBtn) {
        _randomBtn = [[UIButton alloc] init];
        _randomBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_randomBtn setTitleColor:[UIColor colorWithHexString:@"FAFAFA" alpha:1] forState:UIControlStateNormal];
        _randomBtn.backgroundColor = [UIColor whiteColor];
        [_randomBtn setTitle:MicLocalizedNamed(@"RandomTopic") forState:UIControlStateNormal];
        [_randomBtn setBackgroundImage:[UIImage imageNamed:@"chatlist_random_normal"] forState:UIControlStateNormal];
        [_randomBtn setBackgroundImage:[UIImage imageNamed:@"chatlist_random_select"] forState:UIControlStateSelected];
        [_randomBtn addTarget:self action:@selector(randomRoomName) forControlEvents:UIControlEventTouchUpInside];
    }
    return _randomBtn;
}

- (UIView *)typeBtnBgView {
    if (!_typeBtnBgView) {
        _typeBtnBgView = [[UIView alloc] init];
        _typeBtnBgView.userInteractionEnabled = YES;
    }
    return _typeBtnBgView;
}

- (UIButton *)createBtn {
    if (!_createBtn) {
        _createBtn = [[UIButton alloc] init];
        _createBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_randomBtn setTitleColor:[UIColor colorWithHexString:@"FFFFFF" alpha:1] forState:UIControlStateNormal];
        _createBtn.backgroundColor = [UIColor whiteColor];
        [_createBtn setTitle:MicLocalizedNamed(@"CreateChatRoom") forState:UIControlStateNormal];
        [_createBtn setBackgroundImage:[UIImage imageNamed:@"chatlist_createbg_normal"] forState:UIControlStateNormal];
        [_createBtn setBackgroundImage:[UIImage imageNamed:@"chatlist_createbg_select"] forState:UIControlStateSelected];
        [_createBtn addTarget:self action:@selector(createChatRoom) forControlEvents:UIControlEventTouchUpInside];
    }
    return _createBtn;
}

@end
