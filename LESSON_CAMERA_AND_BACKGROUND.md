# 🎮 Сценарий занятия: «Кинематографичная камера и живой фон в Godot 4»
**Формат:** LiveCode-практикум для детей (10–15 лет)  
**Продолжительность:** 60–90 минут  
**Движок:** Godot 4.3+ (2D Platformer)  
**Ветка проекта с готовыми шагами:** `lesson/camera-background`

---

## 🧭 Как преподавателю вести занятие по шагам (Git-теги)
В репозитории проекта каждый шаг зафиксирован в отдельном коммите с тегом. Если на уроке кто-то отстал или нужно быстро показать «как должно быть», вы можете переключиться на нужный этап:

```bash
git checkout step-1-screen       # Шаг 1: Настройки экрана (640x360, масштабирование, пиксельный снэп)
git checkout step-2-static-bg    # Шаг 2: Статический фон (CanvasLayer + TextureRect)
git checkout step-3-parallax     # Шаг 3: Параллакс (3 слоя Parallax2D + автоскролл облаков)
git checkout step-4-camera       # Шаг 4: Камера игрока (плавность, границы, синхронизация с физикой)
git checkout step-5-intro        # Шаг 5: Кинематографичный облёт уровня на старте (Path2D + Tween)
git checkout step-6-room         # Шаг 6: Статичная комната с плавным входом и выходом (CameraRoom)
git checkout step-7-shake        # Шаг 7: Универсальная тряска экрана (GameCamera.shake_current)
```

---

## ⏱️ Тайминг занятия
- **00:00 – 00:05 (5 мин)** — Вводная интрига: «Почему игра выглядит плоской?»
- **00:05 – 00:20 (15 мин)** — Блок 1. Настройка экрана и пикселей: чиним размытие при ходьбе
- **00:20 – 00:35 (15 мин)** — Блок 2. Статический фон: разбор типичной ошибки с `TextureRect`
- **00:35 – 00:50 (15 мин)** — Блок 3. Параллаксный фон: создаем иллюзию 3D в 2D
- **00:50 – 01:05 (15 мин)** — Блок 4. Камера2D: «оператор на пружинке», границы и синхронизация физики
- **01:05 – 01:20 (15 мин)** — Блок 5. Режиссерский пролет камеры перед стартом уровня
- **01:20 – 01:30 (10 мин)** — Блок 6. Секретная комната: плавный вход И плавный выход
- **01:30 – 01:35 (5 мин)** — Блок 7. Универсальная тряска камеры + итоги и челленджи

---

## 🎬 Вводная часть (5 мин). Интрига
> **Слова преподавателя:**  
> *«Ребята, посмотрите на экран. У нас есть персонаж, он умеет бегать и прыгать по платформам. Но почему игра выглядит так, будто мы играем в картонной коробке?*  
> *1. При ходьбе пиксели героя размываются и "плывут".*  
> *2. За границами платформ — серая пустота.*  
> *3. Камера прибита к персонажу гвоздями — каждое резкое движение бьет по глазам.*  
> *4. Фон плоский: двигаемся мы, а за нами ничего не оживает.*  
> *Сегодня мы превратимся в кинорежиссёров и профессиональных разработчиков: настроим экран без размытия, сделаем живой многослойный параллакс, научим камеру летать над уровнем и сделаем универсальную систему комнат!»*

---

## 🖥️ Блок 1. Настройка экрана и пикселей (LiveCode)

### 1.1. Проблема №1: Маленький персонаж на огромном экране
> **Вопрос детям:** *«Если мы делаем пиксельную игру со спрайтами 16×16 пикселей на экране Full HD (1920×1080), какого размера будет наш герой?»*  
> **Ответ:** *«Он будет размером с ноготь мизинца! Поэтому игре нужен свой маленький виртуальный холст, который потом увеличивается на весь монитор».*

### 1.2. Проблема №2: Размытие спрайта при движении (Субпиксели)
> **Секрет для преподавателя и детей:**  
> *«Почему при беге персонажа пиксели размываются? Потому что скорость персонажа — это дробные числа: например, позиция 124.37 пикселя! Монитор не умеет рисовать пол-пикселя, он пытается смешать цвета соседних точек, и картинка становится "мыльной" или дрожит. Чтобы это вылечить, мы включим принудительное округление до целых пикселей (Pixel Snap)!»*

