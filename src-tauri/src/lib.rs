// Library entry point for mobile platforms

use std::time::Duration;
use tauri::{Manager, Emitter};
use serde::Deserialize;

#[derive(Debug, Deserialize)]
struct SongApiResponse {
    #[serde(flatten)]
    stations: std::collections::HashMap<String, SongData>,
}

#[derive(Debug, Deserialize)]
struct SongData {
    titel: String,
    interpret: String,
}

#[derive(Debug, Deserialize)]
struct ShowApiResponse {
    #[serde(rename = "now playing")]
    now_playing: std::collections::HashMap<String, ShowData>,
}

#[derive(Debug, Deserialize)]
struct ShowData {
    titel: String,
    moderator: String,
}

#[derive(Debug, serde::Serialize)]
struct NowPlayingData {
    title: String,
    artist: String,
    show: String,
    moderator: String,
}

#[tauri::command]
async fn fetch_now_playing(station_id: String) -> Result<NowPlayingData, String> {
    println!("[Rust] Fetching now playing for station: {}", station_id);
    
    // Validate station ID against allowlist
    const VALID_STATIONS: [&str; 3] = ["sr1", "sr2", "sr3"];
    if !VALID_STATIONS.contains(&station_id.as_str()) {
        return Err("Invalid station ID".to_string());
    }
    
    // Create HTTP client with timeout
    let client = reqwest::Client::builder()
        .timeout(Duration::from_secs(10))
        .build()
        .map_err(|e| format!("Failed to create HTTP client: {}", e))?;
    
    let song_url = "https://musikrecherche.sr-online.de/sophora/titelinterpret.php";
    let show_url = format!("https://www.sr.de/sr/epg/nowPlaying.jsp?welle={}", station_id);
    
    // Fetch song info
    let song_result = client.get(song_url).send().await;
    let mut title = String::new();
    let mut artist = String::new();
    
    match song_result {
        Ok(response) => {
            if let Ok(json) = response.json::<SongApiResponse>().await {
                if let Some(data) = json.stations.get(&station_id) {
                    title = data.titel.clone();
                    artist = data.interpret.clone();
                    println!("[Rust] Song: {} - {}", artist, title);
                }
            }
        }
        Err(e) => println!("[Rust] Error fetching song: {}", e),
    }
    
    // Fetch show info
    let show_result = client.get(&show_url).send().await;
    let mut show = String::new();
    let mut moderator = String::new();
    
    match show_result {
        Ok(response) => {
            if let Ok(json) = response.json::<ShowApiResponse>().await {
                if let Some(data) = json.now_playing.get(&station_id) {
                    show = data.titel.clone();
                    moderator = data.moderator.clone();
                    println!("[Rust] Show: {} (moderator: {})", show, moderator);
                }
            }
        }
        Err(e) => println!("[Rust] Error fetching show: {}", e),
    }
    
    Ok(NowPlayingData {
        title,
        artist,
        show,
        moderator,
    })
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let mut builder = tauri::Builder::default();

    #[cfg(not(any(target_os = "ios", target_os = "android")))]
    {
        builder = builder.plugin(tauri_plugin_global_shortcut::Builder::new().build());
    }

    builder
        .invoke_handler(tauri::generate_handler![fetch_now_playing])
        .setup(|app| {
            // On mobile, a "main" webview window may not be available.
            let window = app.get_webview_window("main");
            
            // Apply platform-specific window styling
            #[cfg(target_os = "macos")]
            {
                if let Some(window) = window {
                    window.set_background_color(Some(tauri::window::Color(18, 18, 18, 255))).ok();
                }
                
                // Create native menu
                use tauri::menu::{Menu, MenuItem, PredefinedMenuItem, Submenu};
                
                // Create About menu item (custom, not predefined)
                let about_item = MenuItem::with_id(app, "about", "About SR Radio", true, None::<&str>)?;
                let separator = PredefinedMenuItem::separator(app)?;
                let hide_item = PredefinedMenuItem::hide(app, None)?;
                let hide_others_item = PredefinedMenuItem::hide_others(app, None)?;
                let show_all_item = PredefinedMenuItem::show_all(app, None)?;
                let quit_item = PredefinedMenuItem::quit(app, None)?;
                let close_window_item = PredefinedMenuItem::close_window(app, None)?;
                let minimize_item = PredefinedMenuItem::minimize(app, None)?;
                let undo_item = PredefinedMenuItem::undo(app, None)?;
                let redo_item = PredefinedMenuItem::redo(app, None)?;
                let cut_item = PredefinedMenuItem::cut(app, None)?;
                let copy_item = PredefinedMenuItem::copy(app, None)?;
                let paste_item = PredefinedMenuItem::paste(app, None)?;
                let select_all_item = PredefinedMenuItem::select_all(app, None)?;
                
                // App Menu (macOS)
                let app_menu = Submenu::with_items(
                    app,
                    "SR2 Radio",
                    true,
                    &[
                        &about_item,
                        &separator,
                        &hide_item,
                        &hide_others_item,
                        &show_all_item,
                        &separator,
                        &quit_item,
                    ],
                )?;
                
                // File Menu
                let file_menu = Submenu::with_items(
                    app,
                    "File",
                    true,
                    &[
                        &close_window_item,
                    ],
                )?;
                
                // Edit Menu
                let edit_menu = Submenu::with_items(
                    app,
                    "Edit",
                    true,
                    &[
                        &undo_item,
                        &redo_item,
                        &separator,
                        &cut_item,
                        &copy_item,
                        &paste_item,
                        &select_all_item,
                    ],
                )?;
                
                // Window Menu
                let window_menu = Submenu::with_items(
                    app,
                    "Window",
                    true,
                    &[
                        &minimize_item,
                        &separator,
                        &close_window_item,
                    ],
                )?;
                
                // Create main menu
                let menu = Menu::with_items(app, &[
                    &app_menu,
                    &file_menu,
                    &edit_menu,
                    &window_menu,
                ])?;
                
                app.set_menu(menu)?;
                
                // Handle menu events
                let _app_handle = app.handle().clone();
                app.on_menu_event(move |app, event| {
                    if event.id() == "about" {
                        // Emit event to frontend to open about dialog
                        let _ = app.emit("menu-about-clicked", ());
                    }
                });
            }
            
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
