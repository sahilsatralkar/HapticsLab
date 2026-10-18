import Foundation
import SwiftUI

nonisolated enum HapticNumberInput {
    enum InputError: LocalizedError, Equatable {
        case empty, invalidNumber, nonFinite, tooSmall, outsideRange, positiveRequired

        var errorDescription: String? {
            switch self {
            case .empty: "Enter a value."
            case .invalidNumber: "Enter a number without units or grouping separators."
            case .nonFinite: "Enter a finite number."
            case .tooSmall: "This number is too small to represent. Enter zero explicitly or a larger value."
            case .outsideRange: "Enter a value within the allowed range."
            case .positiveRequired: "Duration must be greater than zero."
            }
        }
    }

    static func text(for value: Double, locale: Locale) -> String {
        // Round-trip the stored Double; opening and saving must not round slider values.
        String(value).replacingOccurrences(of: ".", with: locale.decimalSeparator ?? ".")
    }

    static func parse(_ text: String, range: ClosedRange<Double>,
                      requiresPositive: Bool = false, locale: Locale) throws -> Double {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw InputError.empty }
        guard trimmed.count <= 256 else { throw InputError.invalidNumber }
        let separator = locale.decimalSeparator ?? "."
        var normalized = trimmed
        if separator != "." {
            // Accept the keyboard's separator or a pasted Swift decimal, but not both.
            guard !(trimmed.contains(separator) && trimmed.contains(".")) else {
                throw InputError.invalidNumber
            }
            normalized = normalized.replacingOccurrences(of: separator, with: ".")
        }
        normalized = normalized.map { character in
            if character.unicodeScalars.count == 1,
               let scalar = character.unicodeScalars.first,
               CharacterSet.decimalDigits.contains(scalar),
               let digit = character.wholeNumberValue {
                return String(digit)
            }
            return String(character)
        }.joined()
        let grammar = #"^[+-]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?$"#
        guard normalized.range(of: grammar, options: .regularExpression) != nil else {
            throw InputError.invalidNumber
        }
        guard let value = Double(normalized), value.isFinite else { throw InputError.nonFinite }
        let significand = normalized.lowercased().split(separator: "e", maxSplits: 1)[0]
        if value == 0 && significand.contains(where: { "123456789".contains($0) }) {
            throw InputError.tooSmall
        }
        guard range.contains(value) else { throw InputError.outsideRange }
        guard !requiresPositive || value > 0 else { throw InputError.positiveRequired }
        return value
    }
}

struct HapticValueEditor: View {
    let title: LocalizedStringResource
    @Binding var value: Double
    let range: ClosedRange<Double>
    let requiresPositive: Bool
    let seconds: Bool
    let locale: Locale
    let additionalValidation: ((Double) -> String?)?

    @State private var text: String
    @State private var hasEdited = false
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(title: LocalizedStringResource, value: Binding<Double>, range: ClosedRange<Double>,
         requiresPositive: Bool, seconds: Bool, locale: Locale,
         additionalValidation: ((Double) -> String?)? = nil) {
        self.title = title
        _value = value
        self.range = range
        self.requiresPositive = requiresPositive
        self.seconds = seconds
        self.locale = locale
        self.additionalValidation = additionalValidation
        _text = State(initialValue: HapticNumberInput.text(for: value.wrappedValue, locale: locale))
    }

    private var validationMessage: String? {
        do {
            let parsed = try HapticNumberInput.parse(text, range: range,
                                           requiresPositive: requiresPositive, locale: locale)
            return additionalValidation?(parsed)
        } catch { return error.localizedDescription }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        TextField("Value", text: $text)
                            .keyboardType(.decimalPad)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($isFocused)
                            .submitLabel(.done)
                            .onSubmit(save)
                            .accessibilityIdentifier("custom.value.text")
                        if seconds { Text("s").foregroundStyle(.secondary) }
                    }
                } footer: {
                    VStack(alignment: .leading) {
                        if requiresPositive {
                            Text("Greater than zero, up to \(HapticNumberInput.text(for: range.upperBound, locale: locale)).")
                        } else {
                            Text("Allowed range: \(HapticNumberInput.text(for: range.lowerBound, locale: locale)) to \(HapticNumberInput.text(for: range.upperBound, locale: locale)).")
                        }
                        if hasEdited, let validationMessage {
                            Text(validationMessage)
                                .foregroundStyle(.red)
                                .accessibilityIdentifier("custom.value.error")
                        }
                    }
                }
            }
            .navigationTitle(Text(title))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .accessibilityIdentifier("custom.value.save")
                }
            }
            .onChange(of: text) { _, _ in hasEdited = true }
            .onAppear { isFocused = true }
        }
        .presentationDetents([.medium, .large])
    }

    private func save() {
        do {
            let parsed = try HapticNumberInput.parse(text, range: range,
                                                    requiresPositive: requiresPositive, locale: locale)
            guard additionalValidation?(parsed) == nil else { hasEdited = true; return }
            value = parsed
            dismiss()
        } catch {
            hasEdited = true
        }
    }
}
