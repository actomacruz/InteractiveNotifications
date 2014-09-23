//
//  MainViewController.h
//  InteractiveNotifications
//
//  Created by Arvin John Tomacruz on 9/16/14.
//  Copyright (c) 2014 Voyager Innovations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, INConversationStatus) {
    INConversationStatusNotReady = 0,
    INConversationStatusStarting,
    INConversationStatusStarted
};

typedef NS_ENUM (NSUInteger, INQuestionNumber) {
    INFirstQuestion = 0,
    INSecondQuestion,
    INThirdQuestion,
    INNoQuestion
};

@interface MainViewController : UIViewController

@property (nonatomic) INConversationStatus conversationStatus;
@property (nonatomic, strong) NSTimer *timer;

- (void)setUpConversationBubbleView;
- (void)setUpReplyFieldsForQuestion:(INQuestionNumber)questionNumber;
- (void)displayConversationWithMessage:(NSString *)message;

@end
