// Behavioral test: build a cJSON document, serialize, re-parse, assert fields.
#include <cJSON.h>
#include <cassert>
#include <cstring>

int main() {
    cJSON* root = cJSON_CreateObject();
    cJSON_AddNumberToObject(root, "answer", 42);
    cJSON_AddStringToObject(root, "lib", "cJSON");
    char* text = cJSON_PrintUnformatted(root);

    cJSON* parsed = cJSON_Parse(text);
    assert(parsed != nullptr);
    assert(cJSON_GetObjectItem(parsed, "answer")->valueint == 42);
    assert(std::strcmp(cJSON_GetObjectItem(parsed, "lib")->valuestring, "cJSON") == 0);

    cJSON_free(text);
    cJSON_Delete(root);
    cJSON_Delete(parsed);
    return 0;
}
