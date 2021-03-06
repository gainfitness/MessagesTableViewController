//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSMessagesViewController
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import "JSBubbleView.h"

#import "JSMessageInputView.h"
#import "JSAvatarImageFactory.h"
#import "NSString+JSMessagesView.h"

#define kMarginTop 8.0f
#define kMarginBottom 4.0f
#define kPaddingTop 4.0f
#define kPaddingBottom 8.0f
#define kNotificationBubblePaddingRight 43.0f
#define kBubblePaddingRight 33.0f

#define kMarginLeftRight 10.0f

#define kForegroundImageViewOffset 22.0f //for fist bump or right-side image on notification

#define kMessageBubbleTailWidth 6.0f


@interface JSBubbleView()

- (void)setup;

- (void)addTextViewObservers;
- (void)removeTextViewObservers;

+ (CGSize)textSizeForText:(NSString *)txt type:(JSBubbleMessageType)type;
+ (CGSize)neededSizeForText:(NSString *)text type:(JSBubbleMessageType)type;
+ (CGFloat)neededHeightForText:(NSString *)text type:(JSBubbleMessageType)type;

@property (nonatomic, strong) UIImageView *avatarImageView;

@end


@implementation JSBubbleView

@synthesize font = _font;
@synthesize cachedBubbleFrameRect;

#pragma mark - Setup

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
                   bubbleType:(JSBubbleMessageType)bubleType
              bubbleImageView:(UIImageView *)bubbleImageView
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
        
        _type = bubleType;
        
        bubbleImageView.userInteractionEnabled = YES;
        [self addSubview:bubbleImageView];
        _bubbleImageView = bubbleImageView;
        
        UILabel *textView = [[UILabel alloc]init];
        textView.font = [UIFont systemFontOfSize:17.0f];
        textView.textColor = [UIColor blackColor];
        textView.userInteractionEnabled = YES;
        textView.backgroundColor = [UIColor clearColor];
        textView.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        textView.numberOfLines = 0;
        [self addSubview:textView];
        [self bringSubviewToFront:textView];
        _textView = textView;
        
        UIButton *foregroundImageButton = [[UIButton alloc]init];
        [self addSubview:foregroundImageButton];
        [self bringSubviewToFront:foregroundImageButton];
        _foregroundImageButton = foregroundImageButton;
        
        [self addTextViewObservers];
        
        //        NOTE: TODO: textView frame & text inset
        //        --------------------
        //        future implementation for textView frame
        //        in layoutSubviews : "self.textView.frame = textFrame;" is not needed
        //        when setting the property : "_textView.textContainerInset = UIEdgeInsetsZero;"
        //        unfortunately, this API is available in iOS 7.0+
        //        update after dropping support for iOS 6.0
        //        --------------------
        
        self.startWidth = NAN;
        self.subtractFromWidth = 0.0;
        self.cachedBubbleFrameRect = CGRectNull;
    }
    return self;
}

- (void)dealloc
{
    [self removeTextViewObservers];
    _bubbleImageView = nil;
    _textView = nil;
}

#pragma mark - KVO

