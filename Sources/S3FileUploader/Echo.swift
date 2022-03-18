// Copyright (c) 2022 Bob
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import Foundation

public enum ASCIIColor: String, CaseIterable {
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case magenta = "\u{001B}[0;35m"
    case cyan = "\u{001B}[0;36m"
    case white = "\u{001B}[0;37m"
    case `default` = "\u{001B}[0;0m"
}

func echo(_ items: [Any], color: ASCIIColor = .default) {
    let message = items.reduce(into: "") { $0 = "\($0) \($1)" }
    print("\(color.rawValue)\(message)\(ASCIIColor.default.rawValue)")
}

func echo(_ items: Any..., color: ASCIIColor = .default) {
    echo(items, color: color)
}

func success(_ items: Any...) {
    echo(items, color: .green)
}

func error(_ items: Any...) {
    echo(items, color: .red)
}

func warning(_ items: Any...) {
    echo(items, color: .yellow)
}
