/*
 *  ncutil3 - network configuration utility, version 3
 *  NCError
 *
 *  Error-handling for the package.
 *
 *  Created by Jeffrey Frey on Wed Jun 1 2005.
 *  Copyright (c) 2005. All rights reserved.
 *
 */

#include "NCError.h"
#include "CFAdditions.h"
#include "CFCString.h"

#include <time.h>
#include <unistd.h>

static Boolean NCErrorLoggingIsEnabled = TRUE;

extern FILE* stddbg;

//

Boolean
NCErrorLogging()
{
  return NCErrorLoggingIsEnabled;
}

//

void
NCErrorSetLogging(
  Boolean   enabled
)
{
  NCErrorLoggingIsEnabled = enabled;
}

//
#pragma mark -
//

typedef struct _NCError {
  int               errNo;
  CFStringRef       explanation;
  void*             context;
  struct _NCError*  upLink;
  struct _NCError*  dnLink;
} NCError;

static NCError* NCErrorStack = NULL;
static NCError* NCErrorStackTop = NULL;

#define NCErrorBaseStackSize 10
#define NCErrorStackSizeInc  10

//

void
NCErrorInitStack()
{
  size_t      bytes = NCErrorBaseStackSize * sizeof(NCError);
  void*       ptr = malloc(bytes);
  int         i = NCErrorBaseStackSize - 1;
  NCError*    lastNode = NULL;
  
  NCErrorStack = (NCError*)ptr;
  NCErrorStackTop = NCErrorStack;
  while (i--) {
    ptr += sizeof(NCError);
    NCErrorStack->upLink = (NCError*)ptr;
    NCErrorStack->dnLink = lastNode;
    
    lastNode = NCErrorStack;
    NCErrorStack = (NCError*)ptr;
  }
  //  We're at the last node, take care of it:
  NCErrorStack->upLink = NULL;
  NCErrorStack->dnLink = lastNode;
}

//

void
NCErrorGrowStack()
{
  size_t      bytes = NCErrorStackSizeInc * sizeof(NCError);
  void*       ptr = malloc(bytes);
  int         i = NCErrorStackSizeInc - 1;
  NCError*    lastNode = NCErrorStack;
  NCError*    curNode = (NCError*)ptr;
  
  NCErrorStack->upLink = curNode;
  NCErrorStackTop = curNode;
  while (i--) {
    ptr += sizeof(NCError);
    curNode->upLink = (NCError*)ptr;
    curNode->dnLink = lastNode;
    
    lastNode = curNode;
    curNode = (NCError*)ptr;
  }
  //  We're at the last node, take care of it:
  curNode->upLink = NULL;
  curNode->dnLink = lastNode;
  //  And now, it becomes the stack:
  NCErrorStack = curNode;
}

//

void
NCErrorPush(
  int         errNo,
  CFStringRef explanation,
  void*       context
)
{
  //  Check the pointer to the current top of the stack; if it's NULL then
  //  we should allocate an initial error stack.  Otherwise, see if the
  //  top node's upLink is NULL, in which case we need to grow the stack:
  if (NCErrorStackTop == NULL)
    NCErrorInitStack();
  else if (NCErrorStackTop->upLink == NULL)
    NCErrorGrowStack();
  
  //  Push the data into the top node of the stack:
  NCErrorStackTop->errNo = errNo;
  NCErrorStackTop->explanation = ( explanation ? CFStringCreateCopy(kCFAllocatorDefault,explanation) : NULL );
  NCErrorStackTop->context = context;
  NCErrorStackTop = NCErrorStackTop->upLink;
  
  //  If logging is enabled, we print the error message now:
  if (NCErrorLoggingIsEnabled)
    NCLog(CFSTR("%!bold;%!red;NCError(%d):%!reset; %@"),errNo,explanation);
}

//

