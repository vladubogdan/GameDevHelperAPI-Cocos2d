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

/**
 GHBone class is used to define skeleton structures. Each bone is connected to other children bones. 
 
 When a bone is moved each of its children is moved as well in order to simulate skeletons.
 
 End users will probably never have to use this class directly.
 */
@interface GHBone : CCNode
{
    BOOL rigid_;
    NSString* name;
    NSString* uuid;
    
    NSMutableArray* neighbours;
    NSMutableArray* neighboursDistances;
    
    CGPoint previousPosition;//used when transitioning
}
/**
 Set and get the rigid state of this bone.
*/
@property(nonatomic,readwrite,assign) BOOL rigid;

/**
 Create a bone using the options from a dictionary.
 */
-(id)initWithDictionary:(NSDictionary*)info;
/**
 Create an autoreleased bone using the options from a dictionary.
 */
+(id)boneWithDictionary:(NSDictionary*)info;

/**
 Returns an array which includes self and all children bones.
 */
-(NSArray*)allBones;

/**
 Returns a specific children bone given the name of the bone.
 */
-(GHBone*)boneWithName:(NSString*)val;

/**
 Returns the name of the bone.
 */
-(NSString*)name;

/**
 Returns the unique identifier of the bone.
 */
-(NSString*)uuid;

/**
 Sets the position of the bone given the bone parent, which may be nil.
 */
-(void)setPosition:(CGPoint)pos parent:(GHBone*)father;

/**
 Returns the angle between this bone and its parent in degrees.
 */
-(float)degrees;

/**
 Save the current position to previousPosition. This is called at the begining of a transition.
 */
-(void)savePosition;

/**
 Returns the previous position.
 */
-(CGPoint)previousPosition;
@end
