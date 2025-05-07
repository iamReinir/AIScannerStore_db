#!/bin/bash
cd ~/AIScannerStore_db
OUTPUT_FILE="schema.sql"
echo "Generate schema script"

cat Tables/store.sql > $OUTPUT_FILE
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
cat Tables/email_confirm_attempt.sql >> $OUTPUT_FILE

