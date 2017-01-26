import Foundation

public protocol Token{
	
	var raw: String {get}
	var header: Dictionary<String, Any> {get}
	var payload: Dictionary<String, Any> {get}
	var signature: String {get}
	
	var issuer: String {get}
	var subject: String {get}
	var audience: String {get}
	var expiration: Date {get}
	var issuedAt: Date {get}
	var tenant: String {get}
	var authBy: String {get}
	var isExpired: Bool {get}
}

internal class AbstractToken: Token{
	
	private static let ISSUER = "iss"
	private static let SUBJECT = "sub"
	private static let AUDIENCE = "aud"
	private static let EXPIRATION = "exp"
	private static let ISSUED_AT = "iat"
	private static let TENANT = "tenant"
	private static let AUTH_BY = "auth_by"

	var raw: String
	var header: Dictionary<String, Any>
	var payload: Dictionary<String, Any>
	var signature: String
	
	internal init? (with raw: String){
		self.raw = raw
		let tokenComponents = self.raw.components(separatedBy: ".")
		guard tokenComponents.count==3 else {
			return nil
		}
		
		let headerComponent = tokenComponents[0]
		let payloadComponent = tokenComponents[1]
		self.signature = tokenComponents[2]

		guard
			let headerDecodedData = Utils.decodeBase64WithString(headerComponent, isSafeUrl: true),
			let payloadDecodedData = Utils.decodeBase64WithString(payloadComponent, isSafeUrl: true)
			else {
				return nil
		}
		
		guard
			let headerDecodedString = String(data: headerDecodedData, encoding: String.Encoding.utf8),
			let payloadDecodedString = String(data: payloadDecodedData, encoding: String.Encoding.utf8)
			else {
				return nil
		}
		
		guard
			let headerDictionary = try? Utils.parseJsonStringtoDictionary(headerDecodedString),
			let payloadDictionary = try? Utils.parseJsonStringtoDictionary(payloadDecodedString)
			else {
				return nil
		}
		
		self.header = headerDictionary
		self.payload = payloadDictionary
	}
	
	var issuer: String {
		return payload[AbstractToken.ISSUER] as! String
	}

	var subject: String {
		return payload[AbstractToken.SUBJECT] as! String
	}
	
	var audience: String {
		return payload[AbstractToken.AUDIENCE] as! String
	}
	
	var expiration: Date {
		return Date()
	}
	
	var issuedAt: Date {
		return Date()
	}
	
	var tenant: String {
		return payload[AbstractToken.TENANT] as! String
	}
	
	var authBy: String {
		return payload[AbstractToken.AUTH_BY] as! String
	}
	
	var isExpired: Bool {
		return false
	}
	
}
