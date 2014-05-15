/*
 * CookieStorage.h
 *
 * Created by Sajid Anwar. Much thanks to Sasmito Adibowo.
 * http://cutecoder.org/programming/implementing-cookie-storage/
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <WebKit/WebKit.h>

@interface CookieStorage : NSObject


+ (BOOL)hostMatchesDomainWithURL:(NSURL *)url domain:(NSString *)domain;

+ (NSMutableArray *)storage;
+ (BOOL)archive;
+ (void)unarchive;
+ (NSString *)cookieStoragePath;

@end