### 1.3. Действие в Godot:
Открываем: **Проект (Project) ➔ Настройки проекта (Project Settings)**.

1. **Размер виртуального экрана (Display ➔ Window)**:
   - `viewport_width` = **640**
   - `viewport_height` = **360**  
   *(Пропорция 16:9, ровно половина от 720p — пиксели увеличиваются в целое число раз без искажений).*
2. **Размер окна при запуске на ПК**:
   - `window_width_override` = **1280**
   - `window_height_override` = **720**  
   *(На мониторе игра откроется в просторном удобном окне).*
3. **Режим растяжения (Stretch)**:
   - **Mode:** `canvas_items` *(2D-мир четко масштабируется под размер окна)*.
   - **Aspect:** `keep` *(сохраняет пропорции: при нестандартном мониторе по бокам будут аккуратные полосы, а персонаж не сплющится)*.
4. **Лекарство от размытия (Rendering ➔ 2D ➔ Snap)**:
   - **`Snap 2D Transforms to Pixel`** = **ON (`true`)**
   - **`Snap 2D Vertices to Pixel`** = **ON (`true`)**
5. **Фильтрация текстур (Rendering ➔ Textures ➔ Canvas Textures)**:
   - **`Default Texture Filter`** = **Nearest** (никакого размытия).

> **Демонстрация:** Запустите проект (`F5`), побегайте.  
> **Показать детям:** Пиксели теперь всегда чёткие, как бритва! Никакого "мыла" при движении.

---

## 🌄 Блок 2. Статический фон: разбор ошибки с `TextureRect` (LiveCode)

### 2.1. Разбор вопроса: «Можно ли просто положить `TextureRect` на сцену?»
> **Эксперимент на экране:**  
> Добавляем обычный `TextureRect` прямо в корень мира. Запускаем. Бежим вправо.  
> **Что видят дети?** Персонаж убегает вперед, а картинка фона осталась в начале уровня!  
> **Почему?** Потому что в 2D-мире у каждого предмета есть мировые координаты: дерево на X=200, а `TextureRect` остался на X=0. Камера уехала, а фон остался позади.

### 2.2. Правильное решение: Небо на «лобовом стекле» (`CanvasLayer`)
> **Аналогия для детей:**  
> *«Представьте, что вы едете в машине. Деревья за окном пролетают мимо, но наклейка на лобовом стекле всегда перед глазами, куда бы вы ни ехали. `CanvasLayer` — это то самое невидимое стекло перед глазами игрока!»*

### Пошаговые действия:
1. В корне сцены `World` нажимаем `+` (добавить узел) ➔ выбираем **`CanvasLayer`**. Переименовываем в `SkyLayer`.
2. В инспекторе у `SkyLayer` ставим:
   - **`Layer`** = `-10` *(знак «минус» значит: рисовать глубже всех остальных слоев, под землей и персонажем)*.
3. Дочерним узлом к `SkyLayer` добавляем **`TextureRect`** (называем `Sky`):
   - Перетаскиваем в поле **`Texture`** картинку `sky.png`.
   - В верхней панели редактора нажимаем кнопку **Якоря (Anchors Preset)** ➔ выбираем **`Full Rect`** (весь прямоугольник).
   - В инспекторе `TextureRect`:
     - `Expand Mode` = `Ignore Size` (разрешить растягивать).
     - `Stretch Mode` = `Keep Aspect Covered` (заполнить без искажения пропорций).
     - `Mouse Filter` = `Ignore` (чтобы клики мыши проходили сквозь фон).

---

## 🏔️ Блок 3. Параллаксный фон: магия слоев и глубины (LiveCode)

### 3.1. Как работает параллакс в реальной жизни?
> **Вопрос детям:** *«Вы сидите у окна поезда. Посмотрите вдаль: что проносится мимо мгновенно, а что кажется почти неподвижным?»*  
> **Вывод:**  
> - Близкие объекты движутся быстро (скорость 1.0 = наш пол).  
> - Средние холмы движутся медленнее (скорость 0.5).  
> - Далекие горы почти стоят на месте (скорость 0.2).  
> - Солнце и небо не двигаются вообще (скорость 0.0 — это наш `SkyLayer`).

