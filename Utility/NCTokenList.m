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

#import "NCTokenList.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct NCToken {
  const char*     text;
  size_t          textlen;
  int             token;
};

//

@interface NCTokenList(NCTokenListPrivate)

- (id) initWithStrings:(char**)strings tokens:(int*)tokens count:(int)count;
- (void) sortTokenTable;

@end

//

@implementation NCTokenList(NCTokenListPrivate)

  - (id) initWithStrings:(char**)strings
    tokens:(int*)tokens
    count:(int)count
  {
    size_t          tableBytes = 0;
    
    if ( count && strings && tokens ) {
      char**      p;
      int         i = count;
      
      tableBytes = count * sizeof(struct NCToken);
      p = (char**)strings;
      while ( i-- ) {
        tableBytes += strlen(*p);
        p++;
      }
    } else {
      [self release];
      return nil;
    }
    if ( self = [super init] ) {
      struct NCToken* tokenArray;
      char*           textArray;
      
      tokenArray = _tokenTable = malloc(tableBytes);
      
      if ( tokenArray ) {
        _tokenCount = count;
        textArray = ((void*)_tokenTable) + count * sizeof(struct NCToken);
        
        while ( count-- ) {
          size_t        tmplen;
          
          tokenArray->text    = textArray;
          tokenArray->textlen = tmplen = strlen(*strings);
          tokenArray->token   = *tokens;
          
          memcpy(textArray,*strings,tmplen);
          
          textArray += tmplen;
          tokenArray++;
          strings++;
          tokens++;
        }
        [self sortTokenTable];
      } else {
        [self release];
        self = nil;
      }
    }
    return self;
  }
  
//

  - (void) sortTokenTable
  {
    int       i,j;
    
    i = 1;
    while ( i < _tokenCount ) {
      struct NCToken    tmpToken = ((struct NCToken*)_tokenTable)[i];
      int               cmpLenI = tmpToken.textlen;
      const char*       textI = tmpToken.text;
      
      j = i;
      while ( j > 0 ) {
        int   cmpLenJ = ((struct NCToken*)_tokenTable)[j - 1].textlen;
        int   result = strncmp(((struct NCToken*)_tokenTable)[j - 1].text,textI,(cmpLenJ < cmpLenI ? cmpLenJ : cmpLenI));
        
        if ( (result > 0) || ( (result == 0) && (cmpLenJ > cmpLenI) ) ) {
          ((struct NCToken*)_tokenTable)[j] = ((struct NCToken*)_tokenTable)[j - 1];
          j--;
        } else {
          break;
        }
      }
      ((struct NCToken*)_tokenTable)[j] = tmpToken;
      i++;
    }

#if 0
    i = 0;
    while ( i < _tokenCount ) {
      char*     p = (char*)(((struct NCToken*)_tokenTable)[i].text);
      
      printf("%d ",((struct NCToken*)_tokenTable)[i].token);
      j = ((struct NCToken*)_tokenTable)[i].textlen;
      while ( j-- ) {
        fputc(*p,stdout);
        p++;
      }
      fputc('\n',stdout);
      i++;
    }
#endif

  }

@end

//

@implementation NCTokenList

+ (id) tokenListWithStrings:(const char**)strings
                     tokens:(const int*)tokens
                      count:(int)count
{
    //
    //  We're going to allocate all storage at once, so we need to know:
    //
    //    n * sizeof(struct NCToken) +
    //    sum( strlen(string[i]),{i|0,count - 1} )
    //
    id          newObject = nil;
    
    if ( count && strings && tokens ) {
        size_t      bytes = count * sizeof(struct NCToken);
        char**      p;
        int         i = count;
        
        p = (char**)strings;
        while ( i-- ) {
            bytes += strlen(*p);
            p++;
        }
        
        if ( (newObject = NCAllocateObject(self,bytes)) )
            [newObject initWithStrings:(char**)strings tokens:(int*)tokens count:count];
    }
    return newObject;
}

//

  - (void) dealloc
  {
    if ( _tokenTable ) free((void*)_tokenTable);
    [super dealloc];
  }
  
//

  - (int) tokenForText:(const char*)text
    start:(int*)start
    length:(int)length
  {
    int         low = 0;
    int         high = _tokenCount - 1;
    
    text += *start;
    
    while ( low <= high ) {
      int       current = (low + high) / 2;
      size_t    len = ((struct NCToken*)_tokenTable)[current].textlen;
      int       comparison = strncmp(((struct NCToken*)_tokenTable)[current].text,text,len);
      
      if ( comparison == 0 ) {
        int     nextPos = *start + ((struct NCToken*)_tokenTable)[current].textlen;
        
        if ( isspace(text[nextPos]) || (text[nextPos] == '\0') ) {
          *start = nextPos;
          return ((struct NCToken*)_tokenTable)[current].token;
        }
        low = current + 1;
      } else if ( comparison < 0 ) {
        low = current + 1;
      } else {
        high = current - 1;
      }
    }
    return kNCTokenInvalid;
  }

//

  - (char*) generateCompletionForText:(const char*)text
    newSession:(BOOL)newSession
    {
    const char*   cmdName = NULL;
    size_t        cmdLen = 0;
    
    if ( newSession ) {
      //  New command to complete:
      _cmdIndex = 0;
      _textLength = strlen(text);
    }
    
    //  Check all of them; they're sorted alphabetically so if we match a
    //  partial command it's efficient to stay at the match during a
    //  matching "session" and continue after it when necessary (skipping
    //  all the text that we already know doesn't match):
    while ( _cmdIndex < _tokenCount ) {
      cmdName = ((struct NCToken*)_tokenTable)[_cmdIndex].text;
      cmdLen = ((struct NCToken*)_tokenTable)[_cmdIndex++].textlen;
      if ( (_textLength <= cmdLen) && (strncmp(cmdName,text,_textLength) == 0) ) {
        char*   cmdCopy = malloc(cmdLen + 1);
        
        memcpy(cmdCopy,cmdName,cmdLen);
        cmdCopy[cmdLen] = '\0';
        return cmdCopy;
      }
    }
    return ((char*)NULL);
  }

@end
