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

#if !defined(__NCUTIL_NCERROR__)
#define __NCUTIL_NCERROR__ 1

#include <CoreFoundation/CoreFoundation.h>
#include <errno.h>

#if defined(__cplusplus)
extern "C" {
#endif

enum {
  kNCErrorNoError                   =   0,
  kNCErrorCouldNotRun               =   1,
  kNCErrorMemoryError               =   2,
  kNCErrorParameterError            =   3,
  kNCErrorUnrecognizedOption        =   4,
  kNCErrorUnknownCommand            =   5,
  kNCErrorUnknownProperty           =   6,
  kNCErrorBadServiceOrder           =   7,
  kNCErrorPropertyNotArrayType      =   8,
  kNCErrorPropertyValueIndexError   =   9,
  kNCErrorLockedProperty            =  10,
  kNCErrorTooFewParameters          =  11,
  kNCErrorInvalidDirectoryID        =  12,
  kNCErrorInvalidDirectoryPath      =  13,
  kNCErrorInternalError             =  14,
  kNCErrorNoSuchLocation            =  15,
  kNCErrorLocationExists            =  16,
  kNCErrorServiceExists             =  17,
  kNCErrorCouldNotCommit            =  18,
  kNCErrorCouldNotApply             =  19,
  kNCErrorInvalidDirectory          =  20,
  kNCErrorNoSuchService             =  21,
  kNCErrorInvalidOperation          =  22,
  kNCErrorCouldNotSetupPreferences  =  23
};

/*!
  @function NCErrorLogging
  Returns <TT>TRUE</TT> if calls to NCErrorPush() should log the error via
  the NCLog() function.
*/
CF_EXPORT Boolean NCErrorLogging();
/*!
  @function NCErrorSetLogging
  Pass <TT>TRUE</TT> if calls to NCErrorPush() should log the error via
  the NCLog() function.
*/
CF_EXPORT void NCErrorSetLogging(Boolean enabled);

/*!
  @function NCErrorPush
  Push an error with the given integer code and CFString-based explanation
  onto the error stack.
*/
CF_EXPORT void NCErrorPush(int errNo,CFStringRef explanation,void* context);
/*!
  @function NCErrorPop
  Retrieve the error code and explanation on the top of the error stack.  Returns
  <TT>FALSE</TT> if the stack is empty.
*/
CF_EXPORT Boolean NCErrorPop(int* errNo,CFStringRef* explanation,void** context);
/*!
  @function NCErrorClear
  Removes all errors from the stack.
*/
CF_EXPORT void NCErrorClear();

//

/*!
  @function NCANSIOutputIsEnabled
  Returns <TT>TRUE</TT> if the NCLog() and NCPrint() functions will honor ANSI formatting
  sequences embedded in the format strings; <TT>FALSE</TT> implies that the sequences
  are discarded.
*/
Boolean NCANSIOutputIsEnabled();
/*!
  @function NCSetANSIOutputIsEnabled
  Pass <TT>TRUE</TT> if you wish the NCLog and NCPrint functions to honor ANSI formatting
  sequences embedded in format strings.
*/
void NCSetANSIOutputIsEnabled(Boolean enabled);

/*!
  @function NCLog
  @discussion Implements a simple logging function which writes out an error
  string composed using the <TT>format</TT> string and any dependent parameters
  passed in the call.  The function will also broadcast a notification with the
  <TT>NCErrorNotification</TT> message through the shared notification center
  using the provided <TT>code</TT> to notify registered listeners of the
  error condition impled by <TT>code</TT>.
  
  The format string is passed as a <TT>CFString</TT>, but if a localization
  bundle has been associated with the framework by the userland code's setting
  the <TT>kNCUtilFoundation_ExternalBundleRef</TT> global variable, the format
  string will be localized prior to its use.
*/
void NCLog(CFStringRef format,...);

/*!
  @function NCPrint
  Formatted print which can make use of CoreFoundation objects.
*/
void NCPrint(FILE* stream,CFStringRef format,...);

#if defined(__cplusplus)
}
#endif

#endif /* !__NCUTIL_NCERROR__ */
