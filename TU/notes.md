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
