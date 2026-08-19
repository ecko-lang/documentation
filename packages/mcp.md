# mcp

Model Context Protocol, both directions: call an MCP server's tools over stdio or HTTP, or be one.

```bash
ecko get github.com/ecko-lang/mcp
```

```ecko
import mcp
```

Declares `net` and `exec`. A capability is only advisory in the manifest: what the package actually gets is the `grant` you give it when you import it.

Version 0.12.0 - [source](https://github.com/ecko-lang/mcp) - MIT.

---


## `PROTOCOL_VERSION`

The MCP protocol version this package speaks, in both directions.

Shared rather than declared per side: a client and a server that disagree
about it fail a handshake, and two constants drift the moment MCP revs.

## `fail(message, detail = {})`

The error this package raises. `kind` is always "mcp", so a caller can
`catch (e) { if e.kind == "mcp" { ... } }` without matching on message text.

## `request(id, method, params = {})`

Build a JSON-RPC request object. `id` correlates the reply; MCP requires it
to be unique within a connection and never null.

## `notification(method, params = {})`

Build a JSON-RPC notification: a request with no `id`, which the server must
not reply to. MCP uses these for `notifications/initialized` and cancellation.

## `encode(message)`

Encode a request or notification for the wire.

## `result_of(reply)`

Decode one JSON-RPC reply and return its `result`, raising the `error` object
if the server sent one.

A JSON-RPC error is a normal outcome of a well-formed call - an unknown tool,
a bad argument - so it becomes an Ecko error carrying the server's own code
and message rather than a generic failure.

## `reply_for(id, text)`

Decode a reply from wire text, checking it belongs to the request we sent.

The id check is what makes a transport that can interleave messages safe: an
SSE channel carries notifications and replies to other requests on the same
stream, and silently accepting the first object that arrives would attribute
someone else's result to this call.

## `is_notification(message)`

True when a decoded message is a notification rather than a reply - it has a
method and no id. A transport reading a shared stream uses this to decide
what to hand back and what to drop.

## `http_transport(url, opts = {})`

An HTTP transport, MCP's "Streamable HTTP" shape: every request is a POST of
one JSON-RPC message, and the reply comes back in the response body.

`opts` takes `headers` (for `Authorization`, which is how hosted MCP servers
authenticate) and `timeout` in seconds.

Needs the **net** capability.

## `body_text(body)`

Pull the JSON out of a response body that may be an SSE frame.

A Streamable HTTP server is allowed to answer a POST with `text/event-stream`
instead of plain JSON, in which case the payload is on a `data:` line. Doing
this here keeps the protocol layer from knowing about either encoding.

## `fake(handler)`

A transport backed by a table of canned replies, for tests and examples.

`handler` takes the decoded request map and returns the reply map. This is
what makes the protocol layer testable offline, which the package guide
requires and a network round trip would prevent.

## `stdio_transport(command, args = [], opts = {})`

A stdio transport: spawn the server and talk to it over its pipes.

  session = mcp.connect(mcp.stdio_transport("npx", ["-y", "@modelcontextprotocol/server-everything"]))

This is how almost every MCP server ships - the client starts the process and
uses the pipes it already has, so there is no port, no URL and nothing to
authenticate. `opts` takes `timeout_ms` (default 30000) for how long to wait
on a reply.

Needs the **exec** capability to start the process. Nothing here touches the
network.

## `expects_reply(text)`

Whether an outgoing message is a request rather than a notification.

Decided from the wire text because that is what the transport has: a request
carries an id, a notification does not.

## `connect(transport, info = {})`

Open a session: send `initialize`, then the `notifications/initialized` the
spec requires before any other call.

`info` names this client to the server (`{ name, version }`). Returns a
session value carrying the transport, the server's reply, and the request-id
counter - pass it to every call below.

## `server_version(session)`

The protocol version the server answered with, or `null` if it did not say.
Worth checking: a server that does not speak our version says so here rather
than failing later on a call it does not implement.

## `server_capabilities(session)`

What the server says it can do - `tools`, `resources`, `prompts` are the keys
worth looking for. Calling into a section the server did not advertise is a
protocol error, so branch on this rather than catching.

## `call(session, method, params = {})`

Send one request and return its result, raising on a JSON-RPC error.

## `notify(session, method, params = {})`

Send a notification: no id, no reply, nothing to wait for.

## `close(session)`

Close the transport. A no-op for HTTP; the seam matters for a transport that
owns a socket or a child process.

## `tools(session)`

The tools the server offers: `[{ name, description, inputSchema }]`.

## `call_tool(session, name, args = {})`

Call a tool by name. `args` is the argument map its `inputSchema` describes.

Returns the raw result, which carries `content` and may carry `isError`. Use
`text_of` for the common case of a tool that answers with text.

## `text_of(result)`

The text parts of a tool result, joined.

MCP returns content as a list of typed parts (`text`, `image`, `resource`);
this takes the text ones and leaves the rest, because a caller that wants an
image should reach into `content` deliberately rather than get a surprise.

## `is_error(result)`

True when the server flagged the tool result as an error. This is *not* a
JSON-RPC error - the call succeeded and the tool itself failed, which the
spec models as data so a model can read the failure and retry.

## `resources(session)`

The resources the server exposes: `[{ uri, name, mimeType }]`.

## `read_resource(session, uri)`

Read one resource by URI. Returns `[{ uri, mimeType, text }]`.

## `prompts(session)`

The prompt templates the server offers: `[{ name, description, arguments }]`.

## `get_prompt(session, name, args = {})`

Render a prompt template. Returns the server's `messages` list.

## `MAX_PAGES`

How many pages of a `*/list` to follow before giving up on a server that
never stops paginating.

## `as_tools(session)`

The server's tools as specs `ai ... using` can take.

  session = mcp.connect(mcp.http_transport(url))
  answer = ai "what changed in the changelog?" using mcp.as_tools(session)

This is the point of the package: the model picks a tool, Ecko calls it over
MCP, and the result goes back into the conversation. Without it a caller has
to wire each tool up by hand.

The parameter names come from the tool's own `inputSchema`, so the model is
told what the server says it accepts.

## `as_tool(session, t)`

One declared tool as a spec. Useful when a server offers fifty and the
program should only expose three.
The `call` closure holds the session, so invoking the tool is a round trip to
the server rather than anything local.

## `schema_params(schema)`

The argument names a JSON Schema declares, in a stable order.

Sorted because Ecko maps are unordered: leaving it to iteration order would
give the model a different signature run to run.

## `cancel(session, request_id, reason = "")`

Tell the server to stop working on a request.

MCP models cancellation as a notification, not a request: there is nothing to
wait for and no acknowledgement. The server may already have finished, in
which case it ignores this - which is why a caller must not treat sending it
as proof the work stopped.

## `next_request_id(session)`

The id the next `call` on this session will use.

Needed to cancel: the id has to be known before the request is sent, and
`call` allocates it internally.

## `tool(name, description, schema, handler)`

Declare a tool: a name, a description the model reads, a JSON Schema for its
arguments, and the function to run.

`handler` takes the decoded argument map and returns either a string (the
common case) or a content list built with `text`.

## `text(value)`

Wrap a value as MCP text content: `[{ type: "text", text: ... }]`.

MCP returns content as a list of typed parts, so even a one-line answer is a
list. `handle` wraps a bare string for you; this is for a handler returning
several parts deliberately.

## `tool_error(message)`

Report a tool failure.

This is *not* a JSON-RPC error. The call succeeded and the tool failed, which
MCP models as data on purpose so a model can read the failure and try
something else. A JSON-RPC error means the call was rejected outright.

## `resource(uri, name, mime_type, reader)`

Declare a resource: something a client can read by URI.

`reader` takes no arguments and returns the body as a string. Lazy on
purpose - a server listing fifty documents should not read fifty files to
answer `resources/list`.

## `prompt(name, description, arguments, renderer)`

Declare a prompt template.

`renderer` takes the decoded argument map and returns either a string (which
becomes one user message) or a full `messages` list.

## `handle(request, offer, info = {})`

Answer one decoded JSON-RPC request. Returns the reply map, or `null` for a
notification, which by definition gets no reply.

`offer` is what this server exposes: `{ tools, resources, prompts }`, each
optional. A bare list is taken as the tools, which is what almost every
server offers and keeps the common call short.

`info` is `{ name, version }` for this server.

## `PAGE_SIZE`

How many entries one `*/list` page carries.

MCP leaves the size to the server. Small enough that pagination is exercised
rather than theoretical, large enough that an ordinary server sends one page.

## `find_tool(tools, name)`

Find a declared tool by name, or null.

## `progress(token, done, total = null)`

Report progress on a long-running request.

`token` is the `progressToken` the client sent in the request's `_meta`;
without one the client did not ask for progress and this returns null rather
than sending a notification nobody is listening for.

## `progress_token(request)`

The progress token a request carries, or null if the client did not ask.

## `tools_changed()`

Announce that the tool list changed, so a client can re-read it.

A session holds whatever `tools/list` returned when it connected; without
this a server that gains or loses a tool is talking to a stale client.

## `resources_changed()`

The same for resources and prompts.

## `prompts_changed()`

The same, for the prompt list.

## `serve_stdio(tools, info = {})`

Serve over stdio: one JSON-RPC message per line on standard input, one reply
per line on standard output.

This is the transport Claude Desktop and every local MCP server uses - the
client spawns the program and talks to it over the pipes it already has, so
there is no port, no URL and nothing to authenticate.

Needs **no capability**: standard input is handed to the process by whoever
started it, the same way its arguments are.

  import mcp_server as srv
  srv.serve_stdio([srv.tool(...)], { name: "my-server", version: "1.0" })

Blocks until standard input closes, which is how the client says goodbye.

## `serve_http(port, tools, info = {})`

Serve over HTTP: one JSON-RPC message per POST body, the reply in the
response body. MCP's Streamable HTTP shape, minus the optional SSE channel.

Needs the **net** capability.

## `handle_text(text, tools, info = {})`

Decode one message, answer it, and encode the reply. `null` when the message
was a notification.

Malformed JSON is answered rather than thrown: a client that sends garbage
should get a parse error back, not a dropped connection.
