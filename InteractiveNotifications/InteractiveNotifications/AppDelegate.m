//
//  AppDelegate.m
//  InteractiveNotifications
//
//  Created by Arvin John Tomacruz on 9/16/14.
//  Copyright (c) 2014 Voyager Innovations Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "MainViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) MainViewController *mainViewController;
@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation AppDelegate
{
    UIUserNotificationType allowedTypes;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self setUpUserNotificationSettings];
    
    self.mainViewController = [[MainViewController alloc] init];
    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    allowedTypes = [notificationSettings types];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"Receive Local Notification");
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:ACCEPT_CONVERSATION_ACTION_IDENTIFIER]) {
        [self handleAcceptActionIdentifierWithNotification:notification];
    }
    else if ([identifier isEqualToString:DECLINE_CONVERSATION_ACTION_IDENTIFIER]) {
        [self handleDeclineActionIdentifierWithNotification:notification];
    }
    else if ([identifier isEqualToString:MAYBE_CONVERSATION_ACTION_IDENTIFIER]) {
        [self handleMaybeActionIdentifierWithNotification:notification];
    }
    else if ([identifier isEqualToString:YES_ACTION_IDENTIFIER]) {
        [self handleYesActionIdentifierWithNotification:notification];
    }
    else if ([identifier isEqualToString:NO_ACTION_IDENTIFIER]) {
        [self handleNoActionIdentifierWithNotification:notification];
    }
    else if ([identifier isEqualToString:REPLY_ACTION_IDENTIFIER]) {
        [self handleReplyActionIdentifierWithNotification:notification];
    }
    
    if (completionHandler) {
        completionHandler();
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (self.window.rootViewController == self.mainViewController) {
        if (self.mainViewController.conversationStatus == INConversationStatusNotReady) {
            if (allowedTypes != UIUserNotificationTypeNone) {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.alertBody = @"Please click \"Start Conversation\" button.";
                notification.fireDate = [[NSDate date] dateByAddingTimeInterval:1];
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }
        else if (self.mainViewController.conversationStatus == INConversationStatusStarting) {
            [self.mainViewController.timer invalidate];
            self.mainViewController.conversationStatus = INConversationStatusStarted;
            [self.mainViewController setUpConversationBubbleView];
            if (allowedTypes != UIUserNotificationTypeNone) {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.category = INVITE_CONVERSATION_CATEGORY_IDENTIFIER;
                notification.alertBody = FIRST_QUESTION;
                notification.fireDate = [[NSDate date] dateByAddingTimeInterval:5];
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }
    }
    
}

- (void)setUpUserNotificationSettings
{
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = ACCEPT_CONVERSATION_ACTION_IDENTIFIER;
    acceptAction.title = ACCEPT_CONVERSATION_ACTION_TITLE;
    acceptAction.activationMode = UIUserNotificationActivationModeBackground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = YES;
    
    UIMutableUserNotificationAction *declineAction = [[UIMutableUserNotificationAction alloc] init];
    declineAction.identifier = DECLINE_CONVERSATION_ACTION_IDENTIFIER;
    declineAction.title = DECLINE_CONVERSATION_ACTION_TITLE;
    declineAction.activationMode = UIUserNotificationActivationModeBackground;
    declineAction.destructive = YES;
    declineAction.authenticationRequired = YES;
    
    UIMutableUserNotificationAction *maybeAction = [[UIMutableUserNotificationAction alloc] init];
    maybeAction.identifier = MAYBE_CONVERSATION_ACTION_IDENTIFIER;
    maybeAction.title = MAYBE_CONVERSATION_ACTION_TITLE;
    maybeAction.activationMode = UIUserNotificationActivationModeBackground;
    maybeAction.destructive = NO;
    maybeAction.authenticationRequired = NO;
    
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    inviteCategory.identifier = INVITE_CONVERSATION_CATEGORY_IDENTIFIER;
    [inviteCategory setActions:@[acceptAction, declineAction, maybeAction] forContext:UIUserNotificationActionContextDefault];
    [inviteCategory setActions:@[acceptAction, declineAction] forContext:UIUserNotificationActionContextMinimal];
    
    UIMutableUserNotificationAction *yesAction = [[UIMutableUserNotificationAction alloc] init];
    yesAction.identifier = YES_ACTION_IDENTIFIER;
    yesAction.title = YES_ACTION_TITLE;
    yesAction.activationMode = UIUserNotificationActivationModeBackground;
    yesAction.destructive = NO;
    yesAction.authenticationRequired = NO;
    
    UIMutableUserNotificationAction *noAction = [[UIMutableUserNotificationAction alloc] init];
    noAction.identifier = NO_ACTION_IDENTIFIER;
    noAction.title = NO_ACTION_TITLE;
    noAction.activationMode = UIUserNotificationActivationModeBackground;
    noAction.destructive = YES;
    noAction.authenticationRequired = NO;
    
    UIMutableUserNotificationCategory *developerQuestionCategory = [[UIMutableUserNotificationCategory alloc] init];
    developerQuestionCategory.identifier = DEVELOPER_QUESTION_CATEGORY_IDENTIFIER;
    [developerQuestionCategory setActions:@[yesAction, noAction] forContext:UIUserNotificationActionContextDefault];
    
    UIMutableUserNotificationAction *replyAction = [[UIMutableUserNotificationAction alloc] init];
    replyAction.identifier = REPLY_ACTION_IDENTIFIER;
    replyAction.title = REPLY_ACTION_TITLE;
    replyAction.activationMode = UIUserNotificationActivationModeForeground;
    replyAction.destructive = NO;
    replyAction.authenticationRequired = YES;
    
    UIMutableUserNotificationCategory *commentQuestionCategory = [[UIMutableUserNotificationCategory alloc] init];
    commentQuestionCategory.identifier = COMMENT_QUESTION_CATEGORY_IDENTIFIER;
    [commentQuestionCategory setActions:@[replyAction] forContext:UIUserNotificationActionContextDefault];
    
    UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:[NSSet setWithObjects:inviteCategory, developerQuestionCategory, commentQuestionCategory, nil]];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}


#pragma mark - NotificationActions handler methods

- (void)handleAcceptActionIdentifierWithNotification:(UILocalNotification *)notification
{
    if (allowedTypes != UIUserNotificationTypeNone) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.category = DEVELOPER_QUESTION_CATEGORY_IDENTIFIER;
        notification.alertBody = SECOND_QUESTION;
        notification.fireDate = [[NSDate date] dateByAddingTimeInterval:1];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    [self.mainViewController displayConversationWithMessage:SECOND_QUESTION];
    [self.mainViewController setUpReplyFieldsForQuestion:INSecondQuestion];
}

- (void)handleDeclineActionIdentifierWithNotification:(UILocalNotification *)notification
{
    if (allowedTypes != UIUserNotificationTypeNone) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = FIRST_QUESTION_DECLINE;
        notification.fireDate = [[NSDate date] dateByAddingTimeInterval:1];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    [self.mainViewController displayConversationWithMessage:FIRST_QUESTION_DECLINE];
    [self.mainViewController setUpReplyFieldsForQuestion:INNoQuestion];
}

- (void)handleMaybeActionIdentifierWithNotification:(UILocalNotification *)notification
{
    if (allowedTypes != UIUserNotificationTypeNone) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = FIRST_QUESTION_MAYBE;
        notification.fireDate = [[NSDate date] dateByAddingTimeInterval:1];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    [self.mainViewController displayConversationWithMessage:FIRST_QUESTION_MAYBE];
    [self.mainViewController setUpReplyFieldsForQuestion:INNoQuestion];
}

- (void)handleYesActionIdentifierWithNotification:(UILocalNotification *)notification
{
    if (allowedTypes != UIUserNotificationTypeNone) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.category = COMMENT_QUESTION_CATEGORY_IDENTIFIER;
        notification.alertBody = THIRD_QUESTION;
        notification.fireDate = [[NSDate date] dateByAddingTimeInterval:1];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    [self.mainViewController displayConversationWithMessage:THIRD_QUESTION];
    [self.mainViewController setUpReplyFieldsForQuestion:INThirdQuestion];
}

- (void)handleNoActionIdentifierWithNotification:(UILocalNotification *)notification
{
    if (allowedTypes != UIUserNotificationTypeNone) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.category = COMMENT_QUESTION_CATEGORY_IDENTIFIER;
        notification.alertBody = THIRD_QUESTION;
        notification.fireDate = [[NSDate date] dateByAddingTimeInterval:1];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    [self.mainViewController displayConversationWithMessage:THIRD_QUESTION];
    [self.mainViewController setUpReplyFieldsForQuestion:INThirdQuestion];
}

- (void)handleReplyActionIdentifierWithNotification:(UILocalNotification *)notification
{
    // do something here
}

@end
