#!/bin/bash
cd ~/AIScannerStore_BE
OUTPUT_FILE="init_db.sql"
echo "Generate database script"

# Table structure
echo "BEGIN;" > $OUTPUT_FILE
cat drop_table.sql >> $OUTPUT_FILE
cat Scripts/store.sql >> $OUTPUT_FILE
cat Scripts/staff.sql >> $OUTPUT_FILE
cat Scripts/category.sql >> $OUTPUT_FILE
cat Scripts/product.sql >> $OUTPUT_FILE
cat Scripts/drink_mapping.sql >> $OUTPUT_FILE
cat Scripts/food_mapping.sql >> $OUTPUT_FILE
cat Scripts/customer.sql >> $OUTPUT_FILE
cat Scripts/inventory.sql >> $OUTPUT_FILE
cat Scripts/inventory_log.sql >> $OUTPUT_FILE
cat Scripts/inventory_log_item.sql >> $OUTPUT_FILE
cat Scripts/wallet.sql >> $OUTPUT_FILE
cat Scripts/wallet_transaction.sql >> $OUTPUT_FILE
cat Scripts/vnp_transaction.sql >> $OUTPUT_FILE
cat Scripts/pos_device.sql >> $OUTPUT_FILE
cat Scripts/order.sql >> $OUTPUT_FILE
cat Scripts/order_item.sql >> $OUTPUT_FILE
cat Scripts/payment.sql >> $OUTPUT_FILE
echo "COMMIT;" >> $OUTPUT_FILE

# mock data
cat MockData/product_mock.sql >> $OUTPUT_FILE
cat MockData/store_mock.sql >> $OUTPUT_FILE
cat MockData/staff_mock.sql >> $OUTPUT_FILE
cat MockData/inventory_mock.sql >> $OUTPUT_FILE
cat MockData/customer_mock.sql >> $OUTPUT_FILE
cat MockData/order_mock.sql >> $OUTPUT_FILE
cat MockData/wallet_mock.sql >> $OUTPUT_FILE
