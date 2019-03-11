import Foundation
import Utility
import Basic

public struct CommandRegistry {
    
    private let parser: ArgumentParser
    private var commands: [Command] = []
    
    public init(usage: String, overview: String) {
        parser = ArgumentParser(usage: usage, overview: overview)
    }
    
    public mutating func register(command: Command.Type) {
        commands.append(command.init(parser: parser))
    }
    
    public func run() throws {
        let parsedArguments = try parse()
        try process(arguments: parsedArguments)
    }
    
    private func parse() throws -> ArgumentParser.Result {
        let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())
        return try parser.parse(arguments)
    }
    
    private func process(arguments: ArgumentParser.Result) throws {
        guard let subparser = arguments.subparser(parser),
            let command = commands.first(where: { $0.command == subparser }) else {
                let stream = BufferedOutputByteStream()
                parser.printUsage(on: stream)
                guard let description = stream.bytes.asString else {
                    throw CommandExecutionError.unableToGenerateDescription
                }
                throw CommandExecutionError.incorrectUsage(usageDescription: description)
        }
        try command.run(with: arguments)
    }
}
