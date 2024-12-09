# README
## Main Application Endpoint
The endpoint for managing products:
```bash
/api/products
```
## Usage Example with Curl
To create a new product, use the following request:

```bash
curl -X POST http://localhost:3000/api/products \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test Product","price":1999,"sku":"TEST123"}'
```
Example response:
```

```bash
{"id":4,"name":"Test Product","price":1999,"sku":"TEST123","created_at":"2024-12-09T08:38:56.953Z","updated_at":"2024-12-09T08:38:56.953Z"}
```

## Key Application Entities
###Product
The Product entity stores data received from the client. Table structure example:

```sql
  t.string "name", null: false
  t.integer "price", null: false
  t.string "sku", null: false
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
  t.index ["sku"], name: "index_products_on_sku"
```

### PublishTaskHandler
The PublishTaskHandler entity stores information about the product publication process in marketplaces. Table structure example:

```sql
  t.string "marketplace"
  t.integer "product_id"
  t.json "steps"
  t.integer "status"
  t.json "logs"
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
  t.index ["marketplace"], name: "index_publish_task_handlers_on_marketplace"
  t.index ["product_id"], name: "index_publish_task_handlers_on_product_id"
```

## Features:

Step statuses: stores information about whether each step of the publication process was successful.
Logs: stores data about requests and responses from marketplaces.

Publication Architecture
The Adapter Pattern is used for product publication. The main class is MarketplacePublisher.

Key Features:
List of available marketplaces:
Retrieved from the product.
Synchronization is performed sequentially for each marketplace.
In the future, the list of marketplaces can be tied to a user or subscription type.
Retry failed steps only:
The PublishTaskHandler entity is used to determine whether each step needs to be executed.
ggVSteps that were successfully completed earlier are skipped.
Rake Task for Manual Publication
If a product publication was interrupted (e.g., due to a Sidekiq failure), it is possible to manually send the product for publication using the following command:

bash
Копировать код
rake marketplace:publish sku=TEST123
Execution Example:
text
Копировать код
2024-12-09T09:01:24.286Z pid=91698 tid=226m INFO: Sidekiq 7.3.6 connecting to Redis with options {:size=>10, :pool_name=>"internal", :url=>nil}
Product 'Test Product' (SKU: TEST123) successfully published.
Additional Information
Requirements:
Ruby: version 3.1+
Rails: version 7.0+
Redis: required for Sidekiq
Installation:
Clone the repository.
Run the following commands:
bash
Копировать код
bundle install
rails db:create db:migrate
Start the server:
bash
Копировать код
rails server
Running Tests:
To execute tests, use the following command:

bash
Копировать код
bundle exec rspec






# README

## Main Application Endpoint

The endpoint for managing products:

```bash
/api/products
```

### Usage Example with Curl

To create a new product, use the following request:

```bash
curl -X POST http://localhost:3000/api/products \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test Product","price":1999,"sku":"TEST123"}'`
```
Example response:

```json
{
  "id": 5,
  "name": "Test Product",
  "price": 1999,
  "sku": "TEST123",
  "created_at": "2024-12-09T08:40:13.999Z",
  "updated_at": "2024-12-09T08:40:13.999Z"
}
```

## Key Application Entities

### **Product**

The `Product` entity stores data received from the client. Table structure example:

```ruby
  t.string "name", null: false
  t.integer "price", null: false
  t.string "sku", null: false
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
  t.index ["sku"], name: "index_products_on_sku"
```
### **PublishTaskHandler**

The `PublishTaskHandler` entity stores information about the product publication process in marketplaces. Table structure example:

```ruby
  t.string "marketplace"
  t.integer "product_id"
  t.json "steps"
  t.integer "status"
  t.json "logs"
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
  t.index ["marketplace"], name: "index_publish_task_handlers_on_marketplace"
  t.index ["product_id"], name: "index_publish_task_handlers_on_product_id"
```

**Features:**

-   **Step statuses:** stores information about whether each step of the publication process was successful.
-   **Logs:** stores data about requests and responses from marketplaces.

## Publication Architecture

The **Adapter Pattern** is used for product publication. The main class is `MarketplacePublisher`.

### Key Features:

1.  **List of available marketplaces**:
    -   Retrieved from the product.
    -   Synchronization is performed sequentially for each marketplace.
    -   In the future, the list of marketplaces can be tied to a user or subscription type.
2.  **Retry failed steps only**:
    -   The `PublishTaskHandler` entity is used to determine whether each step needs to be executed.
    -   Steps that were successfully completed earlier are skipped.

## Rake Task for Manual Publication

If a product publication was interrupted (e.g., due to a Sidekiq failure), it is possible to manually send the product for publication using the following command:

```bash
rake marketplace:publish sku=TEST123`
```

### Execution Example:

```text
`2024-12-09T09:01:24.286Z pid=91698 tid=226m INFO: Sidekiq 7.3.6 connecting to Redis with options {:size=>10, :pool_name=>"internal", :url=>nil}
Product 'Test Product' (SKU: TEST123) successfully published.`
```

## Additional Information

### Requirements:

-   **Ruby:** version 3.3+
-   **Rails:** version 8.0+
-   **Redis:** required for Sidekiq

### Installation:

1.  Clone the repository.
2.  Run the following commands:

```bash
bundle install
rails db:create db:migrate
```

3.  Start the server:

```bash
`rails server`
```
### Running Tests:

To execute tests, use the following command:

```bash
`bundle exec rspec`
```
