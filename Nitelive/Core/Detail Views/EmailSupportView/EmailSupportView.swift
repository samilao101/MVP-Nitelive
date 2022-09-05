//
//  EmailSupportView.swift
//  Nitelive
//
//  Created by Sam Santos on 9/4/22.
//

import SwiftUI
import UIKit
import MessageUI

struct RequestToAddClub {
    let toAddress: String = "delacruz101@gmail.com"
    let subject: String = "New Club"
    let latitude: String
    let longitude: String
    var body: String { """
     Club Name?:
    
    ______________________________________________
    Latitude: \(latitude), Longitude: \(longitude)
    
    """}
}

struct EmailSupportView: View {
    
    @State var supportInfo: RequestToAddClub
    
    var body: some View {
        MailView(data: $supportInfo) { result in
            print(result)
        }
    }
}



typealias MailViewCallback = ((Result<MFMailComposeResult, Error>) -> Void)?

struct MailView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentation
  @Binding var data: RequestToAddClub
  let callback: MailViewCallback

  class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    @Binding var presentation: PresentationMode
    @Binding var data: RequestToAddClub
    let callback: MailViewCallback

    init(presentation: Binding<PresentationMode>,
         data: Binding<RequestToAddClub>,
         callback: MailViewCallback) {
      _presentation = presentation
      _data = data
      self.callback = callback
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
      if let error = error {
        callback?(.failure(error))
      } else {
        callback?(.success(result))
      }
      $presentation.wrappedValue.dismiss()
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(presentation: presentation, data: $data, callback: callback)
  }

  func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
    let vc = MFMailComposeViewController()
    vc.mailComposeDelegate = context.coordinator
    vc.setSubject(data.subject)
    vc.setToRecipients([data.toAddress])
    vc.setMessageBody(data.body, isHTML: false)
   
    vc.accessibilityElementDidLoseFocus()
    return vc
  }

  func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                              context: UIViewControllerRepresentableContext<MailView>) {
  }

  static var canSendMail: Bool {
    MFMailComposeViewController.canSendMail()
  }
}
