//
//  GHBoneSkin.h
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 4/5/13.
//
//

#import <Foundation/Foundation.h>
#import "ghConfig.h"

@class GHSprite;
@class GHBone;

/**
 GHBoneSkin is a helper class that connects a bone to a sprite.
 
 End users will probably never have to use this class directly.
 */
@interface GHBoneSkin : NSObject
{
    GHSprite* sprite;
    GHBone* bone;
    NSString* name;//the name of this skin
    NSString* uuid;//unique identifier for this skin
    
    CGPoint positionOffset;
    float   angleOffset;
    float   connectionAngle;//initial angle when bone was connected with the sprite
}
/**
 Get and set the position offset that is used when transforming a sprite based on bone movement.
 */
@property(nonatomic,readwrite,assign) CGPoint positionOffset;
/**
 Get and set the angle offset that is used when transforming a sprite based on bone movement.
 */
@property(nonatomic,readwrite,assign) float angleOffset;
/**
 Get and set the original angle at which the sprite was connected to the bone.
 */
@property(nonatomic,readwrite,assign) float connectionAngle;
/**
 Get the name of this skin connection.
 */
@property(nonatomic,readonly) NSString* name;
/**
 Get the unique identifier of this connection.
 */
@property(nonatomic,readonly) NSString* uuid;

/**
 Create a GHBoneSkin object given the required arguments.
 */
-(id)initWithSprite:(GHSprite*)spr bone:(GHBone*)bn name:(NSString*)skinName uuid:(NSString*)skinUUID;
/**
 Create an autoreleased GHBoneSkin object given the required arguments.
 */
+(id)skinWithSprite:(GHSprite*)spr bone:(GHBone*)bn name:(NSString*)skinName uuid:(NSString*)skinUUID;

/**
 Get the sprite used in this object.
 */
-(GHSprite*)sprite;
/**
 Set the sprite that will be used by this object.
 */
-(void)setSprite:(GHSprite*)spr;

/**
 Get the bone used in this object.
 */
-(GHBone*)bone;
/**
 Set the bone that will be used by this object.
 */
-(void)setBone:(GHBone*)val;

/**
 Update positionOffset, angleOffset and connectionAngle based on the bone movement.
 */
-(void)setupTransformations;
/**
 Update sprite position and rotation based on the bone movement.
*/
-(void)transform;
@end
