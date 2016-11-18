library(RCIndex)
library(RCodeGen)

d = "/home/clark/dev/opencv/modules/core/include"

tu = createTU(paste(d, "opencv2/core.hpp", sep = "/")
              , includes = c(d, "/usr/include")
              , args = "-xc++")
