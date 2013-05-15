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
@property(nonatomic,readwrite,assign) CGPoint positionOffset;
@property(nonatomic,readwrite,assign) float angleOffset;
@property(nonatomic,readwrite,assign) float connectionAngle;
@property(nonatomic,readonly) NSString* name;
@property(nonatomic,readonly) NSString* uuid;

-(id)initWithSprite:(GHSprite*)spr bone:(GHBone*)bn name:(NSString*)skinName uuid:(NSString*)skinUUID;
+(id)skinWithSprite:(GHSprite*)spr bone:(GHBone*)bn name:(NSString*)skinName uuid:(NSString*)skinUUID;

-(GHSprite*)sprite;
-(void)setSprite:(GHSprite*)spr;

-(GHBone*)bone;
-(void)setBone:(GHBone*)val;

//sets the positionOffset, angleOffset and connectionAngle based on the bone
-(void)setupTransformations;
-(void)transform;//set sprite position and rotation based on bone movement
@end
