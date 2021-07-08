//
//  NoResultView.swift
//  ShazamClone
//
//  Created by Emmanuel Kehinde on 03/07/2021.
//

import SwiftUI

struct NoResultView: View {
    var buttonAction: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image(systemName: "headphones.circle")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(Color.black.opacity(0.8))

            Text("No Result Found")
                .font(.headline)
                .foregroundColor(Color.black.opacity(0.8))

            Button(action: {
                buttonAction()
            }, label: {
                Text("Try Again")
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 48, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 24).fill(Color.blue)
                            .shadow(radius: 1)
                    )
            })
        }
    }
}

struct NoResultView_Previews: PreviewProvider {
    static var previews: some View {
        NoResultView(buttonAction: {})
    }
}
