# CatsAndModules_Sydorenko01

Тестове завдання №1 (курс «Робота в середовищі Apple»). Мобільний додаток iOS,
що відображає список котиків з [TheCatAPI](https://thecatapi.com), побудований
з **двох модулів**.

## Архітектура — Xcode Project + Targets

Один Xcode-проєкт із двома таргетами:

| Модуль | Тип | Платформи | Призначення |
|--------|-----|-----------|-------------|
| **Networking** | Dynamic Framework | iOS, iPadOS, macOS | Уся робота з мережею. Публічний API. |
| **CatsAndModules_Sydorenko01** | App | iOS, iPadOS | Точка входу + верстка (SwiftUI). |

Додаток залежить від `Networking` (Target Dependency + Link + Embed) і
**ніколи не звертається до мережі напряму** — лише через публічний API.

### Модуль Networking (публічний API)
- `Cat` — модель котика (`id`, `url`, `width`, `height`).
- `CatService` — протокол з методом `getCats(limit:) async throws -> [Cat]`.
- `CatAPIClient` — реалізація на `URLSession` (async/await). API-ключ опціональний.
- `NetworkingError` — типізовані помилки.

### Модуль додатку (SwiftUI)
- `CatListView` — список котиків (картинка + випадкове ім'я).
- `CatDetailView` — **повноекранний перегляд** картинки з кнопкою «назад» (бонус +1).
- `CatListViewModel` — використовує `CatService`.

## Що зроблено
- ✅ (8) Додаток з двох модулів, список котиків з API.
- ✅ (+1) Повноекранний перегляд котика по натиску на рядок + повернення назад.
- ✅ (+3) Архітектура готова до ручного підпису обох модулів (див. нижче).

## Як відкрити
Відкрийте `CatsAndModules_Sydorenko01.xcodeproj` у Xcode 15+, оберіть симулятор
iPhone/iPad і натисніть Run. Інтернет потрібен для завантаження картинок.

## Ручний підпис коду (бонус +3)

Сертифікат, профіль і пристрій у вас уже встановлені. Залишилось налаштувати
проєкт. **Зробіть це для обох таргетів — і для Debug, і для Release.**

1. У Xcode виберіть таргет → вкладка **Signing & Capabilities**.
2. Зніміть галочку **Automatically manage signing**.
3. У полі **Provisioning Profile** натисніть та оберіть ваш профіль (якщо його
   немає у списку — **Import Profile…** і вкажіть `.mobileprovision`).
4. Переконайтесь, що **Bundle Identifier** збігається з App ID у вашому профілі
   (поточні: `com.olena.CatsAndModules-Sydorenko01` та `com.olena.Networking` —
   змініть на свої, якщо профіль не wildcard).
5. Повторіть кроки 1–4 для **другого таргета** і **обох конфігурацій** (Debug/Release).

> ⚠️ Не забудьте додати телефон перевіряючого (`g_f0x_phone`) до профілю, інакше
> роботу не вдасться перевірити.

## Здача
Заархівуйте папку `CatsAndModules_Sydorenko01/` у
`CatsAndModules_Sydorenko01.zip` і **додайте до архіву файл профілю**
(`.mobileprovision`), яким підписували додаток.
