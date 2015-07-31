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

#import "NCApplication.h"
#include "ncutil_vers.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <readline/readline.h>
#include <readline/history.h>

#import "NCTokenList.h"
  
NCAutoreleasePool*      NCApplicationAutoreleasePool = nil;

enum {
  kNCUtilCommand_Null                   = kNCTokenInvalid,
  
  kNCUtilCommand_Help                   = 0,
  kNCUtilCommand_Version,
  kNCUtilCommand_VersionNum,
  kNCUtilCommand_OSVariant,
  kNCUtilCommand_List,
  kNCUtilCommand_Read,
  kNCUtilCommand_ReadProperty,
  kNCUtilCommand_Summarize,
  kNCUtilCommand_SetCurrentDirectory,
  kNCUtilCommand_PrintCurrentDirectory,
  kNCUtilCommand_SetProperty,
  kNCUtilCommand_RemoveProperty,
  kNCUtilCommand_AppendValue,
  kNCUtilCommand_RemoveValue,
  
  kNCUtilCommand_CreateLocation,
  kNCUtilCommand_RemoveLocation,
  
  kNCUtilCommand_CreateService,
  kNCUtilCommand_RemoveService,
  
  kNCUtilCommand_PushInterface,
  kNCUtilCommand_PopInterface,
  
  kNCUtilCommand_Enable,
  kNCUtilCommand_Disable,
  kNCUtilCommand_Commit,
  kNCUtilCommand_Refresh,
  kNCUtilCommand_ApplyChanges,
  
  kNCUtilCommand_SetOptions,
  
  kNCUtilCommand_Quit,
  
  //
  // Options have a different enumeration offset which we
  // use to distinguish them easily:
  //
  kNCUtilCommand_OptionsBase        = 0x70000000,
  //
  kNCUtilCommand_ApplyAtExit        = 0x70000000,
  kNCUtilCommand_STDIN,
  kNCUtilCommand_PrefFile,
  kNCUtilCommand_Debug,
  kNCUtilCommand_HexPasswords,
  kNCUtilCommand_TextPasswords,
  kNCUtilCommand_DieOnSyntaxErrors,
  kNCUtilCommand_DisableANSIText,
  kNCUtilCommand_PathSeparator,
  kNCUtilCommand_RecursiveListing
};

//
// Command string-to-token mapping:
//
NCTokenList*      __NCApplicationCommandMapper = nil;

const char*       __NCApplicationCommands[] = {
                                                  "addval",
                                                  "apply-changes",
                                                  "cd",
                                                  "chdir",
                                                  "commit",
                                                  "createloc",
                                                  "create-location",
                                                  "create-service",
                                                  "destroyprop",
                                                  "destroyloc",
                                                  "destroyval",
                                                  "destroy-location",
                                                  "destroy-service",
                                                  "disable",
                                                  "enable",
                                                  "exit",
                                                  "help",
                                                  "list",
                                                  "ls",
                                                  "os-variant",
                                                  "pop-interface",
                                                  "propsummary",
                                                  "push-interface",
                                                  "pwd",
                                                  "quit",
                                                  "read",
                                                  "readprop",
                                                  "refresh",
                                                  "setopt",
                                                  "setprop",
                                                  "set-options",
                                                  "version",
                                                  "version-num",
                                                  "-D",
                                                  "-H",
                                                  "-P",
                                                  "-R",
                                                  "-p",
                                                  "--apply-on-exit",
                                                  "--debug",
                                                  "--die-on-syntax-errors",
                                                  "--disable-ANSI-text",
                                                  "--hex-passwords",
                                                  "--path-separator",
                                                  "--prefpath",
                                                  "--recursive-listing",
                                                  "--stdin",
                                                  "--text-passwords",
                                                  NULL
                                              };
const int         __NCApplicationTokens[] =   {
                                                  kNCUtilCommand_AppendValue,
                                                  kNCUtilCommand_ApplyChanges,
                                                  kNCUtilCommand_SetCurrentDirectory,
                                                  kNCUtilCommand_SetCurrentDirectory,
                                                  kNCUtilCommand_Commit,
                                                  kNCUtilCommand_CreateLocation,
                                                  kNCUtilCommand_CreateLocation,
                                                  kNCUtilCommand_CreateService,
                                                  kNCUtilCommand_RemoveProperty,
                                                  kNCUtilCommand_RemoveLocation,
                                                  kNCUtilCommand_RemoveValue,
                                                  kNCUtilCommand_RemoveLocation,
                                                  kNCUtilCommand_RemoveService,
                                                  kNCUtilCommand_Disable,
                                                  kNCUtilCommand_Enable,
                                                  kNCUtilCommand_Quit,
                                                  kNCUtilCommand_Help,
                                                  kNCUtilCommand_List,
                                                  kNCUtilCommand_List,
                                                  kNCUtilCommand_OSVariant,
                                                  kNCUtilCommand_PopInterface,
                                                  kNCUtilCommand_Summarize,
                                                  kNCUtilCommand_PushInterface,
                                                  kNCUtilCommand_PrintCurrentDirectory,
                                                  kNCUtilCommand_Quit,
                                                  kNCUtilCommand_Read,
                                                  kNCUtilCommand_ReadProperty,
                                                  kNCUtilCommand_Refresh,
                                                  kNCUtilCommand_SetOptions,
                                                  kNCUtilCommand_SetProperty,
                                                  kNCUtilCommand_SetOptions,
                                                  kNCUtilCommand_Version,
                                                  kNCUtilCommand_VersionNum,
                                                  kNCUtilCommand_Debug,
                                                  kNCUtilCommand_HexPasswords,
                                                  kNCUtilCommand_PathSeparator,
                                                  kNCUtilCommand_RecursiveListing,
                                                  kNCUtilCommand_PrefFile,
                                                  kNCUtilCommand_ApplyAtExit,
                                                  kNCUtilCommand_Debug,
                                                  kNCUtilCommand_DieOnSyntaxErrors,
                                                  kNCUtilCommand_DisableANSIText,
                                                  kNCUtilCommand_HexPasswords,
                                                  kNCUtilCommand_PathSeparator,
                                                  kNCUtilCommand_PrefFile,
                                                  kNCUtilCommand_RecursiveListing,
                                                  kNCUtilCommand_STDIN,
                                                  kNCUtilCommand_DisableANSIText,
                                                  -1
                                              };

