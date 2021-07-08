//
//  ContentView.swift
//  ShazamClone
//
//  Created by Emmanuel Kehinde on 03/07/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ShazamView().environmentObject(ShazamViewModel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
