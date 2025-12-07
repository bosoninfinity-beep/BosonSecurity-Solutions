# BosonSecurity-Solutions

# **DoH Stealth – DNS-over-HTTPS Privacy Tool for Windows 10/11**

**DoH Stealth** is a privacy-focused Windows configuration tool that forces all DNS queries through **encrypted DNS-over-HTTPS (DoH)** using Cloudflare (1.1.1.1), blocks all unencrypted DNS traffic, and disables IPv6 DNS leakage.

This enhances privacy by preventing:

* ISPs from tracking your DNS requests
* Network-level monitoring
* DNS hijacking or manipulation
* Third-party DNS visibility

---

# 🔥 **Features**

✔ Forces DNS-over-HTTPS (DoH)
✔ Uses Cloudflare (1.1.1.1 / 1.0.0.1)
✔ Blocks plaintext DNS (TCP/UDP port 53)
✔ Disables IPv6 leaks on active adapters
✔ Provides a full installer interface:
 • Enable DoH Stealth Mode
 • Disable / Restore system defaults
✔ No telemetry, no logging, open-source
✔ Works on Windows 10 & Windows 11

---

# 📦 **Download**

---

# 📘 **How to Install (EXE Version)**

1. **Download `DoH.exe`** from the Releases section.
2. Right-click the file → **Run as Administrator**
3. The installer interface will open.
4. Choose:

```
1 – Enable DoH Stealth Mode
```

5. Wait until all steps complete.
6. Restart your computer.

---

# 🛡️ **What Happens When You Enable Stealth Mode?**

The installer will:

1. Add Cloudflare DoH provider to Windows registry
2. Set DNS to 1.1.1.1 / 1.0.0.1
3. Enable encrypted DoH templates
4. Disable IPv6 on active network adapters
5. Block plain DNS using Windows Firewall
6. Confirm that encrypted DNS is active

---

# 🔄 **How to Disable / Undo All Changes**

If you want to revert everything:

1. Run `DoH.exe` again as Administrator
2. Choose:

```
2 – Disable DoH Stealth Mode (restore defaults)
```

This will:

* Restore DNS to DHCP
* Remove DoH registry entries
* Re-enable IPv6
* Remove firewall rules
* Clear DoH templates

Restart Windows afterward.

---

# 🧪 **How to Verify That DoH Is Working**

Open PowerShell and run:

```powershell
nslookup chat.openai.com
```

If DoH is working, you should see:

```
Server: one.one.one.one
Address: 1.1.1.1
```

If DNS requests are leaking, you will see:

```
DNS request timed out.
```

---

# ❗ Requirements

* Windows 10 or Windows 11
* Administrator privileges
* Internet connection

---

# 🧰 **Advanced Users – File Contents**

The installer uses:

* PowerShell automation
* Windows built-in DoH API
* Firewall rules via `New-NetFirewallRule`
* IPv6 control via network binding

No external libraries or dependencies are required.

---

# 📜 **License**

Open-source MIT License
You may modify, distribute, or integrate the installer freely.

---

# 📣 **Support & Issues**

If you experience problems:

* Drop an Issue in the GitHub repository
* Provide your Windows version and error message
* Logs are **not stored**, so describe what happened

---

# 🔥 **Take back your DNS privacy.

Enable DoH Stealth Mode today.**

---


