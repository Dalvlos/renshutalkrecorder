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
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        
        // 🔑 Centralização horizontal e vertical
        textView.textAlignment = .center
        textView.font = UIFont.systemFont(ofSize: fontSize)
        textView.textColor = .label
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.textAlignment = .center
        uiView.font = UIFont.systemFont(ofSize: fontSize)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CenteredTextEditor
        init(_ parent: CenteredTextEditor) {
            self.parent = parent
        }
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}
