// yandere-chan.binary_tree module-package end-to-end assertion: consume the
// library by import only (no `#include` of its headers, no include path setup).
//
//   * `import binary_tree;`                 — the lib root, re-exporting all three
//   * `import Yc.binary_tree;`              — owning, no parent pointer
//   * `import Yc.parent_aware_binary_tree;` — owning, with parent pointers
//   * `import Yc.intrusive_binary_tree;`    — intrusive node hooks
//
// Every check increments `failures`; the process exits non-zero when a check
// does not hold, which is what makes this a test rather than a sample.

import Yc.intrusive_binary_tree;
import Yc.binary_tree;
import Yc.parent_aware_binary_tree;
import binary_tree;

int main()
{
    int failures = 0;
    auto check = [&failures](bool ok) { if (!ok) { ++failures; } };

    // Owning tree without parent pointers.
    Yc::binary_tree<int> t;
    t.insert(t.root(), 1);
    t.insert(t.root().get_left(), 2);
    t.insert(t.root().get_right(), 3);

    check(!t.empty());
    check(*t.nroot() == 1);
    check(*t.root().get_left() == 2);
    check(*t.root().get_right() == 3);

    int sum = 0;
    t.for_each([&sum](int& v) { sum += v; });
    check(sum == 6);

    // Copy construction walks and copies the structure.
    Yc::binary_tree<int> copy = t;
    int copy_sum = 0;
    copy.for_each([&copy_sum](int& v) { copy_sum += v; });
    check(copy_sum == 6);

    // Owning tree with parent pointers.
    Yc::parent_aware_binary_tree<int> p;
    p.insert(p.root(), 5);
    p.insert(p.root().get_left(), 6);

    check(*p.nroot() == 5);
    check(*p.nroot().get_left() == 6);
    check(!p.parent_of_cnroot().null());

    // Intrusive tree: the user node carries the hooks.
    struct node : Yc::intrusive_binary_tree_node_base<> { int value = 0; };
    Yc::basic_intrusive_binary_tree<> it;
    node a;
    a.value = 7;
    it.insert(it.root(), a);

    check(!it.empty());
    check(static_cast<node&>(*it.nroot()).value == 7);

    return failures == 0 ? 0 : 1;
}
