//
//  GHDebugDraw.m
//  cocos2d-ios
//
//  Created by Bogdan Vladu on 4/29/13.
//
//

#import "GHDebugDrawLayer.h"
#import "GHDirector.h"
#import "ghMacros.h"
#import "GHSprite.h"

#if GH_ENABLE_PHYSICS_INTEGRATION
@implementation GHDebugDrawLayer

-(id)initWithWorld:(b2World*)w{
    self = [super init];
    if(self){
        world = w;
        mShaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_Position_uColor];
        mColorLocation = glGetUniformLocation( mShaderProgram->program_, "u_color");
    }
    return self;
}
+(id)debugDrawLayerWithWorld:(b2World*)world{
    return [[[self alloc] initWithWorld:world] autorelease];
}

-(void) draw
{
	[super draw];
	
#ifdef GH_DEBUG
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	kmGLPushMatrix();
	
    //Iterate over the bodies in the physics world
    for (b2Body* body = world->GetBodyList(); body; body = body->GetNext())
    {
       	[GHDebugDrawLayer DebugDrawBody:body
                          shaderProgram:mShaderProgram
                          colorLocation:mColorLocation];
    }
    
	kmGLPopMatrix();
#endif
}



+(void)DebugDrawBody:(b2Body*)body
       shaderProgram:(CCGLProgram*)shaderProgram
       colorLocation:(GLint)colorLocation

{
    const b2Transform& xf = body->GetTransform();
    for (b2Fixture* f = body->GetFixtureList(); f; f = f->GetNext())
    {
        b2Color color = b2Color(0.5f, 0.5f, 0.3f);
        
        if (body->IsActive() == false)
        {
            color = b2Color(0.5f, 0.5f, 0.3f);
        }
        else if (body->GetType() == b2_staticBody)
        {
            color = b2Color(0.5f, 0.9f, 0.5f);
        }
        else if (body->GetType() == b2_kinematicBody)
        {
            color =  b2Color(0.5f, 0.5f, 0.9f);
        }
        else if (body->IsAwake() == false)
        {
            color = b2Color(0.6f, 0.6f, 0.6f);
        }
        else
        {
            color = b2Color(0.9f, 0.7f, 0.7f);
        }
        
        [GHDebugDrawLayer drawShape:f
                        ofBody:body
                     transform:xf
                         color:color
                 shaderProgram:shaderProgram
                 colorLocation:colorLocation
                         ratio:GH_METER_RATIO()];
    }
}

