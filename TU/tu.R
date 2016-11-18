library(RCIndex)

d = "/home/clark/dev/opencv/modules/core/include"
tu = createTU(paste(d, "opencv2/core.hpp", sep = "/")
                    , includes = c(d, "/usr/lib/llvm-3.8/bin/../lib/clang/3.8.0/include"
                                   , "/home/clark/dev/opencv/build"
                                   )
                    , args = "-xc++"
                    )


k = getCppClasses(tu)
names(k)
