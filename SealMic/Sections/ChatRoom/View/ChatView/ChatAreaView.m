//
//  ChatAreaView.m
//  SealMeeting
//
//  Created by Sin on 2019/2/28.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "ChatAreaView.h"
#import <RongIMLib/RongIMLib.h>
#import "InputBarControl.h"
#import "MessageDataSource.h"
#import "MessageBaseCell.h"
#import "MessageCell.h"
#import "MJRefresh.h"
#import "MessageHelper.h"
#import "TextMessageCell.h"
#import "TipMessageCell.h"
#import "RoomMemberChangedMessage.h"
#import "ClassroomService.h"
#define unknownMessageIdentifier @"unknownMessageIdentifier"
#define InputBarControlWidth self.frame.size.width-94
@interface ChatAreaView()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, InputBarControlDelegate, MessageDataSourceDelegate>
@property (nonatomic, assign) RCConversationType conversationType;
@property (nonatomic, copy)   NSString *targetId;
@property (nonatomic, strong) UITableView *messageListView;
@property (nonatomic, strong) MessageDataSource *dataSource;
@property (nonatomic, assign) BOOL isLoadingHistoryMessage; //是否正在加载历史消息
@end
@implementation ChatAreaView
- (instancetype)initWithFrame:(CGRect)frame conversationType:(RCConversationType)conversationType targetId:(NSString *)targetId{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [HEXCOLOR(0xe1e4e5) colorWithAlphaComponent:0];
        [self addSubview:self.messageListView];
        [self addSubview:self.inputBarControl];
        [self addSubview:self.extensionView];
        [[MessageHelper sharedInstance] setMaximumContentWidth:frame.size.width];
        self.dataSource = [[MessageDataSource alloc] initWithTargetId:targetId conversationType:conversationType];
        self.dataSource.delegate = self;
        self.conversationType = conversationType;
        self.targetId = targetId;
        [self registerCell];
    }
    return self;
}

#pragma mark - MessageDataSourceDelegate
- (void)lastestMessageLoadCompleted{
    [self scrollToBottomWithAnimated:NO];
}

- (void)didInsert:(MessageModel *)model startIndex:(NSInteger)index{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(long)index inSection:0];
    [self.messageListView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
    [self scrollToBottomWithAnimated:YES];
}

- (void)didSendStatusUpdate:(MessageModel *)model index:(NSInteger)index{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    MessageBaseCell *cell = [self.messageListView cellForRowAtIndexPath:indexPath];
    if (cell && [cell isKindOfClass:MessageCell.class]) {
        MessageCell *itemCell = (MessageCell*)cell;
        [itemCell updateSentStatus];
    }
}

