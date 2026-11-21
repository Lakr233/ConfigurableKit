#if canImport(UIKit)
    @testable import ConfigurableKit
    import Testing
    import UIKit

    @MainActor
    struct ConfigurableViewValuePlacementTests {
        final class ValueRow: ConfigurableView {
            var button: EasyHitButton {
                contentView as! EasyHitButton
            }

            override class func createContentView() -> UIView {
                EasyHitButton()
            }

            func configure(value: String) {
                button.titleLabel?.numberOfLines = 1
                button.titleLabel?.lineBreakMode = .byTruncatingMiddle
                button.contentHorizontalAlignment = .trailing
                button.setTitle(value, for: .normal)
            }
        }

        private func makeRow(value: String, description: String = "An explanation of what this row shows.") -> ValueRow {
            let row = ValueRow()
            row.configure(title: "Title")
            row.configure(description: description)
            row.configure(value: value)
            return row
        }

        private func layout(_ row: UIView, width: CGFloat) -> CGSize {
            let size = row.systemLayoutSizeFitting(
                CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            row.frame = CGRect(origin: .zero, size: CGSize(width: width, height: size.height))
            row.layoutIfNeeded()
            return size
        }

        @Test func shortValueStaysBesideTitle() {
            let row = makeRow(value: "On")
            _ = layout(row, width: 340)
            #expect(!row.isValueBelowTitle)
            #expect(row.axis == .horizontal)
            #expect(row.button.titleLabel?.numberOfLines == 1)
        }

        @Test func longValueMovesBelowTitleAndWraps() {
            let row = makeRow(value: "04 A2 B3 C4 D5 E6 90 11 22 33 44 55 66 77 88 99 AA BB CC")
            _ = layout(row, width: 340)
            #expect(row.isValueBelowTitle)
            #expect(row.axis == .vertical)
            #expect(row.button.titleLabel?.numberOfLines == 0)
            #expect(row.button.contentHorizontalAlignment == .leading)
            // Title, then value, then explanation.
            #expect(row.arrangedSubviews == [row.verticalStack, row.contentContainer, row.descriptionLabel])
            // The value is not cut off: its frame is as tall as its wrapped title.
            let label = try! #require(row.button.titleLabel)
            let needed = label.sizeThatFits(CGSize(width: row.button.bounds.width, height: .greatestFiniteMagnitude)).height
            #expect(row.button.bounds.height + 0.5 >= ceil(needed))
        }

        @Test func valueBesideTitleNeverTruncatesTheTitle() {
            // Values just short of and just past what fits beside the title, in a
            // row held at a fixed width like a table cell: either the title and the
            // value both show in full beside each other, or the value moves under
            // the title.
            for style in [ConfigurableDescriptionStyle.hidden, .full] {
                for length in stride(from: 10, through: 60, by: 1) {
                    let row = makeRow(value: String(repeating: "8", count: length))
                    row.configure(title: "Technical")
                    row.descriptionStyle = style
                    let host = UIView(frame: CGRect(x: 0, y: 0, width: 340, height: 600))
                    host.addSubview(row)
                    row.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        row.leadingAnchor.constraint(equalTo: host.leadingAnchor),
                        row.trailingAnchor.constraint(equalTo: host.trailingAnchor),
                        row.topAnchor.constraint(equalTo: host.topAnchor),
                    ])
                    host.layoutIfNeeded()
                    host.layoutIfNeeded()
                    #expect(row.bounds.width == 340)
                    guard !row.isValueBelowTitle else { continue }
                    let title = row.titleLabel
                    #expect(
                        title.bounds.width + 0.5 >= ceil(title.intrinsicContentSize.width),
                        "title cut off beside a \(length)-character value (\(style))"
                    )
                    #expect(
                        row.button.bounds.width + 0.5 >= ceil(row.button.intrinsicContentSize.width),
                        "value cut off beside the title (\(length) characters, \(style))"
                    )
                }
            }
        }

        @Test func valueReturnsBesideTitleWhenRowWidens() {
            let row = makeRow(value: "Nov 21, 2026 at 9:10:38 PM")
            _ = layout(row, width: 300)
            #expect(row.isValueBelowTitle)
            _ = layout(row, width: 900)
            #expect(!row.isValueBelowTitle)
            #expect(row.axis == .horizontal)
            #expect(row.verticalStack.arrangedSubviews == [row.headerStackView, row.descriptionLabel])
            // The row's own line settings come back.
            #expect(row.button.titleLabel?.numberOfLines == 1)
            #expect(row.button.titleLabel?.lineBreakMode == .byTruncatingMiddle)
            #expect(row.button.contentHorizontalAlignment == .trailing)
        }

        @Test func trailingPlacementKeepsOldLayout() {
            let row = makeRow(value: "04 A2 B3 C4 D5 E6 90 11 22 33 44 55 66 77 88 99 AA BB CC")
            row.valuePlacement = .trailing
            _ = layout(row, width: 340)
            #expect(!row.isValueBelowTitle)
            #expect(row.axis == .horizontal)
        }

        @Test func belowTitlePlacementAlwaysMovesValue() {
            let row = makeRow(value: "On")
            row.valuePlacement = .belowTitle
            _ = layout(row, width: 900)
            #expect(row.isValueBelowTitle)
        }

        @Test func switchStaysBesideLongTitle() {
            let row = ConfigurableToggleView(storage: .init(key: "test.toggle", defaultValue: .init(true), storage: UserDefaultKeyValueStorage(suite: .standard)))
            row.configure(title: "A very long title that would need far more room than a narrow row has to offer")
            row.configure(description: "")
            _ = layout(row, width: 300)
            #expect(!row.isValueBelowTitle)
        }

        @Test func descriptionStyles() {
            let row = makeRow(value: "On")
            #expect(row.effectiveDescriptionStyle == .full)
            #expect(row.descriptionLabel.numberOfLines == 0)

            row.descriptionStyle = .singleLine
            #expect(row.descriptionLabel.numberOfLines == 1)
            #expect(!row.descriptionLabel.isHidden)

            row.descriptionStyle = .hidden
            #expect(row.descriptionLabel.isHidden)
            // VoiceOver still reads the explanation.
            #expect(row.titleLabel.accessibilityHint == "An explanation of what this row shows.")

            row.descriptionStyle = .full
            #expect(!row.descriptionLabel.isHidden)
            #expect(row.descriptionLabel.numberOfLines == 0)
        }

        @Test func emptyExplanationStaysHidden() {
            let row = makeRow(value: "On", description: "")
            row.descriptionStyle = .hidden
            row.descriptionStyle = .full
            #expect(row.descriptionLabel.isHidden)
        }

        @Test func hiddenExplanationGivesValueMoreRoom() {
            // About 200 points: below the title beside an explanation in a 340 point row,
            // beside the title once the explanation is hidden.
            let row = makeRow(value: "Nov 21, 2026 at 9:10 PM")
            _ = layout(row, width: 340)
            #expect(row.isValueBelowTitle)
            row.descriptionStyle = .hidden
            _ = layout(row, width: 340)
            #expect(!row.isValueBelowTitle)
        }

        @Test func pageStyleAppliesToRowsWithoutTheirOwn() {
            let controller = StackScrollController()
            let following = makeRow(value: "On")
            let own = makeRow(value: "On")
            own.descriptionStyle = .full
            controller.loadViewIfNeeded()
            controller.stackView.addArrangedSubview(following)
            controller.stackView.addArrangedSubview(own)

            controller.descriptionStyle = .hidden
            #expect(following.descriptionLabel.isHidden)
            #expect(!own.descriptionLabel.isHidden)

            controller.descriptionStyle = nil
            #expect(!following.descriptionLabel.isHidden)
        }

        @Test func pageStyleAppliesWhenRowJoinsWindow() {
            let controller = StackScrollController()
            controller.descriptionStyle = .singleLine
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
            window.rootViewController = controller
            window.isHidden = false
            let row = makeRow(value: "On")
            controller.stackView.addArrangedSubview(row)
            #expect(row.effectiveDescriptionStyle == .singleLine)
            #expect(row.descriptionLabel.numberOfLines == 1)
            window.isHidden = true
        }

        @Test func objectStyleReachesItsView() {
            let object = ConfigurableObject(
                icon: "number",
                title: "UID",
                explain: "Unique identifier.",
                key: "test.object.uid",
                defaultValue: true,
                annotation: .toggle
            ).withDescriptionStyle(.hidden)
            let view = object.createView()
            #expect(view.descriptionStyle == .hidden)
            #expect(view.descriptionLabel.isHidden)
        }

        @Test func sectionHeaderIsLeftAlone() {
            let header = ConfigurableSectionHeaderView().with(rawHeader: "Summary")
            _ = layout(header, width: 200)
            #expect(!header.isValueBelowTitle)
        }
    }
#endif
