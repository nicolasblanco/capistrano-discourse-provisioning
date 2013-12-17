# Copy and rename this config file as config.pp

$app_name = 'myapp'

# Generate your password hash using: openssl passwd -1
$user_password = 'your secret password hash'

$db_name = "${app_name}_production"
$db_user = 'rails'
$db_password = 'secret'
