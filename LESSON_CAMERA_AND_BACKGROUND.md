# 🎮 Сценарий занятия: «Кинематографичная камера и живой фон в Godot 4»
**Формат:** LiveCode-практикум для детей (10–15 лет)  
**Продолжительность:** 60–90 минут  
**Движок:** Godot 4.3+ (2D Platformer)  
**Ветка проекта:** `lesson/camera-background`

---

## 🧭 Как преподавателю вести занятие по шагам (Git-теги)
В репозитории проекта каждый ключевой шаг зафиксирован в отдельном коммите с тегом. Если на уроке кто-то отстал или нужно быстро показать «как должно быть», вы можете переключиться на нужный этап:

```bash
git checkout step-1-screen       # Шаг 1: Настройки экрана (640x360, масштабирование, пиксельный снэп)
git checkout step-2-static-bg    # Шаг 2: Статический фон (CanvasLayer + TextureRect)
git checkout step-3-parallax     # Шаг 3: Параллакс (3 слоя Parallax2D + автоскролл облаков)
git checkout step-4-camera       # Шаг 4: Камера игрока (плавность, границы, синхронизация с физикой)
git checkout step-5-intro        # Шаг 5: Кинематографичный облёт уровня на старте (Path2D)
git checkout step-6-room         # Шаг 6: Статичная комната с бесшовным переходом
git checkout step-7-shake        # Шаг 7: Универсальная тряска экрана (GameCamera.shake_current)
```
*Вернуться к финальной версии:* `git checkout lesson/camera-background`

---

## ⏱️ Тайминг занятия
- **00:00 – 00:05 (5 мин)** — Вводная интрига: «Почему игра выглядит плоской?»
- **00:05 – 00:20 (15 мин)** — Блок 1. Настройка экрана и пикселей: устраняем размытие при ходьбе
- **00:20 – 00:35 (15 мин)** — Блок 2. Статический фон: разбор типичной ошибки с `TextureRect`
- **00:35 – 00:50 (15 мин)** — Блок 3. Параллаксный фон: создаем иллюзию 3D в 2D
- **00:50 – 01:05 (15 мин)** — Блок 4. Единая кинематографичная камера (`GameCamera`): плавность, границы, синхронизация
- **01:05 – 01:15 (10 мин)** — Блок 5. Режиссерский пролет камеры перед стартом уровня
- **01:15 – 01:25 (10 мин)** — Блок 6. Секретные комнаты: фиксация ракурса без скачков и швов
- **01:25 – 01:30 (5 мин)** — Блок 7. Универсальная тряска камеры при сборе монетки
- **01:30 – 01:35 (5 мин)** — Итоги, рефлексия, домашний челлендж

---

## 🎬 Вводная часть (5 мин). Интрига
> **Слова преподавателя:**  
> *«Ребята, посмотрите на экран. У нас есть персонаж, он умеет бегать и прыгать по платформам. Но почему игра выглядит так, будто мы играем в картонной коробке?*  
> *1. При ходьбе пиксели героя размываются и "плывут".*  
> *2. За границами платформ — серая пустота.*  
> *3. Камера прибита к персонажу гвоздями — каждое резкое движение бьет по глазам.*  
> *4. Фон плоский: двигаемся мы, а за нами ничего не оживает.*  
> *Сегодня мы превратимся в кинорежиссёров и профессиональных разработчиков: настроим экран без размытия, сделаем живой многослойный параллакс, научим камеру летать над уровнем и построим универсальную систему комнат!»*

---

## 🖥️ Блок 1. Настройка экрана и пикселей (LiveCode)

### 1.1. Проблема №1: Маленький персонаж на огромном экране
> **Вопрос детям:** *«Если мы делаем пиксельную игру со спрайтами 16×16 пикселей на экране Full HD (1920×1080), какого размера будет наш герой?»*  
> **Ответ:** *«Он будет размером с ноготь мизинца! Поэтому игре нужен свой компактный виртуальный холст, который затем пропорционально увеличивается на весь монитор».*

### 1.2. Проблема №2: Размытие спрайта при движении (Субпиксели)
> **Секрет для преподавателя и детей:**  
> *«Почему при беге персонажа пиксели размываются? Потому что скорость персонажа — это дробные числа: например, координата 124.37 пикселя! Экран не умеет рисовать "половинку" пикселя — он пытается смешать цвета соседних точек, и картинка становится "мыльной" или дрожит. Чтобы это вылечить, мы включим принудительное округление до целых пикселей (Pixel Snap)!»*

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
   - **`Default Texture Filter`** = **Nearest** (никакого сглаживания пикселей).

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

## 🎥 Блок 4. Единая кинематографичная камера (`GameCamera`)