### 3.2. Настройка `Parallax2D` в Godot 4.3+
В современной версии Godot для каждого слоя нужен всего **один узел `Parallax2D`**.

Создаем узел-контейнер `Node2D` с именем `Parallax` (располагаем в дереве **выше** `TileMapLayers`, чтобы фон был сзади).

Добавляем 3 слоя:

#### 1. Слой «Облака» (`Parallax2D`)
- Добавляем дочерний узел `Sprite2D`, вешаем текстуру `clouds.png`, `Centered = false`.
- **`Scroll Scale`** = `(0.1, 1)` — по горизонтали двигаются всего на 10% от скорости игрока.
- **`Repeat Size`** = `(640, 0)` — ширина текстуры. Движок сам зацикливает слой до бесконечности!
- **`Autoscroll`** = `(-8, 0)` — **Секретная фишка!** Облака сами плывут влево со скоростью 8 пикселей в секунду, даже когда игрок стоит!

#### 2. Слой «Дальние горы» (`Parallax2D`)
- Дочерний `Sprite2D` ➔ `mountains_far.png`, `Centered = false`.
- **`Scroll Scale`** = `(0.2, 1)` — горы плывут на 20% скорости.
- **`Repeat Size`** = `(640, 0)`.

#### 3. Слой «Ближние холмы с ёлками» (`Parallax2D`)
- Дочерний `Sprite2D` ➔ `mountains_near.png`, `Centered = false`.
- **`Scroll Scale`** = `(0.5, 1)` — холмы двигаются на 50% скорости.
- **`Repeat Size`** = `(640, 0)`.

> **Проверка:** Запускаем игру! Бежим вправо-влево. Дети видят трехмерную глубину в 2D-пространстве.

---

## 🎥 Блок 4. Камера2D: «Оператор на пружинке» и границы (LiveCode)

Выбираем узел `Player/Camera` (`Camera2D`).

### 4.1. Синхронизация с физикой (Борьба с подергиванием)
- В инспекторе камеры находим: **`Process Callback`** ➔ ставим **`Physics`** (значение `0`).
- *Почему это важно:* Персонаж двигается в `_physics_process()`. Если камера обновляется отдельно в обычном `_process()`, они будут двигаться с разным темпом и персонаж начнет микро-вибрировать. Ставим `Physics` — и камера идеально шагает синхронно с физикой!

### 4.2. Плавность (Position Smoothing)
- Включаем: **`Position Smoothing ➔ Enabled = ON`**
- **`Speed`** = `5.0` px/s.
> **Объяснение детям:**  
> *«Если выключено — камера прикручена к голове героя железным болтом. Включаем сглаживание — и камеру держит оператор, который плавно бежит вслед за игроком. Картинка становится мягкой и кинематографичной!»*

### 4.3. Границы уровня (Limits) — спасаем от серой пустоты
Узнаем ширину нашего уровня: уровень состоит из 151 тайла шириной 16 пикселей = **2416 пикселей**.
- **`Limit Left`** = `0`
- **`Limit Right`** = `2416`
- **`Limit Bottom`** = `384` (дно уровня)
- **`Limit Smoothed`** = `ON`

> **Показать детям:** Подбегаем к левому краю уровня. Персонаж идет к стенке, но камера останавливается на границе 0 и больше не показывает черную пустоту за краем карты!

### 4.4. Мертвая зона по вертикали (Drag Margin)
- Включаем **`Drag ➔ Vertical Enabled = ON`**
- Теперь при маленьких прыжках камера не дергается вверх-вниз, экономя зрение игрока.

---

## 🚁 Блок 5. Режиссерский пролет камеры в начале уровня (LiveCode)

### 5.1. Задача:
В начале уровня камера стартует с конца карты (или от сундука/замка), плавно пролетает над всем уровнем, показывая препятствия, подлетает к герою и отдает ему управление.

