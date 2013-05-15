//
//  ghConfig.h
//  GameDevHelper.com
//
//  Created by Bogdan Vladu.
//  Copyright (c) 2013 Bogdan Vladu. All rights reserved.
//

#ifndef GAME_DEV_HELPER_API_ghConfig_h
#define GAME_DEV_HELPER_API_ghConfig_h

//change GH_ENABLE_PHYSICS_INTEGRATION to 0 if you don't want to use physics
#ifndef GH_ENABLE_PHYSICS_INTEGRATION
#define GH_ENABLE_PHYSICS_INTEGRATION 1
#endif

#if __has_feature(objc_arc) && __clang_major__ >= 3
#define GH_ENABLE_ARC 1
#endif // __has_feature(objc_arc)


#define GH_DEBUG//comment this line if you dont want debug drawing and logs


#endif//GAME_DEV_HELPER_API_ghConfig_h
