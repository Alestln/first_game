# 🎮 Методический план занятия №6: «Пользовательский интерфейс (UI): адаптивный HUD, компоненты здоровья и кошелька в Godot 4»

**Формат:** Пошаговый LiveCode-практикум для детей (10–15 лет)  
**Продолжительность:** 60–90 минут (75 мин база + 15 мин бонус с сердечками)  
**Движок:** Godot 4.3+ (2D Platformer)  
**Ветка проекта:** `feature/add-base-ui`  
**Главные принципы кода на занятии:** `1. Не хардкодить!` · `2. Никаких магических цифр!` · `3. YAGNI!` · `4. Разделяй ответственность (Компоненты)!`

---

## 🧭 Как преподавателю вести занятие по шагам (Git-ветки и подготовка)

Рекомендуемая разбивка занятия на контрольные Git-ветки (если ученик отстал или нужно быстро показать готовый этап):

```bash
git checkout step-1-canvas-layer     # Шаг 1: Сцена HUD (CanvasLayer) и отличие Control от Node2D
git checkout step-2-adaptive-layout  # Шаг 2: Адаптивный каркас (MarginContainer + HBoxContainer)
git checkout step-3-coin-counter     # Шаг 3: Компонент CoinWallet и независимый виджет CoinCounter
git checkout step-4-health-bar       # Шаг 4: Компонент HealthComponent, виджет HealthBar и DamageZone
git checkout step-5-hearts-bonus     # Шаг 5 (Бонус): Независимый виджет сердечек (HeartsBar)
git checkout step-6-tilemap-scenes   # Шаг 6: Размещение монет и ловушек кистью через TileMapLayer
```

*Вернуться к полной итоговой ветке занятия:* `git checkout feature/add-base-ui`

### Чеклист преподавателя перед стартом урока:
1. **Быстрая отладка без ожидания катсцены:** в сцене `scenes/world.tscn` выберите узел `IntroPath` и в Инспекторе временно включите галочку **`Skip Intro = true`**, чтобы при каждом запуске (`F5`) не ждать 6 секунд пролёта камеры.
2. **Готовые спрайты проекта:**
   - **Иконка монеты:** вырезается прямо в редакторе через `AtlasTexture` из первого кадра `assets/animations/coin/gold_spin.png` (`25×25` px).
   - **Шкала здоровья (`assets/ui/`):** `bar_under.png` (`96×16`), `bar_progress.png` (`90×10`), `bar_over.png` (`96×16`).
   - **Сердечки (`assets/ui/`):** `heart_full.png` (`16×16`) и `heart_empty.png` (`16×16`).
   - **Шипы для зоны урона (`assets/traps/`):** `spikes.png` (`16×16` — ровно под одну клетку тайловой сетки!).

---

## ⏱️ Тайминг занятия

- **00:00 – 00:05 (5 мин)** — Вводная интрига: почему `print(coins)` в консоли — это не игра, и правила чистой архитектуры.
- **00:05 – 00:20 (15 мин)** — Блок 1. `CanvasLayer` и зелёный мир `Control`-нод: почему интерфейс нельзя клеить к игроку.
- **00:20 – 00:35 (15 мин)** — Блок 2. Адаптивная вёрстка: якоря (`Anchors`), безопасные поля (`MarginContainer`) и контейнеры (`HBoxContainer`).
- **00:35 – 00:50 (15 мин)** — Блок 3. Кошелёк (`CoinWallet`) и счётчик монет (`CoinCounter`): декомпозиция игрока и сигналы.
- **00:50 – 01:10 (20 мин)** — Блок 4. Компонент здоровья (`HealthComponent`) и шкала (`HealthBar`): геттеры, универсальный `clampi` и плавный `Tween`.
- **01:10 – 01:20 (10 мин, если осталось время)** — Блок 5 (Бонус). Независимый виджет сердечек (`HeartsBar`) без переписывания кода.
- **01:20 – 01:30 (10 мин)** — Блок 6. Расставляем монеты и ловушки кистью по сетке через `TileMapLayer` (`Scenes Collection`).
- **01:30 – 01:35 (5 мин)** — Итоги, шпаргалка типичных ошибок, домашний челлендж.

