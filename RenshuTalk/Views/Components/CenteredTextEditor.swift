//
//  CenteredTextEditor.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/08/29.
//


import SwiftUI

struct CenteredTextEditor: UIViewRepresentable {
    @Binding var text: String
    var fontSize: CGFloat
    var maxWidth: CGFloat = 300 // Personalize conforme o layout da sua tela
    var horizontalPadding: CGFloat = 20

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        textView.font = UIFont.systemFont(ofSize: fontSize)
        textView.textColor = .label
        textView.textContainer.lineFragmentPadding = horizontalPadding
        textView.textContainerInset = .zero
        textView.isScrollEnabled = false
        textView.setContentOffset(.zero, animated: false)
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.autocorrectionType = .default
        textView.autocapitalizationType = .sentences
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.textAlignment = .center
        uiView.font = UIFont.systemFont(ofSize: fontSize)
        uiView.textContainer.lineFragmentPadding = horizontalPadding
        uiView.textContainer.lineBreakMode = .byWordWrapping

        // Limite máximo de largura
        let limitedWidth = min(uiView.frame.width, maxWidth)
        let textHeight = uiView.sizeThatFits(CGSize(width: limitedWidth, height: .greatestFiniteMagnitude)).height
        let viewHeight = uiView.frame.height

        // Centralização vertical quando possível
        if textHeight <= viewHeight {
            let topInset = max((viewHeight - textHeight) / 2, 0)
            uiView.textContainerInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
            uiView.isScrollEnabled = false
        } else {
            uiView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            uiView.isScrollEnabled = true
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CenteredTextEditor
        init(_ parent: CenteredTextEditor) { self.parent = parent }
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

