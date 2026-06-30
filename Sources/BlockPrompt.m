// BlockPrompt.m - Native-style overlay prompt for Safari Tab Blocker
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface BlockPrompt : NSObject {
@private
    UIAlertController *_alertController;
    UIViewController *_presentingViewController;
    void (^_blockAction)(void);
    void (^_whitelistAction)(void);
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

- (instancetype)initWithTitle:(NSString *)title 
                      message:(NSString *)message 
                  blockAction:(void (^)(void))blockAction 
              whitelistAction:(void (^)(void))whitelistAction;

- (void)show;
- (void)dismiss;

@end

@implementation BlockPrompt

- (instancetype)initWithTitle:(NSString *)title 
                      message:(NSString *)message 
                  blockAction:(void (^)(void))blockAction 
              whitelistAction:(void (^)(void))whitelistAction {
    self = [super init];
    if (self) {
        _title = title;
        _message = message;
        _blockAction = [blockAction copy];
        _whitelistAction = [whitelistAction copy];
        
        // Create alert controller with native iOS style
        _alertController = [[UIAlertController alloc] initWithTitle:_title 
                                                            message:_message 
                                                     preferredStyle:UIAlertControllerStyleAlert];
        
        // Add Block button (destructive style)
        UIAlertAction *blockButton = [UIAlertAction title:@"Block" 
                                                    style:UIAlertActionStyleDestructive 
                                                  handler:^(UIAlertAction *action) {
                                                      if (_blockAction) _blockAction();
                                                      [_alertController dismissViewControllerAnimated:YES completion:nil];
                                                  }];
        
        // Add Whitelist button (default style)
        UIAlertAction *whitelistButton = [UIAlertAction title:@"Whitelist" 
                                                        style:UIAlertActionStyleDefault 
                                                      handler:^(UIAlertAction *action) {
                                                          if (_whitelistAction) _whitelistAction();
                                                          [_alertController dismissViewControllerAnimated:YES completion:nil];
                                                      }];
        
        // Add Cancel button
        UIAlertAction *cancelButton = [UIAlertAction title:@"Cancel" 
                                                     style:UIAlertActionStyleCancel 
                                                   handler:^(UIAlertAction *action) {
                                                       [_alertController dismissViewControllerAnimated:YES completion:nil];
                                                   }];
        
        // FIXED: Replaced closing parentheses with brackets
        [_alertController addAction:blockButton];
        [_alertController addAction:whitelistButton];
        [_alertController addAction:cancelButton];
    }
    return self;
}

- (void)show {
    // Get the topmost view controller to present from
    _presentingViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (_presentingViewController.presentedViewController) {
        _presentingViewController = _presentingViewController.presentedViewController;
    }
    
    if (!_presentingViewController) return;
    
    // Present with animation
    [_presentingViewController presentViewController:_alertController 
                                           animated:YES 
                                         completion:nil];
}

- (void)dismiss {
    if (_alertController && _alertController.isPresented) {
        [_alertController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