//
// readline/history stuff:
//

const char*     NCApplicationReadlineName = "ncutil";
const char*     NCApplicationHistoryFile = ".ncutil_history";
char*           NCApplicationHistoryPath = NULL;

#ifndef NCUTIL_MAX_HISTORY
#define NCUTIL_MAX_HISTORY 64
#endif

#define rl_completion_matches completion_matches

char** __NCApplication_ReadlineCompleter(const char*,int,int);
char* __NCApplication_ReadlineCmdGenerator(const char*,int);
char* __NCApplication_ReadlinePathGenerator(const char*,int);

//

void
__NCApplicationReadlineAndHistoryStart()
{
  char*           userHome = getenv("HOME");

  rl_readline_name = (char*)NCApplicationReadlineName;
  rl_attempted_completion_function = __NCApplication_ReadlineCompleter;
  
  using_history();
  stifle_history(NCUTIL_MAX_HISTORY);
  
  if ( userHome ) {
    size_t      len = strlen(userHome) + strlen(NCApplicationHistoryFile) + 2;
    
    if ( (NCApplicationHistoryPath = malloc(len)) ) {
      snprintf(NCApplicationHistoryPath,len,"%s/%s",userHome,NCApplicationHistoryFile);
      read_history(NCApplicationHistoryPath);
    }
  }
}

//

void
__NCApplicationReadlineAndHistoryEnd()
{
  if ( NCApplicationHistoryPath ) {
    write_history(NCApplicationHistoryPath);
    free(NCApplicationHistoryPath);
  }
}

//

char**
__NCApplication_ReadlineCompleter(
  const char*   text,
  int           start,
  int           end
)
{
  if ( start == 0 )
    return rl_completion_matches(text,__NCApplication_ReadlineCmdGenerator);
  return rl_completion_matches(text,__NCApplication_ReadlinePathGenerator);
}

//

char*
__NCApplication_ReadlineCmdGenerator(
  const char*   text,
  int           state
)
{
  return [__NCApplicationCommandMapper generateCompletionForText:text newSession:( state ? NO : YES )];
}

//

char*
__NCApplication_ReadlinePathGenerator(
  const char*   text,
  int           state
)
{
  return ((char*)NULL);
}

//
#pragma mark -
//

const char* NCApplicationPrefPathEnv = "ncutil_prefpath";

@interface NCApplication(NCPrivateApplication)

+ (void) displayVersion;
+ (void) displayVersionNum;
+ (void) displayOSVariant;
+ (void) displayHelp;
+ (SInt32) commandIDForCString:(const char*)cString;

- (void) setLastDirectory:(NCDirectoryNode*)lastDir;
- (NCDirectoryNode*) getDirectoryAtPath:(const char*)path;

- (int) processCommandOptionsFromArguments:(const char**)argv count:(int)argc startingAtIndex:(int)argn;
- (int) processCommandFromArguments:(const char**)argv count:(int)argc startingAtIndex:(int)argn;
- (void) processCommandFromSTDIN;

@end

@implementation NCApplication(NCPrivateApplication)

  + (void) displayVersion
  {
    NCPrint(stdout,CFSTR("%!bold;ncutil%!reset; - %!underline;n%!reset;etwork %!underline;c%!reset;onfiguration %!underline;util%!reset;ity\n"));
    printf("Version %s\n",NCUtilVersionString());
  }
  
//

  + (void) displayVersionNum
  {
    printf("%hu.%hu.%hu%c\n",NCUtilVersion_Major,NCUtilVersion_Minor,NCUtilVersion_Build,NCUtilVersion_Stage);
  }
  
//

  + (void) displayOSVariant
  {
    printf("%s\n",NCUtilOSVariant);
  }
  
//

  + (void) displayHelp
  {
    printf("usage [%s]\n",NCUtilVersionString());
    
    printf("        ncutil [opts] help\n");
    printf("        ncutil [opts] version\n");
    printf("        ncutil [opts] version-num\n");
    printf("        ncutil [opts] enable {directory}\n");
    printf("        ncutil [opts] disable {directory}\n");
    printf("        ncutil [opts] create-location <location-name>\n");
    printf("        ncutil [opts] destroy-location {location-directory}\n");
    printf("        ncutil [opts] create-service <location-directory> <interface-template> <service-name>\n");
    printf("        ncutil [opts] destroy-service {service-directory}\n");
    printf("        ncutil [opts] push-interface <service-directory> <interface-type>\n");
    printf("        ncutil [opts] list {directory}\n");
    printf("        ncutil [opts] propsummary {directory}\n");
    printf("        ncutil [opts] read {directory}\n");
    printf("        ncutil [opts] readprop <directory> <property-name> {..}\n");
    printf("        ncutil [opts] setprop <directory> <property-name> {..}\n");
    printf("        ncutil [opts] destroyprop <directory> <property-name> {..}\n");
    printf("        ncutil [opts] addval <directory> <property-name> {..}\n");
    printf("        ncutil [opts] destroyval <directory> <property-name> {..}\n");
    printf("command-line mode only:\n");
    printf("        chdir [opts] {directory}\n");
    printf("        pwd [opts]\n");
    printf("        commit [opts] {directory}\n");
    printf("        refresh [opts] {directory}\n");
    printf("        apply-changes [opts]\n");
    printf("        set-options [opts]\n");
    printf("options:\n");
    printf("        --recursive-listing (-R)\n");
    printf("        --apply-on-exit\n");
    printf("        --prefpath <path> (-p <path>)\n");
    printf("        --stdin\n");
    printf("        --debug (-D)\n");
    printf("        --hex-passwords (-H) / --text-passwords\n");
    printf("        --die-on-syntax-errors\n");
    printf("        --disable-ANSI-text\n");
    printf("        --path-separator <string> (-P <string>)\n");
  }
  
