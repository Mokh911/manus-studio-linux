<div align="center">

# مانوس ستوديو على لينكس

**شغّل تطبيق Manus Studio الرسمي على نظام لينكس.**

مانوس تصدر Studio لأنظمة macOS وويندوز فقط — لا توجد نسخة لينكس رسمية.
هذا المشروع ينزّل **الحزمة الرسمية** لماك من سيرفرات Manus نفسها، يستخرج
كود التطبيق، ويشغّله على زمن تشغيل Electron المطابق للينكس. لا يحتوي هذا
المستودع على أي ملف من ملفات التطبيق نفسه.

[![المنصة](https://img.shields.io/badge/platform-Linux_x86_64-blue)](https://github.com/Mokh911/manus-studio-linux)
[![Manus Studio](https://img.shields.io/badge/Manus_Studio-2.0.7-8A2BE2)](https://manus.im/download)
[![Electron](https://img.shields.io/badge/Electron-43.6.0-47848F?logo=electron&logoColor=white)](https://www.electronjs.org)
[![الترخيص](https://img.shields.io/badge/wrapper_license-MIT-green)](LICENSE)
[![غير رسمي](https://img.shields.io/badge/status-unofficial-orange)](#-تنبيه)

**[English](README.md) · [العربية](README.ar.md)**

</div>

---

## ⚠️ تنبيه

- هذا مشروع **غير رسمي** من المجتمع، ولا علاقة له بشركة Manus ولا موافقة منها ولا رعاية لها.
- **لا يحتوي** هذا المستودع على تطبيق Manus Studio نفسه. سكربت `install.sh`
  ينزّل المثبّت الرسمي من `download.manus.im` (سيرفرات Manus الرسمية) عبر
  HTTPS ويشغّله محليًا على جهازك.
- تطبيق Manus Studio وأصوله تبقى ملكًا لصاحبها — راجع ملف [NOTICE](NOTICE).
  إذا كنت ممثلًا عن Manus وتريد إزالة هذا المشروع، افتح Issue وسنحذفه فورًا.

## ✨ كيف يعمل

```
Manus-Setup-<version>.dmg          ← حزمة الماك الرسمية (download.manus.im)
        │  7-Zip
        ▼
Contents/Resources/app.asar        ← التطبيق الفعلي (نفس الكود الذي
        │                            تشغّله نسخ الماك/ويندوز)
        ▼
~/.local/share/manus-studio/app/   ← كود التطبيق بعد التثبيت
        +
Electron <version> Linux x86_64    ← زمن تشغيل Electron الرسمي للينكس
        │
        ▼
manus-studio                       ← المشغّل الذي يفتح التطبيق
```

نسخة Electron المستخدمة هنا (`43.6.0`) مطابقة لزمن التشغيل الذي بُني عليه
إصدار 2.0.7 الرسمي، فيعمل التطبيق على نفس البيئة التي جُهّز له.

## 📦 المتطلبات

| المتطلب | ملاحظات |
|---|---|
| لينكس x86_64 | معالج 64-bit إنتل/AMD |
| مساحة ~1.5 جيجابايت | كود التطبيق + زمن التشغيل |
| `curl` | للتنزيل |
| `7-Zip` (`p7zip-full`) | لفكّ ملف الـ .dmg |
| جلسة سطح مكتب X11/Wayland | تطبيق بواجهة رسومية |

## 🚀 التثبيت

بأمر واحد (دون استنساخ المستودع):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Mokh911/manus-studio-linux/main/install.sh)
```

أو استنسخ أولًا:

```bash
git clone https://github.com/Mokh911/manus-studio-linux.git
cd manus-studio-linux
./install.sh
```

تثبيت دون اتصال من ملف `.dmg` عندك مسبقًا:

```bash
MANUS_DMG=/path/to/Manus-Setup-2.0.7.dmg ./install.sh
```

### أين يُثبَّت كل شيء

| العنصر | المسار |
|---|---|
| مجلد التثبيت | `~/.local/share/manus-studio/` |
| كود التطبيق | `~/.local/share/manus-studio/app/` |
| زمن تشغيل Electron | `~/.local/share/manus-studio/electron/` |
| المشغّل | `~/.local/bin/manus-studio` |
| مدخل القائمة | `~/.local/share/applications/manus-studio.desktop` |
| ملف الجلسة (تسجيل الدخول) | `~/.config/Manus Studio/` |

## ⚙️ متغيرات البيئة

| المتغير | الافتراضي | الوظيفة |
|---|---|---|
| `MANUS_VERSION` | `2.0.7` | إصدار Manus Studio المراد تثبيته |
| `ELECTRON_VERSION` | `43.6.0` | إصدار Electron |
| `MANUS_STUDIO_HOME` | `~/.local/share/manus-studio` | مجلد التثبيت |
| `MANUS_STUDIO_USER_DATA` | `~/.config/Manus Studio` | مجلد الملف الشخصي |
| `MANUS_DMG` | — | التثبيت من ملف `.dmg` محلي |
| `MANUS_STUDIO_SKIP_DESKTOP` | `0` | اجعله `1` لتخطي مدخل القائمة |

## 🔑 أول تسجيل دخول

1. افتح **Manus Studio** من قائمة التطبيقات، أو نفّذ `manus-studio` من الطرفية.
2. تظهر صفحة **Sign in to Manus** → اضغط **Sign in** فيُفتح متصفحك على
   `manus.im/login`.
3. سجّل الدخول داخل المتصفح.
4. يعيد المتصفح التوجيه إلى `manuslocal://app?token=…` — والبروتوكول مسجّل
   مسبقًا بواسطة المثبّت، فيلتقطه التطبيق ويُكمل الدخول تلقائيًا.

إذا لم يُعد التوجيه إلى التطبيق، تحقق من:

```bash
xdg-mime query default x-scheme-handler/manuslocal
# المفروض يطبع: manus-studio.desktop
```

## 🧪 ما يعمل / ما لا يعمل

مُختبَر على جهاز واحد (أوبونتو، x86_64، كرت شاشة Intel Haswell) — الدليل
الكامل في [docs/TESTING.md](docs/TESTING.md).

| الميزة | الحالة | السبب |
|---|---|---|
| الدردشة والمهام والوكلاء السحابيون | ✅ تعمل | تُخدم من `api.manus.im` |
| تسجيل الدخول عبر المتصفح | ✅ يعمل | بروتوكول `manuslocal://` مسجّل |
| **My Computer / التحكم بالجهاز محليًا** | ❌ غير متاح | الحزمة الرسمية تضم أدوات التحكم بالجهاز لماك/ويندوز فقط — لا يوجد أي helper للينكس داخل الحزمة |
| أيقونة النظام (Tray) | ⚠️ معطّلة | تكامل الـ tray لماك/ويندوز؛ إغلاق النافذة يُنهي التطبيق |
| تسريع الرسوميات | ⚠️ برمجي | يعمل بـ `--disable-gpu --enable-unsafe-swiftshader` |

## 🧯 حل المشاكل

- **التطبيق لا يبدأ** — شغّل المشغّل من الطرفية واقرأ الخطأ: `manus-studio`.
  رسالة "Electron runtime not found" أو "app payload not found" تعني إعادة
  تشغيل `install.sh`.
- **نافذة فارغة على بعض الكروت** — المشغّل يعطّل الـ GPU مسبقًا. إذا كان عندك
  تعريف كرت شاشة سليم، جرّب إزالة الخيارين
  `--disable-gpu --enable-unsafe-swiftshader` من
  `~/.local/bin/manus-studio`.
- **ضاع رابط تسجيل الدخول** — تحقق من معالج `manuslocal://` (فوق)، ثم سجّل
  الدخول من جديد.
- **نُزّل إصدار خاطئ** — حدّد `MANUS_VERSION`:
  `MANUS_VERSION=2.0.7 ./install.sh`. الإصدارات المنشورة حاليًا في
  <https://manus.im/download>.
- **حذف كل شيء نهائيًا:**

  ```bash
  bash ~/.local/share/manus-studio/uninstall.sh
  ```

## ❓ أسئلة متكررة

**هل هذا المشروع رسمي؟**
لا. انظر قسم التنبيه. كود التطبيق نفسه رسمي، لكن تعبئة اللينكس عمل مجتمعي.

**هل هو آمن؟**
يُنزَّل كود التطبيق عبر HTTPS من سيرفرات Manus الرسمية
(`download.manus.im`) — نفس المثبّت الذي يستلمه مستخدمو الماك/ويندوز.
هذا المستودع لا يضم أي ملفات تنفيذية ولا كودًا معدّلًا ولا ملفات معاد رفعها.

**ليش ما سويتو AppImage أو حزمة deb؟**
بقصد التبسيط: سكربت واحد بلا عبء صيانة تغليف. وترحيب بالمساهمات.

**هل يتحدّث تلقائيًا؟**
لا. المُحدِّث الرسمي يفترض التطبيق المُغلَّف. للتحديث: أعد تشغيل
`install.sh` مع `MANUS_VERSION` الجديد.

## 📄 الترخيص

سكربتات هذا المستودع مرخّصة تحت
[رخصة MIT](LICENSE). **تطبيق Manus Studio نفسه لا يشمله هذا الترخيص**
ولا يُوزَّع من هنا — راجع [NOTICE](NOTICE).
