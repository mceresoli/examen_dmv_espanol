import Flutter
import UIKit
// [10/11/2026] Permiso ATT pedido del lado nativo, igual que en la app
// argentina aprobada por Apple. Flutter (AdsService) espera la respuesta antes
// de iniciar los anuncios. — Claude (IA)
import AppTrackingTransparency

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var attRequested = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // La app usa escenas (SceneDelegate): iOS no llama applicationDidBecomeActive
    // del AppDelegate, pero sí publica esta notificación. Pedimos el ATT recién
    // con la app activa (si no, iOS responde notDetermined sin mostrar el aviso).
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  @objc private func handleDidBecomeActive() {
    if attRequested { return }
    attRequested = true
    if #available(iOS 14, *) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self.requestATT(attempt: 0)
      }
    }
  }

  // Reintenta hasta 8 veces (~1 s entre intentos) mientras siga notDetermined.
  @available(iOS 14, *)
  private func requestATT(attempt: Int) {
    guard UIApplication.shared.applicationState == .active else {
      if attempt < 8 {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          self.requestATT(attempt: attempt + 1)
        }
      }
      return
    }
    ATTrackingManager.requestTrackingAuthorization { status in
      NSLog("[ATT-native] intento \(attempt) -> status = \(status.rawValue)")
      if status == .notDetermined && attempt < 8 {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          self.requestATT(attempt: attempt + 1)
        }
      }
    }
  }
}