//

  + (SInt32) commandIDForCString:(const char*)cString
  {
    int     start = 0;
    
    return [__NCApplicationCommandMapper tokenForText:cString start:&start length:(int)strlen(cString)];
  }

//

  - (void) setLastDirectory:(NCDirectoryNode*)lastDir
  {
    if (lastDir) lastDir = [lastDir retain];
    if (_lastDirectory) [_lastDirectory release];
    _lastDirectory = lastDir;
  }
  
//

  - (NCDirectoryNode*) getDirectoryAtPath:(const char*)path
  {
    NCRootDirectory*      root = [_preferenceSession directoryTree];
    NCDirectoryNode*      target = nil;
    CFIndex               dirID;
    
    if (path[0] == '!') {
      //  Last-used directory:
      target = _lastDirectory;
    } else if (path[0] == '.' && path[1] == '\0') {
      //  Current directory:
      target = _currentDirectory;
    } else if (sscanf(path,"%ld",&dirID) == 1) {
      
      if (!(target = [root searchForNodeWithDirectoryID:dirID])) {
        NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    directory ID %ld is invalid\n"),dirID);
        NCErrorPush(kNCErrorInvalidDirectoryID,NULL,NULL);
      }
    } else {
      CFStringRef     cfPath = CFStringCreateWithCStringNoCopy(
                                  kCFAllocatorDefault,
                                  path,
                                  CFCStringGetDefaultEncoding(),
                                  kCFAllocatorNull
                                );
      if (cfPath) {
        if (!(target = [_currentDirectory searchForNodeWithPath:cfPath])) {
          NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    no such directory: %s\n"),path);
          NCErrorPush(kNCErrorInvalidDirectoryPath,NULL,NULL);
        }
        CFRelease(cfPath);
      }
    }
    return target;
  }
  
//

  - (int) processCommandOptionsFromArguments:(const char**)argv
    count:(int)argc
    startingAtIndex:(int)argn
  {
    const char*			prefFileArgument = NULL;
    const char*     sepStrArgument = NULL;
    
    //  Scan all options that were passed on the command line:
    while (argn < argc) {
      if ((argv[argn])[0] == '-') {
        UInt32		cmdID = [NCApplication commandIDForCString:argv[argn]];
        
        if ( cmdID > kNCUtilCommand_OptionsBase ) {
          switch (cmdID) {
          
            case kNCUtilCommand_RecursiveListing: {
              _options._recursiveList = YES;
              break;
            }
          
            case kNCUtilCommand_ApplyAtExit: {
              _options._activateAtExit = YES;
              break;
            }
              
            case kNCUtilCommand_STDIN: {
              if (!_options._initialParamScanDone)
                _options._runAsShell = YES;
              break;
            }
            
            case kNCUtilCommand_Debug:
              break;
            
            case kNCUtilCommand_PrefFile: {
              argn++;
              if (!_options._initialParamScanDone) {
                if (argn < argc)
                  prefFileArgument = argv[argn];
                else
                  NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    A preference path must be specified following the flag.\n"));
              }
              break;
            }
            
            case kNCUtilCommand_HexPasswords: {
              NCPropertySetUsesTextualPasswords(FALSE);
              break;
            }
            
            case kNCUtilCommand_TextPasswords: {
              NCPropertySetUsesTextualPasswords(TRUE);
              break;
            }
            
            case kNCUtilCommand_DieOnSyntaxErrors: {
              _options._dieOnSyntaxErrors = YES;
              break;
            }
            
            case kNCUtilCommand_DisableANSIText: {
              NCSetANSIOutputIsEnabled(FALSE);
              break;
            }
            
            case kNCUtilCommand_PathSeparator: {
              argn++;
              if (argn < argc)
                sepStrArgument = argv[argn];
              else
                NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    A path separator string must be specified following the flag.\n"));
              break;
            }
            
            default: {
              NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    Unrecognized option '%s'\n"),argv[argn]);
              break;
            }
          }
        }
        argn++;
      } else
        break;
    }
    if (!_options._initialParamScanDone) {
      //
      //  If all that was on the command line were options, then
      //  we're gonna read lines of command-line-like commands
      //  from STDIN:
      //
      if (argn == argc)
        _options._runAsShell = YES;
        
      //
      // At this point, if no pref file was specified, we'll check to
      // see if the user has an evironment variable set:
      //
      if (prefFileArgument == NULL) {
        NCLog(CFSTR(":: Checking environment for a preference path"));
        prefFileArgument = getenv(NCApplicationPrefPathEnv);
      }
      NCLog(CFSTR(":: Allocating directory tree for preference store"));
      if (prefFileArgument) {
        CFStringRef     prefFilePath = CFStringCreateWithCStringNoCopy(
                                          kCFAllocatorDefault,
                                          prefFileArgument,
                                          CFCStringGetDefaultEncoding(),
                                          kCFAllocatorNull
                                        );
        if (prefFilePath) {
          _preferenceSession = [[NCPreferenceSession alloc] initWithPreferencesAtPath:prefFilePath];
          CFRelease(prefFilePath);
        }
        if (!_preferenceSession) {
          NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    Could not use preference store: %s\n"),prefFileArgument);
          NCErrorPush(kNCErrorCouldNotRun,NULL,NULL);
        }
      } else
        _preferenceSession = [[NCPreferenceSession alloc] init];
      
      //  [2008-01-26]
      //
      //  Because of autorelease, the retain counts in the directory tree will be TOTALLY screwy right now; this
      //  was the cause of manifold errors when running ncutil with a command on the CLI.  Anything that attempted
      //  to modify the tree from the CLI would segfault because of this.
      //
      NCApplicationAutoreleasePool = [NCApplicationAutoreleasePool drainButRetain];
      
      //
      // Change the separator string:
      //
      if (sepStrArgument) {
        CFStringRef     sepStr = CFStringCreateWithCString(
                                    kCFAllocatorDefault,
                                    sepStrArgument,
                                    CFCStringGetDefaultEncoding()
                                  );
        if (sepStr) {
          [_preferenceSession setPathSeparatorForDirectoryTree:sepStr];
          CFRelease(sepStr);
        }
      }
      
      /*
      if (errorCondition == kNCUtilFoundation_NewPrefsWarning) {
        errorCondition = kNCErrorNoError;
        [preferenceTree commitChanges];
      }
      */
      _options._initialParamScanDone = YES;
    }
    return argn;
  }

