//
//  SongDetailView.swift
//  ShazamClone
//
//  Created by Emmanuel Kehinde on 03/07/2021.
//

import SwiftUI

struct SongDetailView: View {
    var song: Song

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    AsyncImage(url: song.artworkUrl) { phase in
                        if let image = phase.image {
                            image.resizable()
                                 .aspectRatio(contentMode: .fill)
                                 .frame(maxHeight: 200)
                                 .clipped()
                        } else if phase.error != nil {
                            Color.blue
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(height: 200, alignment: .center)

                    VStack(alignment: .leading) {
                        Text(song.title)
                            .font(.headline)
                            .foregroundColor(Color.black)

                        Text(song.artist)
                            .font(.subheadline)
                            .foregroundColor(Color.black)

                        ScrollView(.horizontal, showsIndicators: false, content: {
                            HStack {
                                ForEach(0..<song.genres.count) { index in
                                    Text(song.genres[index])
                                        .font(.caption)
                                        .padding(4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.gray.opacity(0.3))
                                        )
                                }
                            }
                        })
                    }
                    .padding(.horizontal)
                    .padding(.bottom)

                    if let appleMusicUrl = song.appleMusicUrl {
                        Link(destination: appleMusicUrl, label: {
                            Text("Play on Apple Music ")
                                .font(.system(size: 14, weight: .bold, design: .default))
                                .foregroundColor(.white)
                                .frame(width: geometry.size.width - 64, height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 10).fill(Color.red)
                                        .shadow(radius: 1)
                                )
                        })
                        .padding(.bottom)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: Color.gray.opacity(0.8), radius: 0.8)
                )
                .padding()
            }
        }

    }
}

struct SongDetailView_Previews: PreviewProvider {
    static var previews: some View {
//        SongDetailView()
        Text("")
    }
}
