# Copy and rename this config file as config.pp

$app_name = 'app'
$user_name = 'web'
$ruby_version = "2.1.0"

# Generate your password hash using: openssl passwd -1
$user_password = 'your secret password hash wooz'

$db_name = '<%= ENV["DB_NAME"] %>'
$db_user = '<%= ENV["DB_USERNAME"] %>'
$db_password = '<%= ENV["DB_PASSWORD"] %>'
$db_host = '<%= ENV["DB_HOST"] %>'

$host_name = '<%= ENV["HOST_NAME"] %>'
