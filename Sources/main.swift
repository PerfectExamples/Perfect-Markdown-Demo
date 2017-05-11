//
//  main.swift
//  Markdown Demo
//
//  Created by Rockford Wei on 2017-05-10.
//	Copyright (C) 2017 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2017 - 2018 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMarkdown

func handler(data : [String: Any]) throws -> RequestHandler {
  return {
    request, response in
    let markdown = request.postBodyString?.markdownToHTML ?? ""
    response.setHeader(.contentType, value: "text/html").appendBody(string: markdown).completed()
  }
}

let confData = [
  "servers": [
    [
      "name": "localhost",
      "port": 8080,
      "routes": [
        ["method":"post", "uri":"/api", "handler": handler],
        ["method":"get", "uri":"/**", "handler": PerfectHTTPServer.HTTPHandler.staticFiles,
         "documentRoot": "./webroot"]
      ]
    ]
  ]
]

do {
  try HTTPServer.launch(configurationData: confData)
}catch{
  fatalError("\(error)")
}