Boolean
NCErrorPop(
  int*          errNo,
  CFStringRef*  explanation,
  void**        context
)
{
  if (NCErrorStackTop && NCErrorStackTop->dnLink != NULL) {
    NCErrorStackTop = NCErrorStackTop->dnLink;
    
    if (errNo) *errNo = NCErrorStackTop->errNo;
    if (explanation)
      *explanation = NCErrorStackTop->explanation;
    if (context)
      *context = NCErrorStackTop->context;
    else if (NCErrorStackTop->explanation)
      CFRelease(NCErrorStackTop->explanation);
    
    return TRUE;
  }
  return FALSE;
}

//

void
NCErrorClear()
{
  while (NCErrorPop(NULL,NULL,NULL));
}

//
#pragma mark
//

Boolean NCANSIOutputEnable = TRUE;

Boolean
NCANSIOutputIsEnabled()
{
  return NCANSIOutputEnable;
}

//

void
NCSetANSIOutputIsEnabled(
  Boolean   enabled
)
{
  NCANSIOutputEnable = enabled;
}

//

struct _formatTokenRec {
  CFStringRef   cftoken;
  const char*   ctoken;
  int           code;
};

#define _formatTokenCount 25
struct _formatTokenRec __formatTokenTable[_formatTokenCount] =
  {
    { NULL , "Black",          40 },
    { NULL , "Blue",           44 },
    { NULL , "Cyan",           46 },
    { NULL , "Green",          42 },
    { NULL , "Magenta",        45 },
    { NULL , "Red",            41 },
    { NULL , "Yellow",         43 },
    { NULL , "White",          47 },
    { NULL , "black",          30 },
    { NULL , "blink",           5 },
    { NULL , "blue",           34 },
    { NULL , "bold",            1 },
    { NULL , "cyan",           36 },
    { NULL , "green",          32 },
    { NULL , "invisible",       8 },
    { NULL , "italic",          3 },
    { NULL , "magenta",        35 },
    { NULL , "normal",          2 },
    { NULL , "rapidBlink",      6 },
    { NULL , "red",            31 },
    { NULL , "reset",           0 },
    { NULL , "reverse",         7 },
    { NULL , "underline",       4 },
    { NULL , "white",          37 },
    { NULL , "yellow",         33 }
  };

//

void
__NCReplaceFormatToken(
  CFMutableStringRef    string,
  CFIndex               start,
  CFIndex               end
)
{
  CFRange       cmpRange;
  int           code = -1;
  int           lo,hi,idx;
  UniChar       charToMatch = CFStringGetCharacterAtIndex(string,start + 2);
  Boolean       didLoEqualHiAlready = FALSE;
  
  //  From start+2 to end-1 is the format directive:
  cmpRange.location = start + 2;
  cmpRange.length = end - start - 2;
  
  //  We do a binary search for the token in the table:
  lo = 0;
  hi = _formatTokenCount;
  while ( (lo < hi) && (code == -1) ) {
    int         diff;
    
    idx = (hi + lo) / 2;
    diff = charToMatch - __formatTokenTable[idx].ctoken[0];
    
    //  Positive 'diff' means string is above this one;
    //  Negative 'diff' means string should be below it;
    //  Zero means we matched the first character, so we
    //  do a standard string compare to see if we got it.
    if (diff > 0)
      lo = idx;
    else if (diff < 0)
      hi = idx;
    else {
      CFComparisonResult    cmpResult;
      
      if (__formatTokenTable[idx].cftoken == NULL)
        __formatTokenTable[idx].cftoken = CFStringCreateWithCStringNoCopy(
                                                kCFAllocatorDefault,
                                                __formatTokenTable[idx].ctoken,
                                                CFCStringGetDefaultEncoding(),
                                                kCFAllocatorNull);
      cmpResult = CFStringCompareWithOptions(
                      string,
                      __formatTokenTable[idx].cftoken,
                      cmpRange,
                      0);
      switch (cmpResult) {
        case kCFCompareEqualTo:
          code = __formatTokenTable[idx].code;
          break;
        case kCFCompareLessThan:
          hi = idx;
          break;
        case kCFCompareGreaterThan:
          lo = idx;
          break;
      }
    }
    if (hi == lo) {
      if (didLoEqualHiAlready)
        break;
      else
        didLoEqualHiAlready = TRUE;
    }
  }
  
  //  Replace the full range:
  cmpRange = CFRangeMake(start,end - start + 1);
  
  if (code == -1 || !NCANSIOutputEnable) {
    //  Just remove the thing:
    CFStringDelete(string,cmpRange);
  } else {
    //  Create the ANSI sequence:
    CFStringRef     replacement;
    
    if (replacement = CFStringCreateWithFormat(kCFAllocatorDefault,NULL,CFSTR("\033[%dm"),code)) {
      CFStringReplace(string,cmpRange,replacement);
      CFRelease(replacement);
    } else
      CFStringDelete(string,cmpRange);
  }
}

