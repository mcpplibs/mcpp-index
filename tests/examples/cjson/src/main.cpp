// cJSON is plain C; the header guards itself with extern "C" for C++ users.
#include <cJSON.h>
#include <cstdio>
#include <cstring>

int main() {
    cJSON* root = cJSON_CreateObject();
    cJSON_AddNumberToObject(root, "answer", 42);
    cJSON_AddStringToObject(root, "lib", "cJSON");
    char* text = cJSON_PrintUnformatted(root);

    cJSON* parsed = cJSON_Parse(text);
    int answer = cJSON_GetObjectItem(parsed, "answer")->valueint;
    const char* lib = cJSON_GetObjectItem(parsed, "lib")->valuestring;
    bool ok = (answer == 42) && (std::strcmp(lib, "cJSON") == 0);

    std::printf("cjson ok=%d json=%s\n", ok, text);
    cJSON_free(text);
    cJSON_Delete(root);
    cJSON_Delete(parsed);
    return ok ? 0 : 1;
}
