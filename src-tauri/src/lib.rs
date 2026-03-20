// Library entry point for mobile platforms

use tauri::Manager;

pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_global_shortcut::Builder::new().build())
        .setup(|app| {
            let window = app.get_webview_window("main").unwrap();
            
            // Apply platform-specific window styling
            #[cfg(target_os = "macos")]
            {
                window.set_background_color(Some(tauri::window::Color(18, 18, 18, 255))).ok();
                
                // Create native menu
                use tauri::menu::{Menu, PredefinedMenuItem, Submenu};
                
                // Create menu items
                let about_item = PredefinedMenuItem::about(app, None, None)?;
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
            }
            
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
