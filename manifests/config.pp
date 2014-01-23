# Copy and rename this config file as config.pp

$app_name = 'app'
$user_name = 'web'
$ruby_version = "2.1.0"

# Generate your password hash using: openssl passwd -1
$user_password = 'your secret password hash wooz'

$db_name = "${app_name}_production"
$db_user = 'web'
$db_password = 'secret'

$install_postgresql = "false"
$install_passenger = "false"
