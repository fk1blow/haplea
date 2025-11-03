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

Headings must start on the first character of a line...

- get current char
- if it's a Heading consume it
- else consume as Text

what happens if i find a heading(starts with) in the middle of a line?
**that shouldn't be a heading**
