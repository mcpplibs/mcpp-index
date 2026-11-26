import std;
import huxerui.datatable;

using namespace huxerui;

int main() {
  bool ok = true;

  // 1. Construct DataTable model/value types exported by huxerui.datatable
  const DataTableCellId c1{"row-1", "col-id"};
  const DataTableCellId c2{"row-1", "col-id"};
  const DataTableCellId c3{"row-2", "col-id"};
  ok = ok && (c1 == c2) && !(c1 == c3);

  const DataTableSort s1{"col-id", DataTableSortDirection::Ascending};
  const DataTableSort s2{"col-id", DataTableSortDirection::Descending};
  ok = ok && (s1 == s1) && !(s1 == s2);

  // 2. Call out-of-line DataTable() validation (must throw std::invalid_argument on invalid options)
  bool threw_bad_height = false;
  try {
    DataTableOptions bad{};
    bad.row_height = 0.0F;
    static_cast<void>(DataTable(std::move(bad)));
  } catch (const std::invalid_argument&) {
    threw_bad_height = true;
  }
  ok = ok && threw_bad_height;

  bool threw_dup_col = false;
  try {
    DataTableOptions dup{};
    dup.columns.push_back({
        .id = "dup",
        .header = "A",
        .render_cell = [](const DataTableCellContext&) -> DataTableCellContent {
          return {Text("a"), "a"};
        },
    });
    dup.columns.push_back({
        .id = "dup",
        .header = "B",
        .render_cell = [](const DataTableCellContext&) -> DataTableCellContent {
          return {Text("b"), "b"};
        },
    });
    static_cast<void>(DataTable(std::move(dup)));
  } catch (const std::invalid_argument&) {
    threw_dup_col = true;
  }
  ok = ok && threw_dup_col;

  bool threw_missing_row_cb = false;
  try {
    DataTableOptions missing_cb{};
    missing_cb.rows.count = 3;
    static_cast<void>(DataTable(std::move(missing_cb)));
  } catch (const std::invalid_argument&) {
    threw_missing_row_cb = true;
  }
  ok = ok && threw_missing_row_cb;

  // 3. Construct a valid DataTable View with rows, sortable column, editable column, and event handlers
  DataTableOptions valid{
      .rows = {
          .count = 2,
          .id_at = [](std::size_t index) -> std::string {
            return index == 0 ? "r1" : "r2";
          },
          .index_of = [](std::string_view id) -> std::optional<std::size_t> {
            if (id == "r1") return std::size_t{0};
            if (id == "r2") return std::size_t{1};
            return std::nullopt;
          },
      },
      .row_height = 32.0F,
      .header_height = 36.0F,
      .frozen_column_count = 1,
      .sort = s1,
      .selected_cell = c1,
  };
  valid.columns.push_back({
      .id = "col-id",
      .header = "ID",
      .width = {.initial = 100.0F, .min = 60.0F, .max = 200.0F},
      .sortable = true,
      .render_cell = [](const DataTableCellContext& cell) -> DataTableCellContent {
        return {Text(cell.id.row_id), cell.id.row_id};
      },
  });
  valid.columns.push_back({
      .id = "col-name",
      .header = "Name",
      .width = {.initial = 140.0F, .min = 80.0F, .max = 300.0F},
      .sortable = false,
      .render_cell = [](const DataTableCellContext& cell) -> DataTableCellContent {
        return {Text(cell.id.row_id + ":name"), cell.id.row_id};
      },
      .editor = DataTableEditor{
          .initial_text = [](const DataTableCellContext& cell) { return cell.id.row_id; },
          .render = [](const DataTableEditContext& edit) {
            return TextField(edit.draft)
                .OnChanged([draft = edit.draft](const TextEditingValue& next) { draft = next; })
                .OnSubmitted(edit.commit)
                .With(edit.focus_target);
          },
      },
  });

  View table = DataTable(std::move(valid))
      .On<DataTableEvents::SortRequested>([](const DataTableSort&) {})
      .On<DataTableEvents::SelectionRequested>([](const DataTableCellId&) {})
      .On<DataTableEvents::EditSubmitted>([](const DataTableEditRequest&) {})
      .With(Frame{.width = 640.0F, .height = 360.0F});

  ok = ok && static_cast<bool>(table);

  return ok ? 0 : 1;
}
