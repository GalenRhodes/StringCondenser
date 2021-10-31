/*===============================================================================================================================================================================*
 *     PROJECT: StringCondenser
 *    FILENAME: main.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 10/20/21
 *
 * Copyright © 2021 Galen Rhodes. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this
 * permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
 * AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *===============================================================================================================================================================================*/

import Foundation
import CoreFoundation
import Rubicon
import ArgumentParser
import SourceKittenFramework

struct StringCondenser: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Condense string literals into global variables.", discussion:
    """
    TBD
    """)

    enum BuildMode: String, ExpressibleByArgument {
        case xcode, spm
    }

    //@f:0
    @Option(name: [ .long, .customShort("p") ], help: "The path to the project. (defaults to current working directory)") var projectPath:        String?
    @Option(name: [ .long, .customShort("m") ], help: "The name of the module.")                                          var moduleName:         String?
    @Option(name: [ .long, .customShort("s") ], help: "The name of the source file with the global variables.")           var messagesSourceFile: String    = "Messages.swift"
    @Option(name: [ .long, .customShort("b") ], help: "Build Mode: \"xcode\" or \"spm\" (Swift Package Manager).")        var buildMode:          BuildMode = .xcode
    @Argument(help: "Build arguments to be passed to either Xcode or the Swift Package Manager.")                         var buildArguments:     [String]  = []
    //@f:1

    mutating func run() throws {
        let ch: Character = "🇺🇸"
        var i: Int = 0

        for x in ch.utf8 {
            print("\(i++): \(x)")
        }
    }
    mutating func run2() throws {
        let projectPath: String = (self.projectPath ?? FileManager.default.currentDirectoryPath)
        let moduleInfo:  Module = try getModuleInfo(sourceDirectory: projectPath)
        let moduleName:  String = moduleInfo.name
        let sourcePath:  String = moduleInfo.sourceFiles.commonPrefix
        let sourceFiles: [SourceFile] = try moduleInfo.sourceFiles.map({ try SourceFile(filename: $0) })

        print("        Project Path: \"\(projectPath)\"")
        print("Messages Source File: \"\(messagesSourceFile)\"")
        print("          Build Mode: \"\(buildMode)\"")
        print("     Build Arguments: \(buildArguments)")
        print("         Module Name: \"\(moduleName)\"")
        print("         Source Path: \"\(sourcePath)\"")
        print("        Source Files: \(moduleInfo.sourceFiles.map { $0.hasPrefix(sourcePath) ? String($0[sourcePath.endIndex ..< $0.endIndex]) : $0 })")
        print()

        for sf in sourceFiles {
            if sf.filename.hasSuffix("StringProtocol.swift") {
                for si in sf.strings {
                    print(si)
                }
            }
        }
    }

    private func getModuleInfo(sourceDirectory: String, loadDocs: Bool = false) throws -> Module {
        guard let moduleInfo: Module = Module(xcodeBuildArguments: buildArguments, name: moduleName, inPath: sourceDirectory) else {
            throw AppErrors.ModuleBuildError
        }

        if loadDocs {
            let sw:   StopWatch   = StopWatch(start: true)
            let docs: [SwiftDocs] = moduleInfo.docs
            sw.stop()

            print()
            for d in docs {
                print(d.file.path ?? "")
                if d.file.path?.hasSuffix("/NodeList.swift") ?? false {
                    print(d.description)
                }
            }

            print()
            print(sw.description)
        }
        return moduleInfo
    }
}

DispatchQueue.main.async {
    StringCondenser.main()
    exit(0)
}
dispatchMain()