### 4.1. Архитектурный секрет: Почему нельзя переключать камеры в игре?
> **Важнейший вопрос урока:**  
> *«Многие новички пытаются ставить отдельную камеру на игрока, отдельную камеру в каждой комнате и переключать их через `make_current()`. Но что происходит, когда игрок бежит на полной скорости?  
> Старая камера находится в одной точке, а новая — в другой. Экран резко прыгает (телепортируется), ломая все сглаживание!  
> **Золотое правило геймдева:** В 2D игре должен быть **ОДИН главный оператор (GameCamera)**. Когда мы заходим в комнату, мы не меняем человека с камерой, мы просто просим оператора плавно подойти к центру комнаты. А когда выходим — оператор плавно возвращается за спину игрока!»*

### 4.2. Как отвязать камеру от скейла игрока (`top_level = true`)
Если персонаж увеличен (`scale = Vector2(2, 2)`), прикрепленная камера наследует этот скейл, вызывая дрожание.  
Включаем **`top_level = true`** — камера живет в мировых координатах, не сжимается и не искажается, плавно следуя за игроком по формуле экспоненциального сглаживания.

### Скрипт [scripts/game_camera.gd](file:///c:/Users/Alestln/Godot%20Projects/first_game/scripts/game_camera.gd):
```gdscript
class_name GameCamera
extends Camera2D

static var instance: GameCamera

@export var follow_target: Node2D
@export var follow_speed: float = 6.0
@export var shake_decay: float = 20.0

enum Mode { FOLLOW_PLAYER, LOCKED_TO_POINT, FOLLOW_NODE }

var current_mode: Mode = Mode.FOLLOW_PLAYER
var locked_position: Vector2 = Vector2.ZERO
var target_node: Node2D = null
var current_speed: float = 6.0
var shake_strength: float = 0.0

func _enter_tree() -> void:
	instance = self

func _exit_tree() -> void:
	if instance == self:
		instance = null

func _ready() -> void:
	top_level = true # Полная независимость от скейла и родителя
	scale = Vector2.ONE
	
	if not follow_target:
		follow_target = get_tree().get_first_node_in_group("player") as Node2D
	if follow_target:
		global_position = follow_target.global_position

# --- Универсальные методы вызова (из ЛЮБОГО скрипта в 1 строчку) ---

static func shake_current(strength: float = 4.0) -> void:
	if instance: instance.shake(strength)

static func lock_to_position(target_pos: Vector2, speed: float = 4.0) -> void:
	if instance: instance.set_locked_position(target_pos, speed)

static func unlock_position(speed: float = 5.0) -> void:
	if instance: instance.return_to_player(speed)

static func lock_to_node(node: Node2D, speed: float = 100.0) -> void:
	if instance: instance.set_target_node(node, speed)

# --- Логика движения ---

func shake(strength: float = 4.0) -> void:
	shake_strength = max(shake_strength, strength)

func set_locked_position(target_pos: Vector2, speed: float = 4.0) -> void:
	current_mode = Mode.LOCKED_TO_POINT
	locked_position = target_pos
	current_speed = speed

func return_to_player(speed: float = 5.0) -> void:
	current_mode = Mode.FOLLOW_PLAYER
	current_speed = speed

func set_target_node(node: Node2D, speed: float = 100.0) -> void:
	current_mode = Mode.FOLLOW_NODE
	target_node = node
	current_speed = speed
	if speed >= 50.0 and is_instance_valid(node):
		global_position = node.global_position

func _physics_process(delta: float) -> void:
	# 1. Тряска через offset
	if shake_strength > 0.0:
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_strength
		shake_strength = move_toward(shake_strength, 0.0, shake_decay * delta)
	else:
		offset = Vector2.ZERO

	# 2. Выбор цели
	var destination: Vector2
	match current_mode:
		Mode.LOCKED_TO_POINT:
			destination = locked_position
		Mode.FOLLOW_NODE:
			destination = target_node.global_position if is_instance_valid(target_node) else global_position
		Mode.FOLLOW_PLAYER:
			destination = follow_target.global_position if is_instance_valid(follow_target) else global_position

	# 3. Кинематографичное экспоненциальное сглаживание
	var weight: float = 1.0 - exp(-current_speed * delta)
	global_position = global_position.lerp(destination, weight)
```

### 4.3. Границы уровня (Limits)
В инспекторе `GameCamera`:
- `limit_left` = `0`
- `limit_right` = `2416`
- `limit_bottom` = `384`

---

## 🚁 Блок 5. Режиссерский пролет камеры в начале уровня (LiveCode)

