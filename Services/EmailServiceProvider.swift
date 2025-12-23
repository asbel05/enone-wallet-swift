//
//  EmailServiceProvider.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

final class EmailServiceProvider {
    
    static let shared = EmailServiceProvider()
    
    private init() {}
    
    private let edgeFunctionURL = "https://roqxzsczeapqxyrkeekg.supabase.co/functions/v1/send-email"
    
    func sendEmail(to email: String, subject: String, html: String) async throws {
        guard let url = URL(string: edgeFunctionURL) else {
            throw EmailError.invalidConfiguration
        }
        
        let payload: [String: Any] = [
            "to": email,
            "subject": subject,
            "html": html
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(SupabaseClientProvider.shared.anonKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw EmailError.networkError
        }
        
        if httpResponse.statusCode == 200 {
            print("✅ Email enviado exitosamente a \(email)")
        } else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Error Edge Function: \(errorString)")
            }
            throw EmailError.apiError(statusCode: httpResponse.statusCode)
        }
    }
    
    func generateLimitOTPEmailHTML(otp: String, newLimit: Double) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
                    line-height: 1.6;
                    color: #333;
                    margin: 0;
                    padding: 0;
                }
                .container {
                    max-width: 600px;
                    margin: 0 auto;
                    background: #ffffff;
                }
                .header {
                    background: linear-gradient(135deg, #3385B3 0%, #4D99BF 100%);
                    color: white;
                    padding: 40px 20px;
                    text-align: center;
                }
                .header h1 {
                    margin: 0;
                    font-size: 32px;
                    font-weight: 600;
                }
                .content {
                    padding: 40px 30px;
                }
                .otp-box {
                    background: #f8f9fa;
                    border: 2px solid #3385B3;
                    border-radius: 12px;
                    padding: 30px;
                    text-align: center;
                    margin: 30px 0;
                }
                .otp-label {
                    font-size: 14px;
                    color: #666;
                    margin-bottom: 10px;
                }
                .otp-code {
                    font-size: 42px;
                    font-weight: bold;
                    color: #3385B3;
                    font-family: 'Courier New', monospace;
                    letter-spacing: 8px;
                    margin: 15px 0;
                }
                .info-box {
                    background: #fff3cd;
                    border-left: 4px solid #ffc107;
                    padding: 15px;
                    margin: 20px 0;
                }
                .info-box p {
                    margin: 5px 0;
                    color: #856404;
                }
                .footer {
                    background: #f8f9fa;
                    text-align: center;
                    padding: 30px 20px;
                    color: #666;
                    font-size: 12px;
                }
                .footer p {
                    margin: 5px 0;
                }
                .btn {
                    display: inline-block;
                    background: #3385B3;
                    color: white;
                    padding: 12px 30px;
                    text-decoration: none;
                    border-radius: 8px;
                    margin: 20px 0;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🔐 EnOne</h1>
                    <p style="margin: 10px 0 0 0; font-size: 18px;">Cambio de Límite Transaccional</p>
                </div>
                
                <div class="content">
                    <p>Hola,</p>
                    <p>Has solicitado cambiar tu límite diario de transacciones en tu billetera EnOne.</p>
                    
                    <div class="otp-box">
                        <div class="otp-label">Tu código de verificación es:</div>
                        <div class="otp-code">\(otp)</div>
                        <p style="color: #666; font-size: 14px; margin-top: 15px;">
                            Ingresa este código en la aplicación para confirmar el cambio
                        </p>
                    </div>
                    
                    <p><strong>Nuevo límite solicitado:</strong> S/ \(String(format: "%.2f", newLimit))</p>
                    
                    <div class="info-box">
                        <p><strong>⚠️ Importante:</strong></p>
                        <p>• Este código expira en <strong>10 minutos</strong></p>
                        <p>• No compartas este código con nadie</p>
                        <p>• Solo puedes cambiar tu límite cada 24 horas</p>
                    </div>
                    
                    <p style="color: #888; font-size: 14px; margin-top: 30px;">
                        Si no solicitaste este cambio, ignora este correo. Tu límite permanecerá sin cambios y tu cuenta está segura.
                    </p>
                </div>
                
                <div class="footer">
                    <p><strong>© 2024 EnOne</strong></p>
                    <p>Billetera Digital Segura</p>
                    <p style="margin-top: 15px;">
                        Este es un correo automático, por favor no respondas.
                    </p>
                </div>
            </div>
        </body>
        </html>
        """
    }
}

enum EmailError: LocalizedError {
    case invalidConfiguration
    case networkError
    case apiError(statusCode: Int)
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Configuración de email inválida"
        case .networkError:
            return "Error de red al enviar email"
        case .apiError(let code):
            return "Error del servicio de email (código \(code))"
        case .encodingError:
            return "Error al codificar datos del email"
        }
    }
}