//

  - (int) processCommandFromArguments:(const char**)argv
    count:(int)argc
    startingAtIndex:(int)argn
  {
    SInt32                commandID;
    int                   commandIndex,directoryIndex = -1;
    NCDirectoryNode*      target = _currentDirectory;
    
    if (argn >= argc) {
      NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    Insufficient number of arguments.\n"));
      NCErrorPush(kNCErrorTooFewParameters,NULL,NULL);
    }
    
    //  Get a command number for the command argument:
    commandID = [NCApplication commandIDForCString:argv[commandIndex = argn++]];
    
    //  Check for any options that fall after the command itself:
    if (argn < argc)
      argn = [self processCommandOptionsFromArguments:argv count:argc startingAtIndex:argn];
      
    //  Tricky stuff; for some commands we really don't NEED or WANT to look
    //  for a directory as the first argument.
    switch (commandID) {
      case kNCUtilCommand_Help:
      case kNCUtilCommand_Version:
      case kNCUtilCommand_VersionNum:
      case kNCUtilCommand_OSVariant:
      case kNCUtilCommand_PrintCurrentDirectory:
      case kNCUtilCommand_CreateLocation:
      case kNCUtilCommand_ApplyChanges:
      case kNCUtilCommand_Quit:
        target = nil;
        break;
      
      default: {
        if (argn < argc) {
          directoryIndex = argn;
          if (!(target = [self getDirectoryAtPath:argv[argn]]))
            return argn;
          argn++;
        }
        break;
      }
    }
    
    //  Act upon thy command!!
    switch (commandID) {
//
//  HELP:
//
#pragma mark HELP
      case kNCUtilCommand_Help: {
        [NCApplication displayHelp];
        break;
      }
//
//  VERSION:
//
#pragma mark VERSION
      case kNCUtilCommand_Version: {
        [NCApplication displayVersion];
        break;
      }
//
//  VERSION-NUM:
//
#pragma mark VERSION-NUM
      case kNCUtilCommand_VersionNum: {
        [NCApplication displayVersionNum];
        break;
      }
//
//  OS-VARIANT:
//
#pragma mark OS-VARIANT
      case kNCUtilCommand_OSVariant: {
        [NCApplication displayOSVariant];
        break;
      }
//
//  LIST:
//
#pragma mark LIST
      case kNCUtilCommand_List: {
        if (target)
          [target listSubdirectoriesToStream:stdout recursive:_options._recursiveList];
        break;
      }
//
//  READ:
//
#pragma mark READ
      case kNCUtilCommand_Read: {
        if (target)
          [target listPropertiesToStream:stdout];
        break;
      }
//
//  READPROP:
//
#pragma mark READPROP
      case kNCUtilCommand_ReadProperty: {
        if (target) {
          while (argn < argc) {
            CFStringRef   propertyName = CFStringCreateWithCStringNoCopy(
                                            kCFAllocatorDefault,
                                            argv[argn++],
                                            CFCStringGetDefaultEncoding(),
                                            kCFAllocatorNull
                                          );
            [target listProperty:propertyName toStream:stdout];
            CFRelease(propertyName);
          }
        }
        break;
      }
//
//  PROPSUMMARY:
//
#pragma mark PROPSUMMARY
      case kNCUtilCommand_Summarize: {
        if (target)
          [target summarizePropertiesToStream:stdout];
        break;
      }
//
//  CHDIR:
//
#pragma mark CHDIR
      case kNCUtilCommand_SetCurrentDirectory: {
        if (directoryIndex == -1)
          [self setCurrentDirectory:nil];
        else
          [self setCurrentDirectory:target];
        target = _currentDirectory;
        break;
      }
//
//  PWD:
//
#pragma mark PWD
      case kNCUtilCommand_PrintCurrentDirectory: {
        CFStringRef     curPath = [_currentDirectory pathToNode];
        
        if (curPath) {
          NCPrint(stdout,curPath);fputc('\n',stdout);
          CFRelease(curPath);
        }
        break;
      }
//
//  SETPROP:
//
#pragma mark SETPROP
      case kNCUtilCommand_SetProperty: {
        if (target) {
          //  We need at least two more arguments:
          if (argn + 2 <= argc) {
            CFStringRef       propUIName = CFStringCreateWithCStringNoCopy(
                                              kCFAllocatorDefault,
                                              argv[argn],
                                              CFCStringGetDefaultEncoding(),
                                              kCFAllocatorNull
                                            );
            NCPropertyRef     theProperty = [[target propertyHandler] propertyWithUIName:propUIName];
            
            if (theProperty) {
              if (NCPropertyGetLockStatus(theProperty)) {
                NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    property '%s' is locked\n"),argv[argn]);
                NCErrorPush(kNCErrorLockedProperty,NULL,NULL);
              } else {
                CFIndex             argi = argn + 1;
                CFPropertyListRef   newValue = NCPropertyParseArguments(
                                                  theProperty,
                                                  (char**)argv,
                                                  &argi,
                                                  argc
                                                );
                if (newValue) {
                  [target setValue:newValue ofProperty:NCPropertyGetSCName(theProperty)];
                } else {
                  NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    could not assign that value to '%s'\n"),argv[argn]);
                  NCErrorPush(kNCErrorParameterError,NULL,NULL);
                }
              }
            } else {
              NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    unknown property: %s\n"),argv[argn]);
              NCErrorPush(kNCErrorUnknownProperty,NULL,NULL);
            }
            CFRelease(propUIName);
          } else {
            NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    too few arguments to setprop\n"));
            NCErrorPush(kNCErrorTooFewParameters,NULL,NULL);
          }
        }
        break;
      }
//
//  DESTROYPROP:
//
#pragma mark DESTROYPROP
      case kNCUtilCommand_RemoveProperty: {
        if (target) {
          //  We need at least one more arguments:
          if (argn >= argc) {
            NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    too few arguments to destroyprop\n"));
            NCErrorPush(kNCErrorTooFewParameters,NULL,NULL);
          } else {
            while (argn < argc) {
              CFStringRef       propUIName = CFStringCreateWithCStringNoCopy(
                                                kCFAllocatorDefault,
                                                argv[argn],
                                                CFCStringGetDefaultEncoding(),
                                                kCFAllocatorNull
                                              );
              NCPropertyRef     theProperty = [[target propertyHandler] propertyWithUIName:propUIName];
              
              if (theProperty) {
                if (NCPropertyGetLockStatus(theProperty)) {
                  NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    property '%s' is locked\n"),argv[argn]);
                  NCErrorPush(kNCErrorLockedProperty,NULL,NULL);
                } else {
                  [target removeProperty:NCPropertyGetSCName(theProperty)];
                }
              } else {
                NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    unknown property: %s\n"),argv[argn]);
                NCErrorPush(kNCErrorUnknownProperty,NULL,NULL);
              }
              CFRelease(propUIName);
              argn++;
            }
          }
        }
        break;
      }
//
//  ADDVAL:
//
#pragma mark ADDVAL
      case kNCUtilCommand_AppendValue: {
        if (target) {
          //  We need at least two more arguments:
          if (argn + 2 <= argc) {
            CFStringRef       propUIName = CFStringCreateWithCStringNoCopy(
                                              kCFAllocatorDefault,
                                              argv[argn],
                                              CFCStringGetDefaultEncoding(),
                                              kCFAllocatorNull
                                            );
            NCPropertyRef     theProperty = [[target propertyHandler] propertyWithUIName:propUIName];
            
            if (theProperty) {
              if (NCPropertyGetLockStatus(theProperty)) {
                NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    property '%s' is locked\n"),argv[argn]);
                NCErrorPush(kNCErrorLockedProperty,NULL,NULL);
              } else if (NCPropertyIsArrayType(theProperty)) {
                CFIndex             argi = argn + 1;
                CFPropertyListRef   newValue = NCPropertyParseArguments(
                                                  theProperty,
                                                  (char**)argv,
                                                  &argi,
                                                  argc
                                                );
                if (newValue) {
                  [target appendValue:newValue toProperty:NCPropertyGetSCName(theProperty)];
                } else {
                  NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    could not add those values to '%s'\n"),argv[argn]);
                  NCErrorPush(kNCErrorParameterError,NULL,NULL);
                }
              }
            } else {
              NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    unknown property: %s\n"),argv[argn]);
              NCErrorPush(kNCErrorUnknownProperty,NULL,NULL);
            }
            CFRelease(propUIName);
          } else {
            NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    too few arguments to addval\n"));
            NCErrorPush(kNCErrorTooFewParameters,NULL,NULL);
          }
        }
        break;
      }
//
//  DESTROYVAL:
//
#pragma mark DESTROYVAL
      case kNCUtilCommand_RemoveValue: {
        if (target) {
          //  We need at least two more arguments:
          if (argn + 2 <= argc) {
            CFStringRef       propUIName = CFStringCreateWithCStringNoCopy(
                                              kCFAllocatorDefault,
                                              argv[argn],
                                              CFCStringGetDefaultEncoding(),
                                              kCFAllocatorNull
                                            );
            NCPropertyRef     theProperty = [[target propertyHandler] propertyWithUIName:propUIName];
            
            if (theProperty) {
              if (NCPropertyGetLockStatus(theProperty)) {
                NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    property '%s' is locked\n"),argv[argn]);
                NCErrorPush(kNCErrorLockedProperty,NULL,NULL);
              } else if (NCPropertyIsArrayType(theProperty)) {
                CFIndex             argi = argn + 1;
                CFPropertyListRef   newValue = NCPropertyParseArguments(
                                                  theProperty,
                                                  (char**)argv,
                                                  &argi,
                                                  argc
                                                );
                if (newValue) {
                  [target removeValue:newValue fromProperty:NCPropertyGetSCName(theProperty)];
                } else {
                  NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    could not add those values to '%s'\n"),argv[argn]);
                  NCErrorPush(kNCErrorParameterError,NULL,NULL);
                }
              }
            } else {
              NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    unknown property: %s\n"),argv[argn]);
              NCErrorPush(kNCErrorUnknownProperty,NULL,NULL);
            }
            CFRelease(propUIName);
          } else {
            NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    too few arguments to addval\n"));
            NCErrorPush(kNCErrorTooFewParameters,NULL,NULL);
          }
        }
        break;
      }
//
//  CREATE-LOCATION:
//
#pragma mark CREATE-LOCATION
      case kNCUtilCommand_CreateLocation: {
        if (argn < argc) {
          CFStringRef     newLocName = CFStringCreateWithCString(
                                          kCFAllocatorDefault,
                                          argv[argn++],
                                          CFCStringGetDefaultEncoding()
                                        );
          if (newLocName) {
            [[_preferenceSession directoryTree] addLocationWithName:newLocName];
            CFRelease(newLocName);
          }
        } else {
          NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    too few arguments to createloc\n"));
          NCErrorPush(kNCErrorTooFewParameters,NULL,NULL);
        }
        break;
      }
//
//  DESTROY-LOCATION:
//
#pragma mark DESTROY-LOCATION
      case kNCUtilCommand_RemoveLocation: {
        if (target && [target isKindOfClass:[NCLocationDirectory class]]) {
          //  Make sure we're not being asked to remove the selected one!
          if (target == [[_preferenceSession directoryTree] currentLocation]) {
            NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    cannot remove the active location\n"));
            NCErrorPush(kNCErrorInvalidOperation,NULL,NULL);
          } else {
            //  Is the last directory somewhere along the chain?
            if (_lastDirectory && (_lastDirectory == target || [_lastDirectory descendsFromNode:target]))
              [self setLastDirectory:nil];
            //  Is the current directory somewhere along the chain?
            if (_currentDirectory == target || [_currentDirectory descendsFromNode:target])
              [self setCurrentDirectory:nil];
            
            //  Remove it!
            [(NCLocationDirectory*)target removeLocation];
            target = nil;
          }
        } else {
          NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    directory is not a location\n"));
          NCErrorPush(kNCErrorNoSuchLocation,NULL,NULL);
        }
        break;
      }
//
//  CREATE-SERVICE:
//
#pragma mark CREATE-SERVICE
      case kNCUtilCommand_CreateService: {
        //  We require two additional arguments:
        //  * Service template directory
        //  * Name for service
        if (argn + 2 <= argc) {
          if ([target isKindOfClass:[NCLocationDirectory class]]) {
            NCDirectoryNode*  serviceTemplate = [self getDirectoryAtPath:argv[argn++]];
            
            if (serviceTemplate) {
              //  Make sure it's a service template:
              if ([serviceTemplate isKindOfClass:[NCInterfaceNode class]] && [(NCInterfaceNode*)serviceTemplate isInterfaceTemplate]) {
                CFStringRef     newServiceName = CFStringCreateWithCString(
                                                    kCFAllocatorDefault,
                                                    argv[argn++],
                                                    CFCStringGetDefaultEncoding()
                                                  );
                if (newServiceName) {
                  [(NCLocationDirectory*)target addServiceWithName:newServiceName andInterface:(NCInterfaceNode*)serviceTemplate];
                  CFRelease(newServiceName);
                }
              } else {
                NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    '%s' is not an interface template\n"),argv[argn - 1]);
                NCErrorPush(kNCErrorInvalidDirectory,NULL,NULL);
              }
            }
          } else {
            NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    the current directory is not a location\n"));
            NCErrorPush(kNCErrorInvalidDirectory,NULL,NULL);
          }
        } else {
          NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    too few arguments to createservice\n"));
          NCErrorPush(kNCErrorTooFewParameters,NULL,NULL);
        }
        break;
      }
//
//  DESTROY-SERVICE:
//
#pragma mark DESTROY-SERVICE
      case kNCUtilCommand_RemoveService: {
        if (target && [target isKindOfClass:[NCServiceDirectory class]]) {
          //  Is the last directory somewhere along the chain?
          if (_lastDirectory && (_lastDirectory == target || [_lastDirectory descendsFromNode:target]))
            [self setLastDirectory:nil];
          //  Is the current directory somewhere along the chain?
          if (_currentDirectory == target || [_currentDirectory descendsFromNode:target])
            [self setCurrentDirectory:nil];
          
          //  Remove it!
          [(NCServiceDirectory*)target removeService];
          target = nil;
        } else {
          NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    directory is not a service\n"));
          NCErrorPush(kNCErrorNoSuchLocation,NULL,NULL);
        }
        break;
      }
//
//  PUSH-INTERFACE:
//
#pragma mark PUSH-INTERFACE
      case kNCUtilCommand_PushInterface: {
        //  We require one additional argument:
        //  * Interface type
        if (argn < argc) {
          if ([target isKindOfClass:[NCServiceDirectory class]]) {
            CFStringRef       interfaceType = CFStringCreateWithCString(
                                                  kCFAllocatorDefault,
                                                  argv[argn++],
                                                  CFCStringGetDefaultEncoding()
                                                );
            if (interfaceType) {
              if (![(NCServiceDirectory*)target pushInterfaceLayerOfType:interfaceType]) {
                NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    unable to add interface layer\n"));
                NCErrorPush(kNCErrorInvalidOperation,NULL,NULL);
              }
              CFRelease(interfaceType);
            }
          } else {
            NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    the current directory is not a service\n"));
            NCErrorPush(kNCErrorInvalidDirectory,NULL,NULL);
          }
        } else {
          NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    too few arguments to push-interface\n"));
          NCErrorPush(kNCErrorTooFewParameters,NULL,NULL);
        }
        break;
      }
//
//  ENABLE:
//
#pragma mark ENABLE
      case kNCUtilCommand_Enable: {
        if (target)
          [target setDirectoryIsActive:YES];
        break;
      }
//
//  DISABLE:
//
#pragma mark DISABLE
      case kNCUtilCommand_Disable: {
        if (target)
          [target setDirectoryIsActive:NO];
        break;
      }
//
//  COMMIT:
//
#pragma mark COMMIT
      case kNCUtilCommand_Commit: {
        if (target && [target wasModified] ) {
          [target commitUpdates];
          if (![_preferenceSession commitChanges]) {
            NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    could not commit the modifications\n"));
          }
        }
        break;
      }
//
//  REFRESH:
//
#pragma mark REFRESH
      case kNCUtilCommand_Refresh: {
        if (target)
          [target refresh];
        break;
      }
//
//  APPLY-CHANGES:
//
#pragma mark APPLY-CHANGES
      case kNCUtilCommand_ApplyChanges: {
        if ([[_preferenceSession directoryTree] treeHasBeenModified] || _options._treeWasModified) {
          NCErrorClear();
          if (![_preferenceSession applyChanges])
            NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    could not apply the modifications\n"));
        }
        break;
      }
//
//  SET-OPTIONS:
//
#pragma mark SET-OPTIONS
      case kNCUtilCommand_SetOptions: {
        //  We'll already have processed everything we need!
        break;
      }
//
//  QUIT:
//
#pragma mark QUIT
      case kNCUtilCommand_Quit: {
        _options._completedRunLoop = YES;
        break;
      }
//
//  Unknown command:
//
#pragma mark UNKNOWN
      default: {
        NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    '%s' is not a valid command\n"),argv[commandIndex]);
        NCErrorPush(kNCErrorUnknownCommand,NULL,NULL);
        break;
      }
    }
    if (target)
      [self setLastDirectory:target];
    //  Reset the recursive listing flag:
    _options._recursiveList = NO;
    return argn;
  }
  
