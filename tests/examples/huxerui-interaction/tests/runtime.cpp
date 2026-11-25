// Headless C++23 module consumer test for huxerui.interaction.
// Verifies package resolution, transitive huxerui.huxerui linking, pipe/mask
// operators exported via huxerui.interaction.operators, and out-of-line
// std::invalid_argument validation across the module boundary.
import std;
import huxerui.interaction;

using namespace huxerui;
using namespace huxerui::interaction;

namespace {

template <class Fn>
bool ThrowsInvalidArgument(Fn&& fn) {
  try {
    fn();
  } catch (const std::invalid_argument&) {
    return true;
  }
  return false;
}

} // namespace

int main() {
  bool ok = true;

  // 1. Default-constructed unbound controllers across gesture/overlay/scroll/accessibility subgroups
  ok = ok && (SwipeController{} == SwipeController{}) && !static_cast<bool>(SwipeController{});
  ok = ok && (PanZoomController{} == PanZoomController{});
  ok = ok && (HoverCardController{} == HoverCardController{});
  ok = ok && (PopoverController{} == PopoverController{}) && !static_cast<bool>(PopoverController{});
  ok = ok && (RovingFocusController{} == RovingFocusController{}) && !static_cast<bool>(RovingFocusController{});
  ok = ok && !RovingFocusController{}.FocusIndex(0);
  ok = ok && !RovingFocusController{}.FocusNext();
  ok = ok && (ScrollToTopController{} == ScrollToTopController{}) && !static_cast<bool>(ScrollToTopController{});
  ok = ok && (CompareSliderController{} == CompareSliderController{}) && !static_cast<bool>(CompareSliderController{});
  ok = ok && (RadialDialController{} == RadialDialController{}) && !static_cast<bool>(RadialDialController{});
  ok = ok && (PredictiveBackController{} == PredictiveBackController{}) && !static_cast<bool>(PredictiveBackController{});

  // 2. Construct valid Views and pipeable ViewAdaptors across press, hover, gesture, reorder,
  //    dragdrop, overlay, scroll, accessibility, and visual subgroups (no #include of library headers)
  View composed = Text("interaction-smoke")
                      .With(Ripple{}, Spotlight{}, HoverHighlight{}, Shimmer{})
                  | Pressable([] {})
                  | HoverLift()
                  | DoubleClickable([](const MultiTapEvent&) {})
                  | ContextMenuArea([](Point) {})
                  | KeyboardShortcut({.key = Key::K}, [] {})
                  | BackHandler([] {})
                  | RovingFocusItem(0)
                  | RovingFocusGroup()
                  | Copyable("hello")
                  | Popover([](PopupContext) { return Text("popover"); })
                  | Expandable(true)
                  | Appear()
                  | DropZone<int>([](int v) { return v > 0; });
  ok = ok && static_cast<bool>(composed);

  ok = ok && static_cast<bool>(InteractiveSurface([](const InteractionSnapshot&) { return Text("surface"); }));
  ok = ok && static_cast<bool>(Hoverable([](bool) { return Text("hoverable"); }));
  ok = ok && static_cast<bool>(CompareSlider(Text("before"), Text("after")));
  ok = ok && static_cast<bool>(RadialDial());
  ok = ok && static_cast<bool>(SwipeActions(Text("row"), [](SwipeActionContext) { return Text("act"); }));
  ok = ok && static_cast<bool>(Reorderable({Text("a"), Text("b")}));
  ok = ok && static_cast<bool>(RollingNumber(42));
  ok = ok && static_cast<bool>(HoverCard(Text("anchor"), [](PopupContext) { return Text("card"); }));
  ok = ok && static_cast<bool>(Text("scroll").With(ScrollProgress(ScrollController{}), ScrollEdgeFade(ScrollController{})));
  const SwipeDirectionMask dir_mask = SwipeDirectionMask::Left | SwipeDirectionMask::Right;
  ok = ok && ((dir_mask & SwipeDirectionMask::Left) == SwipeDirectionMask::Left);
  ok = ok && HasDirection(dir_mask, SwipeDirectionMask::Right);

  // 3. Call out-of-line validation paths across subgroups (must throw std::invalid_argument)
  ok = ok && ThrowsInvalidArgument([] { (void)InteractiveSurface({}); });
  ok = ok && ThrowsInvalidArgument([] { (void)Pressable(Text("x"), {.hovered_scale = 0.0F}); });
  ok = ok && ThrowsInvalidArgument([] { (void)HoverLift(Text("x"), {.hovered_scale = -1.0F}); });
  ok = ok && ThrowsInvalidArgument([] { (void)Text("x").With(Ripple{RippleStyle{.duration = 0.0}}); });
  ok = ok && ThrowsInvalidArgument([] { (void)Copyable(std::function<View(bool)>{}, "text"); });
  ok = ok && ThrowsInvalidArgument([] { (void)Popover(Text("x"), std::function<View(PopupContext)>{}); });
  ok = ok && ThrowsInvalidArgument([] { (void)HoverCard(Text("x"), std::function<View(PopupContext)>{}); });
  ok = ok && ThrowsInvalidArgument([] { (void)RollingNumber(0, {.minimum_digits = -1}); });
  ok = ok && ThrowsInvalidArgument([] {
    (void)SwipeActions(Text("row"), [](SwipeActionContext) { return Text("act"); }, {.action_extent = 0.0F});
  });

  return ok ? 0 : 1;
}
