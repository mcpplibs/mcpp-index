// compat.etl — exercise ETL's fixed-capacity containers and their observable
// capacity/ordering behaviour.
#include <etl/queue.h>
#include <etl/vector.h>

int main() {
    etl::vector<int, 4> values;
    values.push_back(3);
    values.push_back(1);
    values.push_back(4);

    if (values.size() != 3 || values.capacity() != 4 ||
        values[0] != 3 || values[2] != 4) {
        return 1;
    }

    etl::queue<int, 4> queue;
    queue.push(10);
    queue.push(20);
    if (queue.front() != 10 || queue.back() != 20) {
        return 2;
    }
    queue.pop();
    if (queue.front() != 20 || queue.size() != 1) {
        return 3;
    }

    return 0;
}
