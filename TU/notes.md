### Thu Dec 22 09:12:28 PST 2016

The issue appears to be in `cppClass.R`.

Looking carefully at the stack trace now:

```
Enter a frame number, or 0 to exit

1: getCppClasses(tu)
2: lapply(ans, readCppClass)
3: lapply(ans, readCppClass)
4: FUN(X[[i]], ...)
5: visitTU(cursor, visitor$update)
6: do(tu)
7: (function (cur, parent)
{
    k = cur$kind
    if (k == CXCursor_CXXAccess
8: new(RclassName, def = cur, name = id, params = list(), returnType =
getResu
9: getClass(Class, where = topenv(parent.frame()))
```

The error happens inside `genCppClassInfoCollector` as it is applied over
the cursors. How does the `RclassName` get set to this? From the `classMap`
variable.

Inspecting `classMap` in frame 7 we see
```
Browse[3]> classMap
                C++ClassMethod.CXCursor_CXXMethod
                                               21
         C++ClassConstructor.CXCursor_Constructor
                                               24
 C++ClassTemplateMethod.CXCursor_FunctionTemplate
                                               30
C++ConversionFunction.CXCursor_ConversionFunction
                                               26
```
They all have this form of concatenated name, which appears to be intentional.
Yet the variable `classMap` is only assigned in one place.

Maybe this relies on name concatenation rules in R that I'm not aware
of. Yes.
```

a = c("there" = 10)
b = c("hello" = a)

> b
hello.there
         10

```

Where do the class declarations happen? `CXCursor_Constructor` only shows
up in the `a_enumDefs_3.x` and `cppClass.R` files. Yet I don't see
`setClass` being used along with it.


### Wed Dec 21 16:30:25 PST 2016

Now back to the other error. This appears to come from RCIndex.

```
Error in getClass(Class, where = topenv(parent.frame())) :
 “C++ClassConstructor.CXCursor_Constructor” is not a defined class
```
So this class doesn't exist. But is the constructor the same as the class?
This seems strange. Shouldn't

Grep doesn't turn anything up in the directory.

grep "C++ClassConstructor.CXCursor_Constructor" * -l


### Wed Dec 21 15:12:21 PST 2016

Previously I had made some local changes, now I'm syncing back up with
Duncan's branch and getting started with this again.

Working on `Ropencv/tu.R` and I run into this error. Which is the same that
I had before.
```
> k = getCppClasses(tu)
Error in asEnum(val, CXCursorKind, "CXCursorKind") : No matching value
```

First lets check what version of llvm the package thinks that I have.
```

library(RCIndex)

vc = RCIndex:::libclangVersion_Install

all(RCIndex:::clangVersionNum(vc) == c(3, 8))

```
Yes, it has the correct version.

Interesting that new files are generated within the R directory of RCIndex
when I install it. Haven't noticed that before when installing packages.

Next step: see what possible values for `CXCursorKind` are.

```

length(CXCursorKind)
# 171

```

Again fails on `CXCursorKind` 417, which is not in RCIndex. Lets try
reinstalling from Duncan's master branch to make sure everything is
configured as it should be.

Reinstalled, looks like the same error. Now let's look in the library code
and check if it's overriden somewhere. 
- It's defined in `R/a_enumDefs_3.8.R`.
- It's defined again in `R/cursorKind.R`, which overwrites the correct one.

I can fix this.

### Thu Nov 17 16:04:53 PST 2016

Now I need to figure out what this translation unit can do.

Everything in this `core.hpp` header file is in the namespace `cv`. I
should be able to find things like all the `enum` objects from the top of
the file.

What's with all the `CV_EXPORTS` and `CV_EXPORTS_W` before the function
definitions? These are macros. See note on line 363 in `cvdef.h` and ask
Duncan.

How the Python bindings are generated:
http://docs.opencv.org/master/da/d49/tutorial_py_bindings_basics.html
Should be very relevant. So it uses custom parsing in Python to parse the
header files

I'm observing that R's S4 OO system is closer to C++ than Python's. Since
we can overload functions.

### Thu Nov 17 15:21:58 PST 2016

Next error:
```
'opencv2/opencv_modules.hpp' file not found
```

```
clark@DSI-CF ~/dev/opencv (master)
$ find . -name "opencv_modules.hpp"
```

This search relative to the opencv root turns up nothing, so it seems this
file isn't in the directory.

Yes, internet confirms this. So I need to build the library first.

http://answers.opencv.org/question/29885/does-opencv_moduleshpp-exist-in-opencv248/

Building: http://docs.opencv.org/trunk/d7/d9f/tutorial_linux_install.html

Wonderful, now the `tu` code actually runs!


### Mon Nov 14 10:32:32 PST 2016

Cannot find file "opencv2/core/cvdef.h". This happened because header files
are given relative to the "include" directory in opencv.

```
/usr/include/limits.h:123:16: fatal error: 'limits.h' file not found
```

The offending line in `/usr/include/limits.h` is:

```
# include_next <limits.h>
```

`include_next` appears to be a GNU extension-
https://gcc.gnu.org/onlinedocs/cpp/Wrapper-Headers.html. These docs say:

> In particular, it should not be used in the headers belonging to a
> specific program

So RCindex doesn't like this. Let's try `createTU` on a simple program with
`# include <limits.h>`

This seems to fix it - need to include directory from llvm. Seems strange.
```
/usr/lib/llvm-3.8/bin/../lib/clang/3.8.0/include
```
