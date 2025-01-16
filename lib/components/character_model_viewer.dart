import 'package:flutter/material.dart';
import 'package:healthxp/services/error_logger.service.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CharacterModelViewer extends StatefulWidget {
  const CharacterModelViewer({super.key});

  @override
  State<CharacterModelViewer> createState() => CharacterModelViewerState();
}

class CharacterModelViewerState extends State<CharacterModelViewer> {
  WebViewController? controller;
  bool isSideView = false;
  bool isModelViewerReady = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: ModelViewer(
        backgroundColor: Colors.transparent,
        src: 'assets/models/character.glb',
        alt: 'A 3D character model',
        autoPlay: true,
        animationName: 'Idle',
        cameraControls: false,
        disableZoom: true,
        ar: false,
        autoRotate: false,
        scale: '1.25 1.25 1.25',
        onWebViewCreated: (controller) {
          this.controller = controller;
          _initializeModelViewer();
        },
        relatedJs: '''
          // Wait for document to be ready
          document.addEventListener('DOMContentLoaded', function() {
            
            // Initialize model viewer
            const modelViewer = document.querySelector('model-viewer');
            
            if (modelViewer) {
              // Set up load event listener
              modelViewer.addEventListener('load', () => {
                
                // Set initial camera position
                modelViewer.cameraOrbit = '0deg 90deg 5m';
                modelViewer.fieldOfView = '30deg';
                
                // Setup animations
                modelViewer.play();
                modelViewer.timeScale = 0.8;
                modelViewer.loopMode = 'repeat';

                // Mark as ready
                window.isModelViewerReady = true;

                // Function to animate camera
                window.animateCamera = (startTheta, endTheta, duration) => {
                  const start = Date.now();
                  
                  function update() {
                    const elapsed = Date.now() - start;
                    const progress = Math.min(elapsed / duration, 1);
                    
                    const theta = startTheta + (endTheta - startTheta) * progress;
                    modelViewer.cameraOrbit = theta + 'deg 90deg 5m';
                    
                    if (progress < 1) {
                      requestAnimationFrame(update);
                    }
                  }
                  
                  requestAnimationFrame(update);
                };
              });

              // Also check for error events
              modelViewer.addEventListener('error', (error) => {
                console.error('Model viewer error:', error);
              });
            } else {
              console.error('Model viewer element not found');
            }
          });
        ''',
      ),
    );
  }

  Future<void> _initializeModelViewer() async {
    // Wait for the model viewer to be ready
    for (int i = 0; i < 20; i++) { // Increased attempts
      try {
        final result = await controller?.runJavaScriptReturningResult('''
          (function() {
            const modelViewer = document.querySelector('model-viewer');
            return window.isModelViewerReady === true && modelViewer != null;
          })()
        ''') as bool? ?? false;

        if (result) {
          setState(() => isModelViewerReady = true);
          return;
        }
      } catch (e) {
        await ErrorLogger.logError('Error checking model viewer: $e');
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    await ErrorLogger.logError('Failed to initialize model viewer after 20 attempts');
  }

  Future<bool> _waitForModelViewer() async {
    if (isModelViewerReady) return true;
    
    // Try to initialize if not ready
    await _initializeModelViewer();
    return isModelViewerReady;
  }

  void animateToSideView() async {
    if (isSideView) return;

    final isReady = await _waitForModelViewer();
    if (!isReady) {
      return;
    }

    await controller?.runJavaScript('''
      window.animateCamera(0, -90, 500);
    ''');
    setState(() => isSideView = true);
  }

  void animateToFrontView() async {
    if (!isSideView) return;

    final isReady = await _waitForModelViewer();
    if (!isReady) {
      return;
    }

    await controller?.runJavaScript('''
      window.animateCamera(-90, 0, 500);
    ''');
    setState(() => isSideView = false);
  }
} 
