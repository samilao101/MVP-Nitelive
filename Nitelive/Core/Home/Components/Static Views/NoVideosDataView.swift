//
//  NoVideosView.swift
//  Nitelive
//
//  Created by Sam Santos on 9/6/22.
//

import SwiftUI

struct NoVideosDataView: View {
    var body: some View {
        Text("""
                  NO VIDEOS YET TONIGHT.
                  
                  Be the first to upload:
                      1. Accept location permission.
                      2. Create an account.
                      2. Go to a club listed.
                      3. Wait until the app recognizes you are in.
                      3. Click on the record button (bottom).
                  """)
        .navigationBarHidden(true)
    }
}

struct NoVideosView_Previews: PreviewProvider {
    static var previews: some View {
        NoVideosDataView()
    }
}