//

  - (void) processCommandFromSTDIN
  {
    //  Read a line from STDIN via the readline library -- and all its cool stuff
    //  like text completion.
    //
    //  First, let's get a prompt to use:
    static CFStringRef    defaultPrompt = CFSTR("[]$ ");
    char*                 cStringPrompt = NULL;
    
    if (_options._needsPrompt) {
      CFStringRef         prompt = NULL;
      
      if (_currentDirectory) {
        prompt = CFStringCreateWithFormat(
                        kCFAllocatorDefault,
                        NULL,
                        CFSTR("[%ld %@]$ "),
                        [_currentDirectory directoryID],
                        [_currentDirectory directoryName]
                    );
      } else {
        prompt = CFRetain(defaultPrompt);
      }
      
      size_t            charCount = CFStringGetLength(prompt);
      
      if ( charCount && (cStringPrompt = malloc(2 * charCount + 1)) ) {
        CFStringGetCString(prompt,cStringPrompt,2 * charCount + 1,CFCStringGetDefaultEncoding());
      }
      
      CFRelease(prompt);
    }
    
    do {
      char*     fullLine = NULL;
      char*     aLine = readline( (cStringPrompt ? cStringPrompt : "") );
      size_t    fullLineLen = 0,aLineLen;
      
      while ( aLine && (aLineLen = strlen(aLine)) ) {
        // User trying to do line continuation?
        size_t  i = aLineLen;
        
        while ( i-- > 0 ) {
          if ( aLine[i] == '\\' )
            break;
          else if ( ! isspace(aLine[i]) )
            break;
        }
        
        //  Not a continuation?
        if ( aLine[i] != '\\' ) {
          if ( fullLineLen ) {
            size_t    resizedLineLen = fullLineLen + aLineLen + 1;
            char*     resizedLine = (char*)realloc(fullLine,resizedLineLen);
            
            if ( resizedLine ) {
              fullLine = resizedLine;
              strncat(fullLine,aLine,aLineLen);
              fullLineLen = resizedLineLen;
              free(aLine);
            }
          } else {
            fullLineLen = aLineLen;
            fullLine = aLine;
          }
          break;
        }
        
        if ( i > 0 ) {
          if ( fullLineLen ) {
            size_t    resizedLineLen = fullLineLen + i + 1;
            char*     resizedLine = (char*)realloc(fullLine,resizedLineLen);
            
            if ( resizedLine ) {
              fullLine = resizedLine;
              strncat(fullLine,aLine,i);
              fullLineLen = resizedLineLen;
              free(aLine);
            } else {
              break;
            }
          } else {
            fullLineLen = i;
            aLine[i] = '\0';
            fullLine = aLine;
          }
        }
        aLine = readline("> ");
      }
      if ( fullLine && fullLineLen ) {
        int         argc = 0;
        char*       p = fullLine;
        char*       start = NULL;
        char*       absEnd = fullLine + fullLineLen;
        char        c;
        char        quote = '\0';
        BOOL        escaped = NO;
        BOOL        scanning = NO;
        BOOL        ok = YES;
          
        NCLog(CFSTR(":: Processing command line: [ %s ]"),fullLine);
        
        //  Add to the readline history:
        add_history(fullLine);
      
        //  Next order of business, separate the line into it's constituent
        //  pieces:
        while ((c = *p)) {
          //  If it was an escape character (\) then we move ahead one to
          //  the explicit character:
          if (c == '\\') {
            p++;
            if ((c = *p))
              escaped = YES;
            else
              break;
          } else
            escaped = NO;
          if (scanning) {
            if (!escaped) {
              //  If we're looking for a quote character, check for it:
              if (quote && c == quote) {
                //  Found the end quote; zero-it and as long as we're NOT on
                //  the starting character we've got another argument:
                *p = '\0';
                if (start != p)
                  argc++;
                quote = '\0';
                scanning = NO;
              } else if (!quote && isspace(c)) {
                //  Blank space, we've hit the end of an unquoted argument:
                *p = '\0';
                if (start != p)
                  argc++;
                scanning = NO;
              }
            }
          } else {
            //  Not scanning yet; see if we're still on whitespace:
            if (!isspace(c)) {
              //  Not a space, is it a quote?  If so, move ahead one
              //  character and zero-out the quote character.  Begin
              //  scanning on next cycle through this loop:
              if (c == '\'' || c == '\"') {
                quote = c;
                *p = '\0';
                start = p + 1;
              } else {
                quote = '\0';
                start = p;
              }
              scanning = YES;
            } else {
              //  It WAS whitespace; zero-out the character and we'll
              //  keep going:
              *p = '\0';
            }
          }
          p++;
        }
        //  If there was something being scanned we need to add it, as well:
        if (scanning) {
          if (quote) {
            ok = NO;
            NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    Unmatched %c.\n"),quote);
          } else
            argc++;
        }
        
        //  If all is okay, make the argv array and process the command line:
        if (ok) {
          const char* argv[argc];
          int         argi = 0;
          
          p = fullLine;
          while (p < absEnd) {
            size_t    pLen = strlen(p);
            
            start = p;
            while ( (p < absEnd) && *p) {
              p++;
              pLen--;
            }
            if (start != p) {
              argv[argi++] = (const char*)start;
            }
            p++;
          }
          if (argi)
            [self processCommandFromArguments:argv count:argi startingAtIndex:0];
        }
        free(fullLine);
        break;
      }
    } while (1);
  }

