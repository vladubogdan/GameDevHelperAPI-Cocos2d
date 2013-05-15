
#import "TestLayer.h"

#pragma mark - TestLayer

@interface TestLayer()
-(void) createResetButton;
@end

@implementation TestLayer

-(id) init
{
	if( (self=[super init])) {

		// enable events

#ifdef __CC_PLATFORM_IOS
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
		self.isMouseEnabled = YES;
#endif

		CGSize s = [CCDirector sharedDirector].winSize;

		// create reset button
		[self createResetButton];

        NSString* title = [self initTest];

		CCLabelTTF *label = [CCLabelTTF labelWithString:title fontName:@"Marker Felt" fontSize:16];
		[self addChild:label z:0];
		[label setColor:ccc3(255,255,255)];
		label.position = ccp( s.width/2, s.height-18);

		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) createResetButton
{
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Reset" fontName:@"Marker Felt" fontSize:20];
    [label setColor:ccc3(255,255,255)];
    
    CCMenuItemLabel* reset = [CCMenuItemLabel itemWithLabel:label block:^(id sender) {
		CCScene *s = [CCScene node];
        id child = [[[self class] alloc] init];
		[s addChild:child];
		[child release];
		[[CCDirector sharedDirector] replaceScene: s];
	}];
    
	CCMenu *menu = [CCMenu menuWithItems:reset, nil];

	CGSize s = [[CCDirector sharedDirector] winSize];

	menu.position = ccp(s.width/2, 18);
	[self addChild: menu z:100];
}

-(NSString*)initTest{
    return @"Tap screen";
}
-(void)executeTestCodeAtPosition:(CGPoint)point{
    
}

-(void) update: (ccTime) dt
{
    
}


#ifdef __CC_PLATFORM_IOS

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
        
		location = [[CCDirector sharedDirector] convertToGL: location];
        
	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
        
		location = [[CCDirector sharedDirector] convertToGL: location];
        
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];

		location = [[CCDirector sharedDirector] convertToGL: location];

		[self executeTestCodeAtPosition: location];
	}
}

#elif defined(__CC_PLATFORM_MAC)
-(BOOL) ccMouseUp:(NSEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];

	[self executeTestCodeAtPosition: location];

	return YES;
}
#endif

@end

