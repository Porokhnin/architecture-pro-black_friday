# pymongo-api

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Конфигурируем и заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```

Подключаемся к любой ноде и выполняем команду для создания кластера:
```
docker compose exec -it redis_1
echo "yes" | redis-cli --cluster create 173.17.0.201:6379  173.17.0.202:6379  173.17.0.203:6379  173.17.0.204:6379  173.17.0.205:6379  173.17.0.206:6379 --cluster-replicas 1 
```


## Как проверить

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080

Откройте в браузере http://localhost:8080/helloDoc/users Запрос пойдет в БД
Откройте в браузере повторно http://localhost:8080/helloDoc/users Запрос пойдет в кэш, время ответа будет сильно меньше

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://localhost:8080/docs



### Если вы запускаете проект на предоставленной виртуальной машине

Узнать белый ip виртуальной машины

```shell
curl --silent http://ifconfig.me
```

Откройте в браузере http://<ip виртуальной машины>:8080

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://<ip виртуальной машины>:8080/docs

Откройте в браузере http://<ip виртуальной машины>:8080/helloDoc/users Запрос пойдет в БД
Откройте в браузере повторно http://<ip виртуальной машины>:8080/helloDoc/users Запрос пойдет в кэш, время ответа будет сильно меньше



# Задание 7. Проектирование схем коллекций для шардирования данных

## Схемы коллекций products, orders и carts

### Схема orders

```
@startjson orders
{
	"_id": "ObjectId",            //Уникальный идентификатор заказа
	"user_id": "ObjectId",        //Идентификатор клиента
	"created_at": "ISODate",      //Дата и время оформления заказа
	"items": [                    //Список заказанных товаров и их цена
	  {                                  
	    "product_id": "ObjectId", //Идентификатор товара
	    "quantity": 0,            //Количество
	    "price": 0                //Цена товаров
	  }                                  
	],                                     
	"status": "string",            //Статус заказа: "new" | "processing" | "dispatched" | "delivery" | "done" | "canceled"
	"price": 0,                    //Общая сумма заказа
	"zone": "string"               //Геозона заказа
}
@endjson
```

[orders](https://editor.plantuml.com/uml/RO-n3i8W48PdI7Y7Xhc3irC7bquT78rf42w69e8Unr2Dx-vT6ur35y9ttzr_q1LoI5F9gSaO08lHBwEL7MEm-yOEbmayzS6sKgm5S5Du14SGHaVY-kDmO5nL9BWLhfuOb4GhPU-OG_Mq5SNsKLsYI3ExNViTY1w41Tzyd9TiVZjL2USRndHTD_wQ5thc17yTHlDu1od8but-0000)

![orders](https://img.plantuml.biz/plantuml/png/RO-n3i8W48PdI7Y7Xhc3irC7bquT78rf42w69e8Unr2Dx-vT6ur35y9ttzr_q1LoI5F9gSaO08lHBwEL7MEm-yOEbmayzS6sKgm5S5Du14SGHaVY-kDmO5nL9BWLhfuOb4GhPU-OG_Mq5SNsKLsYI3ExNViTY1w41Tzyd9TiVZjL2USRndHTD_wQ5thc17yTHlDu1od8but-0000)

Основные операции:
- Быстрое создание заказов с одновременным списанием остатков.
- Поиск истории заказов конкретного пользователя.
- Отображение статуса заказа.

Потенциальным ключем для шардирования можно выбрать:
1) идентификатор пользователя с хэшированным шардированием

sh.enableSharding("somedb");
sh.shardCollection("somedb.orders", { "user_id" : "hashed" } );


### Схема products

```
@startjson products
{
  "_id": "ObjectId",            //Уникальный идентификатор товара
  "name": "string",             //Наименование
  "category": "string",         //Категория товара
  "price": 0,                   //Цена
  "balance": [                  //Остаток товара в каждой геозоне
    {
      "quantity": 0,            //Количество
      "zone": "string"          //Геозона
    }
  ],
  "additional":                 //Дополнительные атрибуты (цвет, размер)
  {
    "color": "color",           //Цвет
    "size":                     //Размер
    {
      "length": 0,              //Длина
      "width": 0,               //Ширина
      "height": 0               //Высота
    },
    "weght": 0                  //Масса
  }
}
@endjson
```
[products](https://editor.plantuml.com/uml/NP2n3i8m34Jdv2jGPWRcJbsP-024K9f4gQlYbCHLrQB-Et4eeiAJx-by9xbEf2DrAU1XYC6EXf9yIQ7kO5LrK9UcSuRELXqpG_rm31D5G5-GqUHyYFCV7Y8OjfvODBhNMEHL2f73XL3FKIC1pPidaoNWFZopLOeRtsjhWI2WxbKboxqoeG-HtP-54rI2nR5XQ-WTUcf_-HFOlMmT-9PO2wug2PFxeZmozw-oTcZvEV8D)

![products](https://img.plantuml.biz/plantuml/png/NP2n3i8m34Jdv2jGPWRcJbsP-024K9f4gQlYbCHLrQB-Et4eeiAJx-by9xbEf2DrAU1XYC6EXf9yIQ7kO5LrK9UcSuRELXqpG_rm31D5G5-GqUHyYFCV7Y8OjfvODBhNMEHL2f73XL3FKIC1pPidaoNWFZopLOeRtsjhWI2WxbKboxqoeG-HtP-54rI2nR5XQ-WTUcf_-HFOlMmT-9PO2wug2PFxeZmozw-oTcZvEV8D)

Основные операции:
Частые обновления остатков при покупках.
Поиск товаров по категориям и фильтрация по диапазону цен.
Описание товара на странице продукта.

Потенциальным ключем для шардирования можно выбрать:
1) категория с хэшированным шардированием

sh.enableSharding("somedb");
sh.shardCollection("somedb.products", { "category" : "hashed" } );


### Схема carts
```
@startjson carts
{
  "_id": "ObjectId",                          //Уникальный идентификатор корзины
  "user_id": "ObjectId",                      //Идентификатор клиента
  "session_id": "ObjectId",                   //Идентификатор сессии для гостей
  "items": [                                  // Список товаров
    {                                       
      "product_id": "ObjectId",               //Идентификатор продукта
      "quantity": 0                           //Количество
    }                                       
  ],                                          
  "status": "string",                         //Статус корзины "active" | "ordered" | "abandoned"
  "created_at": "ISODate",                    //Дата и время создания
  "updated_at": "ISODate",                    //Дата и время последнего обновления
  "expires_at": "ISODate"                     //Время удаления для автоматической очистки старых корзин.
}
@endjson
```
[carts](https://editor.plantuml.com/uml/TP0n2m8n38Nd5leVIcS7PwSRN6wwmL7ag6sG7jZM9eKJyR-RSavIbv2yZ-GzCY3PGWkcg1qtgEHBIM7cuCr1c-cwWAFHcrqJAqBf0WJ4a6AN1O8xidpMF8bsN0YJI_BLKM-1wQFQI86UpFPDUNEvR4PagRPht9KGRvk5As09_6ofaV4q7NdyHix-7u8rXmBuWpWbsmqGVVk9aXy0)

![carts](https://img.plantuml.biz/plantuml/png/TP0n2m8n38Nd5leVIcS7PwSRN6wwmL7ag6sG7jZM9eKJyR-RSavIbv2yZ-GzCY3PGWkcg1qtgEHBIM7cuCr1c-cwWAFHcrqJAqBf0WJ4a6AN1O8xidpMF8bsN0YJI_BLKM-1wQFQI86UpFPDUNEvR4PagRPht9KGRvk5As09_6ofaV4q7NdyHix-7u8rXmBuWpWbsmqGVVk9aXy0)

Создание корзины, когда заходит гость или новый пользователь.
Получение текущей корзины по фильтру { session_id, status:"active" } или { user_id, status:"active" }.
Добавление или замена товара в корзине.
Удаление товара из корзины.
Слияние гостевой корзины в пользовательскую, если пользователь залогинится.
Отметка корзины как заказанной.


Потенциальным ключем для шардирования можно выбрать:
1) идентификатор пользователя с хэшированным шардированием

sh.enableSharding("somedb");
sh.shardCollection("somedb.carts", { "user_id" : "hashed" } );



# Задание 8. Выявление и устранение «горячих» шардов
Для устранения горячих шардов необходимо настроить мониторинг со следующими метриками:
- Число активных соединений
- Среднее время ответа
- Утилизация виртуальной памяти
- Утилизация процессов
- Нагрузка на сеть

+ Метрики
db.serverStatus();
db.currentOp();
db.adminCommand("connPoolStats":1);

Дпри выявлении горячих гардов, можно добавить шарды, a mongo раскидает нагрущку.
sh.addShard("");