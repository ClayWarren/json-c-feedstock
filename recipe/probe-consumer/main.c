#include <json-c/json.h>
#include <string.h>
int main(void) {
 struct json_object *o=json_tokener_parse("{\"answer\":42,\"items\":[1,2]}");
 struct json_object *v=NULL;
 if(!o || !json_object_object_get_ex(o,"answer",&v) || json_object_get_int(v)!=42) return 1;
 if(!json_object_object_get_ex(o,"items",&v) || json_object_array_length(v)!=2) return 2;
 const char *s=json_object_to_json_string_ext(o,JSON_C_TO_STRING_PLAIN);
 int result=!s || !strstr(s,"answer"); json_object_put(o); return result;
}
