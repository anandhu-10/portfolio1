{{flutter_js}}
{{flutter_build_config}}

// Detect mobile device or tablets (including iPads that present as Macintosh but have touch capabilities)
const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) || 
                 (navigator.maxTouchPoints && navigator.maxTouchPoints > 2);

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  onEntrypointLoaded: async function(engineInitializer) {
    const config = {
      renderer: isMobile ? "html" : "canvaskit"
    };
    console.log("Flutter engine initializing with renderer:", config.renderer);
    const appRunner = await engineInitializer.initializeEngine(config);
    await appRunner.runApp();
  }
});
