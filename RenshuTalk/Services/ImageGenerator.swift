//
//  ImageGenerator.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/28.
//

import UIKit

func gerarImagemComTexto(_ texto: String, tamanhoImagem: CGFloat = 1080) -> UIImage {
    let size = CGSize(width: tamanhoImagem, height: tamanhoImagem)
    
    let renderer = UIGraphicsImageRenderer(size: size)
    
    return renderer.image { context in
        UIColor.white.setFill()
        context.fill(CGRect(origin: .zero, size: size))
        
        let paragrafo = NSMutableParagraphStyle()
        paragrafo.alignment = .center
        
        let atributos: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 48, weight: .regular),
            .paragraphStyle: paragrafo,
            .foregroundColor: UIColor.black
        ]
        
        let textoFormatado = NSAttributedString(string: texto, attributes: atributos)
        
        let limiteTexto = CGRect(x: 40, y: 0, width: size.width - 80, height: CGFloat.greatestFiniteMagnitude)
        let boundingRect = textoFormatado.boundingRect(with: limiteTexto.size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        
        let origemY = (size.height - boundingRect.height) / 2
        let textoRect = CGRect(x: limiteTexto.minX, y: origemY, width: limiteTexto.width, height: boundingRect.height)
        
        textoFormatado.draw(in: textoRect)
    }
}
