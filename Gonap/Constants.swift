//
//  Constants.swift
//  Gonap
//
//  Created by Antoine Payan on 11/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import Foundation
import MapKit

struct Server
{
    static let url = "http://gonap.erasme.org/api/"
}

struct Texts
{
    static let error = "Erreur"
    static let alertInternetOffline = "Vous n'êtes pas connecté à internet";
    static let waiting = "Veuillez patienter";
    static let ok = "OK"
    static let alertServerProblem = "Erreur de serveur, veuillez réessayer ultérieurement"
    static let notInZone = "Vous ne pouvez fournir des alertes lorsque que vous n'êtes dans aucune zone";
}

struct Colors
{
    static let green = "#00CD75";
    static let redGL = "#DA0000";
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 1)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension CLLocationCoordinate2D {
    
    func contained(by vertices: [CLLocationCoordinate2D]) -> Bool {
        let path = CGMutablePath()
        
        for vertex in vertices {
            if path.isEmpty {
                path.move(to: CGPoint(x: vertex.longitude, y: vertex.latitude))
            } else {
                path.addLine(to: CGPoint(x: vertex.longitude, y: vertex.latitude))
            }
        }
        
        let point = CGPoint(x: self.longitude, y: self.latitude)
        return path.contains(point)
    }
}

