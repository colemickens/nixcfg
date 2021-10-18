"""Converts JSON objects into nix (hackishly)."""

import sys
import json


INDENT = " " * 2


def strip_comments(t):
    # fixme: doesn't work if JSON strings contain //
    return "\n".join(l.partition("//")[0] for l in t.split("\n"))


def indent(s):
    return "\n".join(INDENT + i for i in s.split("\n"))


def nix_stringify(s):
    # fixme: this doesn't handle string interpolation and possibly has more bugs
    return json.dumps(s)


def sanitize_key(s):
    if s and s.isalnum() and not s[0].isdigit():
        return s
    return nix_stringify(s)


def flatten_obj_item(k, v):
    keys = [k]
    val = v
    while isinstance(val, dict) and len(val) == 1:
        k = next(iter(val.keys()))
        keys.append(k)
        val = val[k]
    return keys, val


def fmt_object(obj, flatten):
    fields = []
    for k, v in obj.items():
        if flatten:
            keys, val = flatten_obj_item(k, v)
            formatted_key = ".".join(sanitize_key(i) for i in keys)
        else:
            formatted_key = sanitize_key(k)
            val = v
        fields.append(f"{formatted_key} = {fmt_any(val, flatten)};")

    return "{\n" + indent("\n".join(fields)) + "\n}"


def fmt_array(o, flatten):
    body = indent("\n".join(fmt_any(i, flatten) for i in o))
    return f"[\n{body}\n]"


def fmt_any(o, flatten):
    if isinstance(o, str) or isinstance(o, bool) or isinstance(o, int):
        return json.dumps(o)
    if isinstance(o, list):
        return fmt_array(o, flatten)
    if isinstance(o, dict):
        return fmt_object(o, flatten)
    raise TypeError(f"Unknown type {type(o)!r}")


def main():
    flatten = "--flatten" in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith("--")]

    if len(args) < 1:
        print(f"Usage: {sys.argv[0]} [--flatten] <file.json>", file=sys.stderr)
        sys.exit(1)

    with open(args[0], "r") as f:
        data = json.loads(strip_comments(f.read()))

    print(fmt_any(data, flatten=flatten))


if __name__ == "__main__":
    main()
