# AGENTS.md

## What this is

`SwiftyEMVTags` is a Swift Package Manager library that turns parsed BER-TLV
data (from the sibling package
[`swifty-ber-tlv`](https://github.com/kaphacius/swifty-ber-tlv)) into
decoded, human-readable EMV tags. It's a pure data/decoding library — no UI,
no networking. Given a `BERTLV` value, it looks up what the tag means (per
EMV kernel spec), decodes its byte-level bitfields, and produces a structured
`EMVTag` with names and meanings instead of raw hex.

Typical consumer: a card/terminal debugging tool that has already parsed a
TLV blob (e.g. from an EMV transaction log or APDU trace) and wants to render
it as readable tag names, byte breakdowns, and enum/bitmap meanings.

## How it works

### Pipeline

1. Caller has a `BERTLV` (tag/length/value, possibly constructed with
   subtags) from `swifty-ber-tlv`.
2. `TagDecoder.decodeBERTLV(_:)` runs the tag against every *active kernel*
   (`KernelInfo`) and merges the results into an `EMVTag`.
3. Each `KernelInfo` knows its own set of tags (`TagDecodingInfo`) — general
   EMVco tags plus scheme-specific ones (Visa, Mastercard, Amex, JCB, etc).
   It finds a matching tag definition by tag number (and optional `context`,
   for tags whose meaning depends on their parent tag).
4. If the matched tag has byte-level rules (`ByteInfo`/`ByteInfo.Group`), the
   value bytes are decoded bit-by-bit into `EMVTag.DecodedByte` /
   `DecodedByte.Group` (bitmap, enum, hex, bool, or RFU groups).
5. Otherwise, `TagMapper` is checked for a whole-value mapping (e.g. tag `9C`
   byte `00` → "Purchase transaction"), or the value is treated as ASCII, or
   parsed as a Data Object List (DOL), depending on `TagInfo` metadata.
6. Constructed tags recurse: subtags are decoded the same way, with the
   parent tag's number passed down as `context`.
7. If multiple kernels claim the same tag with different meanings, the
   result becomes `.multipleKernels(...)` instead of `.singleKernel(...)`
   (resolved by context when possible — see
   `Array<EMVTag.DecodingResult>.flattenDecodingResults` in
   `TagDecoder.swift`).

### Key types

- `EMVTag` (`EMVTag/EMVTag.swift`) — the decoded result: the original
  `BERTLV`, its `Category` (`.plain` or `.constructed(subtags:)`), and a
  `DecodingResult` (`.unknown`, `.singleKernel`, `.multipleKernels`).
- `TagDecoder` (`Decoding/TagDecoder.swift`) — orchestrates decoding across
  all active `KernelInfo`s and a `TagMapper`. `TagDecoder.defaultDecoder()`
  loads all bundled kernel/mapping JSON. Kernels can be added/removed at
  runtime via `addKernelInfo`/`removeKernelInfo`.
- `KernelInfo` (`Info/KernelInfo.swift`) — one kernel's (or "general"'s) list
  of known tags (`TagDecodingInfo`), plus logic to match a tag/context and
  produce a `DecodedTag`.
- `TagInfo` (`Info/TagInfo.swift`) — static metadata for a tag: name,
  description, source, format, length bounds, owning kernel, optional
  `context`, and whether it's a DOL.
- `ByteInfo` / `ByteInfo.Group` (`Info/ByteInfo.swift`,
  `Info/ByteInfoGroup.swift`) — declarative bit-level decoding rules for one
  byte: named bit ranges (`pattern`), each typed as `.bitmap` (independent
  flag-style meanings), `.enumeration` (discrete named values), `.hex`,
  `.bool`, or `.RFU`.
- `DecodedByte` / `DecodedByte.Group` (`Decoding/DecodedByte.swift`) — the
  runtime result of applying a `ByteInfo` to an actual byte value.
- `TagMapper` / `TagMapping` (`Mapping/TagMapper.swift`,
  `Mapping/TagMapping.swift`) — whole-value lookups for tags where the value
  is a single discrete code rather than a bitfield (e.g. Transaction Type
  `9C`).
- `DecodedDataObject` (`Decoding/DecodedDataObject.swift`) — decoded entry
  of a Data Object List (DOL), used for tags marked `isDOL`.

### Data-driven design

All EMV tag knowledge lives in bundled JSON resources, not in Swift code —
adding/fixing tag support usually means editing JSON, not Swift:

- `Sources/SwiftyEMVTags/Resources/KernelInfo/ki_*.json` — one file per
  kernel (`general`, `kernel1`…`kernel5`, matching Visa/Mastercard/Amex/JCB/
  JCB+Visa kernels per EMV Book C). Each defines `TagDecodingInfo` entries:
  tag number, `TagInfo` metadata, and optional `bytes: [ByteInfo]` for
  byte/bit-level decoding.
- `Sources/SwiftyEMVTags/Resources/TagMapping/tm_*.json` — one file per tag
  needing whole-value mapping (e.g. `tm_9c.json`, `tm_9f06.json`), each a
  `TagMapping` with a `value → meaning` dictionary.

Both are loaded via `Bundle.module` at runtime (`Utils/Helpers.swift`,
`defaultJSONResources`), matched by filename prefix (`ki_`/`tm_`). The whole
`Resources` directory is already registered as a package resource
(`Package.swift`), so a new JSON file dropped into the right folder is
picked up automatically by `TagDecoder.defaultDecoder()` /
`TagMapper.defaultMapper()` without touching Swift code.

Byte-pattern fields in the JSON (e.g. `"pattern": "00110000"`) are decoded
via `decodeIntegerFromString(radix:)` helpers, and the lowest N set bits of a
group's `pattern` determine both which bits are extracted from the byte and
the group's bit width (`UInt8.extractingBits(with:)` in
`Utils/UInt8Extensions.swift`).

## Working in this repo

- Build: `swift build`. Test: `swift test`.
- Tests mirror the source layout under `Tests/SwiftyEMVTagsTests/` (one test
  file per source file/concern) and include their own `Resources/` fixtures
  plus a `Helpers.swift` for shared test utilities.
- When adding a new tag or fixing a decoding rule, prefer editing/adding a
  JSON file under `Resources/KernelInfo` or `Resources/TagMapping` over
  writing new Swift decoding logic — the Swift types are already generic
  over the JSON schema.
- Tag/pattern/context numeric fields in JSON are hex or binary *strings*
  (e.g. `"tag": "9F06"`, `"pattern": "00110000"`), decoded via the
  `decodeIntegerFromString(radix:)` helpers — keep new entries consistent
  with that convention.
