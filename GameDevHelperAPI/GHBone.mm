//
//  GHBone.m
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 4/4/13.
//
//

#import "GHBone.h"

@implementation GHBone

@synthesize rigid = rigid_;

-(id)initWithDictionary:(NSDictionary*)info{
    self = [super init];
    if(self){

        neighbours = nil;
        neighboursDistances = nil;
        
        //children
        //name
        //rigid
        //root
        rigid_ = [[info objectForKey:@"rigid"] boolValue];
        
        CGPoint localPos = ccp(0,0);
        id bonePos = [info objectForKey:@"localPos"]; //this position is local from the root bone
        if(bonePos){
            localPos = CGPointFromString(bonePos);
        }
        localPos.x /= CC_CONTENT_SCALE_FACTOR();
        localPos.y /= CC_CONTENT_SCALE_FACTOR();
        
        id boneName = [info objectForKey:@"name"];
        if(boneName){
            name = [[NSString alloc] initWithString:boneName];
        }
        else{
            name = [[NSString alloc] initWithString:@"UntitledBone"];
        }
        
        id boneUUID = [info objectForKey:@"uuid"];
        if(boneUUID){
            uuid = [[NSString alloc] initWithString:boneUUID];
        }
        else{
            uuid = [[NSString alloc] initWithString:@"ERROR_NO_UUID_FOUND"];
        }
        
        
        [self setPosition:localPos];
        
        NSArray* childrenInfo = [info objectForKey:@"children"];
        for(NSDictionary* childInfo in childrenInfo)
        {
            GHBone* childBone = [GHBone boneWithDictionary:childInfo];
            if(childBone){
                [self addChild:childBone];
            }
        }
    }
    return self;
}
+(id)boneWithDictionary:(NSDictionary*)info{
    return [[[self alloc] initWithDictionary:info] autorelease];
}

-(void)dealloc{
    [neighbours release];
    [neighboursDistances release];
    [name release];
    [uuid release];
    
    [super dealloc];
}

-(void)addNeighbor:(GHBone*)neighbor{
    
    if(neighbours == nil){
        neighbours = [[NSMutableArray alloc] init];
        neighboursDistances = [[NSMutableArray alloc] init];
    }
    
    [neighbours addObject:neighbor];
    [self calculateDistancesFromNeighbours];
}

-(void)removeNeighbor:(GHBone*)neighbor{
    [neighbours removeObject:neighbor];
}

// Calculates the distance from neighbours
-(void)calculateDistancesFromNeighbours
{
    [neighboursDistances removeAllObjects];
    for(GHBone* node in neighbours){
        float dx = node.position.x - self.position.x;
        float dy = node.position.y - self.position.y;
        [neighboursDistances addObject:[NSNumber numberWithFloat:sqrtf(dx*dx+dy*dy)]];
    }
};

-(void)addChild:(GHBone*)child
{
    [self addNeighbor:child];
    [super addChild:child];
    [self calculateDistancesFromNeighbours];
    [child addNeighbor:self];    
}

-(NSArray*)allBones{
    
    NSMutableArray* array = [NSMutableArray array];
    
    [array addObject:self];
    for(GHBone* bone in [self children])
    {
        [array addObjectsFromArray:[bone allBones]];
    }
    return array;
}

-(GHBone*)boneWithName:(NSString*)val{

    if([name isEqualToString:val]){
        return self;
    }
    
    for(GHBone* bone in [self children])
    {
        GHBone* retBone = [bone boneWithName:val];
        if(retBone){
            return retBone;
        }
    }
    
    return nil;
}

-(NSString*)name{
    return name;
}
-(NSString*)uuid{
    return uuid;
}


-(void)setPosition:(CGPoint)pos
            parent:(GHBone*)father
{
    self.position = pos;
    [self move:father];
}

-(float)degrees{//return the angle between bone and parent
    GHBone* _father = (GHBone*)[self parent];
    if(_father && [_father isKindOfClass:[GHBone class]])
    {
        CGPoint curPoint = ccp(((GHBone*)_father).position.x,
                               ((GHBone*)_father).position.y);
        CGPoint endPoint = ccp(self.position.x,
                               self.position.y);
        
        //we inverse y points here because of cocos2d flip coordinates
        return  (atan2(curPoint.y - endPoint.y,
                       endPoint.x - curPoint.x)*180.0)/M_PI + 90;
    }
    
    return 0;
}


-(void)move:(GHBone*)father
{
    for(int i = 0; i < [neighbours count]; ++i)
    {
        GHBone* node = [neighbours objectAtIndex:i];
        if(node != father)
        {
            [node MakeMove:self
                     child:node
                  distance:[[neighboursDistances objectAtIndex:i] floatValue]];
            
            [node move:self];
        }
    }
}

-(void)MakeMove:(GHBone*)parent
          child:(GHBone*)child
       distance:(float)dist
{
    if(child && child.rigid)
    {
        //do nothing
    }
    else if(parent)
    {
        float dx = self.position.x - parent.position.x;
        float dy = self.position.y - parent.position.y;
        float angle = atan2f(dy, dx);

        self.position = ccp(parent.position.x + cos(angle)*dist,
                            parent.position.y + sin(angle)*dist);
    }
}

-(void)savePosition{
    previousPosition = self.position;
}
-(CGPoint)previousPosition{
    return previousPosition;
}

@end
