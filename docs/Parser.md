# Parser

the problem is that the 2-phase lexing it contains too much duplication.

Headings in markdown occupy a single line meaning that i can test it just
by looking at the first char, then consume it.

Could also have an enum, like:

```
const Started = enum {
  Heading,
  Image,
  Code,
  ...
}
```
