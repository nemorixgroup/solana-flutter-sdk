[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-teal.svg)](https://opensource.org/licenses/Apache-2.0)
[![Dart](https://img.shields.io/badge/Dart-3.x-teal.svg)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![CI](https://github.com/nemorixgroup/solana-flutter-sdk/actions/workflows/ci.yml/badge.svg)](https://github.com/nemorixgroup/solana-flutter-sdk/actions)
[![Status](https://img.shields.io/badge/Status-Scaffold-lightgrey.svg)](https://github.com/nemorixgroup/solana-flutter-sdk/blob/main)

[English](README.md) | **Español**

# solana_flutter_sdk

Un SDK nativo de Flutter/Dart para pagos en Solana.
Pure Dart · Sin platform channels · Apache 2.0 · pub.dev

> **Estado: esqueleto de repositorio.** Todavía sin implementación -
> la Fase 1 (Fundamentos Criptográficos) comienza a continuación.

Construido para ser un **SDK de Solana abierto y enfocado en
pagos**: Solana Pay (Transfer & Transaction Requests) y
Subscriptions & Allowances (la primitiva nativa de pagos recurrentes
de Solana), construido enteramente desde las specs oficiales; sin
dependencia de paquetes Dart de terceros para Solana.

## Roadmap (v1.0.0)

| Fase | Enfoque | Versión | Estado |
|------|---------|---------|--------|
| 1 | Fundamentos criptográficos (Ed25519) | `0.1.0-dev` | ⏳ Planeado |
| 2 | Direcciones y encoding (Base58, PDA, ATA) | `0.2.0-dev` | ⏳ Planeado |
| 3 | Capa de conexión RPC (HTTP + WebSocket) | `0.3.0-dev` | ⏳ Planeado |
| 4 | Construcción y firma de transacciones (legacy + v0) | `0.4.0-dev` | ⏳ Planeado |
| 5 | System Program y operaciones core de tokens | `0.5.0-dev` | ⏳ Planeado |
| 6 | Solana Pay: Transfer Request | `0.6.0-dev` | ⏳ Planeado |
| 7 | Solana Pay: Transaction Request | `0.7.0-dev` | ⏳ Planeado |
| 8 | Subscriptions & Allowances: Delegaciones | `0.8.0-dev` | ⏳ Planeado |
| 9 | Subscriptions & Allowances: Planes | `0.9.0-dev` | ⏳ Planeado |
| 10 | Manejo de errores, tests y cierre v1.0.0 | `1.0.0` | ⏳ Planeado |

Diferido para una versión extendida post-v1.0.0 (documentado, no
perdido): extensions "Confidential" de Token-2022, resolución
genérica de cuentas de Transfer Hook, y creación/gestión de Address
Lookup Tables.

## Documentacion y Knowledge Base

Este SDK esta construido sobre la [Solana Knowledge Base](https://github.com/nemorixgroup/Solana-Knowledge-Base), una guia detallada del XRP Ledger que cubre arquitectura, transacciones RPC, Solana Pay y el ecosistema de desarrollo. Lectura
recomendada antes de entrar a los detalles internos del SDK.

Cada decisión de implementación detrás de este SDK, incluyendo la elección de bibliotecas, los estándares de codificación y la verificación con respecto a las especificaciones oficiales, está documentada en [docs-sdk/](https://github.com/nemorixgroup/Solana-Knowledge-Base/tree/main/docs-sdk).

## Instalación

```yaml
# pubspec.yaml
dependencies:
  solana_flutter_sdk: ^0.0.1-dev
```

```bash
flutter pub get
```

## Contribuciones

El SDK aun no esta listo para contribuciones externas.
Sigue este repositorio para actualizaciones; las contribuciones
seran bienvenidas a partir de la v1.0.0.

Ver [CONTRIBUTING.md](CONTRIBUTING.md) para futuras guias.

## Licencia

Licenciado bajo [Apache 2.0](LICENSE).

## Para desarrolladores en LATAM

Este SDK esta siendo desarrollado con soporte nativo para la region:

- Documentacion bilingue (español / ingles) desde el primer modulo.
- Parte del ecosistema de SDKs de Nemorix Group para infraestructura
  financiera en LATAM (Hedera, Avalanche, XRPL).
- Desarrollado por [Nemorix Group](https://nemorixpay.com), Ohio, USA.

Siguenos para actualizaciones: **sdks@nemorixpay.com**

## Apoya este proyecto

Si este SDK te resulta util a ti o a tu equipo, considera apoyar su
desarrollo. Cada contribucion ayuda a cubrir infraestructura,
documentacion y el tiempo invertido en construir y mantener esta
herramienta open source para la comunidad de Solana y Flutter. Gracias!

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support-FFDD00?logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/nemorixgroupllc)
[![Sponsor](https://img.shields.io/badge/Sponsor-GitHub-EA4AAA?logo=github-sponsors&logoColor=white)](https://github.com/sponsors/nemorixgroup)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5E5B?logo=ko-fi&logoColor=white)](https://ko-fi.com/nemorixgroupllc)

---

Construido por [Nemorix Group](https://nemorixpay.com) · Apache 2.0
