//
//  MainViewController.m
//  InteractiveNotifications
//
//  Created by Arvin John Tomacruz on 9/16/14.
//  Copyright (c) 2014 Voyager Innovations Inc. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (nonatomic, strong) UIButton *startConversationButton;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *prepareConversationLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UITextField *replyTextField;

@end

@implementation MainViewController
{
    int countdown;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        countdown = 5;
        self.conversationStatus = INConversationStatusNotReady;
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView.image = [UIImage imageNamed:@"steve_whole"];
    [self.view addSubview:self.imageView];
    
    self.startConversationButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.startConversationButton.backgroundColor = [UIColor greenColor];
    self.startConversationButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    [self.startConversationButton setTitle:@"Start Conversation" forState:UIControlStateNormal];
    [self.startConversationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startConversationButton addTarget:self action:@selector(startConversationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startConversationButton];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.imageView sizeToFit];
    [self.startConversationButton sizeToFit];
    self.startConversationButton.frame = CGRectInset(self.startConversationButton.frame, -10, 0);
    self.imageView.center = CGPointMake(self.view.center.x, self.view.center.y - 20);
    self.startConversationButton.center = CGPointMake(self.view.center.x, self.view.center.y + (self.imageView.frame.size.height / 2) + 20);
}

- (void)startConversationButtonTapped:(id)sender
{
    [self setUpPrepareConversationLabel];
    [self.view addSubview:self.prepareConversationLabel];
    self.conversationStatus = INConversationStatusStarting;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(prepareConversation) userInfo:nil repeats:YES];
}

- (void)prepareConversation
{
    countdown--;
    self.prepareConversationLabel.text = [NSString stringWithFormat:@"Please press home button in %d", countdown];
    if (countdown <= 0) {
        [self.timer invalidate];
        self.timer = nil;
        countdown = 5;
        self.conversationStatus = INConversationStatusStarted;
        [self setUpConversationBubbleView];
    }
}

- (void)setUpPrepareConversationLabel
{
    if (!self.prepareConversationLabel) {
        self.prepareConversationLabel = [[UILabel alloc] init];
        self.prepareConversationLabel.backgroundColor = [UIColor redColor];
        self.prepareConversationLabel.textColor = [UIColor whiteColor];
        self.prepareConversationLabel.text = [NSString stringWithFormat:@"Please press home button in %d", countdown];
        [self.prepareConversationLabel sizeToFit];
        self.prepareConversationLabel.center = self.view.center;
        self.prepareConversationLabel.center = self.view.center;
        [self.imageView removeFromSuperview];
        [self.startConversationButton removeFromSuperview];
    }
}

- (void)sendButtonTapped:(id)sender
{
    self.messageLabel.text = LAST_CONVERSATION;
    [self.replyTextField removeFromSuperview];
    [self.sendButton removeFromSuperview];
}

#pragma mark - Method implementation

- (void)setUpConversationBubbleView
{
    if (!self.messageLabel) {
        [self.prepareConversationLabel removeFromSuperview];
        [self.view addSubview:self.imageView];
        
        self.messageLabel = [[UILabel alloc] init];
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.textColor = [UIColor blackColor];
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        
        self.messageLabel.text = FIRST_QUESTION;
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.frame = CGRectMake(50, 25, [[UIScreen mainScreen] bounds].size.width - 100, 150);
        [self.view addSubview:self.messageLabel];
    }
}

- (void)setUpReplyFieldsForQuestion:(INQuestionNumber)questionNumber
{
    switch (questionNumber) {
        case INFirstQuestion:
            
            break;
            
        case INSecondQuestion:
            break;
            
        case INThirdQuestion:
            self.replyTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, self.imageView.frame.origin.y + self.imageView.frame.size.height + 50, self.view.frame.size.width - 100, 25)];
            self.replyTextField.borderStyle = UITextBorderStyleLine;
            self.replyTextField.text = @"Interactive Notification";
            [self.view addSubview:self.replyTextField];
            
            self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(100, self.replyTextField.frame.origin.y + self.replyTextField.frame.size.height + 10, self.view.frame.size.width - 200, 25)];
            self.sendButton.backgroundColor = [UIColor greenColor];
            [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
            [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.sendButton addTarget:self action:@selector(sendButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:self.sendButton];
            break;
            
        default:
            break;
    }
}

- (void)displayConversationWithMessage:(NSString *)message
{
    self.messageLabel.text = message;
}

- (void)dealloc
{
    [self.timer invalidate];
}

@end