---

## 🎬 Вводная часть (5 мин). Интрига и правила архитектуры

> **Слова преподавателя:**  
> *«Ребята, давайте запустим нашу игру и соберём пару монеток. Куда сейчас выводятся наши очки? В нижнюю консоль редактора через `print(coins)` — причём 60 раз в секунду!  
> Если мы отправим готовую игру другу, у него не будет консоли Godot: он бегает, собирает золото, наступает на шипы — но экран абсолютно пустой!  
> Сегодня мы построим настоящий адаптивный **HUD** (экранный интерфейс), который сам подстраивается под любой монитор и работает по-взрослому!»*

### 📜 Четыре правила нашего кода сегодня:

1. **НЕ ХАРДКОДИТЬ!**  
   Никаких зашитых путей вроде `$MarginContainer/TopBar/CoinBox/CoinLabel` в коде! Все связи между узлами передаём через `@export`, а события — через **сигналы**.
2. **НИКАКИХ МАГИЧЕСКИХ ЦИФР!**  
   Никаких загадочных чисел `100`, `20` или `0.25` внутри функций — только `@export var` и именованные константы `const`.
3. **YAGNI (*You Aren't Gonna Need It* — «Тебе это не понадобится»)!**  
   Пишем только то, что реально нужно игре прямо сейчас. Например, пока на уровне нет аптечек — мы не пишем метод лечения `heal()`, но проектируем здоровье так, чтобы добавить лечение в будущем можно было в две строчки!
4. **ПРИНЦИП ЕДИНОЙ ОТВЕТСТВЕННОСТИ (Никаких «скриптов-монстров»)!**  
   - Скрипт `player.gd` должен отвечать **только за движение и анимацию героя**. Если свалить в него ещё и расчёт монет, здоровья, брони и инвентаря — он разрастётся на 1000 строк! Поэтому для монет мы создадим отдельный узел **`CoinWallet`**, а для здоровья — **`HealthComponent`**.
   - Точно так же мы **не будем** вешать один гигантский скрипт на весь `HUD`! У каждого элемента интерфейса (`CoinLabel`, `HealthBar`, `HeartsBar`) будет свой маленький независимый скрипт на 20 строк.

---

## 🟢 Блок 1. `CanvasLayer` и зелёный мир `Control`-нод (LiveCode)

### 1.1. Опыт на экране: две классические ошибки новичка

> **Демонстрация преподавателя:**  
> **Опыт №1:** Добавляем узел `Label` с текстом `"Coins: 0"` прямо в корень сцены `World`. Запускаем игру (`F5`), бежим влево.  
> **Что видят дети?** Надпись осталась висеть в воздухе на месте старта и уехала за край экрана!  
> **Опыт №2:** Перетаскиваем `Label` внутрь узла `Player`. Запускаем игру.  
> **Что видят дети?** Надпись прыгает вместе с героем, да ещё и растянулась в 2 раза из-за `Player.scale = Vector2(2, 2)`! *(Удаляем тестовый `Label`).*

### 1.2. Три цвета узлов в Godot 4

- 🔵 **Синие (`Node2D`)** — объекты игрового мира (платформы, герой, монетки, ловушки).
- 🟢 **Зелёные (`Control`)** — элементы пользовательского интерфейса (текст, полоски здоровья, умные контейнеры).
- ⚪ **Белые (`Node`, `CanvasLayer`)** — чистые логические компоненты (`HealthComponent`, `CoinWallet`) и экранные слои.

> **Главный запрет UI в Godot:** Никогда не кладите синий `Sprite2D` внутрь зелёных контейнеров интерфейса! Зелёные контейнеры не видят размеров синих узлов и сплющат их в точку `(0, 0)`. Для любых картинок в интерфейсе используем зелёный **`TextureRect`**!

### 1.3. Создаём отдельную сцену интерфейса `scenes/hud.tscn`

1. Нажимаем **Сцена (Scene) ➔ Новая сцена (New Scene)**.
2. Выбираем **Другой узел (Other Node) ➔ `CanvasLayer`** и называем его **`HUD`**.
3. Проверяем в Инспекторе: `Layer = 1` (в отличие от `SkyLayer` с `Layer = -10`, интерфейс рисуется **поверх** всего игрового мира).
4. Сохраняем сцену (`Ctrl + S`) как **`res://scenes/hud.tscn`**.
   - *Обратите внимание:* на сам корневой узел `HUD` мы **не вешаем никакого скрипта**! `HUD` — это просто прозрачное «лобовое стекло», на котором живут независимые виджеты.

---

## 📐 Блок 2. Адаптивная вёрстка: Якоря и Контейнеры (LiveCode)

### 2.1. Включаем проверку адаптивности экрана

1. Открываем **Проект (Project) ➔ Настройки проекта (Project Settings) ➔ Display ➔ Window**.
2. В разделе **Stretch** находим параметр **`Aspect`** и ставим **`expand`** (вместо `keep`).
   - *Зачем:* Теперь при растягивании окна мышкой в ширину или высоту игровой холст реально меняет пропорции, и мы сразу проверим адаптивность нашей вёрстки!

### 2.2. Собираем каркас адаптивного HUD в `scenes/hud.tscn`

Строим следующую иерархию зелёных узлов:

```text
HUD (CanvasLayer) — без скрипта!
└── MarginContainer (MarginContainer)        # Безопасный отступ от краёв экрана
    └── TopBar (HBoxContainer)               # Верхняя горизонтальная строка
        ├── HealthBox (VBoxContainer)        # Слева: колонка для шкалы ХП (и сердечек)
        │   └── HealthBar (TextureProgressBar) [скрипт: health_bar.gd]
        └── CoinBox (HBoxContainer)          # Справа: блок монетки (иконка + число)
            ├── CoinIcon (TextureRect)
            └── CoinLabel (Label)            [скрипт: coin_counter.gd]
```

**Шаг 1. Безопасная рамка `MarginContainer` (Safe Area):**
1. Дочерним узлом к `HUD` добавляем **`MarginContainer`**.
2. На верхней панели 2D-редактора нажимаем **Якоря (Anchors Preset) ➔ `Full Rect`**.
3. В Инспекторе у `MarginContainer`:
   - **Mouse ➔ `Filter = Ignore`** (чтобы рамка не перекрывала клики мыши).
   - **Theme Overrides ➔ Constants**: `Margin Left = 12`, `Margin Top = 10`, `Margin Right = 12`, `Margin Bottom = 10`.

**Шаг 2. Верхняя панель `TopBar` (`HBoxContainer`):**
1. Внутрь `MarginContainer` добавляем **`HBoxContainer`** с именем **`TopBar`**.
2. В Инспекторе `TopBar`: **Layout ➔ Container Sizing ➔ Vertical = `Shrink Begin`** (снимаем `Fill`, чтобы верхняя панель прижалась к потолку, а не растягивалась до пола!).

**Шаг 3. Левый блок `HealthBox` и правый блок `CoinBox`:**
1. Внутрь `TopBar` добавляем **`VBoxContainer`** с именем **`HealthBox`** (`Theme Overrides ➔ Constants ➔ Separation = 4`). Внутрь него добавляем **`TextureProgressBar`** с именем **`HealthBar`**.
2. Внутрь `TopBar` вторым ребёнком добавляем **`HBoxContainer`** с именем **`CoinBox`**:
   - В **Layout ➔ Container Sizing ➔ Horizontal** включаем галочку **`Expand`** и выбираем **`Shrink End`**.  
     *Зачем:* `CoinBox` прижмётся к правому верхнему углу, а когда число монет вырастет с `"0"` до `"9999"`, цифры будут расти **влево внутрь экрана**, никогда не уезжая за правый край!
   - В `Theme Overrides ➔ Constants` ставим **`Separation = 4`**.

---

## 🪙 Блок 3. Кошелёк (`CoinWallet`) и счётчик монет (`CoinCounter`) (LiveCode)

### 3.1. Настраиваем иконку монеты (`AtlasTexture`) и текст (`CoinLabel`)

1. Внутрь `CoinBox` добавляем **`TextureRect`** (называем **`CoinIcon`**):
   - В поле `Texture` выбираем **`New AtlasTexture`**.
   - В поле `Atlas` перетаскиваем `assets/animations/coin/gold_spin.png`.
   - Задаём **`Region = Rect2(0, 0, 25, 25)`** (вырезаем ровно первый кадр вращения монетки!).
   - У `CoinIcon` ставим **`Stretch Mode = Keep Aspect Centered`**.
2. Внутрь `CoinBox` добавляем **`Label`** (называем **`CoinLabel`**):
   - `Text = "0"`
   - `Label Settings ➔ New LabelSettings`: `Font Size = 16`, `Outline Size = 4`, `Outline Color = Чёрный (#000000)` (чтобы белые цифры не сливались с белыми облаками!).

### 3.2. Выносим монеты из `Player` в отдельный компонент `CoinWallet`

> **Диалог с классом:**  
> *«Почему плохо хранить переменную `coins` прямо внутри `player.gd`?  
> Потому что `player.gd` уже управляет гравитацией, прыжками, бегом и анимациями. Если мы будем складывать в него ещё и монеты, кристаллы, ключи и здоровье — скрипт игрока превратится в огромную свалку!  
> В Godot для этого используют **узлы-компоненты**: мы создадим маленький узел `CoinWallet` (Кошелёк) и положим его внутрь игрока».*

Создаём скрипт **`res://scripts/coin_wallet.gd`**:

```gdscript
class_name CoinWallet
extends Node

signal coins_changed(new_coins: int)

const MIN_COINS: int = 0

var _coins: int = MIN_COINS

func get_coins() -> int:
	return _coins

func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	_set_coins(_coins + amount)

func _set_coins(value: int) -> void:
	_coins = max(MIN_COINS, value)
	coins_changed.emit(_coins)
```

**Разбор каждой детали (Инкапсуляция, Геттер и Сеттер):**
- `var _coins: int = MIN_COINS` — нижнее подчёркивание `_` показывает, что переменная **приватная**. Ни один внешний скрипт не должен менять `_coins` напрямую в обход правил!
- `func get_coins() -> int:` — явный **геттер** (метод только для чтения текущего баланса монет).
- `func _set_coins(value: int) -> void:` — внутренний **сеттер-метод**, который гарантирует, что баланс не опустится ниже `MIN_COINS`, и рассылает сигнал `coins_changed`.
- `func add_coins(amount: int) -> void:` — понятный публичный метод пополнения кошелька (отсекает некорректные отрицательные или нулевые значения).

### 3.3. Пишем независимый скрипт виджета `scripts/coin_counter.gd`

Прикрепляем скрипт **`res://scripts/coin_counter.gd`** прямо к узлу **`CoinLabel`** в `scenes/hud.tscn`:

```gdscript
class_name CoinCounter
extends Label

@export var coin_wallet: CoinWallet

func _ready() -> void:
	assert(coin_wallet != null, "%s: 'coin_wallet' обязателен для работы!" % name)
	
	coin_wallet.coins_changed.connect(_on_coins_changed)
	_on_coins_changed(coin_wallet.get_coins())

func _on_coins_changed(new_coins: int) -> void:
	text = str(new_coins)
```

- Посмотрите: весь скрипт — **14 строк**! Он отвечает строго за свою надпись `Label`, слушает только `CoinWallet` и вообще ничего не знает про остальной интерфейс!

---

## ❤️‍🩹 Блок 4. Компонент здоровья (`HealthComponent`) и шкала (`HealthBar`) (LiveCode)

### 4.1. Настраиваем «бутерброд» `TextureProgressBar` в `scenes/hud.tscn`

Выбираем узел **`HealthBar`** (`TextureProgressBar`):
1. В разделе **Textures**:
   - `Under` ➔ `assets/ui/bar_under.png` (`96×16` px — тёмное дно колбы).
   - `Progress` ➔ `assets/ui/bar_progress.png` (`90×10` px — рубиновая полоска).
   - `Over` ➔ `assets/ui/bar_over.png` (`96×16` px — металлическая рамка с золотыми уголками).
   - `Texture Progress Offset = Vector2(3, 3)` (так как рамка `bar_over.png` имеет бортик толщиной 3 пикселя).
2. В разделе **Range**:
   - **`Step = 0.01`** (по умолчанию стоит `1.0`, из-за чего полоска при плавной анимации двигалась бы ступеньками!).

### 4.2. Создаём универсальный компонент `scripts/health_component.gd`

> **Вопрос классу:** *«Почему вынести здоровье в отдельный компонент `HealthComponent` ещё круче, чем писать его в игроке?»*  
> **Ответ:** Потому что на следующих занятиях у нас появятся **враги, боссы и разрушаемые ящики**! Мы просто перетащим готовый `HealthComponent` внутрь любого врага — и он сразу обретёт здоровье без единой новой строчки кода!

Создаём скрипт **`res://scripts/health_component.gd`**:

```gdscript
class_name HealthComponent
extends Node

signal health_changed(current_health: int, max_health: int)

const MIN_HEALTH: int = 0

@export var max_health: int = 100

var _current_health: int = MIN_HEALTH

func _enter_tree() -> void:
	_set_health(max_health)

func get_health() -> int:
	return _current_health

func get_max_health() -> int:
	return max_health

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	_set_health(_current_health - amount)

func _set_health(value: int) -> void:
	_current_health = clampi(value, MIN_HEALTH, max_health)
	health_changed.emit(_current_health, max_health)
```

**Разбор архитектуры `HealthComponent`:**
1. **Явные геттеры `get_health()` и `get_max_health()`:** внешний мир может безопасно прочитать текущее и максимальное здоровье, но не может напрямую испортить приватную переменную `_current_health`.
2. **Универсальный внутренний метод `_set_health(value: int)` с `clampi`:** в одном-единственном месте зажимает здоровье в границах от `MIN_HEALTH` до `max_health` и отправляет сигнал `health_changed`.
3. **Публичный метод `take_damage(amount: int)` и правило YAGNI:** сейчас в игре есть только урон от ловушек, поэтому мы пишем только `take_damage()`. Когда в игре появятся аптечки, добавить `heal(amount: int)` можно будет в 3 строчки через тот же `_set_health(_current_health + amount)`!

### 4.3. Подключаем компоненты в `scenes/player.tscn`, `player.gd` и `coin.gd`

1. Открываем сцену **`scenes/player.tscn`**:
   - Добавляем дочерними узлами к `Player` два узла `Node`: называем их **`HealthComponent`** (вешаем `scripts/health_component.gd`) и **`CoinWallet`** (вешаем `scripts/coin_wallet.gd`).
2. Открываем **`scripts/player.gd`**:
   - Удаляем старый `func _process(delta): print(coins)` и `var coins: int = 0`.
   - Добавляем только ссылки на компоненты и проверку `assert` в `_ready()`:

```gdscript
@export var animated_sprite: AnimatedSprite2D
@export var health_component: HealthComponent
@export var coin_wallet: CoinWallet
```

```gdscript
func _ready() -> void:
	assert(health_component != null, "%s: 'health_component' обязателен для работы!" % name)
	assert(coin_wallet != null, "%s: 'coin_wallet' обязателен для работы!" % name)
```
   - В сцене `scenes/player.tscn` назначаем `HealthComponent` и `CoinWallet` в слоты Инспектора у `Player`.
3. В **`scripts/coin.gd`** делаем `@export var coin_value: int = 1` и в методе `collect(player: Player)` вызываем метод кошелька:

```gdscript
	player.coin_wallet.add_coins(coin_value)
```

### 4.4. Пишем скрипт шкалы здоровья `scripts/health_bar.gd`

Прикрепляем скрипт **`res://scripts/health_bar.gd`** непосредственно к узлу **`HealthBar`** (`TextureProgressBar`) в `scenes/hud.tscn`:

```gdscript
class_name HealthBar
extends TextureProgressBar

@export var health_component: HealthComponent
@export var tween_duration: float = 0.25

var _health_tween: Tween

func _ready() -> void:
	assert(health_component != null, "%s: 'health_component' обязателен для работы!" % name)
	
	min_value = HealthComponent.MIN_HEALTH
	max_value = health_component.get_max_health()
	value = health_component.get_health()
	
	health_component.health_changed.connect(_on_health_changed)

func _on_health_changed(current_health: int, max_health_value: int) -> void:
	max_value = max_health_value
	
	if _health_tween and _health_tween.is_running():
		_health_tween.kill()
	
	_health_tween = create_tween()
	_health_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_health_tween.tween_property(self, "value", float(current_health), tween_duration)
```

- Обратите внимание: `HealthBar` даже не привязан жёстко к классу `Player`! Он принимает любой `HealthComponent` — этим же скриптом можно сделать полоску здоровья босса!

### 4.5. Создаём сцену ловушки `scenes/damage_zone.tscn` и связываем всё в `world.tscn` через `Editable Children`

1. Создаём сцену **`scenes/damage_zone.tscn`** (`Area2D`, `collision_layer = 0`, `collision_mask = 2`) со спрайтом `assets/traps/spikes.png` (`16×16` px), `CollisionShape2D` (`14×12` px, `position = Vector2(0, 2)`) и скриптом **`res://scripts/damage_zone.gd`**:

```gdscript
class_name DamageZone
extends Area2D

@export var damage: int = 20

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.health_component.take_damage(damage)
```

2. Открываем **`scenes/world.tscn`** и добавляем в корень сцену **`scenes/hud.tscn`** (кнопка цепочки **Instantiate Child Scene**).
3. **Что такое `Editable Children` («Редактируемые дочерние узлы») и зачем он нужен?**
   - Когда вы добавляете сцену `hud.tscn` или `player.tscn` внутрь `world.tscn`, Godot по умолчанию показывает их в дереве как **один свёрнутый узел со значком хлопушки 🎬**. Их внутренние узлы (`HealthBar`, `CoinLabel`, `HealthComponent`, `CoinWallet`) скрыты, чтобы вы случайно не сбили их вёрстку.
   - Но нам нужно прямо в `world.tscn` связать `HealthBar` с `Player/HealthComponent`, а `CoinLabel` — с `Player/CoinWallet`!
   - **Где включается:** в панели **Сцена (Scene)** кликаем **правой кнопкой мыши** по узлу **`Player`** ➔ ставим галочку **`Editable Children`** (*в русском интерфейсе Godot: **«Редактируемые дочерние узлы»***). Точно так же кликаем ПКМ по узлу **`HUD`** ➔ включаем **`Editable Children`**.
   - **Что происходит:** оба узла раскрываются в дереве (их дочерние элементы подсвечиваются жёлтым цветом). При этом сама исходная сцена `hud.tscn` не ломается — мы просто разрешили настраивать свойства конкретных вложенных узлов внутри уровня `world.tscn`!
4. Назначаем ссылки в Инспекторе `world.tscn`:
   - Выбираем `HUD/MarginContainer/TopBar/HealthBox/HealthBar` и в поле **`Health Component`** назначаем узел `Player/HealthComponent`.
   - Выбираем `HUD/MarginContainer/TopBar/CoinBox/CoinLabel` и в поле **`Coin Wallet`** назначаем узел `Player/CoinWallet`.

> **Тест (`F5`):** Бежим по уровню, собираем монетки, наступаем на шипы и растягиваем окно игры! Счётчик монет и плавная полоска ХП работают как часы!

---

## 💖 Блок 5 (Бонус — если осталось время). Независимый виджет сердечек (`HeartsBar`)

> **Слова преподавателя:**  
> *«А теперь оцените мощь того, что мы не стали лепить один общий скрипт на весь `HUD`! Мы хотим добавить отображение здоровья в виде сердечек. Нам вообще **не нужно открывать и менять** ни `player.gd`, ни `health_component.gd`, ни `health_bar.gd`, ни `coin_counter.gd`! Мы просто добавим в `HealthBox` новый независимый узел `HeartsBar`!»*

1. В сцене **`scenes/hud.tscn`** внутрь `HealthBox` добавляем **`HBoxContainer`** с именем **`HeartsBar`** (`Separation = 3`).
2. Прикрепляем к нему скрипт **`res://scripts/hearts_bar.gd`**:

```gdscript
class_name HeartsBar
extends HBoxContainer

@export var health_component: HealthComponent
@export var full_heart_texture: Texture2D
@export var empty_heart_texture: Texture2D

func _ready() -> void:
	assert(health_component != null, "%s: 'health_component' обязателен для работы!" % name)
	assert(full_heart_texture != null, "%s: 'full_heart_texture' обязателен для работы!" % name)
	assert(empty_heart_texture != null, "%s: 'empty_heart_texture' обязателен для работы!" % name)
	
	health_component.health_changed.connect(_on_health_changed)
	_on_health_changed(health_component.get_health(), health_component.get_max_health())

func _on_health_changed(current_health: int, max_health: int) -> void:
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

3. В Инспекторе `HeartsBar` в `scenes/hud.tscn` назначаем `heart_full.png` и `heart_empty.png`.
4. В сцене **`scenes/world.tscn`**:
   - У `HeartsBar` в слот **`Health Component`** перетаскиваем `Player/HealthComponent`.
   - У `Player/HealthComponent` ставим **`Max Health = 5`**.
   - У сцены `damage_zone.tscn` ставим **`Damage = 1`**.

> **Тест (`F5`):** В левом верхнем углу **одновременно** и полоска `HealthBar` плавно скользит на 20% при каждом ударе, и 5 сердечек `HeartsBar` гаснут по одному — потому что оба независимых виджета слушают один и тот же сигнал от `HealthComponent`!

---

## 🗺️ Блок 6. Расставляем монеты и ловушки кистью по сетке через `TileMapLayer` (`Scenes Collection`)

### 6.1. Проблема сотни копий в дереве сцены

> **Вопрос классу:**  
> *«Посмотрите на узел `Coins` в нашем `world.tscn`: там уже лежат `Coin`, `Coin2`, `Coin3`... `Coin13`. А если на большом уровне будет 200 монет и 50 шипов? Дерево сцены превратится в бесконечную свалку, а выравнивать каждую колючку мышкой по пикселям — настоящее мучение!  
> Можно ли рисовать готовые сцены с `Area2D` и скриптами прямо кисточкой по сетке, как мы рисовали землю?»*  
> **Ответ:** Да! В Godot 4 `TileSet` умеет хранить не только картинки-атласы, но и **Коллекции сцен (`Scenes Collection`)**!

### 6.2. Пошаговая настройка `Scenes Collection` в `scenes/world.tscn`

1. В сцене `scenes/world.tscn` удаляем старый узел `Coins` со всеми `Coin1 ... Coin13` — больше никакого ручного копирования!
2. Внутри `TileMapLayers` (рядом с `Environment`) добавляем второй узел **`TileMapLayer`** и называем его **`Objects`**.
3. В Инспекторе у `Objects` в поле **`Tile Set`** выбираем тот же самый `TileSet`, который уже используется у `Environment` (или нажимаем на `TileSet` в `Environment`, чтобы открыть нижнюю панель **`TileSet`**).
4. В нижней панели **`TileSet`** (слева, где список источников атласов):
   - Нажимаем кнопку **`+` (Add)** ➔ выбираем **`Scenes Collection` (Коллекция сцен)**.
   - У нас появился новый источник сцен (справа пустой список).
   - Перетаскиваем из Файловой системы (`FileSystem`) прямо в это поле файлы **`res://scenes/coin.tscn`** и **`res://scenes/damage_zone.tscn`**!
5. Переключаемся на нижнюю вкладку **`TileMap`**, выбираем в дереве узел **`Objects`**, кликаем по источнику сцен и выбираем инструмент **Кисть (Paint)**:
   - Выбираем в палитре монетку и за 3 секунды рисуем дуги и дорожки из монет по воздуху!
   - Выбираем в палитре шипы (`damage_zone.tscn`, размер спрайта `16×16` px ровно под клетку сетки!) и проводим кистью по клеткам прямо над травой — шипы идеально, пиксель в пиксель, встают на поверхность земли!

> **Финальный тест занятия (`F5`):**  
> При запуске игры `TileMapLayer` автоматически превращает каждую нарисованную клетку в живой узел `Area2D` со скриптами и анимациями: монетки крутятся, собираются и исчезают через `queue_free()`, шипы отнимают здоровье, а дерево сцены `world.tscn` остаётся идеально чистым!

---

## 💡 Шпаргалка типичных детских ошибок

| Симптом проблемы | В чём реальная причина | Как исправить |
| :--- | :--- | :--- |
| **Интерфейс уезжает за край при движении героя** | Элементы `Control` положили в `World` без `CanvasLayer`. | Обернуть интерфейс в корневой узел `CanvasLayer` (`Layer = 1`). |
| **Иконка монетки сплющилась или налезла на цифры** | Внутрь `HBoxContainer` положили синий `Sprite2D` вместо `TextureRect`. | Заменить на зелёный `TextureRect` со `Stretch Mode = Keep Aspect Centered`. |
| **Верхняя панель `TopBar` растянулась до пола** | У `TopBar` внутри `MarginContainer` стоит `Vertical = Fill`. | В разделе `Container Sizing ➔ Vertical` выбрать **`Shrink Begin`**. |
| **Не видно внутренних узлов `HUD` и `Player` в сцене `world.tscn`** | Сцены свёрнуты как единые экземпляры. | Нажать ПКМ по `HUD` и `Player` в `world.tscn` ➔ включить **`Editable Children`**. |
| **Полоска `TextureProgressBar` при `Tween` дёргается рывками** | У `TextureProgressBar` по умолчанию стоит шаг `Step = 1.0`. | В разделе `Range` у `HealthBar` поставить **`Step = 0.01`**. |
| **Игра зависает при уменьшении количества сердечек** | В цикле `while` вызвали `queue_free()` без `remove_child()`. | Перед `extra_heart.queue_free()` обязательно вызвать `remove_child(extra_heart)`. |

---

## 🏆 Домашний челлендж для учеников

*(Соблюдаем все 4 правила: без хардкода, без магических цифр, YAGNI и разделение ответственности по компонентам!)*

1. **Дизайнер плашек (`PanelContainer`):** Обернуть `CoinBox` в `hud.tscn` в узел **`PanelContainer`** с полупрозрачным фоном `StyleBoxFlat` и скруглёнными краями. Убедиться, что скрипт `coin_counter.gd` на `CoinLabel` продолжает работать без единого изменения!
2. **Зелье исцеления (`HealItem`):** Теперь, когда в игре появляется источник лечения, добавить в `HealthComponent` публичный метод `heal(amount: int)`, который использует уже написанный универсальный `_set_health(_current_health + amount)`, и создать сцену аптечки на базе `Area2D`!
3. **Тревожный цвет полоски (`HealthBar`):** Добавить в `scripts/health_bar.gd` экспортируемые цвета `@export var normal_color: Color = Color.WHITE`, `@export var low_health_color: Color = Color(1.0, 0.35, 0.35)` и порог `@export_range(0.0, 1.0) var low_health_ratio: float = 0.3`, чтобы полоска сама меняла свой `tint_progress` при низком здоровье.
4. **Здоровье для врага или ящика:** Создать на уровне тренировочный манекен (`StaticBody2D` или `Area2D`), добавить внутрь него тот же самый `HealthComponent` и маленькую полоску `HealthBar` над ним — убедиться, что наши компоненты работают на любом объекте, а не только на игроке!
