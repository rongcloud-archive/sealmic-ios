//
//  RCMicTextView.m
//  RongEnterpriseApp
//
//  Created by Sin on 2017/8/16.
//  Copyright © 2017年 rongcloud. All rights reserved.
//

#import "RCMicTextView.h"

@interface RCMicTextView ()
@property(strong, nonatomic) UILabel *placeholderLabel;
@end

@implementation RCMicTextView

- (void)setPlaceholder:(NSString *)placeholder color:(UIColor *)color font:(UIFont *)font {
    self.placeholder = placeholder;
    self.placeholderColor = color;
    self.placeholderFont = font;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self)
        return nil;
    [self initSubViews];
    return self;
}

- (void)initSubViews {
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.placeholderLabel];

    self.placeholderColor = [UIColor lightGrayColor];
    self.placeholderFont = [UIFont systemFontOfSize:16.0f];
    self.font = [UIFont systemFontOfSize:16.0f];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
}

#pragma mark - UITextViewTextDidChangeNotification

- (void)textDidChange {
    self.placeholderLabel.hidden = self.hasText;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    
    [self textDidChange];
    if (self.textChangeDelegate && [self.textChangeDelegate respondsToSelector:@selector(micTextView:textDidChange:)]) {
        [self.textChangeDelegate micTextView:self textDidChange:text];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    
    [self textDidChange];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeholderLabel.text = placeholder;
    [self setNeedsLayout];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    self.placeholderLabel.textColor = placeholderColor;
    [self setNeedsLayout];
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont {
    _placeholderFont = placeholderFont;
    self.placeholderLabel.font = placeholderFont;
    [self setNeedsLayout];
}

- (void)setSelectedRange:(NSRange)selectedRange {
    [super setSelectedRange:selectedRange];
    [self textDidChange];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect frame = self.placeholderLabel.frame;
    frame.origin.y = self.textContainerInset.top;
    frame.origin.x = self.textContainerInset.left + 6.0f;
    frame.size.width = self.frame.size.width - self.textContainerInset.left * 2.0;

    CGSize maxSize = CGSizeMake(frame.size.width, MAXFLOAT);
    frame.size.height =
        [self.placeholder boundingRectWithSize:maxSize
                                       options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName : self.placeholderLabel.font}
                                       context:nil]
            .size.height;
    self.placeholderLabel.frame = frame;
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:UITextViewTextDidChangeNotification];
}
@end