### 5.2. Устройство сцены:
1. Создаем узел **`Path2D`** (называем `IntroPath`).
2. В редакторе сверху выбираем инструмент «Перо» и рисуем кривую: от правого края уровня к спавну игрока.
3. Дочерним узлом к `IntroPath` добавляем **`PathFollow2D`** (`rotates = false`, `loop = false`).
4. Внутрь `PathFollow2D` добавляем вторую камеру — **`IntroCamera`** (`Camera2D`).
5. Вешаем скрипт [scripts/intro_camera.gd](file:///c:/Users/Alestln/Godot%20Projects/first_game/scripts/intro_camera.gd):

```gdscript
extends Path2D

@export var player: Player
@export var player_camera: Camera2D
@export var fly_time: float = 5.0      # Длительность полета по уровню
@export var return_time: float = 1.5   # Длительность доводки до игрока
@export var skip_intro: bool = false   # Чекбокс для быстрого тестирования

@onready var path_follow: PathFollow2D = $PathFollow
@onready var intro_camera: Camera2D = $PathFollow/IntroCamera

func _ready() -> void:
	if skip_intro:
		return
	
	# Универсальный автопоиск: работает на ЛЮБОМ уровне, даже если забыли привязать в инспекторе!
	if not player:
		player = get_tree().get_first_node_in_group("player") as Player
	if not player_camera and player:
		player_camera = player.find_child("Camera") as Camera2D
		
	if not player or not player_camera:
		return
		
	play_intro()

func play_intro() -> void:
	# 1. Отключаем кнопки управления у игрока
	player.can_move = false
	
	# 2. Включаем камеру-оператора
	intro_camera.make_current()
	path_follow.progress_ratio = 0.0

	# 3. Аниматор Tween везет тележку камеры от 0.0 до 1.0 (100% пути)
	var fly_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	fly_tween.tween_property(path_follow, "progress_ratio", 1.0, fly_time)
	await fly_tween.finished

	# 4. Плавно переводим фокус на игрока
	var return_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	return_tween.tween_property(intro_camera, "global_position", player_camera.get_screen_center_position(), return_time)
	await return_tween.finished

	# 5. Возвращаем камеру игрока и включаем управление
	player_camera.make_current()
	player_camera.reset_smoothing()
	player.can_move = true
```

---

## 🏰 Блок 6. Секретная комната: плавный вход И плавный выход (LiveCode)

### 6.1. Почему камера резко дергалась при выходе?
> **Разбор ошибки:**  
> *«Когда мы входили в комнату, камера плавно ехала через `Tween` — было красиво. Но при выходе мы делали просто `player_camera.make_current()`. Камера игрока моментально прыгала на 300 пикселей к персонажу за 1 кадр!  
> **Решение:** При выходе из комнаты камера сначала должна плавно долететь обратно к игроку, и только когда она долетела — переключаться на игрока!»*

### 6.2. Универсальный скрипт комнаты [scripts/camera_room.gd](file:///c:/Users/Alestln/Godot%20Projects/first_game/scripts/camera_room.gd):
Скрипт полностью универсален: его можно повесить на любую `Area2D` с камерой на любом уровне без ручной привязки нод!

```gdscript
class_name CameraRoom
extends Area2D

@export var room_camera: Camera2D
@export var player_camera: Camera2D
@export var transition_time: float = 0.6

var room_view_position: Vector2
var active_tween: Tween
var is_player_inside: bool = false

func _ready() -> void:
	# Автопоиск камеры комнаты, если не привязали в инспекторе
	if not room_camera:
		room_camera = get_node_or_null("RoomCamera") as Camera2D
	if room_camera:
		room_view_position = room_camera.global_position

func _on_body_entered(body: Node2D) -> void:
	if not (body is Player or body.is_in_group("player")):
		return
	is_player_inside = true

	if not player_camera:
		player_camera = get_viewport().get_camera_2d()
	if not room_camera:
		return

	if active_tween and active_tween.is_valid():
		active_tween.kill()

	# Плавный въезд в комнату:
	room_camera.global_position = player_camera.get_screen_center_position()
	room_camera.make_current()
	
	active_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(room_camera, "global_position", room_view_position, transition_time)

func _on_body_exited(body: Node2D) -> void:
	if not (body is Player or body.is_in_group("player")):
		return
	is_player_inside = false

	if not room_camera or not player_camera:
		return

	if active_tween and active_tween.is_valid():
		active_tween.kill()

	# ПЛАВНЫЙ ВЫЕЗД ИЗ КОМНАТЫ:
	# Камера комнаты плавно летит назад к позиции игрока
	active_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(room_camera, "global_position", player_camera.global_position, transition_time)
	await active_tween.finished

	# И только когда камера долетела — переключаемся на игрока!
	if not is_player_inside and is_instance_valid(player_camera):
		player_camera.make_current()
		player_camera.reset_smoothing()
```

> **Демонстрация:** Заходим в комнату справа — камера мягко показывает комнату. Выходим обратно — камера мягко скользит назад к герою. Никаких резких рывков!

---

## 💥 Блок 7. Универсальная тряска экрана (Screen Shake)

### 7.1. Как сделать код универсальным, чтобы не дублировать его в каждой сцене?
Раньше монета искала камеру во вьюпорте: `get_viewport().get_camera_2d() as GameCamera`.  
Если монету добавить в другую сцену без этой конкретной камеры, игра могла сломаться.

**Универсальное архитектурное решение:**  
Сделать в `GameCamera` **статический метод**: `GameCamera.shake_current(2.0)`.

### Скрипт [scripts/game_camera.gd](file:///c:/Users/Alestln/Godot%20Projects/first_game/scripts/game_camera.gd):
```gdscript
class_name GameCamera
extends Camera2D

static var current_camera: GameCamera

@export var shake_decay: float = 20.0
var shake_strength: float = 0.0

func _enter_tree() -> void:
	add_to_group("cameras")
	current_camera = self

func _exit_tree() -> void:
	if current_camera == self:
		current_camera = null

## Универсальный метод — можно вызвать отовсюду в одну строчку:
## GameCamera.shake_current(3.0)
static func shake_current(strength: float = 4.0) -> void:
	if current_camera and is_instance_valid(current_camera):
		current_camera.shake(strength)

func shake(strength: float = 4.0) -> void:
	shake_strength = max(shake_strength, strength)

func _process(delta: float) -> void:
	if shake_strength > 0.0:
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_strength
		shake_strength = move_toward(shake_strength, 0.0, shake_decay * delta)
	else:
		offset = Vector2.ZERO
```

### Теперь в ЛЮБОМ объекте игры (монета, враг, сундук, шип):
В [scripts/coin.gd](file:///c:/Users/Alestln/Godot%20Projects/first_game/scripts/coin.gd):
```gdscript
func collect(player: Player) -> void:
	is_collected = true
	collision_shape.set_deferred("disabled", true)
	
	player.coins += coin_value
	GameCamera.shake_current(2.0) # <-- Всего одна универсальная строчка!
	
	animated_sprite.play("collect")
	await animated_sprite.animation_finished
	queue_free()
```
Если на уровне появится враг, при его смерти пишем: `GameCamera.shake_current(4.0)`.  
Если игрок упал в лаву: `GameCamera.shake_current(7.0)`.  
Никаких связей между нодами!

---

## 💡 Шпаргалка типичных детских ошибок:

| Ошибка у ученика | В чем причина | Как исправить |
| :--- | :--- | :--- |
| **Спрайт размывается при беге** | Не включен пиксельный снэп | В Project Settings включить `Snap 2D Transforms to Pixel` и у камеры `Process Callback = Physics`. |
| **Камера не слушается и не двигается** | Забыли включить `Enabled` | Проверить галочку `Enabled` в инспекторе `Camera2D`. |
| **Фон заслоняет персонажа** | Слой `CanvasLayer` выше уровня | У `CanvasLayer` поставить `Layer = -10` (минус десять). |
| **Параллакс не повторяется** | Не задан `Repeat Size` | Указать ширину текстуры (например, `640`) в `Repeat Size` у `Parallax2D`. |
| **Камера резко скачет** | `make_current()` вызван без плавного `Tween` | Использовать `CameraRoom` с анимацией возврата. |

---

## 🏆 Итог занятия и домашнее задание:
1. Запустить игру и насладиться сочной картинкой.
2. **Задание 1:** Добавить новый слой облаков с другой скоростью автоскролла.
3. **Задание 2:** Добавить на уровень вторую секретную комнату с помощью копирования узла `CameraRoom` (проверить, что код работает универсально без правок!).
