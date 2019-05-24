//
//  MemberListView.m
//  SealMic
//
//  Created by 张改红 on 2019/5/10.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "MemberListView.h"
#import "ClassroomService.h"
#import "MemberCell.h"
#define TitleHeight 53
@interface MemberListView()<UITableViewDataSource, UITableViewDelegate, MemberCellDelegate>
@property (nonatomic, strong) UITableView *memberListView;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic, strong) UILabel *emptyView;
@property (nonatomic, assign) int position;
@end
@implementation MemberListView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [HEXCOLOR(0xffffff) colorWithAlphaComponent:0];
        self.members = [[ClassroomService sharedService].currentRoom getAllAudiences];
        self.memberListView.delegate = self;
        [self registerCell];
        [self isShowEmpty];
        [self addSubview:[self headerView]];
        [self addSubview:self.memberListView];
    }
    return self;
}

- (void)showInView:(UIView *)view position:(int)position{
    self.position = position;
    [self reloadMemberList];
    [view addSubview:self];
}

- (void)hidden{
    [self removeFromSuperview];
}

- (void)reloadMemberList{
    self.members = [[ClassroomService sharedService].currentRoom getAllAudiences];
    [self.memberListView reloadData];
    [self isShowEmpty];
}

- (void)didClickCancelButton{
    [self hidden];
}

#pragma mark - help
- (UIView *)headerView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.memberListView.frame.origin.x, 0, self.memberListView.frame.size.width, TitleHeight)];
    view.backgroundColor = [HEXCOLOR(0xf7f7f7) colorWithAlphaComponent:1];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 9;
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:15];
    label.text = MicLocalizedNamed(@"MemberListTitle");
    label.textColor = HEXCOLOR(0x666666);
    [view addSubview:label];
    UIButton *button = [[UIButton alloc] init];
    [button addTarget:self action:@selector(didClickCancelButton) forControlEvents:(UIControlEventTouchUpInside)];
    [button setImage:[UIImage imageNamed:@"member_cancel"] forState:(UIControlStateNormal)];
    [view addSubview:button];
    [label mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view).offset(15);
        make.left.equalTo(view).offset(15);
        make.height.offset(21);
        make.right.equalTo(button.mas_right).offset(-10);
    }];
    [button mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(label).offset(0);
        make.right.equalTo(view).offset(-15);
        make.height.width.offset(21);
    }];
    return view;
}

- (void)isShowEmpty{
    if (self.members.count == 0) {
        [self addSubview:self.emptyView];
    }else{
        [self.emptyView removeFromSuperview];
    }
}
#pragma mark - MemberCellDelegate
- (void)didClickJoinMicButton:(MemberCell *)cell{
    NSIndexPath *indexPath = [self.memberListView indexPathForCell:cell];
    UserInfo *model = [self.members objectAtIndex:indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickJoinMic:index:)]) {
        [self.delegate didClickJoinMic:model.userId index:self.position];
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserInfo *model = [self.members objectAtIndex:indexPath.row];
    MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:MemberCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(!cell){
        cell = [[MemberCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:MemberCellIdentifier];
    }
    cell.delegate = self;
    [cell setUser:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 71;
}

#pragma mark - help
- (void)registerCell{
    [self.memberListView registerClass:[MemberCell class] forCellReuseIdentifier:MemberCellIdentifier];
}

#pragma mark - Getters and setters
- (UITableView *)memberListView{
    if (!_memberListView) {
        _memberListView = [[UITableView alloc] initWithFrame:CGRectMake(10,TitleHeight-9, self.frame.size.width-20, self.frame.size.height) style:(UITableViewStylePlain)];
        _memberListView.estimatedRowHeight =0;
        _memberListView.estimatedSectionHeaderHeight =0;
        _memberListView.estimatedSectionFooterHeight =0;
        if (@available(iOS 11.0, *)) {
            _memberListView.insetsContentViewsToSafeArea = NO;
        }
        _memberListView.tableFooterView = [UIView new];
        _memberListView.dataSource = self;
        _memberListView.delegate = self;
        _memberListView.backgroundColor = [HEXCOLOR(0xf7f7f7) colorWithAlphaComponent:1];
    }
    return _memberListView;
}

-(UILabel *)emptyView{
    if (!_emptyView) {
        _emptyView = [[UILabel alloc] initWithFrame:self.bounds];
        _emptyView.font = [UIFont systemFontOfSize:25];
        _emptyView.textColor = HEXCOLOR(0x999999);
        _emptyView.textAlignment = NSTextAlignmentCenter;
        _emptyView.text = MicLocalizedNamed(@"NOAudience");
    }
    return _emptyView;
}
@end
