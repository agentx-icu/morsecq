[简体中文](./README.zh-CN.md)

# Offline desktop shell

The desktop shell owns window size/position, close-to-tray, localized show/hide/sound/quit menus and the fixed MorseCQ title. AppServices updates tray strings when the locale changes and flushes local learning/settings before quit. There is no unread-message state or chat routing. Physical key bindings remain device-local and are editable in Me.

Plugins: window_manager, tray_manager, screen_retriever. Mobile platforms keep these adapters inert. Plugin-free window/tray/screen fakes cover persistence, failure tolerance and localization in tests.

Close defaults to quit. Me exposes the saved keep-running-in-tray preference;
Linux probes the live StatusNotifier host before hiding. Sound appears in the
tray only when a real sound owner is supplied. Normal geometry is kept while
maximized, full-screen or minimized; activation restores a minimized window.
macOS native reopen invokes the Dart visibility bridge; explicit quit still
terminates after persistence. DesktopInstance owns all local stores from startup
until process exit; tests may explicitly release it.
