import KituraNIO
import SSLService
import Dispatch
import Foundation

class Delegate: ServerDelegate {
    func handle(request: ServerRequest, response: ServerResponse) {
        print("In handler")
        response.statusCode = .OK
        try! response.end()
    }
}

let sslConfig: SSLService.Configuration = {
    let sslConfigDir = URL(fileURLWithPath: #file).appendingPathComponent("../SSLConfig")
    let certificatePath = sslConfigDir.appendingPathComponent("certificate.pem").standardized.path
    let keyPath = sslConfigDir.appendingPathComponent("key.pem").standardized.path
    return SSLService.Configuration(withCACertificateDirectory: nil, usingCertificateFile: certificatePath,
                withKeyFile: keyPath, usingSelfSignedCerts: true, cipherSuite: nil)
}()

func startServer(useSSL: Bool = true, supportIPv6: Bool = false) throws -> HTTPServer {
    let server = HTTP.createServer()
    server.delegate = Delegate() 
    server.allowPortReuse = true 
    server.supportIPv6 = supportIPv6 
    if useSSL {
        server.sslConfig = sslConfig
    }
    try server.listen(on: 8080)
    return server
}

func testIPv6() {
    do {
        _ = try startServer(useSSL: false, supportIPv6: true) 
        let options: [ClientRequest.Options] = [.method("get"), .schema("http"), .hostname("localhost"), .port(Int16(8080)), .path("/")]
        let req = HTTP.request(options) { response in print(response as Any) }
        req.end(close: true)
    } catch let e {
        print(e)
    }
}

func testErrorRequest() {
    do {
        _ = try startServer()
        let options: [ClientRequest.Options] = [.method("plover"), .schema("https"), .hostname("localhost"), .port(Int16(8080)), .path("/xzzy")]
        let req = HTTP.request(options) { response in print(response as Any) }
        req.end(close: true)
    } catch let e { 
        print(e)
    }
}

testIPv6()
testErrorRequest()
dispatchMain()
