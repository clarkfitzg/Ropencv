library(RCIndex)

d = "/home/clark/dev/opencv/modules/core/include"
tu = createTU(paste(d, "opencv2/core.hpp", sep = "/")
             , includes = c(d, "/usr/lib/llvm-3.8/bin/../lib/clang/3.8.0/include"
                            , "/home/clark/dev/opencv/build"
                            )
             , args = "-xc++"
             )

r = getRoutines(tu)

k = getCppClasses(tu)

#Mon Nov 28 09:26:30 PST 2016
#Error in getClass(Class, where = topenv(parent.frame())) :
  #“C++ClassConstructor.CXCursor_Constructor” is not a defined class

names(k)
