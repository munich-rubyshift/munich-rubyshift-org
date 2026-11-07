namespace :rubyevents do
  desc "Write the rubyevents.org export to tmp/rubyevents and list what their schemas reject (LENIENT=1 fills placeholders)"
  task export: :environment do
    mode = ActiveModel::Type::Boolean.new.cast(ENV["LENIENT"]) ? :lenient : :strict
    export = Rubyevents::Export.new(mode: mode)
    directory = Rails.root.join("tmp", "rubyevents")

    FileUtils.rm_rf(directory)
    export.write_to(directory)

    puts "Wrote #{export.files.size} files to #{directory.relative_path_from(Rails.root)}"
    export.warnings.each { |warning| puts "Dropped #{warning}" }
    export.errors.each { |error| puts "Invalid #{error}" }

    abort "#{export.errors.size} schema violation(s) in the #{mode} export" if export.errors.any?
  end
end