@end

//
#pragma mark
//

@implementation NCApplication

  + (void) initialize
  {
    if ( __NCApplicationCommandMapper == nil ) {
      int             tokenCount = 0;
      const char**    stringList = __NCApplicationCommands;
      
      while ( *stringList ) {
        tokenCount++;
        stringList++;
      }
      __NCApplicationCommandMapper = [[NCTokenList tokenListWithStrings:__NCApplicationCommands tokens:__NCApplicationTokens count:tokenCount] retain];
    }
  }

//

  - (id) initWithArguments:(const char**)argv
    count:(int)argc
  {
    int     argn = 1;
  
    //  Check for the debug flag:
    while (argn < argc) {
      if (strcmp(argv[argn++],"--debug") == 0) {
        if (stddbg) fclose(stddbg);
        stddbg = stderr;
        NCErrorSetLogging(TRUE);
      }
    }
    
    if (self = [super init]) {
      NCLog(CFSTR(":: Program initialization commencing:"));
        
      //  We have to do this because of calls to the processCommandOptions:
      //  and (possibly) processCommand: methods:
      NCApp = self;
      
      //  Do the initial c/l parameter scan:
      NCLog(CFSTR(":: * Checking for command-line options"));
      argn = [self processCommandOptionsFromArguments:argv count:argc startingAtIndex:1];
      
      NCLog(CFSTR(":: Program initialization complete (SCError = %d)."),SCError());
      
      //  Passing nil selects the root directory of the tree:
      [self setCurrentDirectory:nil];
      
      //  Register to hear about modifications to the tree:
      [[_preferenceSession directoryTree] setDelegate:self];
      
      if (!_options._runAsShell) {
        [self processCommandFromArguments:argv count:argc startingAtIndex:argn];
        _options._completedRunLoop = YES;
      } else {
        //  If we've got a TTY then we're in true command-line mode:
        if (isatty(STDIN_FILENO))
          _options._needsPrompt = YES;
      }
    }
    return self;
  }

