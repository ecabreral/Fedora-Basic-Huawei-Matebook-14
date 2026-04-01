# Copyous Troubleshooting Guide

## Error: "Failed to load Gda - Clipboard history will be disabled"

### 🔍 What does this mean?

This warning appears when **Copyous** (o **CopyQ**) cannot load the **libgda library**, which is required to save clipboard history between restarts.

The message literally says: `Failed to load Gda` – which means the GDA library is missing.

---

## ✅ Quick Solution

### 1️⃣ Install missing libraries

```bash
sudo dnf install libgda libgda-sqlite
```

### 2️⃣ Restart your system

```bash
reboot
```

After restart, the error should be gone and clipboard history will work correctly.

---

## 📚 What is libgda?

**libgda** (GNU Data Access) is a library that allows Copyous to:

- 💾 **Save clipboard history** between restarts
- 🗄️ Use an **SQLite database** to store clipboard data
- 🔄 Recover what you copied even after restarting

**Without libgda**, Copyous can open but only keeps clipboard history in temporary memory (lost after restart).

---

## 🤔 Why did this happen?

This usually occurs because:

1. **Copyous/CopyQ was installed** but the dependency wasn't available
2. **Dependencies were removed** during system cleanup
3. **An update removed dependencies** automatically
4. **libgda wasn't pre-installed** on your Fedora system

---

## 🚨 If you don't want to use Copyous

You can disable it from autostarting:

### Option 1: GNOME Session Properties

```bash
gnome-session-properties
```

Then uncheck "Copyous" from the list.

### Option 2: Remove from autostart

```bash
rm ~/.config/autostart/copyous.desktop
```

Or for CopyQ:

```bash
rm ~/.config/autostart/copyq.desktop
```

---

## ✔️ How to verify libgda is installed

Run this command to check:

```bash
rpm -q libgda libgda-sqlite
```

If both packages are installed, you'll see:
```
libgda-6.0.0-1.fc40.x86_64
libgda-sqlite-6.0.0-1.fc40.x86_64
```

If not installed, you'll see:
```
package libgda is not installed
```

---

## 🔧 Manual trigger to reload

If you already installed libgda but Copyous still shows the warning:

1. Close Copyous completely
2. Restart GNOME (logout and login or reboot)
3. Reopen Copyous

The library should now load correctly.

---

## 📊 Note

The Fedora setup script (`init.sh`) **automatically installs** `libgda` and `libgda-sqlite`, so this warning shouldn't normally appear unless:

- The system was already running before libgda was installed
- GNOME needs to be restarted to recognize the new libraries

A **system restart** always resolves this issue completely.
