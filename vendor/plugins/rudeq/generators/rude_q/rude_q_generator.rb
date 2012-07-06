class RudeQGenerator < Rails::Generator::NamedBase
  def manifest

    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, class_name

      # Model, spec, and fixture directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('spec/fixtures', class_path)
      m.directory File.join('spec/models', class_path)

      # Model class, spec and fixtures.
      m.template 'rude_q_model.rb',      File.join('app/models', class_path, "#{file_name}.rb")
      m.template 'model:fixtures.yml',  File.join('spec/fixtures', class_path, "#{table_name}.yml")
      m.template 'rude_q_model_spec.rb', File.join('spec/models', class_path, "#{file_name}_spec.rb")

      unless options[:skip_migration]
        m.migration_template 'rude_q_migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end

    end
  end

end