//

  - (void) dealloc
  {
    if (_currentDirectory) [_currentDirectory release];
    if (_lastDirectory) [_lastDirectory release];
    
    //  We don't care to hear about all the changes as we release
    //  the directory tree:
    if (_preferenceSession) {
      [[_preferenceSession directoryTree] setDelegate:nil];
      [_preferenceSession release];
    }
    
    //  One last chance to drain the pool:
    NCApplicationAutoreleasePool = [NCApplicationAutoreleasePool drainButRetain];
    
    [super dealloc];
  }

//

  - (NCPreferenceSession*) preferenceSession
  {
    return _preferenceSession;
  }
  
//

  - (NCDirectoryNode*) currentDirectory { return _currentDirectory; }
  - (void) setCurrentDirectory:(NCDirectoryNode*)newDirectory
  {
    if (newDirectory) newDirectory = [newDirectory retain];
    if (_currentDirectory) [_currentDirectory release];
    if (newDirectory)
      _currentDirectory = newDirectory;
    else
      _currentDirectory = [[_preferenceSession directoryTree] retain];
  }

//

  - (NCDirectoryNode*) lastDirectory
  {
    return _lastDirectory;
  }
  
//

  - (BOOL) runAsShell
  {
    return _options._runAsShell;
  }

//

  - (int) run
  {
    int     result = kNCErrorNoError;
    BOOL    readlineInited = NO;
    
    //  Startup the readline history, etc:
    if ( ! _options._completedRunLoop ) {
      __NCApplicationReadlineAndHistoryStart();
      readlineInited = YES;
    }
    
    while (!feof(stdin) && !_options._completedRunLoop && result == kNCErrorNoError) {
      NCErrorClear();
      
      //  Do one command:
      [self processCommandFromSTDIN];
      
      //  Dispose of the autorelease pool contents:
      NCApplicationAutoreleasePool = [NCApplicationAutoreleasePool drainButRetain];
      
      CFStringRef   errorStr = NULL;
      
      NCErrorPop(&result,&errorStr,NULL);
      
      //  If we're set to ignore malformed commands, etc, check for that now:
      if (!_options._dieOnSyntaxErrors) {
        switch (result) {
            
          case kNCErrorLocationExists:
          case kNCErrorServiceExists:
          case kNCErrorUnknownCommand:
          case kNCErrorLockedProperty:
          case kNCErrorUnknownProperty:
          case kNCErrorTooFewParameters:
          case kNCErrorParameterError:
          case kNCErrorInvalidDirectoryID:
          case kNCErrorInvalidDirectoryPath:
          case kNCErrorInvalidDirectory:
          case kNCErrorInvalidOperation:
          case kNCErrorNoSuchLocation:
          case kNCErrorNoSuchService:
          case kNCErrorPropertyNotArrayType:
            result = kNCErrorNoError;
            break;
        }
      }
      if (errorStr) {
        NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    %@\n"),errorStr);
        CFRelease(errorStr);
      }
    }
    NCErrorClear();
    
    //  Shutdown readline history:
    if ( readlineInited ) {
      __NCApplicationReadlineAndHistoryEnd();
    }
      
    if ([[_preferenceSession directoryTree] treeHasBeenModified] || _options._treeWasModified) {
      if (_options._activateAtExit) {
        if (![_preferenceSession applyChanges]) {
          NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    could not apply the modifications\n"));
        }
      } else {
        if (![_preferenceSession commitChanges]) {
          NCPrint(stdout,CFSTR("%!red;%!bold;ERROR%!reset;:    could not commit the modifications\n"));
        }
      }
      NCErrorPop(&result,NULL,NULL);
    }
    return result;
  }
  
//
#pragma mark NCTreeDelegate informal protocol:
//

  - (void) didAddChildNode:(NCTree*)newNode
  {
    _options._treeWasModified = YES;
  }
  - (void) didAddSiblingNode:(NCTree*)newNode
  {
    _options._treeWasModified = YES;
  }
  - (void) didRemoveChildNode:(NCTree*)newNode
  {
    _options._treeWasModified = YES;
  }
    
@end

//
#pragma mark -
//

NCApplication*    NCApp = nil;

int
NCApplicationMain(
  int						argc,
  const char*		argv[]
)
{
  int		result = kNCErrorCouldNotRun;
  
  NCApplicationAutoreleasePool = [[NCAutoreleasePool alloc] init];

  NCApp = [[NCApplication alloc] initWithArguments:argv count:argc];
  
  if (NCApp) {
    result = [NCApp run];
    [NCApp release];
  }
  return result;
}
