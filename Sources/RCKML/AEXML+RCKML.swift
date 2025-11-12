//
//  AEXML+RCKML.swift
//  RCKML
//
//  Created by Ryan Linn on 11/2/25.
//

import AEXML

extension AEXMLElement {

    var idAttribute: String? { attributes["id"] }

    /// <#Description#>
    /// 
    /// - Parameter kmlObject: <#kmlObject description#>
    convenience init<K: KMLCodableObject>(kmlObject: K) {
        let baseAttributes = ["id" : kmlObject.id].compactMapValues(\.self)
        self.init(name: K.kmlTag, attributes: baseAttributes)

        for child in kmlObject.children {
            addChild(child.xmlElement)
        }
    }

    // MARK: Decoder Functions
    
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - key: <#key description#>
    /// - Returns: <#description#>
    func value<K: KMLValue>(of type: K.Type, forKey key: KMLTagName) throws -> K {
        let item = self[key.name]
        if let error = item.error {
            throw error
        }
        let typedValue = try K(kmlString: item.string)
        return typedValue
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - key: <#key description#>
    /// - Returns: <#description#>
    func valueIfPresent<K: KMLValue>(of type: K.Type, forKey key: KMLTagName) -> K? {
        try? value(of: type, forKey: key)
    }
    
    /// <#Description#>
    ///
    /// - Parameter type: <#type description#>
    ///
    /// - Returns: <#description#>
    func children<K: KMLCodableObject>(of type: K.Type) -> [K] {
        allDescendants(where: { $0.name == K.kmlTag })
            .compactMap { try? K(xml: $0) }
    }

    func firstChild<K: KMLCodableObject>(ofType type: K.Type) throws -> K {
        let xml = self[type.kmlTag]
        if let error = xml.error {
            throw error
        }
        let kmlType = try K(xml: xml)
        return kmlType
    }

    // MARK: Encoder Functions
    
    /// <#Description#>
    /// - Parameters:
    ///   - value: <#value description#>
    ///   - key: <#key description#>
    func setValue<K: KMLValue>(_ value: K?, forKey key: KMLTagName) {
        guard let value else {
            return
        }
        addChild(name: key.name, value: value.kmlString)
    }

    func addChild<K: KMLCodableObject>(_ child: K?) {
        guard let child else {
            return
        }
        let xmlChild = AEXMLElement(kmlObject: child)
        addChild(xmlChild)
    }

// MARK: For Removal

    /// Shorthand for getting a known child element from AEXMLElement.
    ///
    /// Only call this function if you are certain that this XML element
    /// contains a child of the given name.
    ///
    /// - Parameter name: the name of the child tag to be returned.
    /// - Throws: XML error
    /// - Returns: The first child element of this XML element that has the given name.
    func requiredXmlChild(name: String) throws -> AEXMLElement {
        let subItem = self[name]
        if let error = subItem.error {
            throw error
        }
        return subItem
    }
}
