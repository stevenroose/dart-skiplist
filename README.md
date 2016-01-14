# skiplist


This class provides an implementation of skip lists, as they are described
in William Pugh's paper "Skip Lists: A probabilistic Alternative to
Balanced Trees".

Skip lists are a data structure that can be used in place of balanced trees.
Skip lists use probabilistic balancing rather than strictly enforced
balancing and as a result the algorithms for insertion and deletion in skip
lists are much simpler and significantly faster than equivalent algorithms
for balanced trees.

Skip lists have fast search by key, insert, update and delete operations,
all having a time complexity of O(log n).
All other type of operations are usually very bad.

This class implements Map, but can just as easily be used as a Set by
putting in null elements.

The implementation is largely based on the suggested implementation from
the paper. Also the configuration parameters are the same.