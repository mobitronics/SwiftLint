//
//  PatternMatchingKeywordsRule.swift
//  SwiftLint
//
//  Created by Marcelo Fabri on 08/23/17.
//  Copyright © 2017 Realm. All rights reserved.
//

import Foundation
import SourceKittenFramework

public struct PatternMatchingKeywordsRule: ASTRule, ConfigurationProviderRule {
    public var configuration = SeverityConfiguration(.warning)

    public init() {}

    public static let description = RuleDescription(
        identifier: "pattern_matching_keywords",
        name: "Pattern Matching Keywords",
        description: "Combine multiple pattern matching bindings by moving keywords out of tuples.",
        kind: .idiomatic,
        nonTriggeringExamples: [
        ],
        triggeringExamples: [
        ]
    )

    public func validate(file: File, kind: StatementKind,
                         dictionary: [String: SourceKitRepresentable]) -> [StyleViolation] {
        guard kind == .case else {
            return []
        }

        let contents = file.contents.bridge()
        return dictionary.elements.flatMap { subDictionary -> [StyleViolation] in
            guard subDictionary.kind == "source.lang.swift.structure.elem.pattern",
                let offset = subDictionary.offset,
                let length = subDictionary.length,
                let caseRange = contents.byteRangeToNSRange(start: offset, length: length) else {
                    return []
            }

            let letMatches = file.match(pattern: "let", with: [.keyword], range: caseRange)
            let varMatches = file.match(pattern: "var", with: [.keyword], range: caseRange)

            if !letMatches.isEmpty && !varMatches.isEmpty {
                return []
            }

            guard letMatches.count > 1 || varMatches.count > 1 else {
                return []
            }

            return (letMatches + varMatches).map {
                StyleViolation(ruleDescription: type(of: self).description,
                               severity: configuration.severity,
                               location: Location(file: file, byteOffset: $0.location))
            }
        }
    }
}
