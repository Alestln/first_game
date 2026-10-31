# 🎮 Методический план занятия №6: «Пользовательский интерфейс (UI): адаптивный HUD, счётчик монет и шкала здоровья в Godot 4»

**Формат:** Пошаговый LiveCode-практикум для детей (10–15 лет)  
**Продолжительность:** 60–90 минут (75 мин база + 15 мин бонус с сердечками)  
**Движок:** Godot 4.3+ (2D Platformer)  
**Ветка проекта:** `feature/add-base-ui`  
**Три главных правила кода на занятии:** `1. Не хардкодить!` · `2. Никаких магических цифр!` · `3. YAGNI!`

---

## 🧭 Как преподавателю вести занятие по шагам (Git-ветки и подготовка)

Рекомендуемая разбивка занятия на контрольные Git-ветки (если ученик отстал или нужно быстро показать готовый этап):

```bash
git checkout step-1-canvas-layer     # Шаг 1: Сцена HUD (CanvasLayer) и отличие Control от Node2D
git checkout step-2-adaptive-layout  # Шаг 2: Адаптивный каркас (MarginContainer + HBoxContainer)
git checkout step-3-coin-counter     # Шаг 3: Счётчик монет (AtlasTexture + сигнал coins_changed)
git checkout step-4-health-bar       # Шаг 4: Шкала здоровья (TextureProgressBar + Tween + DamageZone)
git checkout step-5-hearts-bonus     # Шаг 5 (Бонус): Динамические сердечки (HeartsBar) без хардкода
```

*Вернуться к полной итоговой ветке занятия:* `git checkout feature/add-base-ui`

### Чеклист преподавателя перед стартом урока:
1. **Быстрая отладка без ожидания катсцены:** в сцене `scenes/world.tscn` выберите узел `IntroPath` и в Инспекторе временно включите галочку **`Skip Intro = true`**, чтобы при каждом запуске (`F5`) не ждать 6 секунд пролёта камеры.
2. **Текстуры для UI (папка `assets/ui/`):**
   - Для иконки монеты внешний файл **не нужен** — мы вырежем первый кадр прямо из уже существующего в проекте спрайтшита `assets/animations/coin/gold_spin.png` с помощью `AtlasTexture`!
   - Для полоски здоровья подготовьте 2–3 пиксельных файла (рекомендуемый размер под наш холст `640×360`: **`96×16` px**): `bar_under.png` (фон), `bar_progress.png` (заполнение), `bar_over.png` (рамка, опционально). *В Блоке 4 также дан «План Б» на встроенных `GradientTexture2D` без единого внешнего файла за 20 секунд.*
   - Для бонус-блока с сердечками: `heart_full.png` (**`16×16` px**) и `heart_empty.png` (**`16×16` px**).

---

## ⏱️ Тайминг занятия

- **00:00 – 00:05 (5 мин)** — Вводная интрига: почему `print(coins)` в консоли — это не игра, и три золотых правила взрослого кода.
- **00:05 – 00:20 (15 мин)** — Блок 1. `CanvasLayer` и зелёный мир `Control`-нод: почему интерфейс нельзя клеить к игроку.
- **00:20 – 00:35 (15 мин)** — Блок 2. Адаптивная вёрстка: якоря (`Anchors`), безопасные поля (`MarginContainer`) и контейнеры (`HBoxContainer`).
- **00:35 – 00:50 (15 мин)** — Блок 3. Счётчик монет: `AtlasTexture`, обводка текста и паттерн «Наблюдатель» на сигналах.
- **00:50 – 01:15 (25 мин)** — Блок 4. Шкала здоровья (`TextureProgressBar`): три слоя текстур, плавный `Tween` и тест урона через `DamageZone`.
- **01:15 – 01:30 (15 мин, если осталось время)** — Блок 5 (Бонус). Здоровье как сердечки (`HeartsBar`): динамическая генерация без копипасты.
- **01:30 – 01:35 (5 мин)** — Итоги, разбор типичных ошибок, домашний челлендж.

---

## 🎬 Вводная часть (5 мин). Интрига и 3 правила программиста

> **Слова преподавателя:**  
> *«Ребята, давайте запустим нашу игру и соберём пару монеток. Куда сейчас выводятся наши очки? В нижнюю консоль редактора через `print(coins)` — причём 60 раз в секунду!  
> А теперь представьте, что мы отправили готовую игру другу. У него нет редактора Godot и нет консоли! Он бегает, собирает золото, получает урон от ловушек — но экран абсолютно пустой: ни счётчика богатства, ни запаса здоровья.  
> Более того: один друг откроет игру на квадратном планшете, а другой — на широком смартфоне. Если просто накидать картинки мышкой в угол, на широком экране интерфейс позорно зависнет посередине, а на узком — улетит за край!  
> Сегодня мы создадим профессиональный адаптивный **HUD** (Heads-Up Display — экранный интерфейс), который идеально подстраивается под любой монитор и работает на событиях без потери FPS!»*

### 📜 Три железных правила нашего кода сегодня (записать на доске):

1. **НЕ ХАРДКОДИТЬ!**  
   Никаких зашитых путей вроде `$MarginContainer/TopBar/CoinBox/CoinLabel` или `"res://..."` внутри скриптов! Стоит дизайнеру переложить текст в другую рамку — и захардкоженный путь обрушит игру. Все ссылки передаём только через `@export`, а связь игрока с UI строим через **сигналы**.
