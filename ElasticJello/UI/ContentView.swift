//
//  ContentView.swift
//  ElasticJello
//
//  Created by lingji zhou on 2/4/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            MetalView(renderer: JelloRenderer())
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
