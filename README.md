# 💳 EnOne - Billetera Digital

Aplicación iOS desarrollada en Swift con arquitectura Clean Architecture + MVVM.

## Características Principales
- Registro y autenticación con verificación de email
- Validación de identidad con DNI peruano
- Billeteras en soles y dólares
- Transferencias P2P entre usuarios
- Conversión de moneda con tipo de cambio en tiempo real
- Depósitos y retiros con tarjeta simulada
- Autenticación de dos factores (2FA/TOTP)
- Límites de transacción configurables (500-2000 soles)
- Actualización en tiempo real (Supabase Realtime)

## 🧭 Flujo de registro y estados del usuario
### ❓ ¿Qué pasa si cierro la app a mitad del registro?

La app maneja 4 estados de usuario:

```swift
enum UserStatus {
    case notAuthenticated    // No hay sesión
    case pendingVerification // Registrado pero email no verificado
    case pendingOnboarding   // Email verificado pero perfil incompleto
    case authenticated       // Todo completo, puede usar la app
}
```

**Flujo completo:**

| Paso | Acción | Si cierras la app... |
|------|--------|---------------------|
| 1. Registro | Crea cuenta con email + password | Al volver → Pantalla de verificación de código |
| 2. Verificación | Ingresa código OTP del email | Al volver → Pantalla de completar perfil |
| 3. Completar Perfil | DNI + teléfono + nombre | Al volver → Home (ya está completo) |
| 4. Listo | Home con wallets PEN y USD | - |

---


## 🧩 Sistema de Cache
### CacheManager

```swift
// Acceso unificado a todos
CacheManager.shared.profile.get()
CacheManager.shared.exchangeRate.getRates()
CacheManager.shared.security.isTwoFactorEnabled
CacheManager.shared.preferences.selectedCurrency
// NO limpia exchangeRate ni preferences
CacheManager.shared.clearAll()
```

---

### 1. ExchangeRateCache - Tipo de Cambio

** ❌Problema:** API con límite de 1,500 requests/mes. Con 10,000 usuarios = 1.5M requests = EXCEDE.

** ✅Solución:** Cache de 3 niveles:

| Nivel | Fuente | Expiración |
|-------|--------|------------|
| 1 | UserDefaults (local) | Cada hora en punto |
| 2 | Supabase (compartido) | Cada hora |
| 3 | API externa | - |
| Fallback | Supabase viejo | 5 min (reintento) |

**Flujo:**
```
UserDefaults válido? → Usa local
        ↓ No
Supabase válido? → Usa compartido + guarda local
        ↓ No
API → Guarda en ambos
        ↓ Falla
Supabase viejo → Guarda con TTL 5min (reintenta pronto)
```

**Resultado:** 1.5M → 720 llamadas/mes (99.95% reducción)

### 2. PreferencesCache - Preferencias de Usuario

Guarda configuraciones que NO se borran al cerrar sesión:
- Moneda seleccionada (PEN/USD)
- Otras preferencias de UI

### 3. KeychainManager - Datos Sensibles

Usa Keychain de iOS para guardar datos de la tarjeta activa del usuario. Más seguro que UserDefaults que guarda en texto plano.

---

## 🛠️ Instalación y uso

1. Clonar repositorio
2. Abrir `enone.xcodeproj` en Xcode 15.4+
3. Ejecutar en simulador iOS 17+ o dispositivo físico

**Dependencias:**
- Supabase Swift SDK

## 🧪Tarjetas mockeadas para pruebas

Para probar depósitos y retiros:

| Número | CVV | Vencimiento | Titular | Saldo Inicial |
|--------|-----|-------------|---------|---------------|
| 4333444555666777 | 812 | 07/29 | TEST UNO | S/ 4,000.00 |
| 7444555666777888 | 741 | 11/28 | TEST DOS | S/ 2,150.70 |

---
