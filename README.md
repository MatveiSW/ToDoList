# Тестовое задание iOS

## ✅ Выполненные требования

### 1. 📋 Управление задачами
* Реализован главный экран со списком задач
* Каждая задача содержит:
  - Название
  - Описание
  - Дату создания
  - Статус выполнения
* Функционал работы с задачами:
  - Создание новых задач
  - Редактирование существующих
  - Удаление
  - Поиск по содержимому

### 2. 🌐 Интеграция с API
* Реализована загрузка задач с dummyjson.com/todos
* Добавлена периодическая синхронизация данных при каждом открытии экрана
* Внедрена логика предотвращения дублирования задач
* Реализовано отслеживание удаленных задач

### 3. 🔄 Многопоточность
* Все операции с данными выполняются в фоновых потоках (GCD)
* Обеспечена отзывчивость интерфейса
* Реализована асинхронная обработка:
  - Создания
  - Загрузки
  - Редактирования
  - Удаления
  - Поиска

### 4. 💾 Хранение данных
* Внедрено локальное хранилище на CoreData
* Реализовано корректное восстановление данных
* Добавлена система отслеживания удаленных задач

## 🎨 Модификации и улучшения

### Улучшенный UX
* Плавные анимации при всех операциях с задачами
* Дизайн в стиле Apple Notes
* Добавлена кнопка "Готово" для предпросмотра задачи

### Расширение функционала API
* Добавлено автоматическое генерирование дат в пределах текущего месяца
* Внедрены дефолтные заголовки для задач
* Реализована умная синхронизация с сервером

## ⚠️ Не реализовано

### Unit Tests
В текущей версии отсутствуют модульные тесты из-за ограниченного опыта в данной области. Тем не менее, готов быстро освоить тестирование и внедрить его в проект, понимая важность этого аспекта разработки.

## 🛠 Технологии
* Swift
* UIKit
* CoreData
* GCD
* MVС
* Git
