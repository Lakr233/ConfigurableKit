@testable import ConfigurableKit
import Foundation
import Testing

struct SeparatorViewTests {
    @Test func separatorCoversWholePixels() {
        // 0.5 pt is 1.5 px at 3x, which rounds to 2 px.
        #expect(abs(SeparatorView.pixelAlignedHeight(scale: 3) * 3 - 2) < 1e-9)
        #expect(SeparatorView.pixelAlignedHeight(scale: 2) == 0.5)
        // Never thinner than one pixel.
        #expect(SeparatorView.pixelAlignedHeight(scale: 1) == 1)
    }

    @Test func unknownScaleKeepsDefaultHeight() {
        #expect(SeparatorView.pixelAlignedHeight(scale: 0) == SeparatorView.defaultHeight)
        #expect(SeparatorView.pixelAlignedHeight(scale: .nan) == SeparatorView.defaultHeight)
    }
}

#if canImport(UIKit)
    import UIKit

    @MainActor
    struct StackScrollControllerSeparatorTests {
        final class Page: StackScrollController {
            override func setupContentViews() {
                super.setupContentViews()
                for index in 0 ..< 6 {
                    let label = UILabel()
                    label.text = "Row \(index)"
                    // Heights that are not whole pixels at 3x put the
                    // separators at different places on the pixel grid.
                    label.heightAnchor.constraint(equalToConstant: 44 + CGFloat(index) / 3).isActive = true
                    stackView.addArrangedSubview(label)
                    stackView.addArrangedSubview(SeparatorView())
                }
            }
        }

        @Test func everySeparatorHasTheSameWholePixelHeight() throws {
            let page = Page()
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
            window.rootViewController = page
            window.isHidden = false
            defer { window.isHidden = true }
            page.view.setNeedsLayout()
            page.view.layoutIfNeeded()

            let scale = page.view.window?.windowScene?.screen.scale ?? page.traitCollection.displayScale
            try #require(scale > 0)
            let separators = page.stackView.arrangedSubviews.compactMap { $0 as? SeparatorView }
            #expect(separators.count == 6)
            for separator in separators {
                let pixels = separator.frame.height * scale
                #expect(abs(pixels - pixels.rounded()) < 0.001)
                #expect(separator.frame.height == SeparatorView.pixelAlignedHeight(scale: scale))
            }
        }
    }
#endif
