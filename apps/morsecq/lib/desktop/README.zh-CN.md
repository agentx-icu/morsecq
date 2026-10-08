# Offline desktop shell

The desktop shell owns window size/position, close-to-tray, localized show/hide/sound/quit menus and the fixed MorseCQ title. AppServices updates tray strings when the locale changes and flushes local learning/settings before quit. There is no unread-message state or chat routing. Physical key bindings remain device-local and are editable in Me.

Plugins: window_manager, tray_manager, screen_retriever. Mobile platforms keep these adapters inert. Plugin-free window/tray/screen fakes cover persistence, failure tolerance and localization in tests.
