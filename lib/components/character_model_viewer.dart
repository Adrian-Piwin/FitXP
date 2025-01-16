import 'package:flutter/material.dart';
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
      height: 300,
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
        onWebViewCreated: (controller) {
          print('WebView created');
          this.controller = controller;
          _initializeModelViewer();
        },
        relatedJs: '''
          // Wait for document to be ready
          document.addEventListener('DOMContentLoaded', function() {
            console.log('DOM Content Loaded');
            
            // Initialize model viewer
            const modelViewer = document.querySelector('model-viewer');
            console.log('Model viewer element:', modelViewer);
            
            if (modelViewer) {
              // Set up load event listener
              modelViewer.addEventListener('load', () => {
                console.log('Model viewer loaded');
                
                // Set initial camera position
                modelViewer.cameraOrbit = '0deg 90deg 5m';
                modelViewer.fieldOfView = '30deg';
                
                // Setup animations
                modelViewer.play();
                modelViewer.timeScale = 1.0;
                modelViewer.loopMode = 'repeat';

                // Mark as ready
                window.isModelViewerReady = true;
                console.log('Model viewer ready');

                // Function to animate camera
                window.animateCamera = (startTheta, endTheta, duration) => {
                  console.log('Animating camera from ' + startTheta + ' to ' + endTheta);
                  const start = Date.now();
                  
                  function update() {
                    const elapsed = Date.now() - start;
                    const progress = Math.min(elapsed / duration, 1);
                    
                    const theta = startTheta + (endTheta - startTheta) * progress;
                    console.log('Setting camera orbit to: ' + theta + 'deg 90deg 5m');
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
    print('Initializing model viewer');
    // Wait for the model viewer to be ready
    for (int i = 0; i < 20; i++) { // Increased attempts
      try {
        final result = await controller?.runJavaScriptReturningResult('''
          (function() {
            const modelViewer = document.querySelector('model-viewer');
            console.log('Checking model viewer:', modelViewer);
            console.log('Is ready:', window.isModelViewerReady);
            return window.isModelViewerReady === true && modelViewer != null;
          })()
        ''') as bool? ?? false;

        print('Check attempt $i: $result');
        
        if (result) {
          print('Model viewer is ready');
          setState(() => isModelViewerReady = true);
          return;
        }
      } catch (e) {
        print('Error checking model viewer: $e');
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    print('Failed to initialize model viewer after 20 attempts');
  }

  Future<bool> _waitForModelViewer() async {
    if (isModelViewerReady) return true;
    
    // Try to initialize if not ready
    await _initializeModelViewer();
    return isModelViewerReady;
  }

  void animateToSideView() async {
    print('Animating to side view');
    if (isSideView) return;

    final isReady = await _waitForModelViewer();
    if (!isReady) {
      print('Model viewer not ready yet');
      return;
    }

    print('Executing side view animation');
    await controller?.runJavaScript('''
      console.log('Model viewer element:', document.querySelector('model-viewer'));
      console.log('Animate camera function:', window.animateCamera);
      window.animateCamera(0, -90, 500);
    ''');
    setState(() => isSideView = true);
  }

  void animateToFrontView() async {
    print('Animating to front view');
    if (!isSideView) return;

    final isReady = await _waitForModelViewer();
    if (!isReady) {
      print('Model viewer not ready yet');
      return;
    }

    print('Executing front view animation');
    await controller?.runJavaScript('''
      console.log('Model viewer element:', document.querySelector('model-viewer'));
      console.log('Animate camera function:', window.animateCamera);
      window.animateCamera(-90, 0, 500);
    ''');
    setState(() => isSideView = false);
  }
} 
