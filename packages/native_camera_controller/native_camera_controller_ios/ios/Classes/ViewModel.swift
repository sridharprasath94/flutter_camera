//
//  ViewModel.swift
//  mddi_flutter_plugin_ios
//
//  Created by Dynamic Element on 07/06/23.
//

import Foundation
import SwiftIOSCamera
import UIKit
import SwiftUI
import Flutter
import MobileCoreServices

enum CustomError: Error {
    case throwError(String)
}

@MainActor class ViewModel : ObservableObject {
    var disableFlash: Bool?
    var closeCam: Bool?
    var flashTorchLevel: Float?
    public static var shared = ViewModel()
    var disposed = false
    
    func initModel(flashState: FlashState,
                   flashTorchLevel: Double) {
        self.disposed = false
        self.disableFlash = flashState == FlashState.disabled
        self.flashTorchLevel = Float(flashTorchLevel)
    }
    
    func closeCamera(){
        self.closeCam = true
        self.disposed = true
    }
    
    func ifCameraNeedToBeClosed()->Bool{
        return self.closeCam == true
    }
    /// Get the current flash.
    func getCurrentFlash() -> Bool {
        guard let safeFlash = self.disableFlash else {
            return true
        }
        return !safeFlash
    }
    
    func getCurrentFlashLevel() -> Float {
        return self.flashTorchLevel ?? 0
    }
}
