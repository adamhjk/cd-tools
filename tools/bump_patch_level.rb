#!/usr/bin/ruby    

def bump_patch_level(metadatarb)
  File.open(metadatarb, 'r+') do |f|
    lines = f.readlines
    lines.each do |line|
      if line =~ /^version\s+["'](\d+)\.(\d+)\.(\d+)["'].*$/
        major = $1
        minor = $2
        patch = $3
        new_patch = patch.to_i + 1
        puts "Incrementing #{metadatarb} version from #{major}.#{minor}.#{patch} to #{major}.#{minor}.#{new_patch}"
        line.replace("version          \"#{major}.#{minor}.#{new_patch}\"\n")
      end
    end
    f.pos = 0
    lines.each do |line|
      f.print line
    end
    f.truncate(f.pos)
  end
end

updated = false

STDIN.each_line do |diff_line|
  if diff_line =~ /^(.)\s+cookbooks\/(.+)/
    next if $1 == "D"
    cookbook = $2.split('/').first
  else
    next
  end
  metadata_file = File.expand_path(File.join("cookbooks", cookbook, "metadata.rb"))
  bump_patch_level(metadata_file)
  if !system("git add #{metadata_file}") 
    raise "Failed to git add #{metdata_file}: #{$?}"
  end
  updated = true
end

if updated
  if !system("git commit -m 'Updated patch level for #{ARGV.join(', ')}'")
    raise "Failed to git commit"
  end

  if !system("git push") 
    raise "Failed to git push"
  end
end
