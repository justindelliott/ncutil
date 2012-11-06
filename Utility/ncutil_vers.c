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

#include "ncutil_vers.h"

#include <stdio.h>

const unsigned short NCUtilVersion_Major = 3;
const unsigned short NCUtilVersion_Minor = 3;
const unsigned short NCUtilVersion_Build = 18;

const char NCUtilVersion_Stage = 'b';

#ifdef NCUTIL_USE_FOUNDATION
const char* NCUtilOSVariant = "Mac OS X";
#else
const char* NCUtilOSVariant = "Darwin OS";
#endif


const char*
NCUtilVersionString()
{
  static char     ncutilVersionString[64] = "";
  
  if ( ! *ncutilVersionString ) {
    const char*   format;
    const char*   stage = NULL;
    
    if ( NCUtilVersion_Build ) {
      if ( NCUtilVersion_Stage != 'f' ) {
        format = "%hu.%hu.%hu (%s for %s)";
      } else {
        format = "%hu.%hu.%hu (%5$s)";
      }
    } else {
      if ( NCUtilVersion_Stage != 'f' ) {
        format = "%hu.%hu (%4$s for %5$s)";
      } else {
        format = "%hu.%hu (%5$s)";
      }
    }
    
    switch ( NCUtilVersion_Stage ) {
    
      case 'a':
        stage = "Alpha";
        break;
      case 'b':
        stage = "Beta";
        break;
      case 'f':
        stage = "Final";
        break;
      default:
        stage = "Development";
        break;
    
    }
    
    snprintf(
        ncutilVersionString,
        64,
        format,
        NCUtilVersion_Major,
        NCUtilVersion_Minor,
        NCUtilVersion_Build,
        stage,
        NCUtilOSVariant
      );
  }
  return (const char*)ncutilVersionString;
}
