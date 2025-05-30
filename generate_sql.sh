#!/bin/bash
OUTPUT_FILE="init_db.sql"
echo "Generate database script"

# Create new file
# Start transaction
echo "BEGIN;" > $OUTPUT_FILE

# Clear all tables (only table, not functions or triggers or SP)
cat drop_table.sql >> $OUTPUT_FILE

## Table structure
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
cat Tables/promotion_mock.sql >> $OUTPUT_FILE
cat Tables/promotion.sql >> $OUTPUT_FILE
cat Tables/password_reset_attempt.sql >> $OUTPUT_FILE
cat Tables/email_confirm_attempt.sql >> $OUTPUT_FILE
cat Tables/order_edit_request.sql >> $OUTPUT_FILE
cat Tables/promotion_log.sql >> $OUTPUT_FILE
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
cat MockData/good_order_mock.sql >> $OUTPUT_FILE
cat MockData/deposit_mock.sql >> $OUTPUT_FILE
cat MockData/wallet_mock.sql >> $OUTPUT_FILE
cat MockData/promotion_mock.sql >> $OUTPUT_FILE
cat MockData/inventory_history_mock.sql >> $OUTPUT_FILE

# Large volume orders mock
cat MockData/auto_generate_order.sql >> $OUTPUT_FILE

# Commit
echo "COMMIT;" >> $OUTPUT_FILE

