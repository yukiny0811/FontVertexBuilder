//
//  File.swift
//  FontVertexBuilder
//
//  Created by Yuki Kuwashima on 2025/10/16.
//

import Foundation

public enum CustomError: String, LocalizedError {
    public var errorDescription: String? { self.rawValue }

    case indexOutOfRange
}
