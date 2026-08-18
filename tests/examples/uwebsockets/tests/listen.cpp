// Behavioral test: instantiate the server templates and bind a real port.
//
// The risk in a header-only package layered on a C library is not "does the
// header exist" — it is whether the templates instantiate over the C types as
// the library was actually built, which only the CONSUMER's compile can answer.
// Registering routes instantiates HttpContext/HttpResponse/HttpRequest over
// us_socket_t, and `listen` walks all the way down to a bound socket.
#include <App.h>

#include <cassert>
#include <string>

int main() {
    bool bound = false;
    int chosen_port = 0;

    uWS::App app;

    // Two route shapes and a websocket behavior: each instantiates a different
    // corner of the template stack.
    app.get("/ping", [](auto* res, auto* /*req*/) {
        res->end("pong");
    });
    app.post("/echo/:id", [](auto* res, auto* req) {
        res->end(std::string(req->getParameter(0)));
    });
    app.ws<int>("/ws", {
        .open = [](auto* /*ws*/) {},
        .message = [](auto* ws, std::string_view msg, uWS::OpCode op) { ws->send(msg, op); },
    });

    // Port 0 asks the OS for an ephemeral port, so the test cannot collide with
    // anything else on the runner.
    app.listen(0, [&](us_listen_socket_t* token) {
        bound = (token != nullptr);
        if (token) {
            chosen_port = us_socket_local_port(0, reinterpret_cast<us_socket_t*>(token));
            us_listen_socket_close(0, token);
        }
    });

    // Returns once the listen socket is closed and nothing else holds the loop.
    app.run();

    assert(bound && "uWS::App failed to bind an ephemeral port");
    assert(chosen_port > 0 && "the OS assigned no port");
    return 0;
}
