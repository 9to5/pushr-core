class PushGenerator < Rails::Generators::Base
  desc "This generator creates an feedback_processor file at lib/pushr"
  def create_lib_file
    copy_file "feedback_processor.rb",  "lib/pushr/feedback_processor.rb"
  end

  def create_initializer_file
    create_file "config/initializers/pushr.rb", "# Push redis initializer\nrequire 'redis'\n$pushredis = Redis.new"
  end
end