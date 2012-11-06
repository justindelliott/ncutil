//
//  ncutil3 - network configuration utility, version 3
//  NCTokenList
//
//  Instances handle the tokenizing of strings and generation of
//  word-completions for a partial string.
//
//  Created by Jeffrey Frey on Mon Nov 19 2007.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCObject.h"

enum {
  kNCTokenInvalid     = 0xFFFFFFFF
};

@interface NCTokenList : NCObject
{
  int       _tokenCount;
  void*     _tokenTable;
  int       _cmdIndex;
  size_t    _textLength;
}

+ (id) tokenListWithStrings:(const char**)strings tokens:(const int*)tokens count:(int)count;

- (int) tokenForText:(const char*)text start:(int*)start length:(int)length;
- (char*) generateCompletionForText:(const char*)text newSession:(BOOL)newSession;

@end
