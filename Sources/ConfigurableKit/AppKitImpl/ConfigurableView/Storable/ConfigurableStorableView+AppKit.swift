#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
    import Combine

    open class ConfigurableStorableView: ConfigurableView {
        @CodableStorage open var value: ConfigurableKitAnyCodable

        public init(storage: CodableStorage) {
            _value = .init(
                key: storage.key,
                defaultValue: storage.defaultValue,
                storage: storage.storage
            )

            super.init(frame: .zero)

            storage.storage.valueUpdatePublisher
                .filter { $0.0 == storage.key }
                .map { _ in () }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.updateValue()
                }
                .store(in: &cancellables)
            updateValue()
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override open class func createContentView() -> NSView {
            NSView()
        }

        open func updateValue() {}
    }
#endif