+(void)drawShape:(b2Fixture*)fixture
          ofBody:(b2Body*)body
       transform:(const b2Transform&)xf
           color:(const b2Color&)color
   shaderProgram:(CCGLProgram*)shaderProgram
   colorLocation:(GLint)colorLocation
           ratio:(float)ratio
{
//    GHSprite* sprite = (GHSprite*)body->GetUserData();
    
    switch (fixture->GetType())
    {
        case b2Shape::e_circle:
        {
            b2CircleShape* circle = (b2CircleShape*)fixture->GetShape();

            b2Vec2 center = b2Mul(xf, -circle->m_p);

//            b2Vec2 center =b2Vec2(GH_VALUE_TO_METERS([sprite contentSize].width/2.0f) + circle->m_p.x ,
//                                  GH_VALUE_TO_METERS([sprite contentSize].height/2.0f)- circle->m_p.y);
            
            float32 radius = circle->m_radius;
            b2Vec2 axis = b2Mul(xf.q, b2Vec2(1.0f, 0.0f));
            
            [GHDebugDrawLayer DrawSolidCircleWithCenter:center
                                            radius:radius
                                              axis:axis
                                             color:color
                                     shaderProgram:shaderProgram
                                     colorLocation:colorLocation
                                             ratio:ratio];

        }
            break;
            
        case b2Shape::e_edge:
        {
            b2EdgeShape* edge = (b2EdgeShape*)fixture->GetShape();
            b2Vec2 v1 = b2Mul(xf, edge->m_vertex1);
            b2Vec2 v2 = b2Mul(xf, edge->m_vertex2);
            
//            b2Vec2 v1 = edge->m_vertex1;
//            v1.x += GH_VALUE_TO_METERS([sprite contentSize].width/2.0f);
//            v1.y += GH_VALUE_TO_METERS([sprite contentSize].height/2.0f);
//
//            
//            b2Vec2 v2 = edge->m_vertex2;
//            v2.x += GH_VALUE_TO_METERS([sprite contentSize].width/2.0f);
//            v2.y += GH_VALUE_TO_METERS([sprite contentSize].height/2.0f);

            
            [GHDebugDrawLayer DrawSegmentWithPoint1:v1
                                        point2:v2
                                         color:color
                                 shaderProgram:shaderProgram
                                 colorLocation:colorLocation
                                         ratio:ratio];

        }
            break;
            
        case b2Shape::e_chain:
        {
            b2ChainShape* chain = (b2ChainShape*)fixture->GetShape();
            int32 count = chain->m_count;
            const b2Vec2* vertices = chain->m_vertices;
            
            b2Vec2 v1 = b2Mul(xf, vertices[0]);
//            b2Vec2 v1 = vertices[0];
//            v1.x += GH_VALUE_TO_METERS([sprite contentSize].width/2.0f);
//            v1.y += GH_VALUE_TO_METERS([sprite contentSize].height/2.0f);
            
            for (int32 i = 1; i < count; ++i)
            {
                b2Vec2 v2 = b2Mul(xf, vertices[i]);
//                b2Vec2 v2 = vertices[i];
//                v2.x += GH_VALUE_TO_METERS([sprite contentSize].width/2.0f);
//                v2.y += GH_VALUE_TO_METERS([sprite contentSize].height/2.0f);


                [GHDebugDrawLayer DrawSegmentWithPoint1:v1
                                            point2:v2
                                             color:color
                                     shaderProgram:shaderProgram
                                     colorLocation:colorLocation
                                             ratio:ratio];

               [GHDebugDrawLayer DrawCircleWithCenter:v1
                                          radius:0.05f
                                           color:color
                                   shaderProgram:shaderProgram
                                   colorLocation:colorLocation
                                           ratio:ratio];

                v1 = v2;
            }
        }
            break;
            
        case b2Shape::e_polygon:
        {
            b2PolygonShape* poly = (b2PolygonShape*)fixture->GetShape();
            int32 vertexCount = poly->m_vertexCount;
            b2Assert(vertexCount <= b2_maxPolygonVertices);
            b2Vec2 vertices[b2_maxPolygonVertices];
            
            for (int32 i = 0; i < vertexCount; ++i)
            {
                vertices[i] = b2Mul(xf, poly->m_vertices[i]);
//                vertices[i] = poly->m_vertices[i];
//                vertices[i].x += GH_VALUE_TO_METERS([sprite contentSize].width/2.0f);
//                vertices[i].y += GH_VALUE_TO_METERS([sprite contentSize].height/2.0f);

            }
            [GHDebugDrawLayer DrawSolidPolygonWithVertices:vertices
                                                count:vertexCount
                                                color:color
                                        shaderProgram:shaderProgram
                                        colorLocation:colorLocation
                                                ratio:ratio];
        }
            break;
            
        default:
            break;
    }
}


+(void) DrawSolidPolygonWithVertices:(const b2Vec2*)old_vertices
                               count:(int32)vertexCount
                               color:(const b2Color&)color
                       shaderProgram:(CCGLProgram*)mShaderProgram
                       colorLocation:(GLint)mColorLocation
                               ratio:(float)mRatio
{
	[mShaderProgram use];
	[mShaderProgram setUniformForModelViewProjectionMatrix];
    
	ccVertex2F vertices[vertexCount];
    
	for( int i=0;i<vertexCount;i++) {
		b2Vec2 tmp = old_vertices[i];
		tmp = old_vertices[i];
		tmp *= mRatio;
		vertices[i].x = tmp.x;
		vertices[i].y = tmp.y;
	}
    
	[mShaderProgram setUniformLocation:mColorLocation withF1:color.r*0.5f f2:color.g*0.5f f3:color.b*0.5f f4:0.5f];
    
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    
	glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
    
	[mShaderProgram setUniformLocation:mColorLocation withF1:color.r f2:color.g f3:color.b f4:1];
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
    
	CC_INCREMENT_GL_DRAWS(2);
    
	CHECK_GL_ERROR_DEBUG();
}


