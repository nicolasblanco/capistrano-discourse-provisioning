set :stage, :production

role :app, ["root@#{ENV['HOST']}"]
