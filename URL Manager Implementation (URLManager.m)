// URLManager.m - SQLite database operations for Safari Tab Blocker
#import "URLManager.h"
#import <sqlite3.h>

@implementation URLManager {
    sqlite3 *_database;
    NSString *_dbPath;
}

- (instancetype)initWithDatabasePath:(NSString *)path {
    self = [super init];
    if (self) {
        _dbPath = path;
        
        // Ensure directory exists
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *directoryURL = [[NSURL alloc] fileURLWithPath:@"/var/mobile/Library/Preferences"];
        if (![fileManager fileExistsAtPath:directoryURL.path]) {
            [fileManager createDirectoryAtURL:directoryURL 
                                     withIntermediateDirectories:YES 
                                                      attributes:nil 
                                                           error:nil];
        }
        
        // Open database connection
        sqlite3_open([_dbPath UTF8String], &_database);
    }
    return self;
}

- (void)dealloc {
    [self closeDatabase];
}

- (BOOL)createTablesIfNeeded {
    if (!_database) return NO;
    
    const char *sql = 
        "CREATE TABLE IF NOT EXISTS urls ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "url TEXT UNIQUE NOT NULL,"
        "type TEXT CHECK(type IN ('block', 'whitelist')) NOT NULL,"
        "timestamp DATETIME DEFAULT CURRENT_TIMESTAMP"
        ");";
    
    char *error;
    int result = sqlite3_exec(_database, sql, NULL, NULL, &error);
    
    if (result != SQLITE_OK) {
        NSLog(@"[SafariTabBlocker] Error creating table: %s", error ? error : "Unknown");
        sqlite3_free(error);
        return NO;
    }
    
    // Create index for faster lookups
    const char *indexSQL = 
        "CREATE INDEX IF NOT EXISTS idx_url_lookup ON urls(url)";
    sqlite3_exec(_database, indexSQL, NULL, NULL, &error);
    
    return YES;
}

- (BOOL)addBlockedURL:(NSString *)url {
    if (!_database || !url) return NO;
    
    const char *sql = 
        "INSERT OR REPLACE INTO urls (url, type, timestamp) VALUES (?, 'block', CURRENT_TIMESTAMP)";

    
    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"[SafariTabBlocker] Error preparing insert statement");
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [url UTF8String], -1, SQLITE_TRANSIENT);
    result = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    return result == SQLITE_OK || result == SQLITE_DONE;
}

- (BOOL)addWhitelistedURL:(NSString *)url {
    if (!_database || !url) return NO;
    
    const char *sql = 
        "INSERT OR REPLACE INTO urls (url, type, timestamp) VALUES (?, 'whitelist', CURRENT_TIMESTAMP)";
    
    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
    
    if (result != SQLITE_OK) {
        NSLog(@"[SafariTabBlocker] Error preparing whitelist statement");
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [url UTF8String], -1, SQLITE_TRANSIENT);
    result = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    return result == SQLITE_OK || result == SQLITE_DONE;
}

- (BOOL)isURLBlocked:(NSString *)url {
    if (!_database || !url) return NO;
    
    const char *sql = 
        "SELECT COUNT(*) FROM urls WHERE url = ? AND type = 'block'";
    
    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
    
    if (result != SQLITE_OK) {
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [url UTF8String], -1, SQLITE_TRANSIENT);
    result = sqlite3_step(statement);
    
    BOOL blocked = (result == SQLITE_ROW && sqlite3_column_int(statement, 0) > 0);
    sqlite3_finalize(statement);
    
    return blocked;
}

- (BOOL)isURLWhitelisted:(NSString *)url {
    if (!_database || !url) return NO;
    
    const char *sql = 
        "SELECT COUNT(*) FROM urls WHERE url = ? AND type = 'whitelist'";
    
    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
    
    if (result != SQLITE_OK) {
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [url UTF8String], -1, SQLITE_TRANSIENT);
    result = sqlite3_step(statement);
    
    BOOL whitelisted = (result == SQLITE_ROW && sqlite3_column_int(statement, 0) > 0);
    sqlite3_finalize(statement);
    
    return whitelisted;
}

- (NSArray<NSDictionary *> *)getBlockedURLs {
    if (!_database) return @[];
    
    const char *sql = 
        "SELECT url, timestamp FROM urls WHERE type = 'block' ORDER BY timestamp DESC";
    
    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
    
    if (result != SQLITE_OK) {
        return @[];
    }
    
    NSMutableArray<NSDictionary *> *urls = [NSMutableArray array];
    
    while ((result = sqlite3_step(statement)) == SQLITE_ROW) {
        const char *urlStr = sqlite3_column_text(statement, 0);
        const char *timestamp = sqlite3_column_text(statement, 1);
        
        if (urlStr && timestamp) {
            [urls addObject:@{
                @"url": [NSString stringWithUTF8String:urlStr],
                @"timestamp": [NSString stringWithUTF8String:timestamp]
            }];
        }
    }
    
    sqlite3_finalize(statement);
    return urls;
}

- (NSArray<NSDictionary *> *)getWhitelistedURLs {
    if (!_database) return @[];
    
    const char *sql = 
        "SELECT url, timestamp FROM urls WHERE type = 'whitelist' ORDER BY timestamp DESC";
    
    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
    
    if (result != SQLITE_OK) {
        return @[];
    }
    
    NSMutableArray<NSDictionary *> *urls = [NSMutableArray array];
    
    while ((result = sqlite3_step(statement)) == SQLITE_ROW) {
        const char *urlStr = sqlite3_column_text(statement, 0);
        const char *timestamp = sqlite3_column_text(statement, 1);
        
        if (urlStr && timestamp) {
            [urls addObject:@{
                @"url": [NSString stringWithUTF8String:urlStr],
                @"timestamp": [NSString stringWithUTF8String:timestamp]
            }];
        }
    }
    
    sqlite3_finalize(statement);
    return urls;
}

- (BOOL)removeURL:(NSString *)url {
    if (!_database || !url) return NO;
    
    const char *sql = "DELETE FROM urls WHERE url = ?";
    
    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
    
    if (result != SQLITE_OK) {
        return NO;
    }
    
    sqlite3_bind_text(statement, 1, [url UTF8String], -1, SQLITE_TRANSIENT);
    result = sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    return result == SQLITE_OK || result == SQLITE_DONE;
}

- (void)clearAllURLs {
    if (!_database) return;
    
    const char *sql = "DELETE FROM urls";
    sqlite3_exec(_database, sql, NULL, NULL, NULL);
}

- (NSInteger)getBlockedCount {
    if (!_database) return 0;
    
    const char *sql = "SELECT COUNT(*) FROM urls WHERE type = 'block'";
    
    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
    
    if (result != SQLITE_OK) {
        return 0;
    }
    
    result = sqlite3_step(statement);
    NSInteger count = (result == SQLITE_ROW) ? sqlite3_column_int(statement, 0) : 0;
    sqlite3_finalize(statement);
    
    return count;
}

- (void)closeDatabase {
    if (_database) {
        sqlite3_close(_database);
        _database = NULL;
    }
}

@end
