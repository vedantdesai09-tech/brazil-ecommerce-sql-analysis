CREATE INDEX idx_orders_purchase_ts
ON orders(order_purchase_timestamp);

CREATE INDEX idx_order_items_order_id
ON order_items(order_id);

CREATE INDEX idx_order_items_seller_id
ON order_items(seller_id);

CREATE INDEX idx_order_items_order_seller
ON order_items(order_id, seller_id);

CREATE INDEX idx_sellers_seller_id
ON sellers(seller_id);
