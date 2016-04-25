//
//  SYRouter.swift
//  SYRouter
//
//  Created by wangshiyu13 on 16/4/24.
//  Copyright © 2016年 wangshiyu13. All rights reserved.
//

import UIKit

enum SYRouterType {
    case None, ViewController, Closure
}

typealias SYRouterParamsClosure = [String: AnyObject] -> AnyObject?

class SYRouter {
    static let shared = SYRouter()
    
    func map(route: String, toControllerClass controllerClass: AnyClass) {
        let subRoutes = subRoutesToRoute(route)
        subRoutes["_"] = controllerClass
    }
    
    func matchController(route: String) -> UIViewController {
        var params = paramsInRoute(route)
        if let controllerClass = params?["controller_class"] as? UIViewController.Type {
            let viewController = controllerClass.init()
            let SEL = Selector("setSy_routeParams:")
            if viewController.respondsToSelector(SEL) {
                viewController.performSelector(SEL, withObject: params)
            }
            return viewController
        } else {
            fatalError("控制器不存在")
        }
    }
    
    func map(route: String, toClosure closure: SYRouterParamsClosure) {
        let subRoutes = subRoutesToRoute(route)
        subRoutes["_"] = closure([:])
    }
    
    func matchClosure(route: String) -> SYRouterParamsClosure? {
        var params = paramsInRoute(route)
        if params == nil {
            return nil
        }
        
        let routerClosure = params!["closure"] as? SYRouterParamsClosure
        let returnclosure: SYRouterParamsClosure? = { (aParams: [String: AnyObject]) in
            if routerClosure != nil {
                var dict = params!
                aParams.forEach { (key, value) in
                    dict[key] = value
                }
                return routerClosure!(dict)
            }
            return nil
        }
        
        return returnclosure
    }
    
    func callClosure(route: String) -> AnyObject? {
        var params = paramsInRoute(route)
        let routerBlock = params?["block"] as? SYRouterParamsClosure
        
        if routerBlock != nil {
            return routerBlock?(params!)
        }
        return nil
    }
    
    func canRoute(route: String) -> SYRouterType {
        var params = paramsInRoute(route)
        if params?["controller_class"] != nil {
            return .ViewController
        }
        
        if params?["block"] != nil {
            return .Closure
        }
        
        return .None
    }
    
    /// MARK: - extract params in a route
    func paramsInRoute(route: String) -> [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
    
        params["route"] = stringFromFilterAppUrlScheme(route)
        
        var subRoutes = self.routeDict
        let pathComponents = pathComponentsFromRoute(stringFromFilterAppUrlScheme(route))
        for pathComponent in pathComponents {
            var found = false
            let subRoutesKeys = subRoutes.allKeys as NSArray
            for k in subRoutesKeys {
                let key = k as! NSString
                if subRoutesKeys.containsObject(pathComponent) {
                    found = true
                    subRoutes = subRoutes[pathComponent] as! NSMutableDictionary
                    break
                } else if (key.hasPrefix(":")) {
                    found = true
                    subRoutes = subRoutes[key] as! NSMutableDictionary
                    params[key.substringFromIndex(1)] = pathComponent
                    break
                }
            }
            if (!found) {
                return nil
            }
        }
    
        /// MARK: - Extract Params From Query.
        let firstRange = (route as NSString).rangeOfString("?")
        if (firstRange.location != NSNotFound && route.characters.count > firstRange.location + firstRange.length) {
            let paramsString = (route as NSString).substringFromIndex(firstRange.location + firstRange.length)
            let paramStringArr = paramsString.componentsSeparatedByString("&")
            for paramString in paramStringArr {
                let paramArr = paramString.componentsSeparatedByString("=")
                if (paramArr.count > 1) {
                    let key = paramArr[0]
                    let value = paramArr[1]
                    params[key] = value
                }
            }
        }
    
        let cls = subRoutes["_"]
        if (class_isMetaClass(object_getClass(cls))) {
            if (cls as! AnyClass).isSubclassOfClass(UIViewController.self) {
                params["controller_class"] = subRoutes["_"]
            } else {
                return nil
            }
        } else {
            if subRoutes["_"] != nil {
                params["block"] = subRoutes["_"]
            }
        }
        
        return params
    }
    
    /// MARK: - Private Property & Method
    private let routeDict = NSMutableDictionary()
    
    var appUrlSchemes: [String] = {
        var schemes: [String] = []
        var infos = NSBundle.mainBundle().infoDictionary
        if let types = infos?["CFBundleURLTypes"] as? NSArray {
            for dict in types {
                let scheme = (dict["CFBundleURLSchemes"] as! NSArray).firstObject as! String
                schemes.append(scheme)
            }
        }
        return schemes
    }()
    
    private func pathComponentsFromRoute(route: String) -> [String] {
        let routePath = NSString(string: route)
        var pathComponents: [String] = []
        for str in routePath.pathComponents {
            let strx = NSString(string: str)
            if strx.isEqualToString("/") {
                continue
            }
            if (strx.substringToIndex(1) as NSString).isEqualToString("?") {
                break
            }
            pathComponents.append(strx as String)
        }
        return pathComponents
    }
    
    private func stringFromFilterAppUrlScheme(string: String) -> String {
        for appUrlScheme in appUrlSchemes {
            if string.hasPrefix("\(appUrlScheme):") {
                return (string as NSString).substringFromIndex(appUrlScheme.characters.count + 2)
            }
        }
        return string
    }
    
    private func subRoutesToRoute(route: String) -> NSMutableDictionary {
        let pathComponents = pathComponentsFromRoute(route)
        var index = 0
        var subRoutes = self.routeDict
        
        while index < pathComponents.count {
            let pathComponent = pathComponents[index]
            if subRoutes[pathComponent] == nil {
                subRoutes[pathComponent] = NSMutableDictionary()
            }
            subRoutes = subRoutes[pathComponent] as! NSMutableDictionary
            index += 1
        }
        return subRoutes
    }
}

private var kAssociatedParamsObjectKey: Void?

extension UIViewController {
    var sy_routeParams: [String: AnyObject]? {
        get {
            return objc_getAssociatedObject(self, &kAssociatedParamsObjectKey) as? [String: AnyObject]
        }
        set {
            objc_setAssociatedObject(self, &kAssociatedParamsObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}