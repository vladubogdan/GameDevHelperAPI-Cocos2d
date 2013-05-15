//
//  GHBone.h
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 4/4/13.
//
//

#import "cocos2d.h"
#import "ghConfig.h"

@class GHSprite;
@class GHBoneSkin;

@interface GHBone : CCNode
{
    BOOL rigid_;
    NSString* name;
    NSString* uuid;
    
    NSMutableArray* neighbours;
    NSMutableArray* neighboursDistances;
    
    CGPoint previousPosition;//used when transitioning
}
@property(nonatomic,readwrite,assign) BOOL rigid;

-(id)initWithDictionary:(NSDictionary*)info;
+(id)boneWithDictionary:(NSDictionary*)info;

-(NSArray*)allBones;//includes self and all subchildren
-(GHBone*)boneWithName:(NSString*)val;

-(NSString*)name;
-(NSString*)uuid;//unique identifier -

-(void)setPosition:(CGPoint)pos parent:(GHBone*)father;
-(float)degrees;//return the angle between bone and parent

//save the current position to previousPosition;
//called at the begining of a transition
-(void)savePosition;
-(CGPoint)previousPosition;
@end
