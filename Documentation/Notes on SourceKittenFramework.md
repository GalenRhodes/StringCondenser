# Notes on SourceKittenFramework

## Structure

Given the following line of source code:

```swift
public let MsgUnexpectedEOF:        String = "Unexpected End of Input"
```

And it's corresponding structure JSON from SourceKitten:

```json
{
  "key.accessibility" : "source.lang.swift.accessibility.public",
  "key.attributes" : [
    {
      "key.attribute" : "source.decl.attribute.public",
      "key.length" : 6,
      "key.offset" : 1311
    }
  ],
  "key.kind" : "source.lang.swift.decl.var.global",
  "key.length" : 63,
  "key.name" : "MsgUnexpectedEOF",
  "key.namelength" : 16,
  "key.nameoffset" : 1322,
  "key.offset" : 1318,
  "key.typename" : "String"
}
```

The length shown in "key.length" - 63 - is the length starting at the "let" keyword - not the "public" keyword.

The keyword "public" is actually considered an attribute of the statement.