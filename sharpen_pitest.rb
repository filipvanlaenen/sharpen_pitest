#!/usr/bin/env ruby
# frozen_string_literal: true

#
# Sharpen PITEST.
# Runs PITEST against the source code one test class at a time, measuring the mutation coverage between a class and
# its corresponding test class only.
#

package_filter = nil
report_only = false
survivors_only = false
sorting_key = 's'

ARGV.each_with_index do |arg, i|
  if ['-h', '--help'].include?(arg)
    puts 'Sharpen PITEST (sharpen_pitest.rb)'
    puts 'Copyright © 2021 Filip van Laenen <f.a.vanlaenen@ieee.org>'
    puts
    puts 'Usage: '
    puts '  sharpen_pitest.rb [<arguments>]'
    puts
    puts 'where arguments include:'
    puts '  -h or --help                         print this message and exit'
    puts '  -p <package> or --package <package>  consider classes in the provided package only'
    puts '  -r or --report-only                  do not run PITEST but report based on the current PIT reports'
    puts '  -s or --survivors-only               do not output classes without full mutation coverage'
    puts '  -t <key> or --sort <key>             sort classes according to sorting key'
    puts
    puts 'The sorting keys can be the following:'
    puts '  a: alphabetically by name'
    puts '  p: descending by percentage of killed mutants'
    puts '  s: ascending by number of surviving mutants (default)'
    exit
  elsif ['-p', '--package'].include?(arg)
    package_filter = ARGV[i + 1]
  elsif ['-r', '--report-only'].include?(arg)
    report_only = true
  elsif ['-s', '--survivors-only'].include?(arg)
    survivors_only = true
  elsif ['-t', '--sort'].include?(arg)
    sorting_key = ARGV[i + 1][0]
  end
end

`pitest` unless report_only

current_path = Dir.pwd
current_rel_dir = current_path.split('/').last
pit_reports_dir = "#{current_rel_dir}-pit-reports"

last_pit_report_dir = Dir.glob("../#{pit_reports_dir}/*/").map { |f| f.split('/').last }.select do |f|
  /^\d+$/.match?(f)
end.max

package_dirs = Dir.glob("../#{pit_reports_dir}/#{last_pit_report_dir}/*/").map { |f| f.split('/').last }
unless package_filter.nil?
  if package_dirs.include?(package_filter)
    package_dirs = [package_filter]
  else
    puts "WARNING: Package #{package_filter} could not be found in the list of packages; will continue without" \
         " package filter."
  end
end

class_names = []
package_dir_by_class_name = {}
package_dirs.map do |package_dir|
  local_class_names = Dir.glob("../#{pit_reports_dir}/#{last_pit_report_dir}/#{package_dir}/*").map do |f|
    f.split('/').last.chomp('.java.html')
  end
  class_names << local_class_names
  local_class_names.each { |lc| package_dir_by_class_name[lc] = package_dir }
end
if class_names.empty?
  puts 'No classes found in the reports, or no reports generated.'
  exit
end
class_names.flatten!.sort!
class_names.delete('index.html')

ignore_map = Hash.new(0)
if File.exist?('pitest.ignore')
  ignore_content = File.read('pitest.ignore')
  ignore_content.scan(%r{.*:\d+}) do |mtch|
    parts = mtch.split(':')
    ignore_map[parts.first] = parts.last.to_i
  end
end

coverages = []
class_names.each do |class_name|
  test_name = "#{class_name}Test"
  `pitest #{test_name}` unless report_only
  last_pit_report_dir = Dir.glob("../#{pit_reports_dir}/#{test_name}/*/").map { |f| f.split('/').last }.select do |f|
    /^\d+$/.match?(f)
  end.max
  index_file_name = "../#{pit_reports_dir}/#{test_name}/#{last_pit_report_dir}/" \
                    "#{package_dir_by_class_name[class_name]}/index.html"
  if File.exist?(index_file_name)
    index_content = File.read(index_file_name)
    index_content.scan(%r{<tr>.*?</tr>}m) do |mtch|
	  if mtch =~ />#{class_name}\.java/m
	    java_content = File.read("src/main/java/#{package_dir_by_class_name[class_name].split('.').join('/')}/#{class_name}.java")
	    equivalent_mutants = java_content.scan(%r{//\s+EQMU:}).count
	    coverage_td = mtch.scan(%r{<td>.*?</td>}m)[2]
	    coverage = coverage_td.scan(%r{<div class="coverage_legend">(\d+/\d+)</div>}).first.first.split('/')
	    killed = coverage.first.to_i + equivalent_mutants + ignore_map[class_name]
	    number = coverage.last.to_i
	    survived = number - killed
	    percentage = killed.to_f / number
        coverages << [class_name, killed, number, survived, percentage]
      end
    end
  else
    puts "WARNING: Report for test class #{test_name} could not be found. Consider running the following command to" \
         " remediate the problem:"
    puts "        pitest #{test_name}"
    exit
  end
end

case sorting_key
when 'a'
  coverages.sort! { |a, b| a[0] <=> b[0] }
when 'p'
  coverages.sort! { |a, b| a[4] == b[4] ? (a[3] == b[3] ? a[0] <=> b[0] : a[3] <=> b[3]) : b[4] <=> a[4] }
else
  coverages.sort! { |a, b| a[3] == b[3] ? a[0] <=> b[0] : a[3] <=> b[3] }
end

total_killed = coverages.map { |a| a[1] }.sum
total_number = coverages.map { |a| a[2] }.sum
total_survived = coverages.map { |a| a[3] }.sum

coverages.reject! { |c| c[3].zero? } if survivors_only

class_name_width = [0, coverages.map { |a| a[0] }.map(&:length)].flatten.max
number_width = total_number.to_s.length

coverages.each do |c|
  puts "#{c[0].ljust(class_name_width)}: #{c[1].to_s.rjust(number_width)} / #{c[2].to_s.rjust(number_width)} " \
       "(#{c[3]}, #{format('%<p>.1f', p: c[4] * 100)}%)"
end

total_percentage = total_killed.to_f / total_number

puts "#{'Σ'.rjust(class_name_width)}: #{total_killed.to_s.rjust(number_width)} / " \
     "#{total_number.to_s.rjust(number_width)} (#{total_survived}, #{format('%<p>.1f', p: total_percentage * 100)}%)"
