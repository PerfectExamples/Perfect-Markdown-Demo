//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
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

func TableDemoHandler(data: [String:Any]) throws -> RequestHandler {
  return {
    request, response in
    let markdown = "# Swift调用C语言自建函数库的方法\n\n本程序示范了如何用Swift调用自定义C语言模块的方法。您可以直接下载本程序，或者按照以下教程逐步完成。\n\n## 快速上手\n\n本程序需要Swift 3.0以上版本。\n\n### 下载、编译和测试\n\n```\n$ git clone https://github.com/RockfordWei/CSwift.git\n$ cd CSwift\n$ swift build\n$ swift test\n```\n\n### Module Map\n\n下一步是修理一下目标的模块映射表。请把module.modulemap修改为如下程序：\n\n``` swift\nmodule CSwift [system] {\n\theader \"CSwift.h\"\n\tlink \"CSwift\"\n\texport *\n}\n```\n\n## 其他\n\nNumber|Name|Date\n------|----|----\n1|CSwift|Mar 7, 2017\n2|SunDown文本处理器|2017年3月7日\n\n"
    response.appendBody(string: markdown)
    response.completed()
  }
}//end TableDemo

func RootHandler(data: [String:Any]) throws -> RequestHandler {
  return {
    request, response in
    let markdown = "# Markdown Demo\n\n## [Demo With Table](demo)\n\n"
    response.appendBody(string: markdown)
    response.completed()
  }//end return
}//end root

/// this is the markdown handler, which will convert all markdowns into HTML.
func MarkdownHandler(data: [String:Any]) throws -> HTTPResponseFilter {
		struct MarkdownFilter: HTTPResponseFilter {
      func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {

        // get the content
        let markdown = response.bodyBytes.withUnsafeBufferPointer { ptr -> String in String(cString: ptr.baseAddress!) }

        // convert markdown to html
        let html = markdown.markdownToHTML ?? "Markdown to HTML Failed"

        // set html back
        response.setBody(string: "<HTML><meta http-equiv='Content-Type' content='text/html;charset=utf-8'><body>\(html)</body></HTML>")

        // fix header
        response.setHeader(.contentLength, value: "\(response.bodyBytes.count)")
        response.setHeader(.contentType, value: "text/html")
        return callback(.continue)
      }
      func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        callback(.continue)
      }
		}
		return MarkdownFilter()
}//end MarkdownHanler

let confData = [
	"servers": [
		[
			"name":"localhost",
			"port":8080,
			"routes":[
        ["method":"get", "uri":"/", "handler":RootHandler, "allowResponseFilters":true],
				["method":"get", "uri":"/demo", "handler":TableDemoHandler, "allowResponseFilters":true],
      ],
			"filters":[
        [
          "type":"response",
          "priority":"high",
          "name":MarkdownHandler,
          ]
      ]
    ]
	]
]

do {
	// Launch the servers based on the configuration data.
	try HTTPServer.launch(configurationData: confData)
} catch {
	fatalError("\(error)") // fatal error launching one of the servers
}

