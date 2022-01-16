import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
  let flutterViewController = FlutterViewController.init()
  let windowFrame = self.frame
  self.contentViewController = flutterViewController
  self.setFrame(windowFrame, display: true)
  RegisterGeneratedPlugins(registry: flutterViewController)

  /* Hiding the window titlebar */
  self.titleVisibility = NSWindow.TitleVisibility.visible;
  self.titlebarAppearsTransparent = true;
  self.isMovableByWindowBackground = true;
  // self.MainFlutterWindow.styleMask = mainWindow.styleMask & ~NSWindowStyleMaskResizable
  self.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)?.isEnabled = false;

  /* Making the window transparent */
  self.isOpaque = false
  self.backgroundColor = .clear
  // self.minSize = NSSize(width: 800, height: 600)
  /* Adding a NSVisualEffectView to act as a translucent background */
  let contentView = contentViewController!.view;
  let superView = contentView.superview!;

  let blurView = NSVisualEffectView()
  blurView.frame = superView.bounds
  blurView.autoresizingMask = [.width, .height]
  blurView.blendingMode = NSVisualEffectView.BlendingMode.behindWindow

  /* Pick the correct material for the task */
  blurView.material = NSVisualEffectView.Material.underWindowBackground

  /* Replace the contentView and the background view */
  superView.replaceSubview(contentView, with: blurView)
  blurView.addSubview(contentView)

  super.awakeFromNib()
  }
}
