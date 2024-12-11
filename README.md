# DesktopRestorer
A simple batch file script to store &amp; restore various desktop layouts.

I have decided to make this script after Windows graciously deleted 10 minutes of me neatly arranging all my desktop icons, just for my PC to restart and all icons to completely jamble.

## How It Works

### Registry Storage of Desktop Layouts

Windows keeps desktop icon layout information in a specific registry key:

```
HKCU\Software\Microsoft\Windows\Shell\Bags\1\Desktop
```

This key stores the positions of icons on your desktop. By exporting and importing this section of the registry, we effectively back up and restore the desktop icon arrangement.

### Save Operation

When you choose **Save Layout**:

1. You provide a name (e.g., "Work", "Gaming", or "Clean").
2. The script generates a timestamped filename (`desktop_layout_<NAME>_YYYY-MM-DD_HH-MM.reg`) and exports the registry key to `%APPDATA%\DesktopLayoutManager\Layouts`.
3. A log entry is appended to `%APPDATA%\DesktopLayoutManager\desktop_layout.log` to record the backup.

### Restore Operation

When you choose **Restore Layout**:

1. The script lists all saved `.reg` files in `%APPDATA%\DesktopLayoutManager\Layouts`.
2. You select which `.reg` file to restore.
3. The script imports the selected `.reg` file into the registry.
4. It then restarts Windows Explorer (`explorer.exe`) to apply the restored layout. If you are having a 20-hour programming session, and have two bazillion folder explorer instances open, I suggest you make sure there is nothing important there, first.
5. A log entry is appended to the log file, noting that a restore occurred.

## Installation and Usage

1. **Download and place** `desktop_layout_manager.bat` anywhere on your system
2. **(Optional) If you want it to be available from startup bar, place** `desktop_layout_manager.bat` in:
   ```
   %APPDATA%\Microsoft\Windows\Start Menu\Programs
   ```
3. **Run the script**

## Technical Details

I really suggest that you go ahead and look at the script yourself if you have good understanding of how batch scripts are built and work.

- Only uses built-in Windows commands (`reg`, `taskkill`, `dir`, `choice`)—no PowerShell or external executables required, since the script isn't even signed, anyway.
- **Backup Directory:**  
  Layouts are stored in `%APPDATA%\DesktopLayoutManager\Layouts`.

  Example backup file format:
  ```
  desktop_layout_<NAME>_2024-12-11_14-30.reg
  ```

  Here, `<NAME>` is the user-provided name, and `2024-12-11_14-30` is the timestamp.

- **Log File:**
  Actions are logged to `%APPDATA%\DesktopLayoutManager\desktop_layout.log` with timestamps and the type of action (SAVED or RESTORED).

- **Explorer Restart:**
  On restore, `explorer.exe` is restarted to re-apply the restored layout immediately.

## Possible Issues and Troubleshooting

1. **Layout Not Restoring as Expected:**
    - **Resolution or Monitor Setup Changed:**  
      If you saved the layout on a different screen resolution or monitor arrangement, icons may not appear as intended when restored.  
      **Solution:** Try restoring on the same monitor configuration and screen resolution as when it was saved.

    - **Corrupted or Invalid .reg File:**  
      If the `.reg` file became corrupted or edited, it may fail to restore.  
      **Solution:** Attempt restoring a different `.reg` file or re-save a new layout.

2. **No Layouts Found During Restore:**
    - If you haven’t saved any layouts, the restore menu will show no files.  
      **Solution:** Save at least one layout first.

    - If you manually deleted `.reg` files from `%APPDATA%\DesktopLayoutManager\Layouts`, there may be nothing to restore.  
      **Solution:** Check `%APPDATA%\DesktopLayoutManager\Layouts` to confirm the presence of `.reg` files.

3. **Registry Operations Blocked (Rare):**
    - In standard user accounts, `reg export` and `reg import` usually work without issue.  
      **Solution:** If you run into permission issues, try running the script as an administrator.

4. **Script Not Found in Start Menu Search:**
    - If you placed the `.bat` file’s shortcut in `%APPDATA%\Microsoft\Windows\Start Menu\Programs` and it’s not appearing, ensure that the shortcut file has a descriptive name. Sometimes it may take a short time before Windows indexes it.  
      **Solution:** Rename the shortcut and try again, or pin the `.bat` file to Start.

## Security Considerations

- **Data Integrity:**  
  The `.reg` files contain only desktop icon layout data. They do not affect other system settings unless edited. Always keep backups and avoid modifying `.reg` files manually.