// Sources/BlockPrompt.h
@interface BlockPrompt : NSObject
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message blockAction:(void (^)(void))blockAction whitelistAction:(void (^)(void))whitelistAction;
- (void)show;
- (void)dismiss;
@end
