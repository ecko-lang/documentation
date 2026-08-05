# `std.proc`

Run a child process, with a timeout that reaps everything it started.

```ecko
import std.proc

r = proc.run("ffmpeg", ["-i", "in.mp4", "out.mp4"], { timeout_ms: 5000 })
if r.timed_out {
    print("gave up; the whole tree was killed")
} else {
    print("exit {r.code}")
}
```

[`std.os`](./os.md)'s `exec` runs a command to completion with no deadline. This
adds the deadline, and makes it mean something.

## Why the process group matters

Killing a process kills that process. It does not kill what that process
started. So a timeout wrapped around `sh -c "ffmpeg ..."` kills the shell and
leaves ffmpeg running, holding the CPU and the file you were writing.

Measured on a dev box: killing one shell orphaned four `sleep` processes.

A child started here gets its own **process group**, and the deadline signals
the group. The whole tree goes.

**Unix only.** Windows has no process groups in this sense - the equivalent is a
Job Object - so `kill` there reaps the direct child and grandchildren survive.

## Capability

Needs **`exec`**. Spawning a program and signalling its process group is process
control, the same authority `os.exec` and `os.exit` need. See
[capabilities](../packages/capabilities.md).

## API

| call | result |
|---|---|
| `proc.run(cmd, args?, opts?)` | `{ code, stdout, stderr, timed_out }`, after waiting. |
| `proc.spawn(cmd, args?)` | A handle for something long-running. |
| `proc.pid(handle)` | The child's pid, which is also its process-group id. |
| `proc.wait(handle, timeout_ms?)` | A result map, or `null` if still running. |
| `proc.kill(handle, signal?)` | Signals the group. Default `"term"`; also `"kill"`, `"int"`, `"hup"`. |

`opts` is `{ timeout_ms: 5000 }`. Left out, `run` waits as long as it takes.

## Notes

**A deadline sends `SIGTERM` first, then `SIGKILL`** after a short grace. A
well-behaved child gets a chance to clean up; one that ignores TERM is exactly
the case a timeout exists for.

**`timed_out` is a field, not an error.** Whatever the child managed to write
before it died is still on the result, which is usually the part that tells you
why it hung.

**`proc.wait` without a deadline is a poll.** `null` means still running, so a
supervisor loop can check without committing to block.

**Output is drained continuously**, not read after the wait. A child that fills
the 64 KiB pipe buffer blocks on write, so reading late would hang rather than
time out.
