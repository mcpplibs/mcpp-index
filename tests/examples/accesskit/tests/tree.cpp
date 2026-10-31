// Behavioral test: compat.accesskit builds a tree (a window holding a button
// with a label, focusable, clickable), reads it back through the library's own
// debug view, and on Linux makes an AT-SPI adapter and gives it the tree. Not
// merely an include: these calls reach the prebuilt Rust library.
#include <accesskit.h>
#include <cstdio>
#include <cstring>

static accesskit_tree_update *tree(void *userdata) {
    (void)userdata;
    accesskit_node *window = accesskit_node_new(ACCESSKIT_ROLE_WINDOW);
    accesskit_node_set_label(window, "Settings");
    accesskit_node_push_child(window, 2);
    accesskit_node *button = accesskit_node_new(ACCESSKIT_ROLE_BUTTON);
    accesskit_node_set_label(button, "Save");
    accesskit_node_add_action(button, ACCESSKIT_ACTION_CLICK);
    accesskit_node_add_action(button, ACCESSKIT_ACTION_FOCUS);
    accesskit_tree_update *update = accesskit_tree_update_with_capacity_and_focus(2, 2);
    accesskit_tree_update_set_tree_info(update, accesskit_tree_info_new(1));
    accesskit_tree_update_push_node(update, 1, window);
    accesskit_tree_update_push_node(update, 2, button);
    return update;
}

#if defined(__linux__)
static void act(accesskit_action_request *request, void *userdata) {
    (void)userdata;
    accesskit_action_request_free(request);
}
static void deactivated(void *userdata) { (void)userdata; }
#endif

int main(void) {
    accesskit_tree_update *update = tree(nullptr);
    if (!update) {
        fprintf(stderr, "no tree update\n");
        return 1;
    }
    char *debug = accesskit_tree_update_debug(update);
    const int named = debug && strstr(debug, "Save") != NULL;
    if (debug) accesskit_string_free(debug);
    accesskit_tree_update_free(update);
    if (!named) {
        fprintf(stderr, "the tree update does not hold the button's label\n");
        return 1;
    }
#if defined(__linux__)
    accesskit_unix_adapter *adapter = accesskit_unix_adapter_new(reinterpret_cast<accesskit_activation_handler_callback>(tree), nullptr, act, nullptr, deactivated, nullptr);
    if (!adapter) {
        fprintf(stderr, "no AT-SPI adapter\n");
        return 1;
    }
    accesskit_unix_adapter_update_window_focus_state(adapter, true);
    accesskit_unix_adapter_free(adapter);
#endif
    printf("accesskit: a window and its button, served\n");
    return 0;
}
