#include <git2.h>

#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>

namespace fs = std::filesystem;

namespace {

bool Expect(bool ok, const char* msg) {
  if (!ok) {
    std::cerr << "FAIL: " << msg << "\n";
  }
  return ok;
}

} // namespace

int main() {
  bool ok = true;

  if (!Expect(git_libgit2_init() >= 1, "git_libgit2_init")) {
    return 1;
  }

  int major = 0, minor = 0, rev = 0;
  git_libgit2_version(&major, &minor, &rev);
  std::cout << "libgit2 version: " << major << "." << minor << "." << rev << "\n";
  ok &= Expect(major == 1 && minor == 9 && rev == 7, "version is 1.9.7");

  const int features = git_libgit2_features();
  ok &= Expect((features & GIT_FEATURE_THREADS) != 0, "GIT_FEATURE_THREADS enabled");
  ok &= Expect((features & GIT_FEATURE_HTTPS) != 0, "GIT_FEATURE_HTTPS enabled");
  ok &= Expect((features & GIT_FEATURE_COMPRESSION) != 0, "GIT_FEATURE_COMPRESSION enabled");

  const fs::path temp_root = fs::temp_directory_path() / "mcpp_libgit2_smoke";
  std::error_code ec;
  fs::remove_all(temp_root, ec);
  fs::create_directories(temp_root, ec);

  // Negative check: opening a nonexistent repository fails cleanly.
  git_repository* missing = nullptr;
  ok &= Expect(git_repository_open(&missing, (temp_root / "missing").string().c_str()) < 0 && missing == nullptr,
               "negative: missing repository fails to open");

  // Positive check: init repository, write file, stage + commit + inspect HEAD commit.
  const fs::path repo_dir = temp_root / "repo";
  git_repository* repo = nullptr;
  ok &= Expect(git_repository_init(&repo, repo_dir.string().c_str(), 0) == 0 && repo != nullptr,
               "git_repository_init");

  if (repo) {
    {
      std::ofstream out(repo_dir / "README.md", std::ios::binary);
      out << "hello libgit2\n";
      ok &= Expect(out.good(), "write README.md");
    }

    git_index* index = nullptr;
    ok &= Expect(git_repository_index(&index, repo) == 0 && index != nullptr, "git_repository_index");
    if (index) {
      ok &= Expect(git_index_add_bypath(index, "README.md") == 0, "git_index_add_bypath");
      git_oid tree_id{};
      ok &= Expect(git_index_write_tree(&tree_id, index) == 0, "git_index_write_tree");
      ok &= Expect(git_index_write(index) == 0, "git_index_write");

      git_tree* tree = nullptr;
      git_signature* sig = nullptr;
      ok &= Expect(git_tree_lookup(&tree, repo, &tree_id) == 0 && tree != nullptr, "git_tree_lookup");
      ok &= Expect(git_signature_new(&sig, "Test User", "test@example.com", 1700000000, 0) == 0 && sig != nullptr,
                   "git_signature_new");

      git_oid commit_id{};
      if (tree && sig) {
        ok &= Expect(git_commit_create_v(&commit_id, repo, "HEAD", sig, sig, nullptr,
                                         "initial commit", tree, 0) == 0,
                     "git_commit_create_v");
      }

      git_commit* commit = nullptr;
      if (git_commit_lookup(&commit, repo, &commit_id) == 0 && commit != nullptr) {
        const char* msg = git_commit_message(commit);
        ok &= Expect(msg != nullptr && std::string(msg) == "initial commit", "git_commit_message matches");
        git_commit_free(commit);
      } else {
        ok = false;
      }

      git_signature_free(sig);
      git_tree_free(tree);
      git_index_free(index);
    }
    git_repository_free(repo);
  }

  fs::remove_all(temp_root, ec);
  git_libgit2_shutdown();
  return ok ? 0 : 1;
}
