// compat.rapidcsv — exercise the parser's document model: a header row, typed
// cell access by column name and by index, a whole column, and CSV's
// quoted-field semantics (a separator inside quotes is data, not a delimiter).
//
// Everything is parsed from memory: no input file, no network.
#include <rapidcsv.h>

#include <sstream>
#include <string>
#include <vector>

int main() {
    std::istringstream csv(
        "city,population\n"
        "tokyo,13960000\n"
        "osaka,2691000\n");

    rapidcsv::Document doc(csv, rapidcsv::LabelParams(0, -1));

    bool ok = doc.GetColumnCount() == 2 && doc.GetRowCount() == 2;

    ok = ok && doc.GetColumnName(0) == "city";
    ok = ok && doc.GetColumnName(1) == "population";

    // Column name + row index. The (columnName, rowName) overloads would throw
    // here: LabelParams(0, -1) declares a header row but no row-name column.
    ok = ok && doc.GetCell<std::string>("city", 0) == "tokyo";
    ok = ok && doc.GetCell<int>("population", 0) == 13960000;
    ok = ok && doc.GetCell<int>(1, 1) == 2691000;

    const std::vector<std::string> cities = doc.GetColumn<std::string>("city");
    const std::vector<int> populations = doc.GetColumn<int>(1);
    ok = ok && cities.size() == 2 && cities[0] == "tokyo" && cities[1] == "osaka";
    ok = ok && populations.size() == 2 && populations[0] == 13960000;
    ok = ok && populations[1] == 2691000;

    // Quoted field: the comma inside the quotes belongs to the cell.
    std::istringstream quoted(
        "venue,note\n"
        "osaka,\"Kansai, Japan\"\n");
    rapidcsv::Document qdoc(quoted, rapidcsv::LabelParams(0, -1));
    ok = ok && qdoc.GetColumnCount() == 2 && qdoc.GetRowCount() == 1;
    ok = ok && qdoc.GetCell<std::string>("note", 0) == "Kansai, Japan";

    return ok ? 0 : 1;
}
