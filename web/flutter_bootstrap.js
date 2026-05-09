(function () {
  const GPU_CONFIG = {
    renderer: 'canvaskit',
    canvasKitMaximumSurfaces: Math.max(
      4,
      Math.min(12, Math.ceil((navigator.hardwareConcurrency || 8) / 2))
    ),
    canvasKitForceCpuOnly: false,
  };

  const BUILD_CONFIG = {
    engineRevision: '425cfb54d01a9472b3e81d9e76fd63a4a44cfbcb',
    builds: [
      {
        compileTarget: 'dart2js',
        renderer: 'canvaskit',
        mainJsPath: 'main.dart.js',
      },
      {},
    ],
  };

  function loadScript(src) {
    return new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = src;
      script.async = false;
      script.onload = resolve;
      script.onerror = reject;
      document.head.appendChild(script);
    });
  }

  async function bootstrap() {
    if (!window._flutter || !window._flutter.loader) {
      await loadScript('flutter.js');
    }

    window._flutter = window._flutter || {};
    window._flutter.buildConfig = BUILD_CONFIG;

    await window._flutter.loader.load({
      config: GPU_CONFIG,
      onEntrypointLoaded: async function (engineInitializer) {
        const appRunner = await engineInitializer.initializeEngine(GPU_CONFIG);
        await appRunner.runApp();
      },
    });
  }

  if (document.readyState === 'complete' || document.readyState === 'interactive') {
    queueMicrotask(bootstrap);
  } else {
    window.addEventListener('load', bootstrap, { once: true });
  }
})();

