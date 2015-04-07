//

#import <UIKit/UIKit.h>

@interface ConfigurationManager : NSObject {
    NSArray* cfgservers;
    NSString* directory;
    NSString* filename;

    int currSerIndex;

    id succTarget;
    SEL succAction;
    id failTarget;
    SEL failAction;
}

-(ConfigurationManager*) initWithServers:(NSArray*)cfgservs andDirectory:(NSString*)directory andCfgFileName:(NSString*)filename ;

+(NSString*)LoadFromFile:(NSString*)filepath;
+(void)SaveToFile:(NSString*)filepath andData:(NSString*)data;

- (void)getConfigFromServer:(id)successTarget successAction:(SEL)successAction failureTarget:(id)failureTarget failureAction:(SEL)failureAction;
@end