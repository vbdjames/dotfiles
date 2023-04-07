#!/usr/bin/env bash

set -euo pipefail

main() {
  declare_variables
  set_computer_name
  ensure_homebrew
  brew_bundle
  install_web_apps
  configure_login_items
  install_python
  install_rosetta
  configure_iterm
  set_macos_defaults
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

add_login_item() {
  osascript -e 'tell application "System Events" to make login item at end with properties {path:"$1", hidden:false}' > /dev/null
}

declare_variables() {
  SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
}

set_computer_name() {
  user "Your computer name is \"$(hostname)\". Would you like to change it? (y/n)"
  read -e response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    user "What would you like it to be?"
    read -e computer_name
    sudo scutil --set ComputerName $computer_name
    sudo scutil --set HostName $computer_name
    sudo scutil --set LocalHostName $computer_name
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $computer_name
  fi
}

ensure_homebrew() {
  if test ! $(which brew); then
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

brew_bundle() {
  brew bundle --global
}

install_web_apps() {
  for app in "$SCRIPT_DIR"/*.app; do
    base_name=$(basename -- "${app}")
    if [ ! -d /Applications/"$base_name" ]; then
      echo "Copying App: $app"
      cp -r "$app" /Applications
    fi
  done
}

configure_login_items() {
  add_login_item "/Applications/Alfred 5.app"
  add_login_item "/Applications/Dropbox.app"
  add_login_item "/Applications/Rectangle.app"
  add_login_item "/Applications/Synergy.app"
  add_login_item "/Applications/Things Helper.app"
}

install_python() {
  rtx global python@latest
}

install_rosetta() {
  softwareupdate --install-rosetta --agree-to-license
}

set_macos_defaults() {
  # Close any open System Preferences panes, to prevent them from overriding settings we’re about to change
  osascript -e 'tell application "System Preferences" to quit'

  # Do NOT optimize icloud mac storage
  defaults write com.apple.bird optimize-storage -bool false

  set_uiux_defaults
  set_input_defaults
  set_screen_defaults
  set_finder_defaults
  set_dock_defaults
  set_safari_defaults
  set_mail_defaults
  set_activity_monitor_defaults
  set_disk_utility_defaults
  set_mas_defaults
  set_photos_defaults
  set_messages_defaults
  set_alfred_defaults
  set_rectangle_defaults

  for app in "Dock" \
	"Finder" \
	"Mail" \
	"Messages" \
	"Photos" \
	"Safari" \
	"SystemUIServer"; do
	killall "${app}" &> /dev/null
  done

  echo "Done. Note that some of these changes require a logout/restart to take effect."
}

set_uiux_defaults() {
  # Disable transparency in the menu bar and elsewhere
  sudo defaults write com.apple.universalaccess reduceTransparency -bool true

  # Always show scrollbars
  defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
  # Possible values: `WhenScrolling`, `Automatic` and `Always`

  # Always show 24-hour time
  defaults write NSGlobalDomain AppleICUForce24HourTime -bool true

  # Disable automatic capitalization as it’s annoying when typing code
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

  # Disable smart dashes as they’re annoying when typing code
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  # Disable automatic period substitution as it’s annoying when typing code
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

  # Disable smart quotes as they’re annoying when typing code
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

  # Disable auto-correct
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  # Expand save panel by default
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

  # Expand print panel by default
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  # Save to disk (not to iCloud) by default
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
}

set_input_defaults() {
  # Trackpad: enable tap to click for this user and for the login screen
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  # Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
}

set_screen_defaults() {
  # Save screenshots to the desktop
  defaults write com.apple.screencapture location -string "${HOME}/Desktop"
}

set_finder_defaults() {
  # Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
  defaults write com.apple.finder QuitMenuItem -bool true

  # Finder: disable window animations and Get Info animations
  defaults write com.apple.finder DisableAllAnimations -bool true

  # Set $HOME as the default location for new Finder windows
  defaults write com.apple.finder NewWindowTarget -string "PfLo"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

  # Show icons for hard drives, servers, and removable media on the desktop
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

  # Finder: show hidden files by default
  defaults write com.apple.finder AppleShowAllFiles -bool true

  # Finder: show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Finder: show status bar
  defaults write com.apple.finder ShowStatusBar -bool true

  # Finder: show path bar
  defaults write com.apple.finder ShowPathbar -bool true

  # Display full POSIX path as Finder window title
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

  # Keep folders on top when sorting by name
  defaults write com.apple.finder _FXSortFoldersFirst -bool true

  # When performing a search, search the current folder by default
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

  # Disable the warning when changing a file extension
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  # Enable spring loading for directories
  defaults write NSGlobalDomain com.apple.springing.enabled -bool true

  # Remove the spring loading delay for directories
  defaults write NSGlobalDomain com.apple.springing.delay -float 0

  # Avoid creating .DS_Store files on network or USB volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  # Automatically open a new Finder window when a volume is mounted
  defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
  defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
  defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

  # Show item info near icons on the desktop and in other icon views
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

  # Show item info to the right of the icons on the desktop
  /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

  # Enable snap-to-grid for icons on the desktop and in other icon views
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

  # Use list view in all Finder windows by default
  # Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

  # TODO: use list view for Recents, external drives, network

  # Disable the warning before emptying the Trash
  defaults write com.apple.finder WarnOnEmptyTrash -bool false

  # Use AirDrop over every interface.
  defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

  # Show the ~/Library folder
  chflags nohidden ~/Library

  # Show the /Volumes folder
  sudo chflags nohidden /Volumes

  # Expand the following File Info panes:
  # “General”, “Open with”, and “Sharing & Permissions”
  defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true
}

set_dock_defaults() {
  # Enable highlight hover effect for the grid view of a stack (Dock)
  defaults write com.apple.dock mouse-over-hilite-stack -bool true

  # Enable spring loading for all Dock items
  defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

  # Wipe all (default) app icons from the Dock
  defaults write com.apple.dock persistent-apps -array

  # Don’t animate opening applications from the Dock
  defaults write com.apple.dock launchanim -bool false

  # Remove the auto-hiding Dock delay
  defaults write com.apple.dock autohide-delay -float 0

  # Remove the animation when hiding/showing the Dock
  defaults write com.apple.dock autohide-time-modifier -float 0

  # Automatically hide and show the Dock
  defaults write com.apple.dock autohide -bool true

  # Don’t show recent applications in Dock
  defaults write com.apple.dock show-recents -bool false

  # Ensure the application folder is shown in the dock
  if [[ $(defaults read com.apple.dock persistent-others | grep "Applications") == '' ]]
  then
    defaults write com.apple.dock persistent-others -array-add '<dict><key>tile-type</key><string>directory-tile</string><key>tile-data</key><dict><key>displayas</key><integer>1</integer><key>file-data</key><dict><key>_CFURLString</key><string>file:///Applications/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>'
  fi

  # Hot corners
  # Possible values:
  #  0: no-op
  #  2: Mission Control
  #  3: Show application windows
  #  4: Desktop
  #  5: Start screen saver
  #  6: Disable screen saver
  #  7: Dashboard
  # 10: Put display to sleep
  # 11: Launchpad
  # 12: Notification Center
  # 13: Lock Screen
  # Top left screen corner → Lock Screen
  defaults write com.apple.dock wvous-tl-corner -int 13
  defaults write com.apple.dock wvous-tl-modifier -int 0
  # Top right screen corner → Desktop
  defaults write com.apple.dock wvous-tr-corner -int 4
  defaults write com.apple.dock wvous-tr-modifier -int 0
  # Bottom left screen corner → Start screen saver
  defaults write com.apple.dock wvous-bl-corner -int 5
  defaults write com.apple.dock wvous-bl-modifier -int 0
}

set_safari_defaults() {
  # Press Tab to highlight each item on a web page
  defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

  # Show the full URL in the address bar (note: this still hides the scheme)
  defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

  # Set Safari’s home page to `about:blank` for faster loading
  defaults write com.apple.Safari HomePage -string "about:blank"

  # Prevent Safari from opening ‘safe’ files automatically after downloading
  defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

  # Hide Safari’s bookmarks bar by default
  defaults write com.apple.Safari ShowFavoritesBar -bool false

  # Hide Safari’s sidebar in Top Sites
  defaults write com.apple.Safari ShowSidebarInTopSites -bool false

  # Disable Safari’s thumbnail cache for History and Top Sites
  defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

  # Enable Safari’s debug menu
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

  # Make Safari’s search banners default to Contains instead of Starts With
  defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

  # Remove useless icons from Safari’s bookmarks bar
  defaults write com.apple.Safari ProxiesInBookmarksBar "()"

  # Enable the Develop menu and the Web Inspector in Safari
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

  # Add a context menu item for showing the Web Inspector in web views
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

  # Warn about fraudulent websites
  defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

  # Enable “Do Not Track”
  defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

  # Update extensions automatically
  defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true
}

set_mail_defaults() {
  # Disable send and reply animations in Mail.app
  defaults write com.apple.mail DisableReplyAnimations -bool true
  defaults write com.apple.mail DisableSendAnimations -bool true

  # Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
  defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

  # Disable inline attachments (just show the icons)
  defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

  # Disable automatic spell checking
  defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled"
}

set_activity_monitor_defaults() {
  # Show the main window when launching Activity Monitor
  defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

  # Visualize CPU usage in the Activity Monitor Dock icon
  defaults write com.apple.ActivityMonitor IconType -int 5

  # Show all processes in Activity Monitor
  defaults write com.apple.ActivityMonitor ShowCategory -int 0

  # Sort Activity Monitor results by CPU usage
  defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
  defaults write com.apple.ActivityMonitor SortDirection -int 0
}

set_disk_utility_defaults() {
  # Enable the debug menu in Disk Utility
  defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
  defaults write com.apple.DiskUtility advanced-image-options -bool true
}

set_mas_defaults() {
  # Enable the automatic update check
  defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

  # Check for software updates daily, not just once per week
  defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

  # Download newly available updates in background
  defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

  # Install System data files & security updates
  defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

  # Turn on app auto-update
  defaults write com.apple.commerce AutoUpdate -bool true
}

set_photos_defaults() {
  # Prevent Photos from opening automatically when devices are plugged in
  defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
}

set_messages_defaults() {
  # Disable smart quotes as it’s annoying for messages that contain code
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

  # Disable continuous spell checking
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false
}

set_alfred_defaults() {
  defaults write com.runningwithcrayons.Alfred-Preferences syncfolder -string "~/alfred"
  killall "Alfred" &> /dev/null
  open "/Applications/Alfred 5.app"
}

set_rectangle_defaults() {
  defaults write com.knollsoft.Rectangle maximize -dict keyCode 36 modifierFlags 1835008
  defaults write com.knollsoft.Rectangle almostMaximize -dict keyCode 36 modifierFlags 1572864
}

configure_iterm() {
  /usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Normal Font\" \"Monaco 16\""  ~/Library/Preferences/com.googlecode.iterm2.plist
}

###############################################################################
#   MANUAL STEPS                                                              #
###############################################################################
#
# load ssh keys
# git init
# git remote add origin git@github.com:vbdjames/dotfiles.git
# git pull origin main
#
# Launch 1Password, and log in
# Launch Alfred, "Begin Setup..."
#   Paste in the powerpack password (from 1Password)
# Launch Hyperkey, open preferences
#   Remap caps lock to hyper key
#   Launch on login
#   Check for updates automatically
#   Hide menu bar icon
# Launch Synergy & configure
# Launch Docker & add Mutagen extension
# Launch Backblaze & ...
# Launch Superduper!
#   Enter license information (from 1Password)
#   Plug in drive and setup backup job
#     Smart Update
#     Do it whenever the drive is plugged in
#     Eject the drive when done
# Launch Mail & add accounts
#   doug.james@customviewbook.com
#   doug.james@digitalwave.com
#   vbdjames@gmail.com
#   doug@dwjames.org
#     requires logging in to fastmail web
#     settings -> privacy & security -> integrations
#     generate password
#     open this configuration file
#     open downloaded file
#     visit it in system preferences to launch it
# Launch Fantastical & add accounts
#   much the same as email - preferences -> Accounts...
# Launch Things -> preferences -> turn on things cloud
# MailSuite
#   download and install (https://smallcubed.com)
#   set up rule for CTRL-A Archive
#   set up rule for CTRL-T Forward to Things
# Epubor Ultimate
#   dowload and install (https://www.epubor.com)
#   enter email to retreive registration code
# Calibre
#   open ~/calibre as the library location
# vsCode
#   turn on settings sync & login with github
# Right-click on the Downloads folder in the dock
#   Display as: Folder
#   View content as: Automatic
# Finder -> Settings -> Sidebar
#   Add home directory
  
main "$@"
