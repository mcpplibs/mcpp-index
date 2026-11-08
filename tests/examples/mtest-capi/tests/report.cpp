#include <mtest.h>
int main() {
    mtest_init("c", 1);
    if (mtest_listing()) { mtest_case("adds", __FILE__, __LINE__, "unit"); return mtest_done(); }
    if (mtest_selected("adds")) { mtest_begin("adds"); mtest_end("adds", 1 + 1 == 2 ? "pass" : "fail", 0); }
    return mtest_done();
}