- (void)didLoadHistory:(NSArray<MessageModel *> *)models isRemaining:(BOOL)remain{
    if (models.count == 0) {
        self.isLoadingHistoryMessage = NO;
        [self.messageListView.mj_header endRefreshing];
        return;
    }
    NSMutableArray *indexPathes = [[NSMutableArray alloc] initWithCapacity:20];
    CGFloat height = self.messageListView.contentSize.height;
    for (int i = 0; i < models.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        MessageModel *msgModel = [self.dataSource objectAtIndex:i];
        height += [msgModel contentSize].height;
        [indexPathes addObject:indexPath];
    }
    if (indexPathes.count <= 0) {
        self.isLoadingHistoryMessage = NO;
        [self.messageListView.mj_header endRefreshing];
        return;
    }
    self.isLoadingHistoryMessage = NO;
    [self.messageListView.mj_header endRefreshing];
    if (@available(iOS 11.0, *)) {
        [UIView setAnimationsEnabled:NO];
        [self.messageListView performBatchUpdates:^{
            [self.messageListView insertRowsAtIndexPaths:indexPathes withRowAnimation:(UITableViewRowAnimationNone)];
        } completion:^(BOOL finished) {
            [self.messageListView scrollToRowAtIndexPath:indexPathes.lastObject atScrollPosition:UITableViewScrollPositionTop animated:NO];
             [UIView setAnimationsEnabled:YES];
        }];
    } else {
        [UIView setAnimationsEnabled:NO];
        [self.messageListView insertRowsAtIndexPaths:indexPathes withRowAnimation:(UITableViewRowAnimationNone)];
        [self.messageListView scrollToRowAtIndexPath:indexPathes.lastObject atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [UIView setAnimationsEnabled:YES];
    }
    
}

- (void)didRemoved:(MessageModel *)model atIndex:(NSInteger)index{
    [UIView setAnimationsEnabled:NO];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.messageListView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
    [UIView setAnimationsEnabled:YES];
}

- (void)forceReloadData{
    [self.messageListView reloadData];
}


#pragma mark - InputBarControlDelegate
- (void)onInputBarControlContentSizeChanged:(CGRect)frame withAnimationDuration:(CGFloat)duration andAnimationCurve:(UIViewAnimationCurve)curve{
    [UIView animateWithDuration:0.2 animations:^{
        [UIView setAnimationCurve:curve];
        CGRect rect = self.inputBarControl.frame;
        if (rect.origin.y == self.extensionView.frame.origin.y) {
            rect.size.width = self.frame.size.width-94;
        }else{
            rect.size.width = UIScreenWidth;
        }
        self.inputBarControl.frame = rect;
        [UIView commitAnimations];
    }];
    
    [self scrollToBottomWithAnimated:YES];
}

- (void)onTouchSendButton:(NSString *)text{
    RCTextMessage *textMsg = [RCTextMessage messageWithContent:text];
    [[MessageHelper sharedInstance] sendMessage:textMsg pushContent:nil pushData:nil
                                      toTargetId:self.targetId conversationType:self.conversationType];
    [self.inputBarControl clearInputView];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *model = [self.dataSource objectAtIndex:indexPath.row];
    NSString *identifier = model.message.objectName?model.message.objectName:unknownMessageIdentifier;
    MessageBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[MessageBaseCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:model.message.objectName];
    }
    if ([[[MessageHelper sharedInstance] getAllSupportMessage] containsObject:model.message.objectName]) {
        [cell setDataModel:model];
    }else{
        //对于目前不支持的消息处理：删除所有子视图，表现为不展示
        [cell.baseContainerView removeFromSuperview];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *model = [self.dataSource objectAtIndex:indexPath.row];
    if ([[[MessageHelper sharedInstance] getAllSupportMessage] containsObject:model.message.objectName]) {
        CGFloat topAndBottomSpace = 12;
        if ([model.message.content isKindOfClass:[RCTextMessage class]]){
            CGFloat userNameHeight = 14;
            CGFloat userNameAndContentSpace = 4;
            return model.contentSize.height + topAndBottomSpace+userNameHeight + userNameAndContentSpace;
        } else if ([model.message.content isKindOfClass:[RoomMemberChangedMessage class]]) {
            CGFloat headerAndContentSpace = 10;
            return model.contentSize.height + headerAndContentSpace;
        } else {
            return model.contentSize.height + topAndBottomSpace;
        }
    } else {
        //对于目前不支持的消息,高度为 0，表现为不展示
        return 0;
    }
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= 15 && !self.isLoadingHistoryMessage){
        [self.messageListView.mj_header beginRefreshing];
    }
    [self.inputBarControl setInputBarStatus:(InputBarControlStatusDefault)];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.messageListView scrollToRowAtIndexPath:firstIndexPath atScrollPosition:(UITableViewScrollPositionTop) animated:YES];
    return NO;
}

#pragma mark - helper
- (void)scrollToBottomWithAnimated:(BOOL)animated {
    if (self.dataSource.count > 0) {
        NSUInteger lastIndex = self.dataSource.count - 1;
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:lastIndex inSection:0];
        [self.messageListView  scrollToRowAtIndexPath:toIndexPath atScrollPosition:(UITableViewScrollPositionBottom) animated:animated];
    }
}

#pragma mark - Target action
- (void)registerCell{
    [self.messageListView registerClass:[MessageBaseCell class] forCellReuseIdentifier:unknownMessageIdentifier];
    [self.messageListView registerClass:[TextMessageCell class] forCellReuseIdentifier:[RCTextMessage getObjectName]];
    [self.messageListView registerClass:[TipMessageCell class] forCellReuseIdentifier:[RoomMemberChangedMessage getObjectName]];
}

#pragma mark - Getters and setters
- (UITableView *)messageListView{
    if (!_messageListView) {
        _messageListView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height-HeighInputBar) style:(UITableViewStylePlain)];
        [_messageListView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _messageListView.estimatedRowHeight =0;
        _messageListView.estimatedSectionHeaderHeight =0;
        _messageListView.estimatedSectionFooterHeight =0;
        if (@available(iOS 11.0, *)) {
            _messageListView.insetsContentViewsToSafeArea = NO;
        }
        _messageListView.dataSource = self;
        _messageListView.delegate = self;
        _messageListView.backgroundColor = [HEXCOLOR(0xe1e4e5) colorWithAlphaComponent:0];
    }
    return _messageListView;
}

- (ExtensionView *)extensionView{
    if (!_extensionView) {
        _extensionView = [[ExtensionView alloc] initWithFrame:CGRectMake(self.frame.size.width-94, self.inputBarControl.frame.origin.y, 94, HeighInputBar)];
        _extensionView.backgroundColor = [UIColor clearColor];
    }
    return _extensionView;
}

- (InputBarControl *)inputBarControl{
    if (!_inputBarControl) {
        _inputBarControl = [[InputBarControl alloc] initWithStatus:InputBarControlStatusDefault];
        _inputBarControl.frame = CGRectMake(0,CGRectGetMaxY(self.messageListView.frame), InputBarControlWidth, HeighInputBar);
        _inputBarControl.delegate = self;
    }
    return _inputBarControl;
}
@end
