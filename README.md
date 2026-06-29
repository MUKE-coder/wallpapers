# HD / 4K Developer Wallpapers

A curated collection of HD and 4K wallpapers for developers — code humor, minimalist
terminal aesthetics, and product shots for the Grit framework.

## Install

One-liner: downloads the wallpapers to `~/Pictures/wallpapers/` and rotates the
desktop background every **5 minutes**.

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/MUKE-coder/wallpapers/main/install.ps1 | iex
```

Uninstall:

```powershell
Unregister-ScheduledTask -TaskName WallpaperRotation -Confirm:$false
```

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/MUKE-coder/wallpapers/main/install.sh | bash
```

Uninstall — macOS:

```bash
launchctl unload ~/Library/LaunchAgents/com.mukecoder.wallpapers.plist \
  && rm ~/Library/LaunchAgents/com.mukecoder.wallpapers.plist
```

Uninstall — Linux:

```bash
crontab -l | grep -v rotate-wallpaper.sh | crontab -
```

Linux rotation supports GNOME (`gsettings`), KDE (`plasma-apply-wallpaperimage`),
XFCE (`xfconf-query`), and `feh` for tiling WMs.

## Preview

| Wallpaper | Theme |
| --- | --- |
| `arch_linux_minimal.jpg` | Arch Linux minimalist logo |
| `bug_or_feature_joke_4k.png` | `try: it_is_a_bug() / except: it_is_a_feature()` |
| `code_coffee_conquer_4k.png` | Code. Coffee. Conquer. |
| `cs_two_hard_things_joke_4k.png` | The classic CS joke — cache invalidation & naming things |
| `eat_sleep_code_repeat.png` | `eat(); sleep(); code(); repeat();` |
| `focus_distractions_null_4k.png` | FOCUS — `while(coding) { distractions = null; }` |
| `git_never_stop_learning_4k.png` | `~/life $ git commit -m 'never stop learning'` |
| `grit_api_headless_go.png` | `grit new my-app --api` — headless Go API |
| `grit_batteries_included_features.png` | Auth · 2FA · Storage · Jobs · AI · Realtime · WAF · Observability |
| `grit_desktop_wails_gorm.png` | `grit new-desktop my-app` — Wails + GORM |
| `grit_double_nextjs_goapi.png` | `grit new my-app --double` — Next.js + Go API |
| `grit_generate_resource_product.png` | `grit generate resource Product` — file scaffold |
| `grit_go_react_built_with_grit_4k.png` | Go + React. Built with Grit. |
| `grit_mobile_expo_react_native.png` | `grit new my-app --mobile` — Expo React Native |
| `grit_one_go_api_every_frontend_4k.png` | One Go API. Every frontend. |
| `grit_secured_observed_shipped.png` | Secured. Observed. Shipped. — Sentinel + Pulse |
| `grit_ship_product_not_plumbing_4k.png` | Batteries included. Ship product, not plumbing. |
| `grit_single_react_cube.png` | `grit new my-app --single` — React SPA cube |
| `grit_single_react_cube_premium.jpeg` | Premium variant of the React single-binary shot |
| `grit_single_vite_lightning_premium.jpeg` | `grit new my-app --single --vite` — lightning bolt |
| `grit_triple_cli_checklist_4k.png` | `grit new my-app --triple` — Go API + React + Admin |
| `grit_triple_saas_shape.png` | The full SaaS shape — Marketing + Admin + API |
| `grit_vs_other_frameworks_4k.png` | Grit vs other frameworks — wire nothing, just `grit new` |
| `it_works_on_my_machine.png` | The eternal developer alibi |
| `motivated_keep_building_python.png` | `if motivated == True: keep_building()` |
| `motivated_keep_building_python_4k.png` | 4K variant of `keep_building()` |
| `success_celebrate_python_4k.png` | `if success() == True: celebrate()` |
| `vernazza_cinque_terre_sunset.jpg` | Vernazza, Cinque Terre at sunset |

## Usage

All wallpapers are free to download and use. Right-click and save, or clone the repo:

```bash
git clone https://github.com/MUKE-coder/wallpapers.git
```
