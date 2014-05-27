# 4.0

* Get rid of the annoying `ActionController` dependency that needs to be passed into each cell. We only need it for "contextual links", when people wanna link to the same page. Make them pass in a URL generator object as a normal argument instead.