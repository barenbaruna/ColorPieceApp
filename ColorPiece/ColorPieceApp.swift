//
//  colorooApp.swift
//  Coloroo
//
//  Main app entry point.
//  Sets SplashView as the root view for the launch flow.
//
//  Created by Academy on 03/03/26.
//

import SwiftUI

// MARK: - App Entry Point

@main
struct ColorPieceApp: App {

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
