#!/bin/sh

# This script removes proprietary dependencies from the project.

cd app

REGEX_A="s/\/\/ \[FOSS_REMOVE_START\]/\/*/"
REGEX_B="s/\/\/ \[FOSS_REMOVE_END\]/\*\//"

# Remove lines from pubspec.yaml
sed -i '/# \[FOSS_REMOVE\]/d' pubspec.yaml

# Comment out parts in Dart files
sed -i "$REGEX_A" lib/config/init.dart
sed -i "$REGEX_B" lib/config/init.dart

# tsudev-lotus: mua trong ứng dụng (purchase_provider, donation_page_vm) đã gỡ khỏi bản fork.

cd ..
echo "Proprietary dependencies removed."
