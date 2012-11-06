//
//  ncutil3 - network configuration utility, version 3
//  ncutil_vers
//
//  Program version stuff.
//
//  Created by Jeffrey Frey on Sun Jun 12 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#ifndef __NCUTIL_VERSION__
#define __NCUTIL_VERSION__

extern const unsigned short NCUtilVersion_Major;
extern const unsigned short NCUtilVersion_Minor;
extern const unsigned short NCUtilVersion_Build;
extern const char           NCUtilVersion_Stage;
extern const char*          NCUtilOSVariant;

const char* NCUtilVersionString();

#endif /* __NCUTIL_VERSION__ */
