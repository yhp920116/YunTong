
/* Vincent, GZ, 2012-03-07 */

#import <Foundation/Foundation.h>


@interface NgnEventArgs : NSObject {
	NSMutableDictionary* mExtras;
}

-(void)putExtraWithKey: (NSString*)key andValue:(NSString*)value;
-(NSString*)getExtraWithKey: (NSString*)key;

@end
