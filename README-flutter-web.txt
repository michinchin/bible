Hello everyone,

TLDR; We're introducing a new command line option --web-renderer to use different renderers for your web apps.

Flutter has two renderers for web targets: HTML, which prioritizes code size, and CanvasKit, which prioritizes performance and rendering quality. Until now, Flutter has defaulted to the HTML renderer on all devices, unless an experimental FLUTTER_WEB_USE_SKIA flag* was specified. 

Now that both renderers are getting closer to our quality goals, we’re introducing a --web-renderer option to allow more flexibility in using our different renderers for your Flutter web app.

The different renderers supported with this option are:

auto  (default option) - Automatically chooses which renderers to use when running your app: the HTML renderers for mobile web and CanvasKit on desktop web.

html - Always use the HTML renderer

canvaskit -Always use the CanvasKit renderer. There may be areas where CanvasKit is still maturing such as fonts and cross origin images  that need to be handled with care. 

For example, if you build your app with the following command:

flutter build web --release

It uses auto as the default, which means that your app runs with the HTML renderer on mobile browsers and CanvasKit on desktop browsers. This is our recommended combination to optimize for the characteristics of each platform.

To build your app to run specifically with HTML, you need to use the following command:

flutter build web --web-renderer=html --release

For more information, see Web renderers on flutter.dev.



*We recommend those using the experimental CanvasKit Flag switch to using  ‘--web-renderer’ to set your renderer going forward.

Thanks,
