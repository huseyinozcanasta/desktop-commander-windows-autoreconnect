# Desktop Commander Windows Otomatik Yeniden Bağlanma

Windows kullanıcı oturumu açıldığında **Desktop Commander Remote MCP**'yi başlatan, kapanırsa tekrar deneyen bir **MIT lisanslı açık kaynak** yardımcı proje.

> Bağımsız topluluk projesidir. Microsoft/Windows parolalarını istemez, okumaz veya saklamaz. Autologon ayarını kendisi etkinleştirmez.

## Gerçek test

Windows 10 Pro üzerinde bir bilgisayar yeniden başlatıldı. Önceden yapılandırılmış Windows otomatik giriş gerçekleşti, Görev Zamanlayıcı watchdog betiğini başlattı, Remote Device yeniden bağlandı ve uzak PowerShell komutu başarıyla çalıştı. Bu **tek gerçek yeniden başlatma testi** olumlu; her cihazda %100 garanti anlamına gelmiyor.

## Kurulum

1. Node.js 18+ ve Desktop Commander hesabını hazırla. Bilgisayarında `node` ve `npm` komutları çalışmalı.
2. İlk defa şu komutla **etkileşimli** OAuth girişini tamamla; ardından `Ctrl+C` ile geçici ajanı kapat:

```powershell
npx -y @wonderwhy-er/desktop-commander@0.3.1 remote
```

3. Bu depoyu indir veya klonla. PowerShell'de depo klasörüne gir ve şu komutları çalıştır:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\status.ps1
```

4. Remote MCP panelinden cihazın bağlı olduğunu gör ve ChatGPT/uyumlu istemciden **zararsız bir komut** çalıştırarak doğrula. Görev durumunun `Running` olması tek başına yeterli değildir.
5. İstersen yeniden başlatma testi yap. Önceden erişim/kurtarma yöntemin hazır olsun.

Kullanıcı oturumunda `DesktopCommander-Public-Watchdog` adlı zamanlanmış görev çalışır. Node.js Remote Device süreçlerini kontrol eder ve eksikse yeniden başlatır. İkinci bir watchdog başlatılmaması için mutex kullanılır.

## Windows otomatik giriş: isteğe bağlı ve riskli

Görev **Windows açılır açılmaz değil, kullanıcı giriş yaptığında** başlar. Ekranı otomatik geçmesini de istiyorsan bunu sadece kendi yetkili bilgisayarında, [Microsoft Sysinternals Autologon](https://learn.microsoft.com/en-us/sysinternals/downloads/autologon) ile **manuel** yapılandırabilirsin.

Otomatik giriş fiziksel güvenliği azaltır. Yönetici yetkisine sahip kişiler, Autologon'un LSA'da şifrelenmiş parolasını çözebilir. Parolanı sohbet, betik, komut satırı veya GitHub üzerinden paylaşma. Ortak veya kolay erişilen bilgisayarlarda otomatik giriş kullanma.

## Kontrol ve kaldırma

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\status.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\uninstall.ps1
# Yerel dosyalar ve loglar da silinsin:
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\uninstall.ps1 -RemoveLocalData
```

Kaldırma işlemi Microsoft Autologon ayarını değiştirmez. Bağlantının sürekliliğini yalnızca süreç/yeniden başlatma düzeyinde kontrol eder; OAuth veya servis kaynaklı bağlantı kesintilerini garanti ederek onaramaz. Ayrıntılar: [README.md](README.md), [SECURITY.md](SECURITY.md).

MIT © 2026 huseyinozcanasta