//

CFStringRef
__NCParseExtendedFormatString(
  CFStringRef format
)
{
  CFMutableStringRef    newFormat = CFStringCreateMutableCopy(
                                        kCFAllocatorDefault,
                                        0,
                                        format);
  CFIndex               length = CFStringGetLength(newFormat);
  CFRange               searchRange = CFRangeMake(0,length);
  CFRange               foundRange;
  
  //  Scan through the mutable copy looking for '%!' sequences to
  //  parse-out:
  while (CFStringFindWithOptions(newFormat,CFSTR("%!"),searchRange,0,&foundRange)) {
    CFIndex     start = foundRange.location;
    CFIndex     end;
    
    if (CFStringFindWithOptions(newFormat,CFSTR(";"),CFRangeMake(start,length - start),0,&foundRange))
      end = foundRange.location;
    else
      end = length;
    __NCReplaceFormatToken(newFormat,start,end);
    length = CFStringGetLength(newFormat);
    if (end >= length)
      break;
    searchRange = CFRangeMake(start,length - start);
  }
  return newFormat;
}
  
//

void
__NCPrint(
  FILE*       stream,
  CFStringRef format,
  va_list     argv,
  Boolean     addNewline
)
{
  CFDataRef     externalRep;
  CFStringRef   string;
  CFRange       range = CFStringFind(format,CFSTR("%!"),0);
  
  //  Look for ANSI formatting directives:
  if (range.location != kCFNotFound) {
    format = __NCParseExtendedFormatString(format);
    string = CFStringCreateWithFormatAndArguments(
                kCFAllocatorDefault,
                NULL,
                format,
                argv);
    CFRelease(format);
  } else {
    string = CFStringCreateWithFormatAndArguments(
                kCFAllocatorDefault,
                NULL,
                format,
                argv);
  }
  
  if (string) {
    externalRep = CFStringCreateExternalRepresentation(
                  kCFAllocatorDefault,
                  string,
                  CFCStringGetDefaultEncoding(),
                  '?');
    CFRelease(string);
    if (externalRep) {
      if ( addNewline )
        fprintf(stream,"%.*s\n",
            (int)CFDataGetLength(externalRep),
            (char*)CFDataGetBytePtr(externalRep)
          );
      else
        fprintf(stream,"%.*s",
            (int)CFDataGetLength(externalRep),
            (char*)CFDataGetBytePtr(externalRep)
          );
      CFRelease(externalRep);
      fflush(stream);
    }
  }  
}

//

void
NCLog(
  CFStringRef	format,
  ...
)
{
  if (format && stddbg) {
    va_list       args;
    Boolean       savedState = NCANSIOutputEnable;
    char          buffer[27];
    time_t        theTime = time(NULL);
      
    //  Get argument list and call __NCPrint driver with a localized
    //  format and those arguments:
    strftime(buffer,26,"%c",localtime(&theTime));
    
    NCANSIOutputEnable = FALSE;
    fprintf(stddbg,"%s [%d]: ",buffer,getpid());
    
    va_start(args,format);
    __NCPrint(stddbg,format,args,TRUE);
    va_end(args);
    NCANSIOutputEnable = savedState;
  }
}

//

void
NCPrint(
  FILE*       stream,
  CFStringRef format,
  ...
)
{
  va_list		argv;
  
  va_start(argv,format);
  __NCPrint(stream,format,argv,FALSE);
  va_end(argv);
}
