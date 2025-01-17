import 'package:healthxp/pages/character/components/character_model_viewer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ModelViewerService {
  static final ModelViewerService instance = ModelViewerService._internal();
  factory ModelViewerService() => instance;
  ModelViewerService._internal();

  CharacterModelViewer? _modelViewerWidget;
  WebViewController? _controller;
  bool _isModelLoaded = false;
  bool _isInitializing = false;

  bool get isModelLoaded => _isModelLoaded;
  WebViewController? get controller => _controller;
  CharacterModelViewer? get modelViewerWidget => _modelViewerWidget;

  void setModelViewerWidget(CharacterModelViewer widget) {
    _modelViewerWidget = widget;
  }

  Future<void> initializeModel(WebViewController controller) async {
    if (_isModelLoaded || _isInitializing) return;
    
    _isInitializing = true;
    _controller = controller;
    
    try {
      await controller.runJavaScript('''
        console.log('Initializing model viewer');
        const modelViewer = document.querySelector('model-viewer');
        
        if (modelViewer) {
          modelViewer.addEventListener('load', () => {
            console.log('Model loaded successfully');
            modelViewer.cameraOrbit = '0deg 90deg 7m';
            modelViewer.fieldOfView = '30deg';
            modelViewer.play();
            modelViewer.timeScale = 1.0;
            modelViewer.loopMode = 'repeat';
            window.isModelViewerReady = true;
          });
        }
      ''');
      
      _isModelLoaded = true;
    } catch (e) {
      print('Error initializing model: $e');
    } finally {
      _isInitializing = false;
    }
  }

  void dispose() {
    _controller = null;
    _isModelLoaded = false;
    _isInitializing = false;
  }
} 
