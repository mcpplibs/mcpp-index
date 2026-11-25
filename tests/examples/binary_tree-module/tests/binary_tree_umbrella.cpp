// yandere-chan.binary_tree umbrella-only assertion: import the lib root and
// nothing else. This checks that `export import` re-exports both the owning
// tree template and the placement-new declarations exported by the wrappers,
// so no `#include <new>` is needed here either.

import binary_tree;

int main()
{
    Yc::binary_tree<int> t;
    t.insert(t.root(), 1);
    t.insert(t.root().get_left(), 2);

    if (t.empty() || *t.nroot() != 1 || *t.root().get_left() != 2) { return 1; }

    int sum = 0;
    t.for_each([&sum](int& v) { sum += v; });
    return sum == 3 ? 0 : 1;
}
