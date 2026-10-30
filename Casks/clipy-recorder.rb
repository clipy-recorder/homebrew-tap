cask "clipy-recorder" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.1.75"
  sha256 arm:   "12f9da7d385a7148559e8adca952d2ee0d840490e6903ac55b9b9cf170c973b8",
         intel: "b695202fd835c9b736ec80925a35efb9312f37a5f5a06dc5b33dddc2326dfb2c"

  url "https://cdn.clipy.online/desktop/stable/#{version}/Clipy_#{arch}.dmg"
  name "Clipy"
  desc "Screen recorder with share links, transcripts and agent-readable context"
  homepage "https://clipy.online/"

  livecheck do
    url "https://clipy.online/api/releases/latest?channel=stable&platform=darwin-aarch64"
    strategy :json do |json|
      json["version"]
    end
  end

  auto_updates true
  conflicts_with cask: "clipy"
  depends_on :macos

  app "Clipy.app"

  uninstall quit: "online.clipy.desktop"

  zap trash: [
        "~/Library/Application Support/Clipy/agent-bridge.json",
        "~/Library/Application Support/online.clipy.desktop",
        "~/Library/Caches/online.clipy.desktop",
        "~/Library/HTTPStorages/online.clipy.desktop",
        "~/Library/Preferences/online.clipy.desktop.plist",
        "~/Library/Saved Application State/online.clipy.desktop.savedState",
        "~/Library/WebKit/online.clipy.desktop",
      ],
      rmdir: "~/Library/Application Support/Clipy"
end
