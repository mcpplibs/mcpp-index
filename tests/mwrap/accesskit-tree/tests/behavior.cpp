// Through the module: a window holding a button built, read back through the
// library's debug view, and on Linux served by an AT-SPI adapter. The names
// are AccessKit's own (no namespace of this package's).
import std;
import mcpplibs.mwrap.accesskit;

namespace {

accesskit_tree_update* tree(void*) {
    accesskit_node* window = accesskit_node_new(ACCESSKIT_ROLE_WINDOW);
    accesskit_node_set_label(window, "Settings");
    accesskit_node_push_child(window, 2);
    accesskit_node* button = accesskit_node_new(ACCESSKIT_ROLE_BUTTON);
    accesskit_node_set_label(button, "Save");
    accesskit_node_add_action(button, ACCESSKIT_ACTION_CLICK);
    accesskit_node_set_toggled(button, ACCESSKIT_TOGGLED_FALSE);
    accesskit_tree_update* update = accesskit_tree_update_with_capacity_and_focus(2, 2);
    accesskit_tree_update_set_tree_info(update, accesskit_tree_info_new(1));
    accesskit_tree_update_push_node(update, 1, window);
    accesskit_tree_update_push_node(update, 2, button);
    return update;
}

}  // namespace

int main() {
    accesskit_tree_update* update = tree(nullptr);
    char* debug = accesskit_tree_update_debug(update);
    const bool named = debug && std::string_view(debug).contains("Save") && std::string_view(debug).contains("Settings");
    if (debug) accesskit_string_free(debug);
    accesskit_tree_update_free(update);
    if (!named) {
        std::println(std::cerr, "the update does not hold the window and its button");
        return 1;
    }
#if defined(__linux__)
    accesskit_unix_adapter* adapter = accesskit_unix_adapter_new(
        tree, nullptr, [](accesskit_action_request* r, void*) { accesskit_action_request_free(r); }, nullptr, [](void*) {}, nullptr);
    if (!adapter) {
        std::println(std::cerr, "no AT-SPI adapter");
        return 1;
    }
    accesskit_unix_adapter_update_window_focus_state(adapter, true);
    accesskit_unix_adapter_free(adapter);
#endif
    std::println("accesskit through its module: a window and its button");
    return 0;
}
