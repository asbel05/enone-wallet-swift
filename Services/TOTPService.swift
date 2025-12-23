import Foundation
import CryptoKit

final class TOTPService {
    
    static let shared = TOTPService()
    
    private init() {}
    
    private let period: Int = 300

    func generateCode(secret: String) -> String {
        let secretData = base32Decode(secret)
        let counter = UInt64(Date().timeIntervalSince1970) / UInt64(period)
        
        return generateHOTP(secret: secretData, counter: counter)
    }
    
    func validateCode(_ code: String, secret: String) -> Bool {
        let currentCode = generateCode(secret: secret)
        
        let secretData = base32Decode(secret)
        let currentCounter = UInt64(Date().timeIntervalSince1970) / UInt64(period)
        
        let previousCode = generateHOTP(secret: secretData, counter: currentCounter - 1)
        let nextCode = generateHOTP(secret: secretData, counter: currentCounter + 1)
        
        return code == currentCode || code == previousCode || code == nextCode
    }

    func generateSecret() -> String {
        var bytes = [UInt8](repeating: 0, count: 20)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return base32Encode(Data(bytes))
    }

    func secondsRemaining() -> Int {
        let elapsed = Int(Date().timeIntervalSince1970) % period
        return period - elapsed
    }
    
    func progress() -> Double {
        let elapsed = Int(Date().timeIntervalSince1970) % period
        return Double(elapsed) / Double(period)
    }

    private func generateHOTP(secret: Data, counter: UInt64) -> String {
        var counterBigEndian = counter.bigEndian
        let counterData = Data(bytes: &counterBigEndian, count: MemoryLayout<UInt64>.size)
        
        let key = SymmetricKey(data: secret)
        let hmac = HMAC<Insecure.SHA1>.authenticationCode(for: counterData, using: key)
        let hmacData = Data(hmac)
        
        let offset = Int(hmacData[hmacData.count - 1] & 0x0F)
        let truncatedHash = hmacData.subdata(in: offset..<(offset + 4))
        
        var code = truncatedHash.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        code = code & 0x7FFFFFFF
        code = code % 1000000
        
        return String(format: "%06d", code)
    }

    private let base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    
    private func base32Encode(_ data: Data) -> String {
        var result = ""
        var buffer: UInt64 = 0
        var bitsLeft = 0
        
        for byte in data {
            buffer = (buffer << 8) | UInt64(byte)
            bitsLeft += 8
            
            while bitsLeft >= 5 {
                bitsLeft -= 5
                let index = Int((buffer >> bitsLeft) & 0x1F)
                result.append(base32Alphabet[base32Alphabet.index(base32Alphabet.startIndex, offsetBy: index)])
            }
        }
        
        if bitsLeft > 0 {
            let index = Int((buffer << (5 - bitsLeft)) & 0x1F)
            result.append(base32Alphabet[base32Alphabet.index(base32Alphabet.startIndex, offsetBy: index)])
        }
        
        return result
    }
    
    private func base32Decode(_ string: String) -> Data {
        var result = Data()
        var buffer: UInt64 = 0
        var bitsLeft = 0
        
        for char in string.uppercased() {
            guard let index = base32Alphabet.firstIndex(of: char) else { continue }
            let value = base32Alphabet.distance(from: base32Alphabet.startIndex, to: index)
            
            buffer = (buffer << 5) | UInt64(value)
            bitsLeft += 5
            
            while bitsLeft >= 8 {
                bitsLeft -= 8
                result.append(UInt8((buffer >> bitsLeft) & 0xFF))
            }
        }
        
        return result
    }
}