+(void) DrawSegmentWithPoint1:(const b2Vec2&)p1
                       point2:(const b2Vec2&)p2
                        color:(const b2Color&)color
                shaderProgram:(CCGLProgram*)mShaderProgram
                colorLocation:(GLint)mColorLocation
                        ratio:(float)mRatio
{
	[mShaderProgram use];
	[mShaderProgram setUniformForModelViewProjectionMatrix];
    
	[mShaderProgram setUniformLocation:mColorLocation withF1:color.r f2:color.g f3:color.b f4:1];
    
	GLfloat				glVertices[] = {
		p1.x * mRatio, p1.y * mRatio,
		p2.x * mRatio, p2.y * mRatio
	};
    
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, glVertices);
    
	glDrawArrays(GL_LINES, 0, 2);
	
	CC_INCREMENT_GL_DRAWS(1);
    
	CHECK_GL_ERROR_DEBUG();
}

+(void) DrawSolidCircleWithCenter:(const b2Vec2&)center
                           radius:(float32)radius
                             axis:(const b2Vec2&)axis
                            color:(const b2Color&)color
                    shaderProgram:(CCGLProgram*)mShaderProgram
                    colorLocation:(GLint)mColorLocation
                            ratio:(float)mRatio
{
	[mShaderProgram use];
	[mShaderProgram setUniformForModelViewProjectionMatrix];
    
	const float32 k_segments = 16.0f;
	int vertexCount=16;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;
    
	GLfloat				glVertices[vertexCount*2];
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
		glVertices[i*2]=v.x * mRatio;
		glVertices[i*2+1]=v.y * mRatio;
		theta += k_increment;
	}
    
    
	[mShaderProgram setUniformLocation:mColorLocation withF1:color.r*0.5f f2:color.g*0.5f f3:color.b*0.5f f4:0.5f];
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, glVertices);
	glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
    
    
	[mShaderProgram setUniformLocation:mColorLocation withF1:color.r f2:color.g f3:color.b f4:1];
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
    
	// Draw the axis line
    
    [GHDebugDrawLayer DrawSegmentWithPoint1:center
                                point2:center+radius*axis
                                 color:color
                         shaderProgram:mShaderProgram
                         colorLocation:mColorLocation
                                 ratio:mRatio];
        
	CC_INCREMENT_GL_DRAWS(2);
    
	CHECK_GL_ERROR_DEBUG();
}

+(void) DrawCircleWithCenter:(const b2Vec2&)center
                      radius:(float32)radius
                       color:(const b2Color&)color
               shaderProgram:(CCGLProgram*)mShaderProgram
               colorLocation:(GLint)mColorLocation
                       ratio:(float)mRatio
{
	[mShaderProgram use];
	[mShaderProgram setUniformForModelViewProjectionMatrix];
    
	const float32 k_segments = 16.0f;
	int vertexCount=16;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;
    
	GLfloat				glVertices[vertexCount*2];
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
		glVertices[i*2]=v.x * mRatio;
		glVertices[i*2+1]=v.y * mRatio;
		theta += k_increment;
	}
    
	[mShaderProgram setUniformLocation:mColorLocation withF1:color.r f2:color.g f3:color.b f4:1];
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, glVertices);
    
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
    
	CC_INCREMENT_GL_DRAWS(1);
    
	CHECK_GL_ERROR_DEBUG();
}

#endif


@end
