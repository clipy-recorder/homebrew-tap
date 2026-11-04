cask "clipy-recorder" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.1.82"
  sha256 arm:   "6b5096acd6f100fa33477b337294985a8255e252807e563cff45b7ff8842278e",
         intel: "dd8b3774a546028cc7867c3a0de376b4844a527f9465d4000f90c1ea7d5ba4d4"

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
