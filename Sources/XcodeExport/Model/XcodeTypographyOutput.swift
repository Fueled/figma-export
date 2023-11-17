import Foundation

public struct XcodeTypographyOutput {
    let urls: URLs
    let generateTextStyles: Bool
    let addObjcAttribute: Bool
    let templatesPath: URL?
    
    public struct FontURLs {
        let fontExtensionURL: URL?
        let swiftUIFontExtensionURL: URL?
        public init(
            fontExtensionURL: URL? = nil,
            swiftUIFontExtensionURL: URL? = nil
        ) {
            self.swiftUIFontExtensionURL = swiftUIFontExtensionURL
            self.fontExtensionURL = fontExtensionURL
        }
    }
    
    public struct TextStyleURLs {
        let textStylesDirectory: URL?
        let textStyleExtensionsURL: URL?

        public init(
            textStylesDirectory: URL? = nil,
            textStyleExtensionsURL: URL? = nil
        ) {
            self.textStylesDirectory = textStylesDirectory
            self.textStyleExtensionsURL = textStyleExtensionsURL
        }
    }
    
    public struct URLs {
        public let fonts: FontURLs
        public let textStyles: TextStyleURLs

        public init(
            fonts: FontURLs,
            textStyles: TextStyleURLs
        ) {
            self.fonts = fonts
            self.textStyles = textStyles
        }
    }

    public init(
        urls: URLs,
        generateTextStyles: Bool? = false,
        addObjcAttribute: Bool? = false,
        templatesPath: URL? = nil
    ) {
        self.urls = urls
        self.generateTextStyles = generateTextStyles ?? false
        self.addObjcAttribute = addObjcAttribute ?? false
        self.templatesPath = templatesPath
    }
}
