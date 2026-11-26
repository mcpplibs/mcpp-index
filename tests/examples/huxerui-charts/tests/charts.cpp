import std;
import huxerui.charts;

using huxerui::AreaChart;
using huxerui::AreaMode;
using huxerui::BarChart;
using huxerui::BarMode;
using huxerui::Brush;
using huxerui::CategoryChartData;
using huxerui::CategoryDatum;
using huxerui::CategorySeries;
using huxerui::ChartAxis;
using huxerui::ChartCategory;
using huxerui::ChartInterpolation;
using huxerui::ChartLegendPlacement;
using huxerui::ChartMarkerShape;
using huxerui::ChartOrientation;
using huxerui::ChartSampling;
using huxerui::ChartTheme;
using huxerui::Color;
using huxerui::Frame;
using huxerui::LineChart;
using huxerui::PieChart;
using huxerui::PieChartData;
using huxerui::PieDatum;
using huxerui::ScatterChart;
using huxerui::ScatterChartData;
using huxerui::ScatterDatum;
using huxerui::ScatterSampling;
using huxerui::ScatterSeries;
using huxerui::View;
using huxerui::XYChartData;
using huxerui::XYDatum;
using huxerui::XYSeries;

int main() {
  bool ok = true;

  // 1. Out-of-line XYChartData snapshot creation, visibility sharing, and validation.
  const XYChartData xy({
      XYSeries("load", "Load", {{"m", 0.0, 12.5}, {"n", 1.0, std::nullopt}, {"e", 2.0, 18.0}}),
  });
  const auto xy_hidden = xy.WithSeriesVisible("load", false);
  ok = ok && xy.Series().size() == 1U && xy.Series()[0].Visible();
  ok = ok && !xy_hidden.Series()[0].Visible();
  ok = ok && xy.Series()[0].Samples().data() == xy_hidden.Series()[0].Samples().data();
  ok = ok && (xy == xy.WithSeriesVisible("load", true));

  bool rejected_xy = false;
  try {
    const XYChartData invalid({XYSeries("bad", "Bad", {{"a", 1.0, 2.0}, {"b", 1.0, 3.0}})});
    (void)invalid;
  } catch (const std::invalid_argument&) {
    rejected_xy = true;
  }
  ok = ok && rejected_xy;

  // 2. Out-of-line CategoryChartData and ScatterChartData snapshots.
  const CategoryChartData categories(
      {ChartCategory{"jan", "January"}, ChartCategory{"feb", "February"}},
      {CategorySeries("rev", "Revenue", {CategoryDatum{"j", "jan", 24.0}, CategoryDatum{"f", "feb", 36.0}})});
  ok = ok && categories.Categories().size() == 2U && categories.Series().size() == 1U;

  const ScatterChartData scatter(
      {ScatterSeries("pts", "Points", {ScatterDatum{"p0", 1.5, 2.5, 40.0}, ScatterDatum{"p1", 3.0, 4.0}})});
  ok = ok && scatter.Series().size() == 1U && scatter.Series()[0].Samples().size() == 2U;

  // 3. Out-of-line PieChartData snapshot.
  const PieChartData pie({PieDatum{"up", "Upload", 72.0}, PieDatum{"down", "Download", 28.0}});
  ok = ok && pie.Data().size() == 2U && pie.Data()[0].key == "up";

  // 4. Out-of-line ChartAxis fluent builders and validation.
  auto y_axis = ChartAxis::Linear()
                    .Domain({0.0, 100.0})
                    .IncludeZero()
                    .TickCount(5U)
                    .Ticks({{0.0, "0"}, {50.0, "50"}, {100.0, "100"}})
                    .Formatter([](double v) { return std::to_string(static_cast<int>(v)); })
                    .Title("Percent")
                    .Visible(true)
                    .Labels(true)
                    .Grid(true);
  auto x_cat = ChartAxis::Category().Title("Month").Grid(false);

  bool rejected_axis = false;
  try {
    (void)ChartAxis::Linear().Domain({10.0, 10.0});
  } catch (const std::invalid_argument&) {
    rejected_axis = true;
  }
  ok = ok && rejected_axis;

  // 5. Out-of-line chart Views (exercises ChartComponent<Derived>, Line/Area/Bar/Scatter/PieChart, BuildChart, BuildPieChart).
  const auto theme = ChartTheme::Default();
  ok = ok && theme.palette.empty();

  View line_view = LineChart(xy)
                       .Title("Load")
                       .XAxis(ChartAxis::Linear().Domain({0.0, 2.0}))
                       .YAxis(std::move(y_axis))
                       .Interpolation(ChartInterpolation::Monotone)
                       .Sampling(ChartSampling::Auto)
                       .Style({.marker = {.shape = ChartMarkerShape::Diamond, .visible = true}})
                       .SeriesStyle("load", {.stroke = Brush(Color::Rgb(35, 105, 210))})
                       .Legend({.visible = true, .interactive = true, .placement = ChartLegendPlacement::Bottom})
                       .With(Frame{.width = 320.0F, .height = 200.0F});

  View area_view = AreaChart(xy)
                       .Title("Area")
                       .Mode(AreaMode::Unstacked)
                       .Baseline(0.0)
                       .Interpolation(ChartInterpolation::StepAfter)
                       .With(Frame{.height = 200.0F});

  View bar_view = BarChart(categories)
                      .Title("Revenue")
                      .CategoryAxis(std::move(x_cat))
                      .ValueAxis(ChartAxis::Linear().IncludeZero())
                      .Mode(BarMode::Grouped)
                      .Orientation(ChartOrientation::Horizontal)
                      .With(Frame{.height = 220.0F});

  View scatter_view = ScatterChart(scatter)
                          .Title("Points")
                          .SizeScale({.min_area = 16.0F, .max_area = 256.0F})
                          .Sampling(ScatterSampling::Exact)
                          .With(Frame{.height = 200.0F});

  View pie_view = PieChart(pie)
                      .Title("Mix")
                      .Style({.inner_radius = 0.62F, .rounded_caps = true})
                      .SliceStyle("up", {.fill = Brush(Color::Rgb(230, 184, 102))})
                      .SliceStyle("down", {.fill = Brush(Color::Rgb(72, 118, 232))})
                      .With(Frame{.width = 160.0F, .height = 160.0F});

  (void)line_view;
  (void)area_view;
  (void)bar_view;
  (void)scatter_view;
  (void)pie_view;

  return ok ? 0 : 1;
}
