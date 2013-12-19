# Copy and rename this config file as config.pp

$app_name = 'app'
$user_name = 'web'
$ruby_version = "2.0.0-p353"

# Generate your password hash using: openssl passwd -1
$user_password = 'your secret password hash'

$db_name = "${app_name}_production"
$db_user = 'rails'
$db_password = 'secret'