### 5.1. Устройство в сцене:
1. Создаем узел **`Path2D`** (называем `IntroPath`).
2. В редакторе рисуем кривую от правого края уровня к спавну игрока.
3. Дочерним узлом к `IntroPath` добавляем **`PathFollow2D`** (`rotates = false`, `loop = false`).
4. Вешаем скрипт [scripts/intro_camera.gd](file:///c:/Users/Alestln/Godot%20Projects/first_game/scripts/intro_camera.gd):

```gdscript
extends Path2D

@export var fly_time: float = 4.5
@export var return_time: float = 1.5
@export var skip_intro: bool = false

@onready var path_follow: PathFollow2D = $PathFollow

func _ready() -> void:
	if skip_intro: return
	play_intro()

func play_intro() -> void:
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player:
		player.can_move = false

	# 1. Говорим камере следовать за тележкой PathFollow
	path_follow.progress_ratio = 0.0
	GameCamera.lock_to_node(path_follow, 100.0)

	# 2. Tween плавно везет тележку по кривой
	var fly_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	fly_tween.tween_property(path_follow, "progress_ratio", 1.0, fly_time)
	await fly_tween.finished

	# 3. Плавно возвращаем камеру к игроку
	GameCamera.unlock_position(3.0)
	await get_tree().create_timer(return_time).timeout

	# 4. Отдаем управление
	if player:
		player.can_move = true
```

---

## 🏰 Блок 6. Секретная комната: плавный вход И плавный выход (LiveCode)

### 6.1. Почему теперь НЕТ резкого скачка при выходе?
В отличие от старого подхода с двумя камерами:
- При входе в комнату: `GameCamera.lock_to_position(target)` — камера плавно замедляется в центре комнаты.
- При выходе из комнаты: `GameCamera.unlock_position(speed)` — камера **непрерывно преследует движущегося игрока**. Куда бы ни побежал персонаж, камера плавно скользит к нему. Никаких переключений `make_current()`, никаких телепортаций!

### 6.2. Универсальный скрипт комнаты [scripts/camera_room.gd](file:///c:/Users/Alestln/Godot%20Projects/first_game/scripts/camera_room.gd):
```gdscript
class_name CameraRoom
extends Area2D

@export var view_point: Node2D
@export var transition_speed: float = 4.0

func _ready() -> void:
	if not view_point:
		view_point = get_node_or_null("ViewPoint")
		if not view_point:
			view_point = get_node_or_null("RoomCamera")

func _on_body_entered(body: Node2D) -> void:
	if body is Player or body.is_in_group("player"):
		var target: Vector2 = view_point.global_position if view_point else global_position
		GameCamera.lock_to_position(target, transition_speed)

func _on_body_exited(body: Node2D) -> void:
	if body is Player or body.is_in_group("player"):
		GameCamera.unlock_position(transition_speed)
```

> **Универсальность:** Вы можете продублировать узел `CameraRoom` (`Ctrl + D`) 10 раз по уровню, задать разный размер `CollisionShape2D` и поставить точки обзора — **все комнаты заработают сразу без единой строчки нового кода!**

---

## 💥 Блок 7. Универсальная тряска экрана (Screen Shake)

### В любом объекте игры (монеты, враги, ловушки):
В [scripts/coin.gd](file:///c:/Users/Alestln/Godot%20Projects/first_game/scripts/coin.gd):
```gdscript
func collect(player: Player) -> void:
	is_collected = true
	collision_shape.set_deferred("disabled", true)
	
	player.coins += coin_value
	GameCamera.shake_current(2.0) # <-- Всего одна строчка в любом месте игры!
	
	animated_sprite.play("collect")
	await animated_sprite.animation_finished
	queue_free()
```

---

## 💡 Шпаргалка типичных детских ошибок:

| Проблема | В чем причина | Как исправить |
| :--- | :--- | :--- |
| **Спрайт размывается при беге** | Не включен пиксельный снэп | Включить `Snap 2D Transforms to Pixel` в Project Settings. |
| **Камера резко скачет при выходе из комнаты** | Попытка переключить разные `Camera2D` | Использовать единую `GameCamera` и команду `unlock_position()`. |
| **Фон заслоняет платформы** | Слой `CanvasLayer` имеет положительный номер | У `CanvasLayer` поставить `Layer = -10` (отрицательный). |
| **Параллакс не зацикливается** | Не задан `Repeat Size` | Указать ширину картинки (например, `640`) в `Repeat Size` у `Parallax2D`. |
| **Тряска смещает саму камеру** | Изменяют `position` вместо `offset` | Всегда трясти через `offset`: `offset = Vector2(rand, rand) * power`. |

---

## 🏆 Домашний челлендж для учеников:
1. Поменять скорость автоскролла облаков `autoscroll` (сделать медленнее или в другую сторону).
2. Нарисовать свою причудливую траекторию полета камеры через точки кривой `Path2D`.
3. Добавить вторую секретную комнату простым дублированием `CameraRoom`.
4. Сделать силу тряски камеры больше при падении в пропасть.
