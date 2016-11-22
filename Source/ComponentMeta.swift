//
//  ComponentMeta.swift
//  Matrioska
//
//  Created by Alex Manzella on 16/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import Foundation

/// A protocol to create meta object that provides metadata for a Component
public protocol ComponentMeta {
    
    /// `ComponentMeta` should implement a subscript function
    /// to allow to retreive meta using a keyed subscript.
    /// A default implementation is provided and use reflection
    /// to retreive the values of the object's properties.
    ///
    /// - Parameter key: The key of the meta to retreive
    subscript(key: String) -> Any? { get }
}

extension ComponentMeta {

    /// The default implementation of the subscript uses reflection to mirror the object
    /// if the key represent a property, its value will be returned
    ///
    /// - Parameter key: the key of the value to retreive, must be the name of a property.
    public subscript(key: String) -> Any? {
        let mirror = Mirror(reflecting: self)
        let candidate = mirror.children.first { (child) -> Bool in
            child.label == key
        }
        return candidate?.value
    }
}

/// A protocol to create `ComponentMeta` that also support json/dictionary for materialization.
/// Adopting this protocol `Component`s are able to materialzie a meta
/// using `MaterializableComponentMeta.metarialize(_ )`.
public protocol MaterializableComponentMeta: ComponentMeta {
    
    /// An initializer that takes a meta to retreive the necessary metadata
    /// to build the `ComponentMeta`.
    /// `MaterializableComponentMeta.metarialize(_ )` will then use this initializer, if necessary,
    /// to create the meta object.
    ///
    /// - Parameter meta: An object that conform to `ComponentMeta`
    ///   and contains the desired metadata. A `Dictionary` can also be used.
    init?(meta: ComponentMeta)
}

extension MaterializableComponentMeta {
    
    /// Materialize a meta into the meta object if possible (meta not nil)
    /// and if needed (meta represents already a valid meta object of type `Self`)
    ///
    /// - Parameter meta: A representation of the meta object to materialize (e.g. a dictionary)
    ///   or an already materialized meta object.
    /// - Returns: A materialized meta object if the input represents correctly
    ///   the object to be materialized.
    public static func metarialize(_ meta: ComponentMeta?) -> Self? {
        guard let meta = meta else {
            return nil
        }
        
        if let meta = meta as? Self {
            return meta
        }
        
        return Self(meta: meta)
    }
}

extension Dictionary: ComponentMeta {
    
    /// Forwards the subscript to Dictionary's implementation
    ///
    /// - Parameter key: the key of the value to retreive
    public subscript(key: String) -> Any? {
        if let key = key as? Key {
            return self[key]
        }
        return nil
    }
}

/// Aggregates multiple metas togheter
public struct ZipMeta: ComponentMeta {
    let metas: [ComponentMeta]
    
    /// Initialize a zip meta from multiple `ComponentMeta`
    ///
    /// - Parameter metas: A list of `ComponentMeta`s
    public init(_ metas: ComponentMeta...) {
        self.metas = metas
    }
    
    /// Forward the subscript to the zipped metas in the order they where provided
    ///
    /// - Parameter key: The key of the meta to retreive
    public subscript(key: String) -> Any? {
        for meta in metas {
            if let result = meta[key] {
                return result
            }
        }
        
        return nil
    }
}
