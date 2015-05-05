**ncutil can modify the Mac OS X (darwin) network service interface settings on the active OS X system or another system volume.**

ncutil behaves much like Apple's legacy NetInfo command line utility, niutil, and the preferences are presented in the form of a directory tree.

Preference entities are specified by directory IDs (numerical values assigned to each directory by ncutil) or by paths. The program in pseudo-shell mode maintains a current directory, which may be indicated using the '.' character. The '!' character references the directory last accessed by any command. You may use '..' and '.' directory entities to reference parent and current directories, respectively. In the context of some commands, the target directory may be an optional parameter, in which case the current directory is assumed.

The user must have root privileges if the changes he/she makes are to be committed to the preference store and/or applied.