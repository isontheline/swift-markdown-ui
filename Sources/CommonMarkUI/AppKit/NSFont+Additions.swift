#if os(macOS)

    import AppKit

    public extension NSFont {
        static func system(size: CGFloat, weight: Weight = .regular) -> NSFont {
            .systemFont(ofSize: size, weight: weight)
        }

        @available(macOS 10.15, *)
        static func system(size: CGFloat, weight: Weight = .regular, design: NSFontDescriptor.SystemDesign) -> NSFont {
            let font = NSFont.systemFont(ofSize: size, weight: weight)
            return font.withDesign(design) ?? font
        }

        @available(macOS 11.0, *)
        static func system(_ style: TextStyle, design: NSFontDescriptor.SystemDesign = .default) -> NSFont {
            let font = NSFont.preferredFont(forTextStyle: style)
            return font.withDesign(design) ?? font
        }

        static func custom(_ name: String, size: CGFloat) -> NSFont {
            NSFont(name: name, size: size) ?? .system(size: size)
        }
    }

    extension NSFont {
        var weight: Weight {
            fontDescriptor.object(forKey: .traits)
                .flatMap { $0 as? [NSFontDescriptor.TraitKey: Any] }
                .flatMap { $0[.weight] as? CGFloat }
                .map { Weight(rawValue: $0) }
                ?? .regular
        }

        func withWeight(_ weight: NSFont.Weight) -> NSFont? {
            let newDescriptor = fontDescriptor.addingAttributes(
                [
                    .traits: [
                        NSFontDescriptor.TraitKey.weight: weight.rawValue,
                    ],
                ]
            )
            return NSFont(descriptor: newDescriptor, size: pointSize)
        }

        @available(macOS 10.15, *)
        func withDesign(_ design: NSFontDescriptor.SystemDesign) -> NSFont? {
            fontDescriptor.withDesign(design).flatMap {
                NSFont(descriptor: $0, size: $0.pointSize)
            }
        }

        func addingSymbolicTraits(_ traits: NSFontDescriptor.SymbolicTraits) -> NSFont? {
            let newTraits = fontDescriptor.symbolicTraits.union(traits)
            return NSFont(descriptor: fontDescriptor.withSymbolicTraits(newTraits), size: pointSize)
        }

        func monospaced() -> NSFont? {
            if #available(macOS 10.15, *) {
                return NSFont.monospacedSystemFont(ofSize: pointSize, weight: weight)
                    .addingSymbolicTraits(fontDescriptor.symbolicTraits)
            } else {
                return NSFont.userFixedPitchFont(ofSize: pointSize)?
                    .addingSymbolicTraits(fontDescriptor.symbolicTraits.union(.monoSpace))
            }
        }
    }

#endif
