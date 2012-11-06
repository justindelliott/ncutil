//
//  ncutil3 - network configuration utility, version 3
//  NCApplication
//
//  The main body of the utility program.
//
//  Created by Jeffrey Frey on Sun Jun 12 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCUtilFoundation.h"
#include "CFCString.h"

enum {
  kNCUtil_NoError                   =   0
};

@interface NCApplication : NCObject
{
  NCPreferenceSession*    _preferenceSession;
  NCDirectoryNode*        _currentDirectory;
  NCDirectoryNode*        _lastDirectory;
  
  struct {
    unsigned int          _runAsShell : 1;
    unsigned int          _recursiveList : 1;
    unsigned int          _activateAtExit : 1;
    unsigned int          _initialParamScanDone : 1;
    unsigned int          _completedRunLoop : 1;
    unsigned int          _dieOnSyntaxErrors : 1;
    unsigned int          _needsPrompt : 1;
    unsigned int          _treeWasModified : 1;
  } _options;
}

- (id) initWithArguments:(const char**)argv count:(int)argc;

- (NCPreferenceSession*) preferenceSession;

- (NCDirectoryNode*) currentDirectory;
- (void) setCurrentDirectory:(NCDirectoryNode*)newDirectory;

- (NCDirectoryNode*) lastDirectory;

- (BOOL) runAsShell;

- (int) run;

@end

CF_EXPORT NCApplication* NCApp;

/*!
  @function NCApplicationMain
  @abstract Program Objective-C entry point.
  @discussion The <TT>NCApplicationMain</TT> function represents
  the entry point of the Objective-C program.
*/
int NCApplicationMain(int argc,const char* argv[]);
