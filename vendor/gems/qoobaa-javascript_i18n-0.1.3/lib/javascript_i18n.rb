module JavascriptI18n
  def self.build
    path = File.join(RAILS_ROOT, "public", "javascripts", "i18n")
    header = File.read(File.join(path, "base.js"))
    I18n.backend.send(:init_translations)
    I18n.backend.send(:translations).each do |key, value|
      File.open(File.join(path, "#{key}.js"), "w") do |file|
        file.puts(header)
        file.puts("\nI18n.translations = I18n.translations || #{value.to_json};")
      end
    end
  end
end
