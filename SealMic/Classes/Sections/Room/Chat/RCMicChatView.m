//
//  RCMicChatView.m
//  SealMic
//
//  Created by lichenfeng on 2020/5/29.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "RCMicChatView.h"
#import "RCMicInputBar.h"
#import "RCMicMacro.h"
@interface RCMicChatView()<UITableViewDataSource, UITableViewDelegate, RCMicMessageCellDelegate>
@property (nonatomic, strong) RCMicRoomViewModel *viewModel;
@property (nonatomic, strong) UITableView *messageTableView;
/// 存放消息类型和 Cell 对应关系的字典
@property (nonatomic, copy) NSMutableDictionary *cellIdentifierDict;
@end
@implementation RCMicChatView

- (instancetype)initWithFrame:(CGRect)frame viewModel:(RCMicRoomViewModel *)viewModel {
    self = [super initWithFrame:frame];
    if (self) {
        _viewModel = viewModel;
        _cellIdentifierDict = [NSMutableDictionary dictionary];
        [self initSubviews];
        [self addConstraints];
        [self bindCellWithValidMessage];
        [self registerCellToTable];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self scrollToBottom];
}

#pragma mark - Private method
- (void)initSubviews {
    _messageTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _messageTableView.backgroundColor = RCMicColor([UIColor clearColor], [UIColor clearColor]);
    _messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _messageTableView.estimatedRowHeight =0;
    _messageTableView.estimatedSectionHeaderHeight =0;
    _messageTableView.estimatedSectionFooterHeight =0;
    if (@available(iOS 11.0, *)) {
        _messageTableView.insetsContentViewsToSafeArea = NO;
    }
    _messageTableView.delegate = self;
    _messageTableView.dataSource = self;
    [self addSubview:_messageTableView];
}

- (void)addConstraints {
    [_messageTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

/// 将 cell 和指定消息类型绑定
- (void)bindCellWithValidMessage {
    [_cellIdentifierDict setValue:[RCMicTextMessageCell class] forKey:[RCTextMessage getObjectName]];
    [_cellIdentifierDict setValue:[RCMicGiftMessageCell class] forKey:[RCMicGiftMessage getObjectName]];
}

- (void)registerCellToTable {
    for (NSString *key in _cellIdentifierDict.allKeys) {
        [_messageTableView registerClass:_cellIdentifierDict[key] forCellReuseIdentifier:key];
    }
}

#pragma mark - Public method
- (void)updateTableViewWithType:(RCMicMessageChangedType)type indexs:(NSArray *)indexs {
    NSMutableArray *indexArray = [NSMutableArray array];
    for (NSNumber *index in indexs) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:[index integerValue] inSection:0];
        [indexArray addObject:path];
    }
    RCMicMainThread(^{
        if (type == RCMicMessageChangedTypeAdd) {
            [self.messageTableView beginUpdates];
            [self.messageTableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.messageTableView endUpdates];
            [self scrollToBottom];
        } else {
            [self.messageTableView beginUpdates];
            [self.messageTableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.messageTableView endUpdates];
        }
    })
}

- (void)scrollToBottom {
    if (self.viewModel.messageDataSource.count > 0) {
        [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.viewModel.messageDataSource.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.messageDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCMicMessageViewModel *messageViewModel = self.viewModel.messageDataSource[indexPath.row];
    NSString *objectName = [[messageViewModel.message.content class] getObjectName];
    
    UITableViewCell *cell;
    //消息注册过展示使用的 cell 时
    if (self.cellIdentifierDict[objectName]) {
        cell = [tableView dequeueReusableCellWithIdentifier:objectName forIndexPath:indexPath];
        ((RCMicMessageBaseCell *)cell).delegate = self;
        [(RCMicMessageBaseCell *)cell updateWithViewModel:messageViewModel];
    } else {//消息未注册过展示使用的 cell 时
        cell = [[UITableViewCell alloc] init];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCMicMessageViewModel *messageViewModel = self.viewModel.messageDataSource[indexPath.row];
    NSString *objectName = [[messageViewModel.message.content class] getObjectName];
    
    Class<RCMicMessageCellHeightProvider> cellCls = self.cellIdentifierDict[objectName];
    if ([cellCls conformsToProtocol:@protocol(RCMicMessageCellHeightProvider)]) {
        return [cellCls contentHeightWithViewModel:messageViewModel];
    } else {
        return 0.0f;
    }
}

#pragma mark - UITableViewDelegate

#pragma mark - RCMicMessageCellDelegate
- (void)messageCell:(RCMicMessageBaseCell *)cell didTapCellWithViewModel:(RCMicMessageViewModel *)viewModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatView:didTapMessageCell:withViewModel:)]) {
        [self.delegate chatView:self didTapMessageCell:cell withViewModel:viewModel];
    }
}

- (void)messageCell:(RCMicMessageBaseCell *)cell didLongPressCellWithViewModel:(RCMicMessageViewModel *)viewModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatView:didLongPressMessageCell:withViewModel:)]) {
        [self.delegate chatView:self didLongPressMessageCell:cell withViewModel:viewModel];
    }
}
@end