2. **НИКАКИХ МАГИЧЕСКИХ ЦИФР!**  
   Если посреди функции внезапно написано число `100`, `20` или `0.25` — через неделю никто не вспомнит, что оно значит. Все настройки выносим в понятные `@export var` или именованные константы `const`. Игровой интерфейс должен сам узнавать максимальное здоровье у игрока, а не угадывать число `100`!
3. **YAGNI (*You Aren't Gonna Need It* — «Тебе это не понадобится»)!**  
   Не пишем код «на вырост» для маны, инвентаря на 50 слотов или сохранения в облако, пока этого нет в игре. Пишем только то, что реально работает прямо сейчас — чисто, коротко и понятно.

---

## 🟢 Блок 1. `CanvasLayer` и зелёный мир `Control`-нод (LiveCode)

### 1.1. Опыт на экране: две классические ошибки новичка

> **Демонстрация преподавателя:**  
> **Опыт №1:** Добавляем узел `Label` с текстом `"Coins: 0"` прямо в корень сцены `World` рядом с игроком. Запускаем игру (`F5`), бежим влево за монетками.  
> **Что видят дети?** Надпись осталась висеть в воздухе на месте старта и уехала за край экрана, как деревянная табличка на земле!  
> **Опыт №2:** Перетаскиваем `Label` внутрь узла `Player`. Запускаем игру.  
> **Что видят дети?** Надпись бешено прыгает вместе с героем, врезается в потолок, да ещё и стала гигантской, потому что унаследовала `Player.scale = Vector2(2, 2)`! *(Удаляем тестовый `Label`).*

### 1.2. Три цвета узлов в Godot 4

> **Вопрос классу:** *«Обратите внимание на цвет иконок в окне создания узла. Почему `Player` и `Sprite2D` синие, а `Label` и `TextureRect` — зелёные?»*  
> **Объяснение:**
> - 🔵 **Синие (`Node2D`)** — объекты игрового мира (платформы, герой, монетки). У них есть физика, координаты уровня, и на них смотрит камера.
> - 🟢 **Зелёные (`Control`)** — элементы пользовательского интерфейса (текст, кнопки, полоски здоровья, умные контейнеры). Они умеют растягиваться и прижиматься к углам экрана.
> - ⚪ **Белые (`Node`, `CanvasLayer`)** — организаторы и экранные слои.
>
> **Главный запрет UI в Godot:** Никогда не кладите синий `Sprite2D` внутрь зелёных контейнеров интерфейса! Зелёные контейнеры не видят размеров синих узлов и сплющат их в точку `(0, 0)`. Для любых картинок в интерфейсе всегда используем зелёный **`TextureRect`**!

### 1.3. Создаём отдельную сцену интерфейса `scenes/hud.tscn`

> **Вопрос классу:** *«На прошлом уроке мы создавали `SkyLayer` (`CanvasLayer`) со свойством `Layer = -10`, чтобы небо рисовалось позади всего мира. Какой `Layer` должен быть у интерфейса?»*  
> **Вывод:** Положительный (`Layer = 1` стоит по умолчанию)! Тогда интерфейс всегда рисуется на «лобовом стекле» поверх тайлов, монет и персонажа.  
> **Зачем делать отдельную сцену `hud.tscn`, а не лепить узлы прямо в `world.tscn`?** Чтобы не хардкодить интерфейс под один уровень! Когда мы создадим Уровень 2 и Уровень 3, мы добавим туда готовый `hud.tscn` одним кликом.

**Пошаговые действия:**
1. Нажимаем в верхнем меню **Сцена (Scene) ➔ Новая сцена (New Scene)**.
2. Выбираем **Другой узел (Other Node) ➔ `CanvasLayer`**. Переименовываем корень в **`HUD`**.
3. Проверяем в Инспекторе: `Layer = 1`.
4. Сохраняем сцену (`Ctrl + S`) под именем **`res://scenes/hud.tscn`**.

---

## 📐 Блок 2. Адаптивная вёрстка: Якоря и Контейнеры (LiveCode)

### 2.1. Включаем проверку адаптивности экрана

По умолчанию в нашем проекте окно имеет виртуальное разрешение `640×360` (пропорция 16:9). Давайте разрешим игре честно расширять обзор на любых широкоформатных экранах без чёрных полос по бокам!

1. Открываем **Проект (Project) ➔ Настройки проекта (Project Settings) ➔ Display ➔ Window**.
2. В разделе **Stretch** находим параметр **`Aspect`** и ставим **`expand`** (вместо `keep`).
   - *Зачем:* Теперь, если игрок растянет окно в ширину (как на современном смартфоне 20:9) или в высоту (как на планшете 4:3), игровой холст реально изменит свои пропорции, и мы сразу увидим, умеет ли наш интерфейс адаптироваться!
   - *💡 Заметка преподавателю:* Для демонстрации адаптивности UI по обеим осям режим `expand` идеален. В финальном релизе горизонтального 2D-платформера также часто выбирают `keep_height` — он адаптирует ширину экрана под любые мониторы и смартфоны, но фиксирует вертикальный обзор камеры `360 px`, чтобы под горами параллакса снизу не оголялось небо на слишком узких вертикальных окнах.

### 2.2. Почему нельзя расставлять интерфейс мышкой?

> **Аналогия для детей:**  
> *«Представьте, что вы прибили счётчик монет гвоздём на расстоянии `580` пикселей от левого края экрана (ширина нашего экрана `640`). Это и есть **хардкод координат**! На широком экране шириной `900` пикселей ваш счётчик позорно зависнет посередине, а на узком экране `480` пикселей — улетит за правую границу в пустоту!  
> В профессиональной вёрстке элементы не прибивают к координатам `X, Y`, а складывают в **умные коробки-контейнеры** с пружинками и отступами».*

### 2.3. Собираем каркас адаптивного HUD

Собираем в сцене `scenes/hud.tscn` следующую иерархию зелёных узлов:

```text
HUD (CanvasLayer)
└── MarginContainer (MarginContainer)      # Безопасный отступ от краёв экрана
    └── TopBar (HBoxContainer)             # Верхняя горизонтальная строка
        ├── HealthBar (TextureProgressBar) # Слева: шкала здоровья
        └── CoinBox (HBoxContainer)        # Справа: блок монетки (иконка + число)
            ├── CoinIcon (TextureRect)
            └── CoinLabel (Label)
```

**Шаг 1. Безопасная рамка `MarginContainer` (Safe Area):**
1. Дочерним узлом к `HUD` добавляем **`MarginContainer`**.
2. На верхней панели 2D-редактора нажимаем зелёный значок **Якоря (Anchors Preset) ➔ `Full Rect`** (растянуть на весь экран).
3. В Инспекторе у `MarginContainer`:
   - Раздел **Mouse ➔ `Filter = Ignore`**  
     *Зачем:* Невидимый контейнер во весь экран не должен перехватывать клики мыши в будущих меню.
   - Раздел **Theme Overrides ➔ Constants**:
     - `Margin Left = 12`
     - `Margin Top = 10`
     - `Margin Right = 12`
     - `Margin Bottom = 10`  
     *Зачем:* В геймдизайне интерфейс никогда не прилипает вплотную к рамке монитора или скруглённым углам смартфона. Мы задали аккуратный «воздух» по периметру экрана.

**Шаг 2. Верхняя панель `TopBar` (`HBoxContainer`):**
1. Внутрь `MarginContainer` добавляем **`HBoxContainer`** и называем его **`TopBar`** (*Horizontal Box* — коробка, выстраивающая детей в ряд слева направо).
2. **Критически важная настройка в Инспекторе `TopBar`:**
   - Открываем **Layout ➔ Container Sizing ➔ Vertical** и выбираем **`Shrink Begin`** (снимаем галочку `Fill`, прижимаем к верху!).  
     *Зачем:* По умолчанию `MarginContainer` растягивает ребёнка на все `360` пикселей до самого пола! Режим `Shrink Begin` прижимает верхнюю панель аккуратно к потолку экрана по высоте её содержимого.

**Шаг 3. Левый и правый углы внутри `TopBar` без пустых распорок:**
1. Внутрь `TopBar` добавляем **`TextureProgressBar`** и называем **`HealthBar`** (он автоматически встанет **слева**).
   - В `Layout ➔ Container Sizing ➔ Vertical` ставим **`Shrink Center`** (выравнивание по вертикальному центру верхней строки).
2. Внутрь `TopBar` вторым ребёнком добавляем **`HBoxContainer`** и называем **`CoinBox`** (группа для иконки монеты и цифр).
   - В Инспекторе `CoinBox` открываем **Layout ➔ Container Sizing ➔ Horizontal**:
     - Ставим галочку **`Expand = ВКЛ`** (забрать всё свободное место справа от полоски здоровья).
     - Переключаем режим с `Fill` на **`Shrink End`** (прижаться к самому правому краю!).  
     *Зачем это гениально:* Теперь, когда число монет вырастет с `"0"` до `"99999"`, блок `CoinBox` будет автоматически расширяться **влево внутрь экрана**, и цифры никогда не вылезут за правую рамку монитора!
   - В `Theme Overrides ➔ Constants` у `CoinBox` ставим **`Separation = 4`** (отступ 4 пикселя между иконкой монетки и цифрами).

---

## 🪙 Блок 3. Счётчик монет: `AtlasTexture` и сигналы (LiveCode)

### 3.1. Настраиваем иконку монеты и читаемый текст

1. Внутрь `CoinBox` добавляем **`TextureRect`** (называем **`CoinIcon`**).
   - *Демонстрация:* Если просто перетащить `assets/animations/coin/gold_spin.png` в поле `Texture`, на экране появится смешная «колбаса» сразу из 7 кадров вращения монеты!
   - **Решение без фотошопа (`AtlasTexture`):**
     - В поле `Texture` у `CoinIcon` нажимаем стрелочку ➔ **`New AtlasTexture`**.
     - Кликаем по созданному `AtlasTexture`, чтобы раскрыть его свойства.
     - В поле **`Atlas`** перетаскиваем `assets/animations/coin/gold_spin.png`.
     - Нажимаем кнопку **`Edit Region`** (или вписываем `Region`: `x = 0, y = 0, w = 25, h = 25`) — ровно первый кадр нашей золотой монетки!
   - У самого `CoinIcon` ставим **`Stretch Mode = Keep Aspect Centered`**.
2. Внутрь `CoinBox` вторым узлом добавляем **`Label`** (называем **`CoinLabel`**):
   - В поле `Text` для предпросмотра пишем `0`.
   - **Вопрос классу:** *«Что произойдёт с белой цифрой `0`, когда над ней проплывёт белое облако параллакса?»*  
     Цифра исчезнет! Создаём контрастную обводку:
   - В поле **`Label Settings`** выбираем **`New LabelSettings`**, раскрываем его:
     - `Font Size = 16`
     - `Outline Size = 4`
     - `Outline Color = Чёрный (#000000)`

### 3.2. Архитектура без хардкода: Сигналы (Паттерн «Наблюдатель»)

> **Диалог с классом:**  
> *«Раньше в `player.gd` у нас стояла функция `func _process(delta): print(coins)`. Она работала 60 раз каждую секунду! Если за 5 минут игры мы собрали всего 10 монет, функция впустую сработала **18 000 раз**!  
> Ещё хуже, если `HUD` будет каждый кадр лезть в игрока или игрок будет искать `$HUD/MarginContainer/.../CoinLabel`. Стоит удалить интерфейс со сцены — и игрок сломается!  
> Вместо этого мы используем **Сигналы (паттерн Observer / Наблюдатель)**. Игрок просто кричит в громкоговоритель: **"Эй, моё количество монет изменилось!"**. Ему всё равно, слушает ли его интерфейс, система достижений или звук. А `HUD` подписывается на этот сигнал и обновляет текст **ровно в тот момент, когда подобрана монета**!»*

### 3.3. Рефакторим `scripts/coin.gd` и `scripts/player.gd`

1. Открываем **`scripts/coin.gd`** и делаем ценность монеты настраиваемой в Инспекторе (убираем зашитую в скрипт единицу):

```gdscript
@export var coin_value: int = 1
```
*(Теперь в Инспекторе любую монетку на уровне можно сделать редкой рубиновой монетой на 5 или 10 очков без единой строчки кода!).*

2. Открываем **`scripts/player.gd`**:
   - **Удаляем** старый метод `func _process(delta: float) -> void: print(coins)` — он нам больше не нужен (**YAGNI**!).
   - В самом верху скрипта (после `extends CharacterBody2D`) объявляем сигнал и константу минимума:

```gdscript
signal coins_changed(new_coins: int)

const MIN_COINS: int = 0
```

   - Обновляем переменную `coins`, добавляя ей **сеттер (`set(value)`)** (дети уже видели сеттеры в `camera_frame.gd`!):

```gdscript
var coins: int = MIN_COINS:
	set(value):
		coins = max(MIN_COINS, value)
		coins_changed.emit(coins)
```

**Разбор каждой строчки:**
- `const MIN_COINS: int = 0` — именованная константа нижней границы (никаких безымянных чисел).
- `set(value):` — умный перехватчик! Как только монетка выполняет `player.coins += coin_value`, автоматически срабатывает этот блок.
- `max(MIN_COINS, value)` — защита от багов: количество монет никогда не уйдёт в минус.
- `coins_changed.emit(coins)` — мгновенно рассылает сигнал с новым числом монет всем подписчикам.

### 3.4. Пишем чистый скрипт `scripts/hud.gd` (Этап 1 — только монеты по YAGNI!)

Прикрепляем к корневому узлу `HUD` в сцене `scenes/hud.tscn` новый скрипт **`res://scripts/hud.gd`**:

```gdscript
class_name HUD
extends CanvasLayer

@export var player: Player
@export var coin_label: Label

func _ready() -> void:
	assert(player != null, "%s: 'player' обязателен для работы!" % name)
	assert(coin_label != null, "%s: 'coin_label' обязателен для работы!" % name)
	
	player.coins_changed.connect(_on_coins_changed)
	_on_coins_changed(player.coins)

func _on_coins_changed(new_coins: int) -> void:
	coin_label.text = str(new_coins)
```

**Почему мы написали `@export var coin_label: Label`, а НЕ `$MarginContainer/TopBar/CoinBox/CoinLabel`?**
- Если завтра мы захотим обернуть `CoinBox` в красивую тёмную рамку `PanelContainer`, путь к узлу изменится, и запись через `$` **обрушит игру с ошибкой `Nil`**!
- Ссылка через `@export var coin_label: Label` привязывается в Инспекторе. Даже если вы переименуете или перетащите `CoinLabel` в другое место внутри `hud.tscn`, Godot **автоматически обновит ссылку**, и код не сломается никогда!
- Вызов `_on_coins_changed(player.coins)` в конце `_ready()` сразу синхронизирует стартовое число на экране при запуске уровня.

**Подключение в сцене:**
1. В сцене **`scenes/hud.tscn`** выбираем корень `HUD` и в Инспекторе в слот **`Coin Label`** перетаскиваем узел `CoinLabel`. Сохраняем сцену (`Ctrl + S`).
2. Открываем **`scenes/world.tscn`**, нажимаем значок цепочки (**Instantiate Child Scene**) и добавляем **`scenes/hud.tscn`** в корень `World`.
3. Выбираем добавленный `HUD` в `world.tscn` и в Инспекторе в слот **`Player`** назначаем узел `Player`.

> **Тест:** Запускаем проект (`F5`), собираем монетки и прямо во время игры тянем край окна мышкой в ширину и высоту!  
> **Результат:** Консоль чистая, счётчик мгновенно увеличивается при сборе золота и железно держится в правом верхнем углу при любом размере окна!

---

## ❤️‍🩹 Блок 4. Шкала здоровья (`TextureProgressBar`) и плавный `Tween` (LiveCode)

### 4.1. Как устроен «бутерброд» `TextureProgressBar`?

Возвращаемся в сцену **`scenes/hud.tscn`** и выбираем узел **`HealthBar`** (`TextureProgressBar`).

> **Объяснение для детей:**  
> *«Обычный серый `ProgressBar` подходит для установки программ в Windows, но не для игры. `TextureProgressBar` работает как трёхслойный бутерброд из ваших пиксель-арт рисунков:*
> 1. **`Under` (Подложка)** — тёмное дно пустой колбы (показывает, сколько здоровья мы уже потеряли).
> 2. **`Progress` (Начинка)** — яркая красная или зелёная полоска жизни, которую движок обрезает в зависимости от текущего ХП.
> 3. **`Over` (Крышка / Рамка)** — декоративная окантовка с бликами, которая рисуется поверх полоски».*

**Настройка `HealthBar` в Инспекторе:**
1. Открываем раздел **Textures**:
   - В **`Under`** перетаскиваем текстуру фона (`assets/ui/bar_under.png`).
   - В **`Progress`** перетаскиваем текстуру заполнения (`assets/ui/bar_progress.png`).
   - В **`Over`** (если рамка нарисована отдельно) — `assets/ui/bar_over.png`. *(В наших спрайтах рамка `bar_over.png` имеет размер `96×16` и толщину бортика 3 пикселя, а заполнение `bar_progress.png` — `90×10`, поэтому задаём **`Texture Progress Offset = Vector2(3, 3)`**).*
2. Открываем раздел **Range** (унаследован от базового класса шкал):
   - **`Step = 0.01`** *(Критически важная настройка!)*  
     *Зачем:* По умолчанию `Step` равен `1.0` — полоска двигается только грубыми рывками по целым единицам! Значение `0.01` разрешает плавной анимации `Tween` скользить мягко, пиксель за пикселем.
   - *А нужно ли вручную вбивать `Max Value = 100`?* **Нет!** Наш код сам возьмёт максимум у игрока, чтобы мы никогда не дублировали числа в двух местах!

> 💡 **План Б для преподавателя (если нет внешних `.png` файлов под рукой):**  
> Вы можете за 20 секунд собрать стильную ретро-полоску прямо внутри Godot!  
> 1. В слот `Textures ➔ Under` выберите **`New GradientTexture2D`**: поставьте `Width = 96`, `Height = 14`, а оба цвета градиента сделайте тёмно-графитовыми (`#1e1e2e`).  
> 2. В слот `Textures ➔ Progress` выберите **`New GradientTexture2D`**: поставьте `Width = 92`, `Height = 10`, цвета градиента — от алого (`#e63946`) к коралловому (`#ff6b6b`).  
> 3. Поставьте `Texture Progress Offset = Vector2(2, 2)`. Готово — у вас полоска здоровья с чёткой тёмной рамкой толщиной 2 пикселя без единого файла!

### 4.2. Проектируем здоровье в `scripts/player.gd` (Без магических цифр!)

> **Вопрос классу:** *«Какие данные должен передавать сигнал `health_changed`? Только текущее здоровье `current_health` или ещё и `max_health`?»*  
> **Вывод:** Обязательно **оба числа** (`current_health` и `max_health`)! Если интерфейс не знает `max_health`, программисту придётся захардкодить число `100` в интерфейсе. А если завтра герой наденет броню на `150` ХП или мы перейдём на `5` сердечек — захардкоженный интерфейс сломается!

Дополняем **`scripts/player.gd`**:

1. Добавляем сигнал, константу и экспортируемый максимум здоровья:

```gdscript
signal coins_changed(new_coins: int)
signal health_changed(current_health: int, max_health: int)

const MIN_COINS: int = 0
const MIN_HEALTH: int = 0

@export var max_health: int = 100
```

2. Добавляем переменную `health` с безопасным сеттером `clampi`:

```gdscript
var health: int = MIN_HEALTH:
	set(value):
		health = clampi(value, MIN_HEALTH, max_health)
		health_changed.emit(health, max_health)
```

3. В методе `_enter_tree()` инициализируем полное здоровье при появлении игрока на уровне:

```gdscript
func _enter_tree() -> void:
	assert(instance == null, "На сцене может быть только один экземпляр Player!")
	instance = self
	health = max_health
```

4. Добавляем чистый метод получения урона в конец `scripts/player.gd`:

```gdscript
func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	health -= amount
```

**Разбор архитектурных решений:**
- Почему `health = max_health` стоит в `_enter_tree()`, а не `var health: int = max_health` в шапке класса?  
  В Godot строки `var ... = ...` в шапке выполняются **до** того, как движок применит настройки Инспектора сцены! Если бы вы поменяли `Max Health` в Инспекторе со `100` на `150`, переменная `health` осталась бы равна старым `100`. А в `_enter_tree()` настройки Инспектора уже загружены — и причём это происходит **до** запуска `_ready()` у `HUD`!
- `clampi(value, MIN_HEALTH, max_health)` — железная гарантия: здоровье никогда не упадёт в `-20` и не превысит `max_health`.

### 4.3. Учим `scripts/hud.gd` плавно анимировать шкалу через `Tween`

Обновляем **`scripts/hud.gd`**, добавляя работу со шкалой здоровья:

```gdscript
class_name HUD
extends CanvasLayer

@export var player: Player
@export var coin_label: Label
@export var health_bar: TextureProgressBar
@export var health_tween_duration: float = 0.25

var _health_tween: Tween

func _ready() -> void:
	assert(player != null, "%s: 'player' обязателен для работы!" % name)
	assert(coin_label != null, "%s: 'coin_label' обязателен для работы!" % name)
	assert(health_bar != null, "%s: 'health_bar' обязателен для работы!" % name)
	
	player.coins_changed.connect(_on_coins_changed)
	player.health_changed.connect(_on_health_changed)
	
	_on_coins_changed(player.coins)
	_init_health_bar(player.health, player.max_health)

func _init_health_bar(current_health: int, max_health: int) -> void:
	health_bar.min_value = Player.MIN_HEALTH
	health_bar.max_value = max_health
	health_bar.value = current_health

func _on_coins_changed(new_coins: int) -> void:
	coin_label.text = str(new_coins)

func _on_health_changed(current_health: int, max_health: int) -> void:
	health_bar.max_value = max_health
	
	if _health_tween and _health_tween.is_running():
		_health_tween.kill()
	
	_health_tween = create_tween()
	_health_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_health_tween.tween_property(health_bar, "value", float(current_health), health_tween_duration)
```

**Разбор важных деталей:**
- `@export var health_tween_duration: float = 0.25` — длительность анимации урона вынесена в Инспектор (никаких магических цифр `0.25` внутри `tween_property`!).
- Зачем отдельно `_init_health_bar()` и `_on_health_changed()`? На старте игры шкала должна **мгновенно** встать на максимум, а не «наливаться с нуля», тогда как при реальном уроне в игре срабатывает плавный `Tween`.
- Зачем строчка `if _health_tween and _health_tween.is_running(): _health_tween.kill()`? Если персонаж быстро наступит на две ловушки подряд, старый незавершённый твин мгновенно отменяется, чтобы два твина не «дрались» за полоску и она не дёргалась!
- Не забудьте в сцене **`scenes/hud.tscn`** назначить узел `HealthBar` в новый слот **`Health Bar`** у корня `HUD`!

### 4.4. Испытываем урон в бою: зона опасности `DamageZone` (7 строк кода!)

> **Слова преподавателя:**  
> *«Новички для проверки урона часто пишут в скрипте героя костыль: `if Input.is_key_pressed(KEY_K): take_damage(20)`. Но это грубое нарушение всех трёх наших правил: захардкоженная кнопка клавиатуры, магическое число `20` и мусорный код в `Player`!  
> Вместо мусора создадим настоящую универсальную зону урона `DamageZone` на базе `Area2D` — точно так же, как мы делали `CameraRoom` на прошлом занятии!»*

1. В сцене **`scenes/world.tscn`** добавляем узел **`Area2D`**, называем **`DamageZone`** и ставим рядом с игроком:
   - `Collision ➔ Layer = пусто (0)` (зона сама ни с кем физически не толкается).
   - `Collision ➔ Mask = 2` (слой `Player`).
2. Внутрь `DamageZone` добавляем **`CollisionShape2D`** с формой `RectangleShape2D` (например, `32×16` px; можно включить `Debug Collision Color` красного оттенка или поставить над ямой/шипами).
3. Прикрепляем к `DamageZone` скрипт **`res://scripts/damage_zone.gd`**:

```gdscript
class_name DamageZone
extends Area2D

@export var damage: int = 20

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(damage)
```

4. Подключаем сигнал **`body_entered`** узла `DamageZone` к функции `_on_body_entered`.

> **Тест:** Запускаем проект (`F5`), забегаем персонажем в `DamageZone` несколько раз!  
> **Результат:** При каждом касании полоска здоровья мягко и сочно скользит влево (`100 ➔ 80 ➔ 60 ➔ 40...`), останавливаясь ровно на нуле!

---

## 💖 Блок 5 (Бонус — если осталось время). ХП как сердечки (`HeartsBar`)

### 5.1. Почему нельзя просто скопировать 3 сердечка руками?

> **Вопрос классу:**  
> *«Во многих платформерах (Hollow Knight, Zelda, Minecraft) здоровье показано не полоской, а сердечками. Новичок создаст вручную `Heart1`, `Heart2`, `Heart3` и напишет в коде `if health == 2: $Heart3.texture = empty`.  
> Почему за такой код в игровой студии сразу отправят на переделку?»*  
> **Ответ:** Это эталонный **хардкод**! Если геймдизайнер изменит `Max Health` игрока с `3` на `5` или даст игроку бонусное сердце в сундуке — придётся вручную копировать узлы в сцене и дописывать простыню из `elif`!  
> **Правильное решение:** Пустой `HBoxContainer`, который **сам создаёт нужное количество сердечек в цикле**, глядя на `max_health` игрока!

### 5.2. Пишем независимый UI-компонент `scripts/hearts_bar.gd`

1. Открываем сцену **`scenes/hud.tscn`**.
2. Внутрь `TopBar` (рядом с `HealthBar`) добавляем узел **`HBoxContainer`** и называем **`HeartsBar`**:
   - `Layout ➔ Container Sizing ➔ Vertical = Shrink Center`.
   - `Theme Overrides ➔ Constants ➔ Separation = 4` (расстояние между сердечками настраивается в Инспекторе — никаких магических цифр в коде!).
3. Прикрепляем к `HeartsBar` скрипт **`res://scripts/hearts_bar.gd`**:

```gdscript
class_name HeartsBar
extends HBoxContainer

@export var full_heart_texture: Texture2D
@export var empty_heart_texture: Texture2D

func _ready() -> void:
	assert(full_heart_texture != null, "%s: 'full_heart_texture' обязателен для работы!" % name)
	assert(empty_heart_texture != null, "%s: 'empty_heart_texture' обязателен для работы!" % name)

func update_hearts(current_health: int, max_health: int) -> void:
	_sync_hearts_count(max_health)
	
	for i: int in range(max_health):
		var heart_icon: TextureRect = get_child(i) as TextureRect
		if i < current_health:
			heart_icon.texture = full_heart_texture
		else:
			heart_icon.texture = empty_heart_texture

func _sync_hearts_count(target_count: int) -> void:
	while get_child_count() < target_count:
		var heart_icon: TextureRect = TextureRect.new()
		heart_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(heart_icon)
	
	while get_child_count() > target_count:
		var last_index: int = get_child_count() - 1
		var extra_heart: Node = get_child(last_index)
		remove_child(extra_heart)
		extra_heart.queue_free()
```

**Глубокий разбор кода:**
- `HeartsBar` вообще ничего не знает про `Player`! Это чистый, изолированный UI-виджет: ему дают два числа (`current_health`, `max_health`), и он рисует ровно столько сердец, сколько нужно.
- Мы не удаляем и не пересоздаём все сердечки при каждом ударе: `_sync_hearts_count` создаёт узлы `TextureRect` только один раз на старте (или если `max_health` вырос в ходе игры), а при уроне цикл `for` просто мгновенно меняет картинку `.texture` с полной на пустую!
- **Опасная ловушка Godot в цикле `while`:** почему перед `extra_heart.queue_free()` обязательно написана строчка **`remove_child(extra_heart)`**?  
  Метод `queue_free()` ставит узел в очередь на удаление только **в конце кадра**! Если не вызвать `remove_child()`, число `get_child_count()` внутри цикла `while` не уменьшится, и игра намертво зависнет в бесконечном цикле!

### 5.3. Подключаем `HeartsBar` к `HUD` и устраиваем «Момент истины»!

1. В **`scripts/hud.gd`** добавляем одну опциональную экспорт-переменную:

```gdscript
@export var hearts_bar: HeartsBar
```

   и вызываем обновление сердечек внутри `_init_health_bar` и `_on_health_changed`:

```gdscript
	if hearts_bar != null:
		hearts_bar.update_hearts(current_health, max_health)
```

2. В сцене **`scenes/hud.tscn`**:
   - У `HeartsBar` в Инспекторе задаём `Full Heart Texture` (`heart_full.png`) и `Empty Heart Texture` (`heart_empty.png`).
   - У корня `HUD` в слот **`Hearts Bar`** перетаскиваем `HeartsBar`.
   - У старого `HealthBar` можно нажать на иконку **глазика** в дереве сцены (скрыть полоску), либо оставить оба элемента видимыми для крутого эксперимента!

3. **МОМЕНТ ИСТИНЫ (Триумф чистой архитектуры!):**
   - Открываем **`scenes/world.tscn`**.
   - Выбираем `Player` и в Инспекторе меняем **`Max Health = 5`** (вместо `100`).
   - Выбираем `DamageZone` и в Инспекторе меняем **`Damage = 1`** (вместо `20`).
   - **НЕ МЕНЯЕМ НИ ЕДИНОЙ СТРОЧКИ КОДА!** Нажимаем **`F5`**!

> **Что видят дети на экране:**  
> В углу автоматически построились ровно **5 сердечек**! При каждом шаге в `DamageZone` сердечки одно за другим гаснут (`5 ➔ 4 ➔ 3...`) — а если оставить видимым и `HealthBar`, полоска и сердечки синхронно убывают по `20%` за удар от одного и того же сигнала!  
> *«Вот зачем, ребята, программисты запрещают хардкод и магические цифры! За 5 секунд в Инспекторе мы полностью сменили жанровую механику здоровья и не сломали ни строчки кода!»*

---

## 📦 Полные итоговые скрипты занятия (для сверки преподавателем)

### 1. `scripts/player.gd`
```gdscript
class_name Player
extends CharacterBody2D

signal coins_changed(new_coins: int)
signal health_changed(current_health: int, max_health: int)

const MIN_COINS: int = 0
const MIN_HEALTH: int = 0

static var instance: Player

@export var SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -400.0
@export var max_health: int = 100
@export var animated_sprite: AnimatedSprite2D

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL
}

var current_state: State = State.IDLE

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_move: bool = true

var coins: int = MIN_COINS:
	set(value):
		coins = max(MIN_COINS, value)
		coins_changed.emit(coins)

var health: int = MIN_HEALTH:
	set(value):
		health = clampi(value, MIN_HEALTH, max_health)
		health_changed.emit(health, max_health)

func _enter_tree() -> void:
	assert(instance == null, "На сцене может быть только один экземпляр Player!")
	instance = self
	health = max_health

func _exit_tree() -> void:
	if instance == self:
		instance = null

static func set_movement_enabled(enabled: bool) -> void:
	assert(instance != null, "Player: экземпляр игрока отсутствует на сцене!")
	instance.can_move = enabled

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	health -= amount

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	var direction: float = 0.0
	if can_move:
		handle_jump()
		direction = Input.get_axis("move_left", "move_right")
	
	handle_movement(direction)
	
	move_and_slide()
	
	handle_flip(direction)
	update_state(direction)
	play_animation()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func handle_movement(direction: float) -> void:
	velocity.x = direction * SPEED

func handle_flip(direction: float) -> void:
	if direction > 0.0:
		animated_sprite.flip_h = false
	elif direction < 0.0:
		animated_sprite.flip_h = true

func update_state(direction: float) -> void:
	if is_on_floor():
		if direction == 0.0:
			current_state = State.IDLE
		else:
			current_state = State.RUN
	else:
		if velocity.y < 0.0:
			current_state = State.JUMP
		else:
			current_state = State.FALL

func play_animation() -> void:
	match current_state:
		State.IDLE:
			animated_sprite.play("idle")
		State.RUN:
			animated_sprite.play("run")
		State.JUMP:
			animated_sprite.play("jump")
		State.FALL:
			animated_sprite.play("fall")
```

### 2. `scripts/hud.gd` *(полная версия с опциональным `HeartsBar` из Блока 5)*
```gdscript
class_name HUD
extends CanvasLayer

@export var player: Player
@export var coin_label: Label
@export var health_bar: TextureProgressBar
@export var hearts_bar: HeartsBar
@export var health_tween_duration: float = 0.25

var _health_tween: Tween

func _ready() -> void:
	assert(player != null, "%s: 'player' обязателен для работы!" % name)
	assert(coin_label != null, "%s: 'coin_label' обязателен для работы!" % name)
	assert(health_bar != null, "%s: 'health_bar' обязателен для работы!" % name)
	
	player.coins_changed.connect(_on_coins_changed)
	player.health_changed.connect(_on_health_changed)
	
	_on_coins_changed(player.coins)
	_init_health_display(player.health, player.max_health)

func _init_health_display(current_health: int, max_health: int) -> void:
	health_bar.min_value = Player.MIN_HEALTH
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	if hearts_bar != null:
		hearts_bar.update_hearts(current_health, max_health)

func _on_coins_changed(new_coins: int) -> void:
	coin_label.text = str(new_coins)

func _on_health_changed(current_health: int, max_health: int) -> void:
	health_bar.max_value = max_health
	
	if _health_tween and _health_tween.is_running():
		_health_tween.kill()
	
	_health_tween = create_tween()
	_health_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_health_tween.tween_property(health_bar, "value", float(current_health), health_tween_duration)
	
	if hearts_bar != null:
		hearts_bar.update_hearts(current_health, max_health)
```

---

## 💡 Шпаргалка типичных детских ошибок

| Симптом проблемы | В чём реальная причина | Как исправить |
| :--- | :--- | :--- |
| **Интерфейс остаётся на месте старта и уезжает за край при беге** | Элементы `Control` положили прямо в `World` без `CanvasLayer`. | Обернуть весь интерфейс в корневой узел `CanvasLayer` (`Layer = 1`). |
| **Иконка монетки налезает на цифры или сплющилась в точку** | Внутрь `HBoxContainer` положили синий `Sprite2D` вместо зелёного `TextureRect`. | Заменить `Sprite2D` на `TextureRect` со `Stretch Mode = Keep Aspect Centered`. |
| **Верхняя панель `TopBar` растянулась до самого низа экрана** | У `TopBar` внутри `MarginContainer` стоит `Vertical Sizing = Fill`. | В разделе `Container Sizing ➔ Vertical` выбрать **`Shrink Begin`**. |
| **При сборе 10+ монет цифры вылезают за правый край окна** | `CoinBox` поставили мышкой по координатам вместо адаптивного контейнера. | Положить `CoinBox` в `TopBar` и включить `Horizontal: Expand + Shrink End`. |
| **Вместо одной монетки на иконке видна «колбаса» из 7 монет** | В `TextureRect` напрямую закинули весь спрайтшит `gold_spin.png`. | Использовать `New AtlasTexture` и вырезать первый кадр `Region (0, 0, 25, 25)`. |
| **Шкала `TextureProgressBar` при уроне движется рывками, несмотря на `Tween`** | У `TextureProgressBar` по умолчанию стоит шаг округления `Step = 1.0`. | В разделе `Range` у `TextureProgressBar` поставить **`Step = 0.01`**. |
| **Ошибка `Assertion failed: 'player' обязателен для работы!`** | Добавили `hud.tscn` в `world.tscn`, но забыли указать `Player` в Инспекторе. | Выбрать узел `HUD` в сцене `world.tscn` и назначить `Player` в поле Инспектора. |
| **Игра намертво зависает при работе цикла удаления сердечек** | В цикле `while get_child_count() > ...` вызвали `queue_free()` без `remove_child()`. | Перед `extra_heart.queue_free()` обязательно вызвать `remove_child(extra_heart)`. |

---

## 🏆 Домашний челлендж для учеников

*(Напоминание: при выполнении всех заданий соблюдаем 3 главных правила — никакого хардкода, никаких магических цифр и строго YAGNI!)*

1. **Дизайнер плашек (`PanelContainer`):** Обернуть узел `CoinBox` внутри `hud.tscn` в новый узел **`PanelContainer`** и настроить ему в `Theme Overrides ➔ Styles ➔ Panel` ресурс `New StyleBoxFlat` (полупрозрачный чёрный фон со скруглёнными уголками `Corner Radius = 4`). Запустить игру и убедиться, что благодаря `@export var coin_label: Label` в `hud.gd` не пришлось менять ни единой строчки кода!
2. **Зелье исцеления (`HealZone` / `Potion`):** Создать по аналогии с монеткой собираемый предмет аптечки с параметром `@export var heal_amount: int = 25` (или `1` для режима сердечек) и добавить в `Player` чистый метод `heal(amount: int)`. Проверить, что сеттер с `clampi` не позволяет вылечиться выше `max_health`, а полоска плавно ползёт вправо!
3. **Тревожный индикатор здоровья:** Добавить в `scripts/hud.gd` три настраиваемых параметра в Инспектор:
   - `@export var normal_health_color: Color = Color.WHITE`
   - `@export var low_health_color: Color = Color(1.0, 0.35, 0.35)`
   - `@export_range(0.0, 1.0) var low_health_ratio: float = 0.3`  
   Сделать так, чтобы когда доля здоровья `float(current_health) / float(max_health) <= low_health_ratio`, свойство `health_bar.tint_progress` меняло цвет на тревожный (и возвращалось обратно при лечении) — без единой магической цифры!
4. **Краш-тест разрешениями:** Запустить игру и протестировать интерфейс в трёх экстремальных форматах окна: узкий вертикальный смартфон, квадратный ретро-монитор и ультраширокий киноэкран. Ни один элемент HUD не должен уехать за край или налезть на соседа!
