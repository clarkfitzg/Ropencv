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