- (void)addTextViewObservers
{
    [_textView addObserver:self
                forKeyPath:@"text"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
    
    [_textView addObserver:self
                forKeyPath:@"font"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
    
    [_textView addObserver:self
                forKeyPath:@"textColor"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
}

- (void)removeTextViewObservers
{
    [_textView removeObserver:self forKeyPath:@"text"];
    [_textView removeObserver:self forKeyPath:@"font"];
    [_textView removeObserver:self forKeyPath:@"textColor"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.textView) {
        if([keyPath isEqualToString:@"text"]
           || [keyPath isEqualToString:@"font"]
           || [keyPath isEqualToString:@"textColor"]) {
            [self setNeedsLayout];
        }
    }
}

#pragma mark - Setters

- (void)setFont:(UIFont *)font
{
    _font = font;
    //    _textView.font = font;
}

#pragma mark - UIAppearance Getters

- (UIFont *)font
{
    if (_font == nil) {
        _font = [[[self class] appearance] font];
    }
    
    if (_font != nil) {
        return _font;
    }
    
    return [UIFont systemFontOfSize:16.0f];
}

#pragma mark - Getters

+ (CGFloat)heightForSingleLine {
    NSAttributedString *singleLineString = [[NSAttributedString alloc] initWithString:@"." attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:16.0f] forKey:NSFontAttributeName]];
    CGRect boundingRect = [singleLineString boundingRectWithSize:(CGSize){5, CGFLOAT_MAX} options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    
    CGSize bubbleSize = [JSBubbleView neededSizeForAttributedText:singleLineString offset:boundingRect.size.height];
    return bubbleSize.height;
}


- (CGRect)bubbleFrame
{
    if(CGRectIsNull(self.cachedBubbleFrameRect)) {
        
        CGSize bubbleSize;
        
        if(self.type == JSBubbleMessageTypeNotification) {
            bubbleSize = [JSBubbleView neededSizeForAttributedText:self.textView.attributedText offset:self.hasAvatar ? [JSBubbleView heightForSingleLine] : 10.0];

            
            self.cachedBubbleFrameRect = CGRectIntegral((CGRect){kMarginLeftRight, kMarginTop, bubbleSize.width - (kMarginLeftRight*2), bubbleSize.height + (kMarginTop / 1.5)});
        } else {
            bubbleSize = [JSBubbleView neededSizeForText:self.textView.text type:self.type];
            self.cachedBubbleFrameRect = CGRectIntegral(CGRectMake((self.type == JSBubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width - kMarginLeftRight : kMarginLeftRight),
                                                                   kMarginTop,
                                                                   bubbleSize.width,
                                                                   bubbleSize.height + (kMarginTop/1.5) ));
        }
    }
    return self.cachedBubbleFrameRect;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bubbleImageViewFrame = [self bubbleFrame];
    bubbleImageViewFrame.size.width -= self.subtractFromWidth;
    
    self.bubbleImageView.frame = bubbleImageViewFrame;
    
    if(self.type == JSBubbleMessageTypeNotification) {
        // for fist bump icon
        [self.foregroundImageButton setFrame:(CGRect){self.bubbleImageView.frame.size.width - kForegroundImageViewOffset, 0, self.frame.size.width-(self.bubbleImageView.frame.size.width-kForegroundImageViewOffset), self.frame.size.height}];
        self.foregroundImageButton.center = CGPointMake(self.foregroundImageButton.center.x, self.bubbleImageView.center.y);
        [self.foregroundImageButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    }
    
    if(isnan(self.startWidth)) {
        self.startWidth = self.bubbleImageView.frame.size.width;
    }
    [self layoutTextViewFrame];
}

-(void)layoutTextViewFrame {
    
    CGFloat offset = [JSBubbleView heightForSingleLine];
    
    CGFloat textX = self.bubbleImageView.frame.origin.x + (self.hasAvatar ? offset : 0);
    CGFloat textY = self.bubbleImageView.frame.origin.y;
    
    if(self.type == JSBubbleMessageTypeIncoming) {
        textX += kMessageBubbleTailWidth;  // begin after left-tail
    }

    CGFloat textWidth = self.bubbleImageView.frame.size.width - (self.bubbleImageView.image.capInsets.right / 2.0f);
    if(self.type == JSBubbleMessageTypeNotification) {
        textY += 1.0f;
        textWidth -= kForegroundImageViewOffset;
        textWidth -= 22.0f;
    } else {
        textWidth -= 18.0f;
    }
    textWidth -= (self.hasAvatar ? offset : 0);
    
    CGRect textFrame = CGRectMake(textX,
                                  textY,
                                  textWidth,
                                  self.bubbleImageView.frame.size.height - kMarginTop);

    
    // to make up for changing this to UILabel, we add/subtract based on this former line of code that only applied to UITextView:
    //_textView.textContainerInset = UIEdgeInsetsMake(8.0f, 4.0f, 2.0f, 4.0f);
    // for the insets...  some values had to change to make it work with UILabel.
    
    textFrame.origin.y += 4.0f;
    textFrame.origin.x += 12.0f;
    textFrame.size.height -= 2.0f;
    
    [self.textView setFrame:textFrame];
}

#pragma mark - Bubble view

+ (CGSize)textSizeForText:(NSString *)txt type:(JSBubbleMessageType)type
{
    CGFloat maxWidth = [UIScreen mainScreen].applicationFrame.size.width * .70f;
    
    CGFloat maxHeight = MAX([JSMessageTextView numberOfLinesForMessage:txt],
                            [txt js_numberOfLines]) * [JSMessageInputView textViewLineHeight];
    maxHeight += kJSAvatarImageSize;
    
    CGSize stringSize = [txt sizeWithFont:[[JSBubbleView appearance] font]
                        constrainedToSize:CGSizeMake(maxWidth, maxHeight)];
    
    return CGSizeMake(roundf(stringSize.width), roundf(stringSize.height));
}

+(CGSize)textSizeForAttributedText:(NSAttributedString *)attributedText offset:(CGFloat)offset {
    CGFloat maxWidth = 255.0 - offset;  // this seems to be the magic number...  not sure exactly why, but it works for sizing.
    
    CGRect boundingRect = [attributedText boundingRectWithSize:(CGSize){maxWidth, CGFLOAT_MAX} options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    
    return CGSizeMake(320.0, boundingRect.size.height);
}

+ (CGSize)neededSizeForText:(NSString *)text type:(JSBubbleMessageType)type
{
    CGSize textSize = [JSBubbleView textSizeForText:text type:type];
    
    CGFloat bubblePaddingRight = (type == JSBubbleMessageTypeNotification ? kNotificationBubblePaddingRight : kBubblePaddingRight);
    
	return CGSizeMake(textSize.width + bubblePaddingRight,
                      textSize.height + kPaddingTop + kPaddingBottom);
}

+ (CGSize)neededSizeForAttributedText:(NSAttributedString *)attributedText offset:(CGFloat)offset {
    CGSize attributedTextSize = [JSBubbleView textSizeForAttributedText:attributedText offset:offset];
    
    return CGSizeMake(attributedTextSize.width, attributedTextSize.height + kPaddingTop + kPaddingBottom);
}

+ (CGFloat)neededHeightForText:(NSString *)text type:(JSBubbleMessageType)type
{
    CGSize size = [JSBubbleView neededSizeForText:text type:type];
    return size.height + kMarginTop + kMarginBottom;
}

+ (CGFloat)neededHeightForAttributedText:(NSAttributedString *)attributedText offset:(CGFloat)offset {
    CGSize size = [JSBubbleView neededSizeForAttributedText:attributedText offset:offset];
    
    return size.height + kMarginTop + kMarginBottom;
}

#pragma mark - Instance methods
-(void)assignSubtractFromWidth:(CGFloat)value {
    if(isnan(self.startWidth)) { return; }
    
    self.subtractFromWidth = value;
    
    CGRect imageViewFrame = self.bubbleImageView.frame;
    imageViewFrame.size.width = self.startWidth - self.subtractFromWidth;
    
    self.bubbleImageView.frame = imageViewFrame;
    
    CGRect foregroundImageButtonFrame = self.foregroundImageButton.frame;
    foregroundImageButtonFrame.size.width = self.startWidth - self.subtractFromWidth - kForegroundImageViewOffset;
    self.foregroundImageButton.frame = foregroundImageButtonFrame;
    
    [self layoutTextViewFrame];
    
}

- (void)configureAvatarView:(UIImageView *)imageview {
    
    [self.avatarImageView removeFromSuperview];
    
    CGFloat size = [JSBubbleView heightForSingleLine]  + (kMarginTop / 1.5);
    
    self.avatarImageView = imageview;
    self.avatarImageView.hidden = !self.hasAvatar;
    self.avatarImageView.frame = CGRectMake(3, 4.5, size-10, size-10);
    self.avatarImageView.layer.cornerRadius = (size-8)/2;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.backgroundColor = [UIColor redColor];
    
    [self.bubbleImageView addSubview:self.avatarImageView];
    
}

@end