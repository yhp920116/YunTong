
/* Vincent, GZ, 2012-03-07 */

#import "NgnSipSession.h"
#import "NgnStringUtils.h"

#import "tsk_debug.h"

@implementation NgnSipSession

-(NgnSipSession*) initWithSipStack: (NgnSipStack*)sipStack{
	if((self = [super init])){
		mSipStack = [sipStack retain];
		mOutgoing = NO;
		mConnectionState = CONN_STATE_NONE;
		mId = -1;
		/* initialize must be called by the child class after session_create() */
        /* initialize(); */
	}
	return self;
}
-(void)dealloc{
	[mSipStack release];
	[mFromUri release];
    [mToUri release];
    [mCompId release];
    [mRemotePartyUri release];
    [mRemotePartyDisplayName release];
	
	[super dealloc];
}

-(void)initialize{
	// Sip Headers (common to all sessions)
	[self getSession]->addCaps("+g.oma.sip-im");
	[self getSession]->addCaps("language", "\"en,fr\"");
}

-(long)getId{
	if(mId == -1){
		mId = [self getSession]->getId(); 
	}
	return mId;
}

-(NSNumber*)getIdAsNumber{
	return [NSNumber numberWithLong: [self getId]];
}

-(BOOL)isOutgoing{
	return mOutgoing;
}

-(NgnSipStack*)getSipStack{
	return mSipStack;
}

-(BOOL)addHeaderWithName: (NSString*)name andValue: (NSString*)value{
	return [self getSession]->addHeader([name UTF8String], [value UTF8String]);
}

-(BOOL)removeHeaderWithName: (NSString*)name{
	return [self getSession]->removeHeader([name UTF8String]);
}

-(BOOL)addCapsWithName: (NSString*)name{
	return [self getSession]->addCaps([name UTF8String]);
}

-(BOOL)addCapsWithName: (NSString*)name andValue: (NSString*)value{
	return [self getSession]->addCaps([name UTF8String], [value UTF8String]);
}


-(BOOL)removeCapsWithName: (NSString*)name{
	return [self getSession]->removeCaps([name UTF8String]);
}

-(BOOL)isConnected{
	return (mConnectionState == CONN_STATE_CONNECTED);
}

-(ConnectionState_t)getConnectionState{
	return mConnectionState;
}

-(void)setConnectionState: (ConnectionState_t)state{
	mConnectionState = state;
}

-(NSString*)getFromUri{
	return mFromUri;
}

-(BOOL)setFromUri:(NSString*)uri{
	if (![self getSession]->setFromUri([uri UTF8String])){
		TSK_DEBUG_ERROR("%s is invalid as FromUri", [uri UTF8String]);
		return NO;
	}
	[mFromUri release], mFromUri = [uri retain];
	return YES;
}

-(NSString*)getToUri{
	return mToUri;
}

-(BOOL)setToUri:(NSString*)uri{
	if (![self getSession]->setToUri([uri UTF8String])){
		TSK_DEBUG_ERROR("%s is invalid as ToUri", [uri UTF8String]);
		return NO;
	}
	[mToUri release], mToUri = [uri retain];
	return YES;
}

-(NSString*)getRemotePartyUri{
	if([NgnStringUtils isNullOrEmpty:mRemotePartyUri]){
		mRemotePartyUri =  mOutgoing ? [mToUri retain] : [mFromUri retain];
	}
	return [NgnStringUtils isNullOrEmpty:mRemotePartyUri] ? @"" : mRemotePartyUri;
}

-(void)setRemotePartyUri:(NSString*)uri{
	[mRemotePartyUri release], mRemotePartyUri = [uri retain];
}

-(void)setSigCompId:(NSString*)compId{
	if(mCompId != nil && mCompId != compId){
		[self getSession]->removeSigCompCompartment();
	}
	[mCompId release], mCompId = [compId retain];
	if(mCompId != nil){
		[self getSession]->addSigCompCompartment([mCompId UTF8String]);
	}
}

-(BOOL)setExpires:(unsigned)expires{
	return [self getSession]->setExpires(expires);
}

-(SipSession*)getSession{
	[NSException raise:NSInternalInconsistencyException
				format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
	return tsk_null;
}

@end
