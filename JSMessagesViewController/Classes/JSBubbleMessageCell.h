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

#import <UIKit/UIKit.h>
#import "JSBubbleView.h"

static NSString *GFCStateDelivered = @"Delivered";
static NSString *GFCStateRead = @"Read";
static NSString *GFCStateFailed = @"Failed";

extern NSString * const SideTimeAnimateNotification;
FOUNDATION_EXPORT NSString *const GFNotificationRetryMessage;

/**
 *  The `JSBubbleMessageCell` class defines the attributes and behavior of the cells that appear in `JSMessagesViewController`. This class includes properties and methods for setting and managing cell content.
 */
@interface JSBubbleMessageCell : UITableViewCell

/**
 *  Returns the bubble view used in the cell. JSBubbleMessageCell adds the appropriate bubble view when you create the cell with a given cell type and bubbleImageView. This property is never `nil`.
 *  @see JSBubbleView.
 *  @see JSBubbleMessageType.
 */
@property (weak, nonatomic, readonly) JSBubbleView *bubbleView;

/**
 *  Returns the label used to display the timestamp for the cell. This property may be `nil` if no timestamp is provided.
 *  @see JSMessagesViewDataSource.
 */
@property (weak, nonatomic, readonly) UILabel *timestampLabel;

/**
 *  Returns the label used to display the timestamp on the side for the cell. This property may be `nil` if no timestamp is provided.
 *  @see JSMessagesViewDataSource.
 */
@property (weak, nonatomic, readonly) UILabel *sideTimestampLabel;

/**
 *  Returns the image view used to display the avatar for the cell. This property may be `nil` if no avatar is provided.
 *  @see JSMessagesViewDataSource.
 */
@property (weak, nonatomic, readonly) UIImageView *avatarImageView;

/**
 *  Returns the button used to indicate a failed send state for the cell.
 *  @see JSMessagesViewDataSource.
 */
@property (weak, nonatomic) UIButton *failedButton;

/**
 *  Returns the label used to display the subtitle for the cell. This property may be `nil` if no subtitle is provided.
 *  @see JSMessagesViewDataSource.
 */
@property (weak, nonatomic, readonly) UILabel *subtitleLabel;

@property (nonatomic) CGFloat sideLabelStartX;

@property (nonatomic) CGFloat bubbleViewStartX;
@property (nonatomic) CGFloat failedButtonStartX;

/**
 *  ID of the message associated with this cell.  If retry is needed on this message, GFNotificationRetryMessage notification will be sent with this ID
 */
@property (nonatomic, strong) NSString *uniqueID;

#pragma mark - Initialization

/**
 *  Initializes a message cell and returns it to the caller.
 *
 *  @param type            A constant indicating a message type. @see JSBubbleMessageType for details.
 *  @param bubbleImageView An image view initialized with bubble images. The `UIImageView` properties `image` and `highlightedImage` must not be `nil`. @see JSBubbleImageViewFactory.
 *  @param hasTimestamp    A boolean value indicating whether or not the cell should be initialized with a timestampLabel. Pass `YES` to initialize with a timestamp, `NO` otherwise.
 *  @param hasAvatar       A boolean value indicating whether or not the cell should be initialized with an avatarImageView. Pass `YES` to initialize with an avatar, `NO` otherwise.
 *  @param hasSubtitle     A boolean value indicating whether or not the cell should be initialized with a subtitleLabel. Pass `YES` to initialize with a subtitle, `NO` otherwise.
 *  @param reuseIdentifier A string used to identify the cell object to be reused for drawing multiple rows of a JSMessagesViewController. This property must not be `nil`.
 *
 *  @return An initialized `JSBubbleMessageCell` object or `nil` if the object could not be created.
 */
- (instancetype)initWithBubbleType:(JSBubbleMessageType)type
                   bubbleImageView:(UIImageView *)bubbleImageView
                      hasTimestamp:(BOOL)hasTimestamp
                         hasAvatar:(BOOL)hasAvatar
                       hasSubtitle:(BOOL)hasSubtitle
                   reuseIdentifier:(NSString *)reuseIdentifier
                communicationState:(NSString *)communicationState;

-(void)slideInSideTime:(CGFloat)xMoved allowAnimation:(BOOL)allowAnimation;

#pragma mark - Setters

/**
 *  Sets the message to be displayed in the bubbleView of the cell.
 *
 *  @param msg The message text for the cell.
 *  @param attributedMsg The attributed text for the cell.  Can be `nil`.
 */
- (void)setMessage:(NSString *)msg attributedMsg:(NSAttributedString *)attributedMsg;

/**
 *  Sets the date to be displayed in the timestampLabel of the cell. The date is formatted for you via `NSDateFormatter` by `JSBubbleMessageCell`.
 *
 *  @param date The date for the cell.
 */
- (void)setTimestamp:(NSDate *)date;

/**
 *  Sets the date to be displayed in the sideTimestampLabel of the cell. The date is formatted for you via `NSDateFormatter` by `JSBubbleMessageCell`.  This will always be called.
 *
 *  @param date The date for the cell.
 */
- (void)setSideTimestamp:(NSDate *)date;

/**
 *  Sets the imageView for the avatarImageView of the cell. The frame is set for you by `JSBubbleMessageCell`.
 *
 *  @param imageView An imageView containing an avatar image. The `image` property of the `UIImageView` must not be `nil`.
 */
- (void)setAvatarImageView:(UIImageView *)imageView;

/**
 *  Sets the text to be displayed in the subtitleLabel of the cell.
 *
 *  @param subtitle The subtitle text for the cell.
 */
- (void)setSubtitle:(NSString *)subtitle;

/**
 * Sets up the failed button for outgoing messages
 *
 */
- (void)setupFailedButton;

#pragma mark - Getters

/**
 *  Returns a contant indicating the message type for the cell.
 *  @see JSBubbleMessageType.
 *
 *  @return A contant indicating the message type.
 */
- (JSBubbleMessageType)messageType;

#pragma mark - Class methods

/**
 *  Computes and returns the minimum necessary height of a `JSBubbleMessageCell` needed to display its contents.
 *
 *  @param text         The text to display in the cell.
 *  @param attributedText   If applicable, the attributed text to display in the cell.
 *  @param hasTimestamp A boolean value indicating whether or not the cell has a timestamp.
 *  @param hasAvatar    A boolean value indicating whether or not the cell has an avatar.
 *  @param hasSubtitle  A boolean value indicating whether or not the cell has a subtitle.
 *
 *  @return The height required for the frame of the cell in order for the cell to display the entire contents of its subviews.
 */
+ (CGFloat)neededHeightForBubbleMessageCellWithText:(NSString *)text
                                     attributedText:(NSAttributedString *)attributedText
                                          timestamp:(BOOL)hasTimestamp
                                             avatar:(BOOL)hasAvatar
                                           subtitle:(BOOL)hasSubtitle
                                               type:(JSBubbleMessageType)type;

@end