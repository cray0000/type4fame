#guard start -p

notification :off

if File.exists?("./config.rb")
  guard 'compass' do
    watch %r{sass/.+\.s[ac]ss$}
  end
end

guard 'haml', input: 'haml', output: 'views' do
  watch %r{haml/.+\.(html|haml)}
end

guard 'livereload' do
  watch %r{public/css/.+\.css$}
end
