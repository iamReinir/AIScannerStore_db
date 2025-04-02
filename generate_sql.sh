#!/bin/bash
cd ~/AIScannerStore_db
OUTPUT_FILE="init_db.sql"
echo "Generate database script"

# Table structure
# Create new file
echo "BEGIN;" > $OUTPUT_FILE
cat drop_table.sql >> $OUTPUT_FILE
cat Tables/store.sql >> $OUTPUT_FILE
cat Tables/pos_device.sql >> $OUTPUT_FILE
cat Tables/staff.sql >> $OUTPUT_FILE
cat Tables/category.sql >> $OUTPUT_FILE
cat Tables/product.sql >> $OUTPUT_FILE
cat Tables/drink_mapping.sql >> $OUTPUT_FILE
cat Tables/food_mapping.sql >> $OUTPUT_FILE
cat Tables/customer.sql >> $OUTPUT_FILE
cat Tables/deposit.sql >> $OUTPUT_FILE
cat Tables/card.sql >> $OUTPUT_FILE
cat Tables/order.sql >> $OUTPUT_FILE
cat Tables/product_in_store.sql >> $OUTPUT_FILE
cat Tables/inventory_note.sql >> $OUTPUT_FILE
cat Tables/inventory_note_item.sql >> $OUTPUT_FILE
cat Tables/wallet.sql >> $OUTPUT_FILE
cat Tables/wallet_transaction.sql >> $OUTPUT_FILE
cat Tables/vnp_transaction.sql >> $OUTPUT_FILE
cat Tables/order_item.sql >> $OUTPUT_FILE
cat Tables/promotion.sql >> $OUTPUT_FILE
cat Tables/password_reset_attempt.sql >> $OUTPUT_FILE
# Function
# cat Functions/generate_code.sql
# mock data
cat MockData/product_mock.sql >> $OUTPUT_FILE
cat MockData/store_mock.sql >> $OUTPUT_FILE
cat MockData/staff_mock.sql >> $OUTPUT_FILE
cat MockData/inventory_mock.sql >> $OUTPUT_FILE
cat MockData/customer_mock.sql >> $OUTPUT_FILE
cat MockData/card_mock.sql >> $OUTPUT_FILE
cat MockData/order_mock.sql >> $OUTPUT_FILE
cat MockData/deposit_mock.sql >> $OUTPUT_FILE
cat MockData/wallet_mock.sql >> $OUTPUT_FILE
cat MockData/promotion_mock.sql >> $OUTPUT_FILE
cat MockData/inventory_history_mock.sql >> $OUTPUT_FILE
echo "COMMIT;" >> $OUTPUT_FILE

