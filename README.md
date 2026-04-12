# テーブル設計

## users テーブル

| Column             | Type   | Options     |
| ------------------ | ------ | ----------- |
| email              | string | null: false, unique: true |
| encrypted_password | string | null: false |
| name               | string | null: false |
| nickname           | string | null: false |
| birth_date         | date   | null: false |

### Association

- has_many :items
- has_many :purchases
- has_many :comments



## items テーブル

| Column                 | Type       | Options     |
| ---------------------- | ---------- | ----------- |
| item_name              | string     | null: false |
| item_info              | text       | null: false |
| category_id            | integer    | null: false |
| item_status_id         | integer    | null: false |
| shipping_fee_status_id | integer    | null: false |
| prefecture_id          | integer    | null: false |
| scheduled_delivery_id  | integer    | null: false |
| item_price             | integer    | null: false |
| user_id                | references | null: false, foreign_key: true |
 
### Association

- has_many :comments
- has_one :purchase
- belongs_to :user
- belongs_to :category
- belongs_to :item_status
- belongs_to :shipping_fee_status
- belongs_to :prefecture
- belongs_to :scheduled_delivery



## comments テーブル

| Column  | Type       | Options                        |
| ------- | ---------- | ------------------------------ |
| text    | text       | null: false                    |
| user    | references | null: false, foreign_key: true |
| item    | references | null: false, foreign_key: true |

### Association

- belongs_to :user
- belongs_to :item




## purchases テーブル

| Column  | Type       | Options     |
| ------- | ---------- | ----------- |
| user    | references | null: false, foreign_key: true |
| item    | references | null: false, unique: true, foreign_key: true |
| token   | string     | null: false |

### Association

- belongs_to :user
- belongs_to :item
- has_one :address




## addresses テーブル

| Column        | Type       | Options     |
| ------------- | ---------- | ----------- |
| postal_code   | string     | null: false |
| prefecture_id | integer    | null: false |
| city          | string     | null: false |
| street        | string     | null: false |
| building      | string     | null: true  |
| phone_number  | string     | null: false |
| purchase      | references | null: false, foreign_key: true |

### Association

- belongs_to :purchase
- belongs_to :prefecture