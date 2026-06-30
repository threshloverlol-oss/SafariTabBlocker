// URLManager.h - SQLite database manager for Safari Tab Blocker
#import <Foundation/Foundation.h>

@interface URLManager : NSObject {
@private
    void *_database; // sqlite3* opaque type
    NSString *_dbPath;
}

- (instancetype)initWithDatabasePath:(NSString *)path;

// Table management
- (BOOL)createTablesIfNeeded;

// URL operations
- (BOOL)addBlockedURL:(NSString *)url;
- (BOOL)addWhitelistedURL:(NSString *)url;
- (BOOL)removeURL:(NSString *)url;
- (void)clearAllURLs;

// Query methods
- (BOOL)isURLBlocked:(NSString *)url;
- (BOOL)isURLWhitelisted:(NSString *)url;
- (NSArray<NSDictionary *> *)getBlockedURLs;
- (NSArray<NSDictionary *> *)getWhitelistedURLs;
- (NSInteger)getBlockedCount;

// Database management
- (void)closeDatabase;

@end
